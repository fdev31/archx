PROFILES=''
for dir in hooks/* ; do
    if [ -d $dir ] && [ "$dir" != "alternatives" ] ; then
        PROFILES="$PROFILES ${dir#*/}"
    fi
done
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST='firefox-ublock-origin firefox-download-youtube-videos-as-mp4 firefox-flashgot'
function distro_install_hook() {
    return
 }
