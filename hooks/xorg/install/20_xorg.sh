install_pkg xorg
install_pkg xorg-xinit
install_pkg accountsservice
raw_install_pkg -R xf86-input-synaptics # force libinput usage

enable_service accounts-daemon
if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg gtk-engines
    install_pkg gvfs
fi

install_pkg libx264
install_pkg gnome-keyring
if [ -z "$USE_NVIDIA" ]; then
    install_pkg mesa-libgl
    install_pkg lib32-mesa-libgl
    install_pkg libva-vdpau-driver
    install_pkg libva-intel-driver
    install_pkg mesa-vdpau
    install_pkg libvdpau
else
    install_pkg nvidia
    install_pkg nvidia-libgl
    install_pkg mesa-vdpau
    install_pkg libva-vdpau-driver
    install_pkg opencl-nvidia
    install_pkg lib32-nvidia-libgl
    install_pkg nvidia-utils
    #install_pkg cuda

    if [ ! -f "$R/etc/modprobe.d/nvidia.conf" ]
    then
        echo "blacklist nouveau" | append_text "/etc/modprobe.d/nvidia.conf"
    fi
fi
