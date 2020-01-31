# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
#!/bin/bash

#Install Apache
yum install -y httpd

# echo "Listen 80" >> /etc/httpd/conf/httpd.conf
service httpd start

# make httpd service start at boot
chkconfig --add httpd
chkconfig httpd on

sudo systemctl disable firewalld
sudo systemctl stop firewalld

sudo firewall-cmd --permanent --zone=public --add-port=80/tcp

sudo firewall-cmd --reload

echo '<html>
    <head>
        <title>Hello World from Apache running</title>
    </head>
    <body>
Hello World from Apache running on! <br><br>
Instance Name: ' > /var/www/html/index.html

sudo curl http://169.254.169.254/opc/v1/instance/displayName >>/var/www/html/index.html

echo '
    </body>
</html>
' >> /var/www/html/index.html

# END install apache
