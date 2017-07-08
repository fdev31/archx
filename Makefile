.PHONY: all distrib intro

all: ARCHX.img

include configuration.sh
include my_conf.sh

info:
	@echo "Building ${DISKLABEL} :: ${DISTRIB}"
	@echo "${COMPRESSION_TYPE} compression used"
	@echo "${PACMAN_BIN} will be used to install packages."

list: help
help:
	@echo "Targets:"
	@echo "info        show some configuration information"
	@echo "ARCHX.img   build the disk image"
	@echo "rootfs.s    build the compressed apps image"
	@echo "hooks       build the apps"
	@echo "ROOT        clear root filesystem and install minimal software"

ARCHX.img: rootfs.s
	./cos-makedisk.shck

rootfs.s: hooks
	./cos-makesquash.sh

hooks: ROOT
	./cos-installpackages.sh
	touch $@

ROOT: my_conf.sh
	./cos-baseinstall.sh

