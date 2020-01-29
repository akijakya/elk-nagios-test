#! /bin/bash

# installing Docker
sudo apt-get install -yy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   bionic \
   stable"
sudo apt update
sudo apt install -yy docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER

# installing docker-compose
sudo apt install -yy docker-compose

# cloning docker-elk repo and starting the docker container
cd /home/ubuntu
sudo apt install git
git clone https://github.com/deviantony/docker-elk.git
cd docker-elk
# In order to limit the memory consumption of the stack, the docker.compose.yml has to be edited.
printf "\nlimits:\n  memory: 1500m" >> docker.compose.yml
sudo systemctl start docker
sudo docker-compose up -d

# The stack is pre-configured with the following privileged bootstrap user:
# user: elastic
# password: changeme