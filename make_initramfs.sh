#!/bin/bash

. ./configuration.sh
. ./strapfuncs.sh

sudo cp resources/rolinux.inithook $_MOUNTED_ROOT_FOLDER/resources/

tmpfile=$(mktemp)
echo $tmpfile

cat > $tmpfile <<EOF
#!/bin/bash
set -xe
. /strapfuncs.sh
. /.installed_hooks/pre-mkinitcpio/50_init_mounthandler.sh
mkinitcpio -p linux
EOF

sudo mv "$tmpfile" "${_MOUNTED_ROOT_FOLDER}/inst.sh"
sudo chmod 777 "${_MOUNTED_ROOT_FOLDER}/inst.sh"

sudo arch-chroot ${_MOUNTED_ROOT_FOLDER} /inst.sh

sleep 1
