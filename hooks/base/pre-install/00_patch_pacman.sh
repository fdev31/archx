pat="# MOVABLE PATCH"

append_text "/etc/pacman.conf" < resources/additional_mirrors.conf

raw_install_pkg -Syu --noconfirm # sync db
