install_pkg dash
install_pkg $PACMAN_BIN binutils bash-completion

# better compatibility for building AUR packages:
step "Enabling multilib mode (32 bits applications allowed)"

have_package gcc-libs && raw_install_pkg -Rdd --noconfirm gcc-libs && install_pkg --asdeps gcc-libs-multilib
have_package gcc && raw_install_pkg -Rdd --noconfirm gcc && install_pkg --asdeps gcc-multilib

