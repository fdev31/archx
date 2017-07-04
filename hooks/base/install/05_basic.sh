install_pkg dash
install_pkg $PACMAN_BIN
install_pkg binutils
install_pkg bash-completion

# better compatibility for building AUR packages:
step "Enabling multilib mode (32 bits applications allowed)"

have_package gcc-libs && raw_install_pkg -Rdd --noconfirm gcc-libs && raw_install_pkg --asdeps -S gcc-libs-multilib
have_package gcc && raw_install_pkg -Rdd --noconfirm gcc && raw_install_pkg --asdeps -S gcc-multilib

install_pkg netctl
install_pkg wpa_supplicant
install_pkg ifplugd

$SUDO sed -i 's/^#Color/Color/' "$R/etc/pacman.conf"
$SUDO sed -i 's/^CheckSpace/#CheckSpace/' "$R/etc/pacman.conf"

$SUDO sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j2"/' "$R/etc/makepkg.conf"

