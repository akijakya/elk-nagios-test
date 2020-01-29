#!/bin/bash
cd /etc/ssh
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' sshd_config
sudo service ssh restart
sudo useradd -m -p $(openssl passwd -1 password) dev

sudo apt-get update -y

# Install the Nagios Plugins
# Create a directory for storing the downloads, if you don't already have one.
mkdir /home/ubuntu/downloads
cd /home/ubuntu/downloads
# Make sure that you have the following packages installed.
sudo apt-get install -y autoconf gcc libc6 libmcrypt-dev make libssl-dev wget bc gawk dc build-essential snmp libnet-snmp-perl gettext
# Download the source code tarball of the Nagios plugins (visit http://www.nagios.org/downloads/ for links to
# the latest versions). At the time of writing, the latest stable version of the Nagios plugins was 2.3.1.
wget http://nagios-plugins.org/download/nagios-plugins-2.3.1.tar.gz
# Extract the Nagios plugins source code tarball.
tar xzf nagios-plugins-2.3.1.tar.gz
cd nagios-plugins-2.3.1
# Note: on some systems, you will have to run the extract this way:
# gunzip -c nagios-plugins-2.2.1.tar.gz | tar xf -
# Compile and install the plugins.
./configure
make
make install
# Depending on the version of the plugins, the permissions on the plugin directory and the plugins may need
# to be fixed at this point. If so run the following commands:
useradd nagios
groupadd nagios
usermod -a -G nagios nagios
chown nagios.nagios /usr/local/nagios
chown -R nagios.nagios /usr/local/nagios/libexec

# Install xinetd
# If you will be running NRPE per-connections, some distributions, such as Fedora Core 6, don't ship with
# xinetd installed by default, so install it with the following command:
sudo apt-get install -y xinetd

#  Install the NRPE daemon
# Download the source code tarball of the NRPE addon (visit https://www.nagios.org/downloads/nagios-coreaddons/ for links to the latest versions). At the time of writing, the latest version of NRPE was 3.2.1.
cd /home/ubuntu/downloads
wget https://github.com/NagiosEnterprises/nrpe/releases/download/nrpe-4.0.0/nrpe-4.0.0.tar.gz
# Extract the NRPE source code tarball:
tar xzf nrpe-4.0.0.tar.gz
cd nrpe-4.0.0
# Compile the NRPE addon:
./configure
make all
# If you didn't create the groups and users in (i) above, do it now:
make install-groups-users
# Install the NRPE plugin (for testing), daemon, and sample daemon configuration file.
make install
make install-config
# If you want NRPE to run per-connection under inetd, xinetd, launchd, systemd, smf, etc. run the following command:
make install-inetd
# Make sure nrpe 5666/tcp is in your /etc/services file, if applicable.
# If you want to run NRPE all the time under init, launchd, systemd, smf, etc. run the followning command:
make install-init
# You may need to reload or restart the controlling daemon using one of the following (or similar) commands:
service xinetd restart
systemctl reload xinetd # systemd
systemctl enable nrpe && systemctl start nrpe # systemd
svcadm enable nrpe # smf
initctl reload-configuration # upstart

# If everything worked, add the hostname or IP address of the nagios server to the /etc/xinetd.d/nrpe
# file, or /etc/hosts-allow and hosts-deny.

# vi. Open firewall rules
# If the server has a firewall running, you need to allow access to the NRPE port (5666) from the Nagios server.
# In Ubuntu, the firewall is disabled by default (check: $ sudo ufw status)