if have_xorg ; then
    install_pkg teamviewer
    echo "#!/bin/sh
    if ! systemctl list-units |grep ^teamviewerd | grep running ; then
        systemctl start teamviewerd
        sleep 1
    fi
    exec teamviewer
    " | sudo dd of="$R/bin/runteamviewer.sh"
    sudo chmod 755 "$R/bin/runteamviewer.sh"
#    enable_service teamviewerd
fi
