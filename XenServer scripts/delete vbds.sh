#!/bin/bash
x=1;
while [ $x -lt 100 ]; do
   a=`sed "$1q;d" /tmp/vbds.txt`
   echo $a;
  xe vbd-destroy uuid=$a;
   sed  '1d' /tmp/vbds.txt > /tmp/vbds.tmp
   mv /tmp/vbds.tmp /tmp/vbds.txt
   x=$[x+1];
done