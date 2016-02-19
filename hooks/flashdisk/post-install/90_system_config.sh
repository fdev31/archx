
step2 "conf.d"
for FOLDERD in system journal coredump; do
    sudo mkdir "$R/etc/systemd/$FOLDERD.conf.d/" 2> /dev/null
    sudo cp -r resources/$FOLDERD.conf.d/. "$R/etc/systemd/$FOLDERD.conf.d"
done

step2 "clean folders service"

install_file resources/clean-folders.service "$R/etc/systemd/system/clean-folders.service"
install_bin resources/cleanup_filesystem.sh "$R/usr/bin/"
enable_service clean-folders

#step2 "mount services"

#install_file resources/mount_persist.service "$R/etc/systemd/system/mount_persist.service"
#install_bin resources/persist_mounter.sh "$R/bin/"
#enable_service mount_persist

step2 "no clear console"

sudo mkdir -p "$R/etc/systemd/system/getty@tty1.service.d"
echo "[Service]
TTYVTDisallocate=no
" | sudo dd "of=$R/etc/systemd/system/getty@tty1.service.d/noclear.conf"

