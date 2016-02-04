
sudo useradd -R "$R" -G $DEFAULT_GROUPS -m $USERNAME
sudo useradd -R "$R" -G $ADMIN_GROUPS -m superuser

echo "root:$PASSWORD
superuser:$PASSWORD
$USERNAME:$PASSWORD" | sudo chpasswd -R "$R"

