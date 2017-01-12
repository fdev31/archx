pushd $R/etc/fonts/conf.d/
sudo rm 10-*hint*
sudo ln -s ../conf.avail/10-autohint.conf
sudo rm 11-*lcdfilter*
sudo ln -s ../conf.avail/11-lcdfilter-default.conf
popd
