install_pkg nvidia
install_pkg nvidia-libgl
install_pkg lib32-nvidia-libgl
install_pkg opencl-nvidia

if [ ! -f "$R/etc/modprobe.d/nvidia.conf" ]
then
    echo "blacklist nouveau" | append_text "/etc/modprobe.d/nvidia.conf"
fi
