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

# creating the volume for Nagios config files to be added to the container
sudo mkdir /usr/local/nagios/
sudo mkdir /usr/local/nagios/etc/

# creating a volume for the Nagios commands
# sudo mkdir /usr/local/nagios/libexec/

# pulling and starting the docker container
sudo systemctl start docker
sudo docker pull jasonrivers/nagios:latest
sudo docker run -d --name nagios4  \
  -v /usr/local/nagios/etc/:/opt/nagios/etc/ \
#  -v /usr/local/nagios/libexec/:/opt/nagios/libexec/ \
  -p 80:80 jasonrivers/nagios:latest