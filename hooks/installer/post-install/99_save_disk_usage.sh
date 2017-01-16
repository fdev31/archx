sudo du -s $R | cut -d '	' -f 1 > .diskusage
sudo mv .diskusage $R/.diskusage
