. ./strapfuncs.sh

pat="# MOVABLE PATCH"

# update pacman conf
I="$R/etc/pacman.conf"
## undo
if contains "$pat" "$I"; then
    strip_end "$pat" "$I"
fi
# apply
echo "$pat" >> "$I"
cat resources/additional_mirrors.conf >> "$I"

