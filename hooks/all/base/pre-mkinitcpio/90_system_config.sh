source ./configuration.sh

mkdir "$R/etc/systemd/system.conf.d/" 2>/dev/null

echo "LogTarget=kmsg" > "$R/etc/systemd/system.conf.d/log_kmsg.conf"

