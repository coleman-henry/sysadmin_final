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

# EC2
resource "aws_instance" "minecraft_server" {
  ami           = "ami-091138d0f0d41ff90"
  instance_type = "t2.medium"

  # Associate the instance to the SG
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  # For cost tracking, since this is totally real.
  tags = {
    Name = "Minecraft-Node"
  }
}

# Security Group
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
    cidr_blocks = ["192.168.56.1/32"]
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

# Outputs----------------------------------------------------------------------
# The AWS API is going to hand back the public ip for this instance
output "server_public_ip" {
  value       = aws_instance.minecraft_server.public_ip
  description = "The public IP address of the provisioned server."
}
# -----------------------------------------------------------------------------
