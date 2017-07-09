install_pkg whois
install_pkg iputils
install_pkg netcat 
install_pkg lftp 
install_pkg avahi 
install_pkg nss-mdns
install_pkg sshuttle
install_pkg dnsmasq

if have_xorg; then  install_pkg wireshark-$PREFERRED_TOOLKIT ; fi

enable_service avahi-daemon
enable_service avahi-dnsconfd
install_file resources/nsswitch.conf "/etc/nsswitch.conf"
