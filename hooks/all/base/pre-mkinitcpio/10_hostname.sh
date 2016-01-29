source ./configuration.sh

echo $DISKLABEL | tr "A-Z" "a-z" > "$R/etc/hostname"

