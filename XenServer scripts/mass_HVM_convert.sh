#!/bin/bash

UUIDS=("eda10741-16ee-5f40-d217-1359ce486e98"
"5a7f6eae-48d2-062c-47e1-14f0a333b6b0"
"0f225371-5491-679b-8bb4-333568dcb6e0"
"32e94e7c-fe1e-4761-9c24-f83e786e6608"
"4d2c4489-3f5c-8d2e-78c7-c89e3cd58907"
"90ffd52b-db22-bf00-9570-ce72e9623075"
"cd75db5e-d4e3-d527-15b1-1a435cfebb30"
"32e94e7c-fe1e-4761-9c24-f83e786e6608"
"ca166f8b-b21c-de18-a493-05dc9aba4449"
"32e94e7c-fe1e-4761-9c24-f83e786e6608"
"d7f9c458-0e42-25c9-7f84-b8a4f48a5aca"
"aeac55e5-8a9d-e1f0-21d1-55087517ab56")

for i in "${UUIDS[@]}"
do
  xe vm-param-set uuid=$i HVM-boot-policy="BIOS order" PV-args="" PV-bootloader-args="" HVM-boot-params:order="dc" PV-bootloader=""
done


xe template-param-set uuid=$TEMPLATE_UUID HVM-boot-policy="" PV-bootloader=pygrub PV-args=console="hvc0";