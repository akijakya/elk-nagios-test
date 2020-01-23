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

# pulling and starting the docker container
sudo systemctl start docker
sudo docker pull akijakya/docker-single-test:latest
sudo docker run -d -p 80:3000 akijakya/docker-single-test:latest