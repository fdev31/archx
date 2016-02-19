install_pkg tesseract-data-${LANG_ISO3}
l=$(LC_ALL=C raw_install_pkg -Si paperwork |grep "^Depends")
for d in ${l#*: }; do
    install_pkg --asdeps "$d"
done
install_pkg paperwork
