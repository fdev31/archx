source ./configuration.sh
rm -fr $R/boot/*fallback* # unused, previously installed profile

mkdir "$R/etc/systemd/system.conf.d/" 2> /dev/null
echo "LogTarget=kmsg" > "$R/etc/systemd/system.conf.d/log_kmsg.conf"

