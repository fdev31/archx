. ./strapfuncs.sh

install_pkg wireshark-$PREFERRED_TOOLKIT whois iputils netcat lftp avahi

enable_service avahi-dnsconfd
