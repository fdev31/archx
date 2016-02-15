
sudo rm -fr "$R/home/$USERNAME/"
sudo cp -r ./resources/HOME "$R/home/$USERNAME"

sudo chown -R 1000.100 "$R/home/$USERNAME"

