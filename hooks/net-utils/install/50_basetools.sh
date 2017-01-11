install_pkg whois iputils netcat lftp avahi nss-mdns
have_xorg && install_pkg wireshark-$PREFERRED_TOOLKIT

enable_service avahi-daemon
enable_service avahi-dnsconfd
install_file resources/nsswitch.conf "/etc/nsswitch.conf"
