install_pkg connman
install_pkg wpa_supplicant

enable_service connman

if have_xorg ; then
    if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
        install_pkg connman-ui-git
    else
        install_pkg cmst
    fi
fi
