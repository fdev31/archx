# script-forced
source ./strapfuncs.sh

# Injects or updates boot's mount process using resources/initcpio_mounthandler.sh

I="$R/lib/initcpio/init"
ORIG="\"$$mount_handler\" \\/new_root"

## undo first
if contains "MOVABLE ROOT PATCH" "$I"; then
    replace_with "#MOVABLE ROOT PATCH" "$ORIG" $"I"
fi  

# apply new conf
FOOTER=$(sed "0,/mount_handler.*new_root/ d" "$I")
HEADER=$(sed "/mount_handler.*new_root/,$ d" "$I")

echo "$HEADER
$(cat resources/initcpio_mounthandler.sh)
$FOOTER" | sed -e "s/DISKLABEL/$DISKLABEL/" -e "s/ROOTIMAGE/$ROOTNAME/" | sudo dd "of=$I"
