# elk-nagios-test
Files for testing ELK and Nagios

To access the server as root, run:

> $ ssh -i "nagios-test" ubuntu@*IPv4*.eu-central-1.compute.amazonaws.com

This command list the users on the machine, for checking if the user "dev" has been created

> $ cut -d: -f1 /etc/passwd

To access the server as the user "dev", run:

> $ ssh dev@*IPv4*

To check the use of the drive, run:

> $ df -t ext4