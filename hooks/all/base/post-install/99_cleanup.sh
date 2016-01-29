source ./configuration.sh

arch-chroot $R pacman-optimize
arch-chroot $R ldconfig

#rm -fr $R/var/cache/pacman/pkg/*
