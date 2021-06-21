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
#openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout /etc/ssl/private/SERVER.key -out /etc/ssl/certs/SELFSIGNED_SERVER.crt
openssl req -new -newkey rsa:2048 -nodes -keyout /etc/ssl/private/SERVER.key -out SERVER_CSR.csr

## after you get the SERVER.crt certificate, intermediate and root CA combine them into one  file following this specific order -> server, itermediate and root certificate
cat SERVER.crt CASUB.crt CAROOT.crt > cert_chain.crt
# then convert this into PKCS12 using the key
openssl pkcs12 -export -inkey SERVER.key -in cert-chain.crt -out SERVER.pkcs12
# convert it into a java keystore
keytool -importkeystore -srckeystore SERVER.pkcs12 -srcstoretype PKCS12 -destkeystore /etc/cloudstack/management/keystore.pkcs12 -deststoretype pkcs12

## edit ACS  /etc/cloudstack/management/server.properties like this:
https.enable=true
https.keystore=/etc/cloudstack/management/keystore.pkcs12
https.keystore.password=<enter the same password as used for certificate conversion>

## In addition automatic redirect from HTTP/port 8080 to HTTPS/port 8443 can also be configured in /usr/share/cloudstack-management/webapp/WEB-INF/web.xml
## Add the following section before the section around line 22:
<security-constraint>
  <web-resource-collection>
    <web-resource-name>Everything</web-resource-name>;
    <url-pattern>*</url-pattern>
  </web-resource-collection>
  <user-data-constraint>
    <transport-guarantee>CONFIDENTIAL></transport-guarantee>
  </user-data-constraint>
</security-constraint>
 
 ## restart the management server
 systemctl restart cloudstack-management



