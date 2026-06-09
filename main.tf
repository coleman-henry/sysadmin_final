# Variables--------------------------------------------------------------------

# -----------------------------------------------------------------------------

# Base configuration-----------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
}
# -----------------------------------------------------------------------------

# Resources--------------------------------------------------------------------

# EC2 configuration
resource "aws_instance" "minecraft_server" {
  ami           = "ami-091138d0f0d41ff90"
  instance_type = "t2.medium"
  # Associate the instance to the SG
  vpc_security_group_ids    = [aws_security_group.minecraft_sg.id]
  # Associate SSH key
  key_name    = aws_key_pair.mc_auth.key_name
  # ssh connection
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/minecraft_key")
    host        = self.public_ip
  }
  # Build Context -------------------------------------------------------------
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/minecraft-build"
    ]
  }
  provisioner "file" {
    source        = "init.sh"
    destination   = "/tmp/minecraft-build/init.sh"
  }
  provisioner "file" {
    source        = "Dockerfile"
    destination   = "/tmp/minecraft-build/Dockerfile"
  }
  provisioner "file" {
    source        = "entrypoint.sh"
    destination   = "/tmp/minecraft-build/entrypoint.sh"
  }
  # ---------------------------------------------------------------------------
  # Run the initialization script
  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/minecraft-build/init.sh",
      "/tmp/init.sh"
     ]
  }
  # For cost tracking, since this is totally real.
  tags = {
    Name = "Minecraft-Node"
  }
}

# Security Group---------------------------------------------------------------
resource "aws_security_group" "minecraft_sg" {
  name          = "mc_allow"
  description   = "In: Minecraft (all), ssh(me); Out: All"
  
  # Allow all minecraft traffic
  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ssh from my ip
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# -----------------------------------------------------------------------------
# SSH Keys
resource "aws_key_pair" "mc_auth" {
  key_name    = "minecraft-ssh-key"
  public_key  = file("~/.ssh/minecraft_key.pub")
}
# -----------------------------------------------------------------------------

# Outputs----------------------------------------------------------------------
# The AWS API is going to hand back the public ip for this instance
output "server_public_ip" {
  value       = aws_instance.minecraft_server.public_ip
  description = "The public IP address of the provisioned server."
}
# -----------------------------------------------------------------------------
