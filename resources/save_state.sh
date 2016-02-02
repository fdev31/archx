#!/bin/sh
FOLDERS="usr var/lib etc"
cd /.ghost
rm -fr /var/cache/pacman/pkg/*
rm -fr /var/lib/systemd/coredump/core.*

#mount -o remount,rw /boot
(tar cvf - $FOLDERS --exclude-caches-all | xz -5 > /boot/session.txz.tmp) && mv /boot/session.txz.tmp /boot/session.txz || echo "No space left !"
rm -fr /boot/session.txz.tmp 2>/dev/null
#mount -o remount,ro /boot
