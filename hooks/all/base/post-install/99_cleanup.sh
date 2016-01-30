source ./configuration.sh

pacman-optimize "$R/var/lib/pacman"
ldconfig -r "$R"
