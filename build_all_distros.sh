#!/bin/sh

source ./configuration.sh

for n in distrib/*.sh; do
    n=${n##*/}
    n=${n%.sh}
    echo "DISTRIB=$n" > my_conf.sh
    sudo rm -fr "$R"
    yes O | ./mkbootstrap.sh
    sudo du -sh "$R" > "root_size-$n.txt"
    mv ARCHX.img ARCHX-$n.img
done
