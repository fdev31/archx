sudo rm -fr "$R/home/$USERNAME/"
sudo cp -r ./resources/HOME "$R/home/$USERNAME"
set_user_ownership "$R/home/$USERNAME"
