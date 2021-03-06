#!/bin/bash

# Creating user "dev"
cd /etc/ssh
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' sshd_config
sudo service ssh restart
sudo useradd -m -p $(openssl passwd -1 password) dev

# Installing Nagios (https://support.nagios.com/kb/article/nagios-core-installing-nagios-core-from-source-96.html#Ubuntu)

# Prerequisites
# Perform these steps to install the pre-requisite packages.
sudo apt-get update
sudo apt-get install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php7.2 libgd-dev

# Downloading the Source
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/archive/nagios-4.4.5.tar.gz
tar xzf nagioscore.tar.gz
 
# Compile
cd /tmp/nagioscore-nagios-4.4.5/
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled
sudo make all

# Create User And Group
# This creates the nagios user and group. The www-data user is also added to the nagios group.
sudo make install-groups-users
sudo usermod -a -G nagios www-data

# Install Binaries
# This step installs the binary files, CGIs, and HTML files.
sudo make install
 
# Install Service / Daemon
# This installs the service or daemon files and also configures them to start on boot.
# Information on starting and stopping services will be explained further on.
sudo make install-daemoninit

# Install Command Mode
# This installs and configures the external command file.
sudo make install-commandmode
 
# Install Configuration Files
# This installs the *SAMPLE* configuration files. These are required as Nagios needs some configuration files to allow it to start.
sudo make install-config

# Install Apache Config Files
# This installs the Apache web server configuration files and configures Apache settings.
sudo make install-webconf
sudo a2enmod rewrite
sudo a2enmod cgi

# Configure Firewall
# You need to allow port 80 inbound traffic on the local firewall so you can reach the Nagios Core web interface.
sudo ufw allow Apache
sudo ufw reload
 
# Create nagiosadmin User Account
# You'll need to create an Apache user account to be able to log into Nagios.
# The following command will create a user account called nagiosadmin and you will be prompted to provide a password for the account.
sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin strongpassword

# Start Apache Web Server
# Need to restart it because it is already running.
sudo systemctl restart apache2.service

# Start Service / Daemon
# This command starts Nagios Core.
sudo systemctl start nagios.service


# Test Nagios
# Nagios is now running, to confirm this you need to log into the Nagios Web Interface.
# Point your web browser to the ip address or FQDN of your Nagios Core server, for example:
# http://10.25.5.143/nagios
# http://core-013.domain.local/nagios
# You will be prompted for a username and password. The username is nagiosadmin (you created it in a previous step) and the password is what you provided earlier.
# Once you have logged in you are presented with the Nagios interface. Congratulations you have installed Nagios Core.

# BUT WAIT ...
# Currently you have only installed the Nagios Core engine. You'll notice some errors under the hosts and services along the lines of:
# (No output on stdout) stderr: execvp(/usr/local/nagios/libexec/check_load, ...) failed. errno is 2: No such file or directory 
# These errors will be resolved once you install the Nagios Plugins, which is covered in the next step.


# Installing The Nagios Plugins
# Nagios Core needs plugins to operate properly. The following steps will walk you through installing Nagios Plugins.
# These steps install nagios-plugins 2.3.1. Newer versions will become available in the future and you can use those in the following installation steps. Please see the releases page on GitHub for all available versions.
# Please note that the following steps install most of the plugins that come in the Nagios Plugins package. However there are some plugins that require other libraries which are not included in those instructions. Please refer to the following KB article for detailed installation instructions:
# Documentation - Installing Nagios Plugins From Source
 

# Prerequisites
# Make sure that you have the following packages installed.
sudo apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
 
# Downloading The Source
cd /tmp
wget --no-check-certificate -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/archive/release-2.3.1.tar.gz
tar zxf nagios-plugins.tar.gz
 
# Compile + Install
cd /tmp/nagios-plugins-release-2.3.1/
sudo ./tools/setup
sudo ./configure
sudo make
sudo make install
 

# Test Plugins
# Point your web browser to the ip address or FQDN of your Nagios Core server, for example:
# http://10.25.5.143/nagios
# http://core-013.domain.local/nagios
# Go to a host or service object and "Re-schedule the next check" under the Commands menu. The error you previously saw should now disappear and the correct output will be shown on the screen.


# Service / Daemon Commands
# sudo systemctl start nagios.service
# sudo systemctl stop nagios.service
sudo systemctl restart nagios.service
# sudo systemctl status nagios.service


# Monitoring Host Setup
# On the monitoring host (the machine that runs Nagios), you'll need to do just a few things:
# • Install the check_nrpe plugin
# • Create a Nagios command definition for using the check_nrpe plugin
# • Create Nagios host and service definitions for monitoring the remote host
# These instructions assume that you have already installed Nagios on this machine according to the
# quickstart installation guide. The configuration examples that are given reference templates that are
# defined in the sample localhost.cfg and commands.cfg files that get installed if you follow the quickstart.

# i. Install the check_nrpe Plugin
# Download the source code tarball of the NRPE addon (visit https://www.nagios.org/downloads/nagios-core-
# addons/ for links to the latest versions). At the time of writing, the latest version of NRPE was 4.0.0.
mkdir /home/ubuntu/downloads
cd /home/ubuntu/downloads
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.0/nrpe-4.0.0.tar.gz
# Extract the NRPE source code tarball:
tar xzf nrpe-4.0.0.tar.gz
cd nrpe-4.0.0
# Compile the NRPE addon:
sudo ./configure
sudo make check_nrpe
# Install the NRPE plugin.
sudo make install-plugin