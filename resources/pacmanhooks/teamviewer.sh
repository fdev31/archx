_sf="/usr/lib/systemd/system/teamviewerd.service"
if ! grep TimeoutStopSec "$_sf" ; then
    sudo sed -i "s/\[Service\]/[Service]\nTimeoutStopSec=5s/" $_sf
fi
