if have_xorg; then  install_aur_pkg streamstudio-bin ; fi
have_package steamstudio-bin && upx_comp "/opt/streamstudio-bin/lib/" || true
if have_xorg; then  install_aur_pkg popcorntime-ce-bin ; fi
