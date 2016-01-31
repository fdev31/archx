. ./strapfuncs.sh

install_pkg -Sy --noconfirm qemu qemu-arch-extra

if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
    install_pkg -Sy --noconfirm qtemu
else
    install_pkg -Sy --noconfirm qemu-launcher
fi
