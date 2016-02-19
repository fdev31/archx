install_pkg gcc-multilib gcc-libs-multilib
for pkg in $(pacman -Qqg base-devel); do
    install_pkg $pkg
done
