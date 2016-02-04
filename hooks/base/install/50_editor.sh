. ./strapfuncs.sh

have_xorg && install_pkg gvim
have_xorg || install_pkg vim

install_pkg vim-spell-${LANG%_*}
