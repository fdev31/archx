sudo useradd -R "$R" -G $DEFAULT_GROUPS -m $USERNAME -g $USERGID -u $USERID

echo "root:$PASSWORD
$USERNAME:$PASSWORD" | sudo chpasswd -R "$R"

