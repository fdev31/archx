source ./configuration.sh

useradd -R "$R" -G $DEFAULT_GROUPS -m user
useradd -R "$R" -G $ADMIN_GROUPS -m admin

echo "root:$PASSWORD
admin:$PASSWORD
user:$PASSWORD" | chpasswd -R "$R"

