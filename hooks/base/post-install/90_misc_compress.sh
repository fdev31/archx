if [ -e "$R/usr/lib/rustlib/x86_64-unknown-linux-gnu/lib/" ]; then
    install_pkg upx
    upx_comp /usr/lib/rustlib/x86_64-unknown-linux-gnu/lib/
fi
