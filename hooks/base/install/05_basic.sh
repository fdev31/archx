install_pkg dash
sudo ln -sf "dash" "$R/bin/sh"
install_pkg  $PACMAN_BIN binutils arch-install-scripts bash-completion

# better compatibility for building AUR packages:
step "Enabling multilib mode (32 bits applications allowed)"

raw_install_pkg -Rdd --noconfirm gcc-libs
raw_install_pkg -S --asdeps  --noconfirm gcc-libs-multilib

raw_install_pkg -Rdd --noconfirm gcc
raw_install_pkg -S --asdeps  --noconfirm gcc-multilib

