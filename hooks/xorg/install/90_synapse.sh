if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg synapse
    autostart_app synapse
    sudo sed -i "resources/HOME/.config/autostart/synapse.desktop" -e "s/Exec=synapse/Exec=synapse -s/"
fi
