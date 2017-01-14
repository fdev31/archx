install_pkg dash
install_pkg $PACMAN_BIN binutils bash-completion

# better compatibility for building AUR packages:
step "Enabling multilib mode (32 bits applications allowed)"

have_package gcc-libs && raw_install_pkg -Rdd --noconfirm gcc-libs && raw_install_pkg --asdeps -S gcc-libs-multilib
have_package gcc && raw_install_pkg -Rdd --noconfirm gcc && raw_install_pkg --asdeps -S gcc-multilib

install_pkg  netctl wpa_supplicant ifplugd

sudo sed -i 's/^#Color/Color/' "$R/etc/pacman.conf"
sudo sed -i 's/^CheckSpace/#CheckSpace/' "$R/etc/pacman.conf"


#install_pkg --asdeps linux-headers
#install_pkg virtualbox-guest-dkms 

#have_xorg && install_pkg virtualbox-guest-utils
#have_xorg || install_pkg virtualbox-guest-utils-nox

#install_pkg virtualbox-guest-iso

