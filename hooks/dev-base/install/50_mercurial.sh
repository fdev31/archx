install_pkg mercurial
install_pkg python2-pygments

# Too costly!
#if have_xorg ; then
#    for d in python2 mercurial python2-pyqt4 python2-qscintilla python2-iniparse; do
#        install_pkg --asdeps "$d"
#    done
#    have_xorg && install_pkg tortoisehg
#fi
