$SUDO sed -i 's/^#Color/Color/' "$R/etc/pacman.conf"
$SUDO sed -i 's/^CheckSpace/#CheckSpace/' "$R/etc/pacman.conf"

$SUDO sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j2"/' "$R/etc/makepkg.conf"

$SUDO rm -fr sources
