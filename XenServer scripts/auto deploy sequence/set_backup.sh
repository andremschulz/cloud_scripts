echo "Installing backup..."
mkdir /opt/script
cp $DIR/scripts/vm_backup.sh /opt/scripts/

echo "Configuring mailing module..."
cat $DIR/scripts/ssmtp.conf > /etc/ssmtp/ssmtp.conf
ssmtp yordan.kostov@circles.bz < $DIR/scripts/test_msg.txt

echo "Configuring logging module..."
cat $DIR/scripts/xenserver.conf > /etc/rsyslog.d/xenserver.conf
systemctl restart rsyslog.service

echo "Setting up daily backup at 4 AM"
sed -i.bak '/vm_backup/d' /etc/crontab

echo "Setting up daily backup at 4 AM"
echo "00 4 * * * root /opt/scripts/vm_backup.sh -t daily_backup -k 7 -x `xe sr-list name-label=backup\ daily params=uuid |cut -d ":" -f 2 |sed 's/ //g'`  -m  backup.team@tracksystem.info" >> /etc/crontab

echo "Setting up weekly backup on Saturday at 4 PM"
echo "0 16 * * 6 root /opt/scripts/vm_backup.sh -t backup -k 2 -x `xe sr-list name-label=backup\ weekly params=uuid |cut -d ":" -f 2 |sed 's/ //g'` -m  backup.team@tracksystem.info" >> /etc/crontab
