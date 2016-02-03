. ./strapfuncs.sh

install_pkg pulseaudio
install_pkg pulseaudio-gconf
install_pkg paman
install_pkg pavucontrol
install_pkg pavumeter
install_pkg paprefs
install_pkg pasystray

pat="# MOVABLE PATCH"

I="$R/etc/pulse/default.pa"

strip_end "$pat" "$I"
_FILE=$(cat "$I")
ADD_FILE=$(cat "resources/default.pa")

echo "$_FILE

# MOVABLE PATCH

$ADD_FILE
" | sudo dd "of=$I"


