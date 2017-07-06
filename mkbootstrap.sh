#!/bin/bash
set -e

echo "" > /tmp/failedpkgs.log

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

#if [ -n "$SECUREBOOT" ]; then
#    DEPS="$DEPS preloader-signed"
#fi

ERROR=0
pacman -Qq $DEPS > /dev/null || ERROR=1

[ $ERROR -ne 0 ] && echo "Required packages: $DEPS" 
[ $ERROR -ne 0 ] && exit 1

SECT_SZ=512
ROOT_DEV=''
HOOK_BUILD_FLAG=0

function run_hooks() {
    if [ $HOOK_BUILD_FLAG -eq 0 ]; then
        # BUILD CURRENT HOOKS COLLECTION
        if [ -e "$HOOK_BUILD_DIR" ]; then
            sudo rm -fr "$HOOK_BUILD_DIR"
        fi
        sudo mkdir "$HOOK_BUILD_DIR"
        sudo chmod 1777 "$HOOK_BUILD_DIR"
        for hooktype in pre-mkinitcpio pre-install install post-install ; do
            mkdir "$HOOK_BUILD_DIR/$hooktype"
        done
        for PROFILE in $PROFILES; do
            step2 " ===> profile $PROFILE"
            for stage in "hooks/$PROFILE/"* 
            do
                sstage=${stage#*/}
                sstage=${sstage#*/}
                for hook in $stage/*;
                do
                    cp "./$stage/$(basename $hook)" "$HOOK_BUILD_DIR/$sstage/"
                done
            done
        done
        HOOK_BUILD_FLAG=1
    fi

    sudo arch-chroot "$R" /resources/chroot_installer "$1"
}

function reset_rootfs() {
    step "Clear old rootfs"
    sudo rm -fr "$R" 2> /dev/null
    sudo mkdir "$R" 2> /dev/null
}

function base_install() {
    # TODO configuration step
    step "Installing base packages & patch root files"
    sudo cp onelinelog.py "$R/onelinelog.py"
    # install packages
    sudo pacstrap -cd "$R" base python sudo geoip gcc-libs-multilib gcc-multilib base-devel yajl git expac perl # base-devel & next are needed to build cower, needed by pacaur
    sudo chown root.root "$R"
    sudo cp -r strapfuncs.sh configuration.sh onelinelog.py resources  distrib/$DISTRIB.sh "$R"
}

function reconfigure() {
    step "Re-generating RAMFS and low-level config" 
    CHROOT='' run_hooks pre-mkinitcpio
    sudo arch-chroot "$R" mkinitcpio -p linux
}

function run_install_hooks() {
    HOOK_BUILD_DIR="$R/$HOOK_BUILD_FOLDER"
    (sudo cp -r strapfuncs.sh configuration.sh onelinelog.py resources distrib/$DISTRIB.sh "$R")
    if [ -e my_conf.sh ] ; then
        sudo cp my_conf.sh "$R"
    fi
    sudo rm -fr "$HOOK_BUILD_DIR" 2> /dev/null
    step "Installing pacman hooks"
    sudo mkdir -p "$R/etc/pacman.d/hooks"
    sudo cp -r resources/pacmanhooks "$R/etc/pacman.d/hooks"
    step "Triggering install hooks"
    run_hooks pre-install
    echo "################################################################################"
    echo "$_net_mgr"
    run_hooks install
    if [ -n "$DISTRO_PACKAGE_LIST" ]; then
        step2 "Distribution packages"
        install_pkg $DISTRO_PACKAGE_LIST
    fi

    install_extra_packages

    distro_install_hook
    sudo systemctl --root ROOT set-default ${BOOT_TARGET}.target
    run_hooks post-install
    (cd "$R" && sudo rm -fr strapfuncs.sh configuration.sh onelinelog.py resources $DISTRIB.sh)
    if [ -e my_conf.sh ] ; then
        sudo rm "$R/my_conf.sh"
    fi
    sudo mv "$R/stdout.log" .
}

function install_extra_packages() {
    step2 "Extra packages"
    sudo cp -r extra_packages "$R"
    return
    if [ -e "extra_packages/dependencies.txt" ]; then
        sudo pacman -r "$R" -S --needed --noconfirm $(cat extra_packages/dependencies.txt)
    else
        echo "No extra packages dependencies declared"
    fi
    if [ -z "$NO_EXTRA_PACKAGES" ] && ls extra_packages/*pkg.tar* >/dev/null 2>&1 ; then
        sudo pacman -r "$R" -U --needed --noconfirm extra_packages/*pkg.tar*
    fi
    sudo rm -fr "$R/extra_packages"
}

function make_squash_root() {
    step "Cleaning FS & building SQUASHFS ($COMPRESSION_TYPE)"
    IF=../ignored.files
    pushd "$R" >/dev/null || exit -2
        sudo find boot/ | sed 1d > $IF
        sudo find var/cache/ | sed 1d >> $IF
        sudo find run/ | sed 1d >> $IF
        sudo find var/run/ -type f >> $IF
        sudo find var/log/ -type f >> $IF

        sudo find proc/ | sed 1d >> $IF
        sudo find sys/ | sed 1d >> $IF
        sudo find dev/ -type f >> $IF

        if [ ! -d ".$LIVE_SYSTEM" ]; then
            sudo mkdir ".$LIVE_SYSTEM"
        fi

        SQ_OPTS="-no-exports -noappend -no-recovery"
        if [ -n "$NOCOMPRESS" ]; then
            sudo mksquashfs . "$SQ" -ef $IF  -noI -noD -noF -noX $SQ_OPTS
        else
            if [ "$COMPRESSION_TYPE" = "xz" ]; then
                sudo mksquashfs . "$SQ" -ef $IF -comp xz   $SQ_OPTS -b 1M  -Xdict-size '100%'
            else # gz == gzip
                sudo mksquashfs . "$SQ" -ef $IF -comp gzip $SQ_OPTS -b 1M
            fi
        fi  
    popd > /dev/null
    sudo rm ignored.files
}

function mount_part0() {
    OFFSET=$(($SECT_SZ * $(get_part_offset "$D" boot) ))
    LO_DEV=$(sudo losetup -o "$OFFSET" --show -f "$D")

    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr "$T" 2> /dev/null
    sudo mkdir "$T"
    sudo mount "$LO_DEV" "$T"
}

function umount_part0() {
    sudo umount "./$T"
    sudo rmdir "$T"
    sudo sudo losetup -d "$LO_DEV"
}

function mount_root_from_image() {
    mount_part0
    echo "Mounted in $T, ^D to leave "
    cd "$T"
        $SHELL
    cd ..
    umount_part0
}

function get_part_offset() {
    _DISK="$1"
    _IS_BOOT="$2"
    if [ -z "$_IS_BOOT" ]; then
        _GREP='-v'
    fi
    fdisk -lu $_DISK | grep ^$_DISK | grep $_GREP '*' | sed 's/*/ /' | awk '{print $2}'
}

function make_disk_image() {
    # computed disk size, in MB
    # copy extra files to /boot
    if [ -n "$LIVE_SYSTEM" ]; then
        sudo cp -r extra_files/* "$R/boot/" 2>/dev/null || echo "No extra files to install"
    fi

    if [ $DISK_TOTAL_SIZE ] ; then
        rsize=${DISK_TOTAL_SIZE}000
    else
        sqsize=$(( $(filesize $ROOTNAME) / 1000 / 1000 ))
        rsize=$(( $sqsize + $DISK_MARGIN + $BOOT_MARGIN ))
    fi
    # FORCE SQUASH SIZE as in installer:
    sqsize=3500
    echo "Creating disk image of ${rsize}MB"
    dd if=/dev/zero of="$D" bs=1MB count=$rsize

    step2 "Building persistent filesystem"
    MPT="$WORKDIR/.storage_mnt_pt"
    mkdir "$MPT"
    mkdir "$MPT/ROOT"
    mkdir "$MPT/WORK"
    sudo cp -ra "$R/home" "$MPT/ROOT" # pre-populate HOME // default settings
    
    pushd "$MPT"
        sudo tar cf - . | ${COMPRESSION_TYPE} -9 > ../rootfs.default
        sudo mv ../rootfs.default $R/boot/
    popd > /dev/null
    sudo rm -fr "$MPT"

    sudo ROOT_TYPE="$ROOT_TYPE" DISKLABEL="ARCHINST" ./resources/installer-standard.sh "$D" $BOOT_MARGIN "$SQ"
    sudo pacman -r "$R" -Qtt | sort > $DISTRIB-pkglist.txt
}

# MAIN

PARAM="$1"

if [ -z "$PARAM" ]; then
    if [ ! -d "$R" ]; then
        PARAM="all"
    else
        PARAM="up"
    fi
fi

case "$PARAM" in
    run*)
        shift
        if [ -n "$EFI" ]; then
            BIOSDRIVE="-drive file=/usr/share/ovmf/ovmf_x64.bin,format=raw,if=pflash,readonly"
        else
            BIOSDRIVE=""
        fi
        echo qemu-system-x86_64 -m 1024 -enable-kvm $BIOSDRIVE -drive file=$D,format=raw $*
        exec qemu-system-x86_64 -m 1024 -enable-kvm $BIOSDRIVE -drive file=$D,format=raw $*
        # if GRUB is broken for you, try loading linux directly:
#        qemu-system-x86_64 -m 1024 -enable-kvm -drive file=$D,format=raw -kernel $R/boot/vmlinuz-linux -initrd $R/boot/initramfs-linux.img -append root=LABEL=$DISKLABEL
        exit
        ;;
    m*)
        mount_root_from_image
        ;;
	shell*)
        shift
		echo sudo arch-chroot "$R" $*
		sudo arch-chroot "$R" $*
		;;
	ins*)
		shift # pop the first argument
        install_pkg "$*"
		;;
    pkg)
        run_install_hooks
        ;;
    ex*)
        install_extra_packages
        ;;
    hook*)
        source "$1"
        ;;
    conf*)
        reconfigure
        make_disk_image
        ;;
    sq*):
        make_squash_root
        make_disk_image
        ;;
    d*)
        make_disk_image
        ;;
    reb*)
        reconfigure
        make_squash_root
        make_disk_image
        ;;
    up*)
        run_install_hooks
        make_squash_root
        make_disk_image
        ;;
    zip)
        (cd 3rdparty && ./get.sh)
        mkdir $DISKLABEL
        ln 3rdparty/* $DISKLABEL
        rm $DISKLABEL/get.sh
        ln "$D" $DISKLABEL/
        rm $DISKLABEL.zip 2>/dev/null
        zip -r4 $DISKLABEL.zip $DISKLABEL
        rm -fr $DISKLABEL
        ;;
    all*)
        reset_rootfs
        base_install
        reconfigure
        run_install_hooks
        if [ -n "$LIVE_SYSTEM" ]; then
            make_squash_root
            make_disk_image
        else
            echo "TODO: flash disk w/ grub"
        fi
        ;;
	*)
        echo "Usage: $0 <command> [options]"
        echo "Commands:"
        echo "       all: build the full system from scratch (RUN THIS FIRST - default if first run)"
        echo "       run: runs QEMU emulator"
        echo "        up: re-create rootfs after a manual update (default)"
        echo "     shell: start a shell"
        echo "   install: install some package (args = pacman args)"
#        echo "      conf: re-create intial ramdisk"
#        echo "    squash: re-create squash rootfs"
#        echo "      disk: re-create disk image from current squash & ramdisk"
        exit 0
esac
echo "Done"

