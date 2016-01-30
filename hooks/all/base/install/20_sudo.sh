. ./strapfuncs.sh

install_pkg -Sy --noconfirm sudo

cat > $R/etc/sudoers.d/50_nopassword <<EOF
%wheel ALL=(ALL) ALL
EOF
