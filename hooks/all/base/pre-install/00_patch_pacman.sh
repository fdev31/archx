source ./configuration.sh

pat="# MOVABLE PATCH"

# update pacman conf
I="$R/etc/pacman.conf"
## undo
if grep "$pat" "$I"; then
    sed -i "/^$pat/,$ d" $I
fi
# apply
echo "$pat" >> $I
cat resources/additional_mirrors.conf >> $I

