#!/bin/bash

# Check if we need to install docker
if ! command -v docker &> /dev/null; then
  sudo apt update -y
  sudo apt install docker -y
  sudo systemctl enable docker
  sudo systemctl start docker
fi

# Check whether the container is already built
if sudo docker ps -a --format '{{.Names}}' | grep -Eq "^mc_server\$"; then
  exit 0
fi

# This is where the tf needs to send this Dockerfile as well as init.sh
sudo docker build -t minecraft-node /tmp/minecraft-build

# --restart will send a termination signal; entrypoint.sh will catch the interrupt signal and 
#   relay a termination signal to Java. Java can then run its shutdown hooks, which includes 
#   one for neatly saving and quitting out of minecraft

sudo docker run -d --name mc_server -p 25565:25565 --restart unless-stopped minecraft-node