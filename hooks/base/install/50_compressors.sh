install_pkg p7zip
install_pkg unrar

install_pkg zramswap
if [ $LOW_MEM ] ; then
    enable_service zramswap
fi
