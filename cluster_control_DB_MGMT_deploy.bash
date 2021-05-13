wget -O install-cc https://severalnines.com/scripts/install-cc?OLRqyYORG8Dmye0EzW4XrUSbNQeHYNknKqG-lZ0cVg8
chmod +x install-cc
#S9S_CMON_PASSWORD=passdb S9S_ROOT_PASSWORD=passroot ./install-cc   # as root or sudo user
./install-cc   # as root or sudo user

 #http://IP00/clustercontrol
 
 
 ## ssh paswordless access to slave nodes. Run this on CC master node
 
ssh-keygen -t rsa # press enter on all prompts
ssh-copy-id -i ~/.ssh/id_rsa $IP00
ssh-copy-id -i ~/.ssh/id_rsa $IP01 # repeat this to all target database nodes
ssh-copy-id -i ~/.ssh/id_rsa $IP02 # repeat this to all target database node

# add this to a custom CNF file
innodb_rollback_on_timeout=1
innodb_lock_wait_timeout=600
log-bin=mysql-bin

# deploy cluster 
s9s cluster --create --cluster-type=galera --nodes="$IP01;$IP02"  --vendor=mariadb --provider-version=10.5 --db-admin-passwd="password" --os-user=root --cluster-name="BGHQ-RD-CSTACK" --wait



