
step2 "conf.d"
sudo mkdir "$R/etc/systemd/system.conf.d/" 2> /dev/null
sudo cp -r resources/system.conf.d/. "$R/etc/systemd/system.conf.d"

step2 "clean folders service"
if [ ! -e "$R/etc/systemd/system/clean-folders.service" ]; then
    _TGT="shutdown.target.wants"
    sudo mkdir "$R/etc/systemd/$_TGT" 2> /dev/null
    sudo install -m 644 -o root -g root resources/clean-folders.service "$R/etc/systemd/system/clean-folders.service"
    sudo ln -sf  "../clean-folders.service" "$R/etc/systemd/system/$_TGT/clean-folders.service"
    sudo install -m 755 -o root -g root resources/cleanup_filesystem.sh "$R/usr/bin/"
    enable_service clean-folders
fi
step2 "no clear console"

sudo mkdir -p "$R/etc/systemd/system/getty@tty1.service.d"
echo "[Service]
TTYVTDisallocate=no
" | sudo dd "of=$R/etc/systemd/system/getty@tty1.service.d/noclear.conf"

