for pkg in $(pacman -r "$R" -Sqg base-devel); do
    install_pkg $pkg
done
install_pkg ltrace
