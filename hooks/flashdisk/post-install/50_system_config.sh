step2 "conf.d"
for FOLDERD in system journal coredump; do
    $SUDO mkdir "$R/etc/systemd/$FOLDERD.conf.d/" 2> /dev/null
    $SUDO cp -r resources/$FOLDERD.conf.d/. "$R/etc/systemd/$FOLDERD.conf.d"
done

step2 "clean folders service"

install_file resources/clean-folders.service "/etc/systemd/system/clean-folders.service"
install_bin resources/cleanup_filesystem.sh "/usr/bin/"
enable_service clean-folders

step2 "no clear console"

$SUDO mkdir -p "$R/etc/systemd/system/getty@tty1.service.d"
echo "[Service]
TTYVTDisallocate=no
" | $SUDO dd "of=$R/etc/systemd/system/getty@tty1.service.d/noclear.conf" 2>/dev/null && echo "Should not clear console"

