
step2 "conf.d"
for FOLDERD in system journal coredump; do
    sudo mkdir "$R/etc/systemd/$FOLDERD.conf.d/" 2> /dev/null
    sudo cp -r resources/$FOLDERD.conf.d/. "$R/etc/systemd/$FOLDERD.conf.d"
done

step2 "clean folders service"

_TGT="shutdown.target.wants"
sudo mkdir "$R/etc/systemd/$_TGT" 2> /dev/null
sudo install -m 644 -o root -g root resources/clean-folders.service "$R/etc/systemd/system/clean-folders.service"
sudo ln -sf  "../clean-folders.service" "$R/etc/systemd/system/$_TGT/clean-folders.service"
sudo install -m 755 -o root -g root resources/cleanup_filesystem.sh "$R/usr/bin/"
enable_service clean-folders

step2 "mount services"

_TGT="multi-user.target.wants"
sudo mkdir "$R/etc/systemd/$_TGT" 2> /dev/null
sudo install -m 644 -o root -g root resources/mount_persist.service "$R/etc/systemd/system/mount_persist.service"
enable_service mount_persist

step2 "no clear console"

sudo mkdir -p "$R/etc/systemd/system/getty@tty1.service.d"
echo "[Service]
TTYVTDisallocate=no
" | sudo dd "of=$R/etc/systemd/system/getty@tty1.service.d/noclear.conf"


sudo install -m 755 -o root -g root resources/persist_mounter.sh "$R/bin/"

