pushd $R/etc/fonts/conf.d/
$SUDO rm 10-*hint*
$SUDO ln -s ../conf.avail/10-autohint.conf
$SUDO rm 11-*lcdfilter*
$SUDO ln -s ../conf.avail/11-lcdfilter-default.conf
popd
