install_pkg gcc-multilib gcc-libs-multilib
for pkg in $(pacman -Sqg base-devel); do
    install_pkg $pkg
done
