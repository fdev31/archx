pat="# MOVABLE PATCH"

# update pacman conf
I="$R/etc/pacman.conf"
## undo
if contains "$pat" "$I"; then
    strip_end "$pat" "$I"
fi
_MIR_FILE=$(cat "$I")

# apply
echo "$_MIR_FILE
$pat
$(cat resources/additional_mirrors.conf)
" | sudo dd "of=$I"

raw_install_pkg -Syu --noconfirm # sync db
