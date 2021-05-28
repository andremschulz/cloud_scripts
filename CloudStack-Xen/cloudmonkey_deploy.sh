#!/bin/bash
profile='xxxx'
user='admin'
cloudstack='http://x.x.x.x:8080/client/api'
apikey='xxxx'
secretkey='xxxx'

## install cloudmonkey
yum install jq -y   # preprequisite: lightweight command-line JSON processor
yum install python-pip -y
pip install --upgrade "pip < 21.0"
python2 -m pip install cloudmonkey

## Configure cloudmonkey profle

cloudmonkey set profile $profile
cloudmonkey set username $user
cloudmonkey set apikey $apikey
cloudmonkey set url $cloudstack
cloudmonkey set secretkey $secretkey
cloudmonkey sync

## Configure cloudmonkey settings
cloudmonkey set display table