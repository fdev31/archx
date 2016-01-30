# script-forced
source ./configuration.sh

# Injects or updates boot's mount process using resources/initcpio_mounthandler.sh

I="$R/lib/initcpio/init"
garbage=tmp.file
orig="\"$$mount_handler\" \\/new_root"

## undo first
if grep "MOVABLE ROOT PATCH" "$I"; then
    (sed "/^#MOVABLE ROOT PATCH/,/^#-MOVABLE ROOT PATCH/ s/.*/$orig/" < "$I" | uniq) > $garbage
    install -TD -o root -g root -m 755 $garbage "$I"
fi  

# apply new conf
footer=$(sed "0,/mount_handler.*new_root/ d" "$I")
header=$(sed "/mount_handler.*new_root/,$ d" "$I")

echo "$header
$(cat resources/initcpio_mounthandler.sh)
$footer" | sed -e "s/DISKLABEL/$DISKLABEL/" -e "s/ROOTIMAGE/$ROOTNAME/" > "$I"
