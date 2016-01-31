. ./strapfuncs.sh

if ls extra_packages/* >/dev/null 2>&1 ; then
    install_pkg -U --noconfirm extra_packages/*
fi

