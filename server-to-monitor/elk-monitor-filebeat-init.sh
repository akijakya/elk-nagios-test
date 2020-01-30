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

# pulling and starting a docker container
sudo systemctl start docker
sudo docker pull akijakya/docker-single-test:latest
sudo docker run -d -p 80:3000 akijakya/docker-single-test:latest

# installing Filebeat
# If you use Apt or Yum, you can install Filebeat from our repositories to update to the newest version more easily:
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update && sudo apt-get install filebeat
sudo systemctl enable filebeat
# If your system does not use systemd then run:
# sudo update-rc.d filebeat defaults 95 10

# Configuring Filebeat
cd /etc/filebeat
