install_pkg dash
sudo ln -sf "dash" "$R/bin/sh"
install_pkg $PACMAN_BIN binutils arch-install-scripts bash-completion

# better compatibility for building AUR packages:
step "Enabling multilib mode (32 bits applications allowed)"

have_package gcc-libs && raw_install_pkg -Rdd --noconfirm gcc-libs && install_pkg --asdeps gcc-libs-multilib
have_package gcc && raw_install_pkg -Rdd --noconfirm gcc && install_pkg --asdeps gcc-multilib

