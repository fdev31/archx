. ./configuration.sh

if ls extra_packages/* >/dev/null 2>&1 ; then
    ./mkbootstrap.sh install -U --noconfirm extra_packages/*
fi

