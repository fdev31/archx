.PHONY: all distrib intro setup

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
	@echo "<default>   build the disk image (default)"
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

hooks.flag: ROOT
	./cos-installpackages.sh
	touch $@

ROOT: my_conf.sh
	./cos-baseinstall.sh

setup:
	./cos-customdistro.sh
