#!/bin/sh
rm -fr /var/cache/pacman/pkg/*
rm -fr /var/lib/systemd/coredump/core.*
for HOMEDIR in /home/* ; do
    rm -fr $HOMEDIR/.cache
    rm -fr $HOMEDIR/.thumb
done
pacman-optimize "/var/lib/pacman"

sync
sync
sync
