# preparing SSL keys

#  PREREQUISITES
#  httpd   - install and enable Apache
#  mod_ssl - an Apache module that provides support for SSL encryption
yum install httpd mod_ssl
systemctl enable httpd.service

# Create a new directory to store our private key
mkdir /etc/ssl/private 
# Since files kept within this directory must be kept strictly private, we will modify the permissions to make sure only the root user has access:
chmod 700 /etc/ssl/private
# Create the SSL key and certificate files with openssl. Both of the created files will be placed in the appropriate subdirectories of /etc/ssl.
openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt