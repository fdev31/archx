
install_pkg  qemu qemu-arch-extra

if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
    install_pkg  qtemu
else
    install_pkg  qemu-launcher
fi
