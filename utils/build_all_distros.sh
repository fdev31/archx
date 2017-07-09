#l!/bin/sh

source ./configuration.sh

for n in distrib/{default,noobs,multichoice}.sh; do
    n=${n##*/}
    n=${n%.sh}
    echo "DISTRIB=$n" > my_conf.sh
    echo "removing old root..."
    sudo rm -fr "$R"
    echo "building !"
    yes O | ./mkbootstrap.sh
    sudo du -sh "$R" > "root_size-$n.txt"
    mv ARCHX.img ARCHX-$n.img
done
