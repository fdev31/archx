for pkg in $(pacman --sysroot "$R" -Sqg base-devel); do
    install_pkg $pkg
done
install_pkg ltrace
