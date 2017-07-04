$SUDO useradd -R "$R" -G $DEFAULT_GROUPS -m $USERNAME -g $USERGID -u $USERID

echo "root:$PASSWORD
$USERNAME:$PASSWORD" | $SUDO chpasswd -R "$R"

