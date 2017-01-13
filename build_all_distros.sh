#!/bin/sh

source ./configuration.sh

for n in distrib/*.sh; do
    n=${n##*/}
    n=${n%.sh}
    echo "DISTRIB=$n" > my_conf.sh
    sudo rm -fr "$R"
    ./mkbootstrap.sh
    mv ARCHX.img ARCHX-$n.img
done
