#/bin/bash
#Created by: Yordan.kostov
#Created on: 17.04.2018

### Initialize certiface source

certfile="/etc/scripts/config_ca_root/CA-root.crt"
certname="CORP ROOT CA"
certfile2="/etc/scripts/config_ca_root/SUB-CA-1.crt"
certname2="CORP SUB ROOT CA"

#Check for databases
C8=$(find /home/CORP  -name "cert8.db" 2> /dev/null)
C9=$(find /home/CORP  -name "cert9.db" 2> /dev/null)

#selecting logfile name and dir
logf=/tmp/vdi_$(whoami)

#####Initialize Firefox databases and install corp.int certificate
if [ "$C8" == '' ] && [ "$C9" == '' ]; then
        date > $logf
        nohup firefox --headless 2>/dev/null  & 2>/dev/null
        F_PID=$!
        sleep 3
        kill -15 $F_PID 2> /dev/null

        #importing certificate for legacy DB
        for certDB in $(find /home/CORP -name "cert8.db" 2> /dev/null)
        do
                echo $certDB >> $logf
                certdir=$(dirname ${certDB});
                certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d dbm:${certdir}
                certutil -A -n "${certname2}" -t "TCu,Cu,Tu" -i ${certfile2} -d dbm:${certdir}
        done

        #importing certificate for SQL DB
        for certDB in $(find /home/CORP -name "cert9.db" 2> /dev/null)
        do
                echo $certDB >> $logf
                certdir=$(dirname ${certDB});
                certutil -A -n "${certname}" -t "TCu,Cu,Tu" -i ${certfile} -d sql:${certdir} 2> /dev/null
                certutil -A -n "${certname2}" -t "TCu,Cu,Tu" -i ${certfile2} -d sql:${certdir} 2> /dev/null
        done
#else
#       echo DB already exists. No action taken.
fi
