#!/usr/bin/env bash

PACKAGES="cower pacaur" # add your packages here !

cd $(dirname $0)


[ -e sources ] || mkdir sources

function fetch_install() {
    if pacman -Qq $1 ; then
        return
    fi
    dir="sources/$1"
    if [ !  -e "$dir/PKGBUILD" ]; then
        mkdir "$dir" || echo "STRANGE: $dir folder already created..."
        curl -o "$dir/PKGBUILD" 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h='$1
    fi
    (cd $dir && sudo -u user -- makepkg && pacman -U *.pkg.*)
}

for n in $PACKAGES ; do
    fetch_install $n
done
