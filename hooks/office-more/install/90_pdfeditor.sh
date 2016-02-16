install_pkg masterpdfeditor
CFG="resources/HOME/.config/Code Industry/Master PDF Editor.conf"

if [ ! -e "$CFG" ]; then
    echo "[General]
    lang=$(echo ${LANG%.*} | tr 'A-Z' 'a-z') " > "$CFG"
fi
