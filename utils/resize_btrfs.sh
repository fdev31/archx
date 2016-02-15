#!/bin/sh
# Ex: resize_btrfs.sh image.btr 500M
IMAGE="$1"
SIZE="$2"
echo dd if=/dev/zero "of=$IMAGE" "bs=$SIZE" oflag=append conv=notrunc count=1
dd if=/dev/zero "of=$IMAGE" "bs=$SIZE" oflag=append conv=notrunc  count=1
mkdir .btrfs_mount
sudo mount -o compress "$IMAGE" ./.btrfs_mount
echo  btrfs filesystem resize "+$SIZE" ./.btrfs_mount
sudo btrfs filesystem resize "+$SIZE" ./.btrfs_mount

