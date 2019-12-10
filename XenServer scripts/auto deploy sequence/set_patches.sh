#!/bin/bash
URL=$1

is_it_ok () {
if ["$1" != "0" ]; then
	echo "date '+%D--%X'#$2"
	exit $3
fi
}

echo "Begining patching sequence..."
echo "Downloading patches..."
wget "$URL/patch"
if [ "$?" != "0" ]; then 
	exit 1;
fi
tar -zxvf patch
sleep 5
cd patches
    echo "date '+%D--%X'#Importing patch: XS70E004.xsupdate..."
    xe patch-upload file-name=XS70E004.xsupdate
    sleep 5
    echo "date '+%D--%X'#Applying patch: XS70E004.xsupdate..."
    xs_name=$(echo XS70E004.xsupdate|awk -F . '{print $1}')
    PATCH_UUID=$(xe patch-list name-label=$xs_name |grep uuid |awk '{print $5}')
    xe patch-pool-apply uuid=$PATCH_UUID
    sleep 5
    xe patch-list name-label="$xs_name"
for xs in *.xsupdate; do
        echo "date '+%D--%X'#Importing patch: $xs..."
        xe patch-upload file-name=$xs
        sleep 5
        echo "date '+%D--%X'#Applying patch: $xs..."
        xs_name=$(echo $xs|awk -F . '{print $1}')
        PATCH_UUID=$(xe patch-list name-label=$xs_name |grep uuid |awk '{print $5}')
        xe patch-pool-apply uuid=$PATCH_UUID
        sleep 5
        xe patch-list name-label="$xs_name"
done
cd $DIR

