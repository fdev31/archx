install_pkg arch-install-scripts
install_bin resources/installer.py /bin/
install_bin resources/installer-embed.sh /bin/
install_bin resources/installer-standard.sh /bin/
install_bin resources/installer-archlinux.sh /bin/
$SUDO mkdir -p "$R/usr/share/installer"
for path in resources/locales/gettext/*_*; do
    loc=${path##*/}
    install_file $path/LC_MESSAGES/messages.mo /usr/share/locale/${loc%_*}/LC_MESSAGES/installer.mo
done
install_bin resources/instlib.sh /usr/share/installer
install_pkg parted # used for partprobe

install_pkg python-pythondialog

echo "#!/bin/sh
mount /boot -o remount,rw
cp $* /boot/
mount /boot -o remount,ro
" | $SUDO dd of="$R/bin/copy2boot.sh" 2>/dev/null
$SUDO chmod +x "$R/bin/copy2boot.sh"
