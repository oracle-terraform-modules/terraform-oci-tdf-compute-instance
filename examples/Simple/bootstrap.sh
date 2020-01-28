#!/bin/bash

cp /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)

EOF
 
yum install -y python-oci-cli
systemctl enable ocid.service
systemctl start ocid.service
systemctl status ocid.service
