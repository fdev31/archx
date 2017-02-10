if have_xorg ; then
    install_pkg teamviewer
    write_bin /bin/runteamviewer.sh << EOF
echo "#!/bin/sh
if ! systemctl list-units |grep ^teamviewerd | grep running ; then
    gksu systemctl start teamviewerd
    sleep 3
fi
exec teamviewer
EOF
#    enable_service teamviewerd
fi
