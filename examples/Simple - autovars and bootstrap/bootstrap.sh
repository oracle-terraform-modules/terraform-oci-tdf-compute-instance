# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#!/bin/bash
 
cp /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)

EOF
 
yum install -y python-oci-cli
systemctl enable ocid.service
systemctl start ocid.service
systemctl status ocid.service
