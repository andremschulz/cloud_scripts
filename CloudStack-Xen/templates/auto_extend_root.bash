#!/bin/bash
pvresize /dev/xvda2
vgextend centos /dev/xvda2
lvresize -l +100%FREE /dev/centos/root