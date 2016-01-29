source ./configuration.sh

cat > $R/etc/fstab <<EOF
# <file system> <dir>   <type>  <options>   <dump>  <pass>
/dev/loop0 /               auto    rw             0      0
tmpfs      /tmp            tmpfs   nodev,nosuid   0      1
tmpfs      /run            tmpfs   rw             0      3
tmpfs      /var/cache      tmpfs   rw             0      3
tmpfs      /var/log        tmpfs   rw             0      3
tmpfs      /var/tmp        tmpfs   rw             0      3
tmpfs      /var/spool      tmpfs   rw             0      3
EOF

