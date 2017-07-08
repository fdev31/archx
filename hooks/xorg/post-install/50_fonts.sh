pushd $R/etc/fonts/conf.d/
    if [ ! -e "11-lcdfilter-default.conf" ] ; then
        $SUDO rm 10-*hint*
        $SUDO ln -s ../conf.avail/10-autohint.conf
        $SUDO ln -s ../conf.avail/11-lcdfilter-default.conf
    fi
popd
