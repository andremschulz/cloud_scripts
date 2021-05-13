##configure maria db 10.4 repo##
echo '[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1' > /etc/yum.repos.d/mariadb.repo

## install MariaDB
yum install MariaDB-server MariaDB-client galera-4 -y

yum install rsync policycoreutils-python -y

systemctl start mariadb
systemctl enable mariadb

mysql_secure_installation

#mysql -uroot
#set password = password("pass");

## create basic cluster config 
FIRST_NODE_IP="$1"
SECOND_NODE_IP="$2"
THIRD_NODE_IP="$3"
THIS_NODE_IP="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 10)"
THIS_NODE_NAME=`hostname`
echo "[mysqld]
binlog_format=ROW
default-storage-engine=innodb
innodb_autoinc_lock_mode=2
bind-address=0.0.0.0
log_error=/var/log/mariadb.log

# Galera Provider Configuration
wsrep_on=ON
wsrep_provider=/usr/lib64/galera-4/libgalera_smm.so

# Galera Cluster Configuration
wsrep_cluster_name=\"CSDB-CLUSTER\"
wsrep_cluster_address=\"gcomm://$FIRST_NODE_IP,$SECOND_NODE_IP,$THIRD_NODE_IP\"

# Galera Synchronization Configuration
wsrep_sst_method=rsync

# Galera Node Configuration
wsrep_node_address=\"$THIS_NODE_IP\"
wsrep_node_name=\"$THIS_NODE_NAME\"" > /etc/my.cnf.d/galera.cnf
touch /var/log/mariadb.log
chown mysql:mysql /var/log/mariadb.log
cat /etc/my.cnf.d/galera.cnf


## Configure firewall
firewall-cmd --list-all
sudo firewall-cmd --permanent --zone=public --add-service=mysql 
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --permanent --zone=public --add-port=4567/tcp
sudo firewall-cmd --permanent --zone=public --add-port=4568/tcp
sudo firewall-cmd --permanent --zone=public --add-port=4444/tcp
sudo firewall-cmd --permanent --zone=public --add-port=4567/udp

sudo firewall-cmd --permanent --zone=public --add-source=$FIRST_NODE_IP/32
sudo firewall-cmd --permanent --zone=public --add-source=$SECOND_NODE_IP/32
sudo firewall-cmd --permanent --zone=public --add-source=$THIRD_NODE_IP/32

sudo firewall-cmd --reload
firewall-cmd --list-all

## selinux configuration

sudo semanage port -a -t mysqld_port_t -p tcp 4567
sudo semanage port -a -t mysqld_port_t -p udp 4567
sudo semanage port -a -t mysqld_port_t -p tcp 4568
sudo semanage port -a -t mysqld_port_t -p tcp 4444

semanage permissive -a mysqld_t
systemctl stop mariadb

### create cluster (master node 1)#####

galera_new_cluster
lsof -i:3306
lsof -i:4567

mysql -u root -p -e 'CREATE DATABASE selinux;
CREATE TABLE selinux.selinux_policy (id INT NOT NULL AUTO_INCREMENT, PRIMARY KEY(id));
INSERT INTO selinux.selinux_policy VALUES ();'

### join to cluster (slave nodes 2 and 3)#####
systemctl start mariadb
mysql -u root -p -e 'INSERT INTO selinux.selinux_policy VALUES ();'



#### on all 3 nodes ##
grep mysql /var/log/audit/audit.log | sudo audit2allow -M Galera
semodule -i Galera.pp
semanage permissive -d mysqld_t

### starting the cluster (all 3 nodes) #### 
systemctl stop mariadb
systemctl status mariadb

#on the master node 1
galera_new_cluster
mysql -u root -p -e "SHOW STATUS LIKE 'wsrep_cluster_size'"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';"
mysql -u root -p -e "FLUSH PRIVILEGES;"
# mysql -u root -p'password' -h xx.xx.xx.xx -P 33306   -D local ## to troubleshoot access

#on the other nodes
sudo systemctl start mariadb
sudo systemctl status mariadb

## After NFS is configured exceute on the master node
mkdir -p /mnt/secondary
sudo mount -t nfs BGHQ-RD-NFS01:/export/secondary /mnt/secondary
/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt -m /mnt/secondary -u http://download.cloudstack.org/systemvm/4.15/systemvmtemplate-4.15.1-xen.vhd.bz2 -h xenserver -F
umount /mnt/secondary
rmdir /mnt/secondary
####galera commands
#  mysql  -e "SHOW STATUS LIKE 'wsrep_cluster_size'"                  ## Get cluster members (find how many arein the cluster)
#  mysql  -e "SHOW STATUS LIKE 'wsrep_local_state_comment'"           ## find if node is synced



