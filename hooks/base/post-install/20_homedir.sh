. ./strapfuncs.sh

rm -fr "$R/home/$USERNAME/"
cp -r ./ressources/HOME "$R/home/$USERNAME"

sudo chown -R 1000.100 "$R/home/$USERNAME"

