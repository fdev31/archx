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
