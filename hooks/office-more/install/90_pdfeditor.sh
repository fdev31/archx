install_pkg masterpdfeditor
CFG="resources/HOME/.config/Code Industry/Master PDF Editor.conf"

if [ ! -e "$CFG" ]; then
    mkdir "${CFG%/*}"
    echo "[General]
lang=${LANG_ISO2}_${LANG_ISO2}" > "$CFG"
fi
