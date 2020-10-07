SR_ID=1bea20d5-853d-23b8-cca4-44f51a5d0341
size=$((10*1024*1024*1024))
uuid=`xe vdi-create sr-uuid=$SR_ID name-label="CYHQ-kube-lb" type=user virtual-size=$size`
xe vdi-import format=vhd uuid=$uuid filename=/run/sr-mount/78a608e1-1bd8-5831-14af-c0e8eb04bf8c/xenserver/a96aa64d-bb88-413c-a810-8977628d14f3-kube_vhd.vhd


SR_ID=1bea20d5-853d-23b8-cca4-44f51a5d0341
size=$((20*1024*1024*1024))
uuid=`xe vdi-create sr-uuid=$SR_ID name-label="CYHQ-docker_0" type=user virtual-size=$size`
xe vdi-import format=vhd uuid=$uuid filename=/run/sr-mount/78a608e1-1bd8-5831-14af-c0e8eb04bf8c/xenserver/0f513491-09f5-4dfc-a1d2-5770f7b3c4fa_docker_0.vhd

SR_ID=1bea20d5-853d-23b8-cca4-44f51a5d0341
size=$((100*1024*1024*1024))
uuid=`xe vdi-create sr-uuid=$SR_ID name-label="CYHQ-docker_1" type=user virtual-size=$size`
xe vdi-import format=vhd uuid=$uuid filename=/run/sr-mount/78a608e1-1bd8-5831-14af-c0e8eb04bf8c/xenserver/b2daec54-baec-4e9d-96c8-1709fb83b92e_docker_1.vhd