if have_xorg ; then
    install_pkg teamviewer

    echo "#!/bin/sh
    if ! systemctl list-units |grep ^teamviewerd | grep running ; then
        systemctl start teamviewerd
    fi
    teamviewer
    " | sudo dd of="$R/bin/runteamviewer.sh"
    sudo chmod 755 "$R/bin/runteamviewer.sh"

    echo "#!/bin/sh
    if ! systemctl list-units |grep ^teamviewerd | grep running ; then
        systemctl start teamviewerd
    fi
    teamviewer
    " | sudo dd of="$R/bin/runteamviewer.sh"
    sudo chmod 755 "$R/bin/runteamviewer.sh"
    enable_service teamviewerd
fi
