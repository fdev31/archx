.PHONY: all distrib intro setup

all: ARCHX.img

include configuration.sh
include my_conf.sh

info:
	@echo "Building ${DISKLABEL} :: ${DISTRIB}"
	@echo "${COMPRESSION_TYPE} compression used"
	@echo "${PACMAN_BIN} will be used to install packages."

list: help

init:
	mkdir  ${_ORIG_ROOT_FOLDER} || true
	mkdir  ${_MOUNTED_ROOT_FOLDER} || true
	sudo mount --bind ${_ORIG_ROOT_FOLDER} ${_MOUNTED_ROOT_FOLDER}

umount:
	sudo umount ${_MOUNTED_ROOT_FOLDER} || true

help:
	@echo "Targets:"
	@echo "<default>   build the disk image (default)"
	@echo "fresh       rebuild everything"
	@echo "info        show some configuration information"
	@echo "setup       create a customm distribution by answering questions"
#     @echo ""
#     @echo "rootfs.s    build the compressed apps image"
#     @echo "hooks       build the apps"
#     @echo "ROOT        clear root filesystem and install minimal software"

ARCHX.img: rootfs.s
	./cos-makedisk.sh

rootfs.s: hooks.flag
	./cos-makesquash.sh

hooks.flag: ROOT.flag
	./cos-installpackages.sh
	touch $@

ROOT.flag: my_conf.sh
	./cos-baseinstall.sh
	touch $@

clean: umount
	./cos-cleanup.sh || true

setup:
	./cos-customdistro.sh

shell:
	sudo install -m 600 -o root -g root resources/sudo_conf_nopass ${_MOUNTED_ROOT_FOLDER}/etc/sudoers.d/50_nopassword
	sudo arch-chroot ${_MOUNTED_ROOT_FOLDER}
	sudo rm -fr ${_MOUNTED_ROOT_FOLDER}/var/cache/pacman/pkg/*

overlays: umount
	./make_overlays.sh

initramfs: 
	./make_initramfs.sh

