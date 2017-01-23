append_text "/etc/pacman.conf" <<EOF
[pantheon]
SigLevel = Optional
Server = http://pkgbuild.com/~alucryd/\$repo/\$arch
EOF

install_pkg pantheon
install_pkg pantheon-files
install_pkg pantheon-photos
install_pkg pantheon-terminal
install_pkg contractor
