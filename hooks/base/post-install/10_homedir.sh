$SUDO rm -fr "$R/home/$USERNAME/"
$SUDO cp -r ./resources/HOME/* "$R/home/$USERNAME"
set_user_ownership "$R/home/$USERNAME"
