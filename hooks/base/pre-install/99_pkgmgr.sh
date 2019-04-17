$SUDO sed -i 's/^#Color/Color/' "$R/etc/pacman.conf"
$SUDO sed -i 's/^CheckSpace/#CheckSpace/' "$R/etc/pacman.conf"

$SUDO sed -i 's/#MAKEFLAGS="-j2"/MAKEFLAGS="-j2"/' "$R/etc/makepkg.conf"

sudo -u user gpg --batch --recv-key 1EB2638FF56C0C53 || echo "Unable to retrieve key from server ! Expect failure soon..."

for n in cower pikaur; do
    if ! have_package $n ; then
        mkdir -p sources/$n
        curl -o sources/$n/PKGBUILD 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h='$n
        (cd sources/$n && chown -R user . && sudo -u user makepkg -fs && pacman -U --noconfirm *.pkg* )
    fi
done
$SUDO rm -fr sources
