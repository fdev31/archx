PROFILES="$PKG_BASE env-cinnamon $PKG_XORG $PKG_EDIT $PKG_GFX $PKG_UI $PKG_EMU $PKG_UI $PKG_EMU $PKG_DOC $PKG_SND proprietary"

PREFERRED_TOOLKIT='gtk'

DISTRO_PACKAGE_LIST='chromium pidgin telepathy gnome-extra vlc shotwell clementine dropbox deluge handbrake'

function distro_install_hook() {
    return
}
