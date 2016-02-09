
sudo useradd -R "$R" -G $DEFAULT_GROUPS -m $USERNAME

echo "root:$PASSWORD
$USERNAME:$PASSWORD" | sudo chpasswd -R "$R"

