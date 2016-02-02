source ./strapfuncs.sh

sudo mkdir "$R/etc/systemd/system.conf.d/" 2> /dev/null
sudo cp -r resources/system.conf.d "$R/etc/systemd/system.conf.d"

