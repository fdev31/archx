append_text "/etc/pacman.conf" < resources/additional_mirrors.conf
raw_install_pkg -Syu --needed --noconfirm # sync db
