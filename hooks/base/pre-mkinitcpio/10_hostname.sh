echo $DISKLABEL | tr "A-Z" "a-z" | $SUDO dd "of=$R/etc/hostname" 2>/dev/null && echo "- hostname updated"
