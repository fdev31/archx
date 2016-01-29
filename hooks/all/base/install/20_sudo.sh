source ./configuration.sh

./mkbootstrap.sh install -Sy --noconfirm sudo

cat > $R/etc/sudoers.d/50_nopassword <<EOF
%wheel ALL=(ALL) NOPASSWD: ALL
user ALL=(ALL) NOPASSWD: ALL
EOF
