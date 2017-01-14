echo $DISKLABEL | tr "A-Z" "a-z" | sudo dd "of=$R/etc/hostname"
