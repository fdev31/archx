sudo -u user gpg --batch --recv-key 1EB2638FF56C0C53

for n in cower pacaur ; do
    if ! have_package $n ; then
        mkdir -p sources/$n
        curl -o sources/$n/PKGBUILD 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h='$n
        (cd sources/$n && chown -R user . && sudo -u user makepkg -f && pacman -U --noconfirm *.pkg* )
    fi
done
