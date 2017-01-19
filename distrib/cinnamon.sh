PROFILES="$PKG_BASE $PKG_XORG env-cinnamon $PKG_EDIT $PKG_GFX $PKG_UI $PKG_EMU $PKG_UI $PKG_EMU $PKG_DOC $PKG_SND proprietary "
DISK_TOTAL_SIZE=4

PREFERRED_TOOLKIT='gtk'

DISTRO_PACKAGE_LIST='chromium pidgin telepathy gnome-extra shotwell clementine dropbox deluge handbrake'

function distro_install_hook() {
    return
}
