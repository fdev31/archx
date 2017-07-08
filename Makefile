.PHONY: all distrib

all: ARCHX.img

ARCHX.img: rootfs.s
	./cos-makedisk.sh


rootfs.s: hooks
	./cos-makesquash.sh

hooks: ROOT
	./cos-installpackages.sh
	touch hooks

ROOT: my_conf.sh
	./cos-baseinstall.sh
	touch ROOT

