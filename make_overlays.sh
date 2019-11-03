source ./strapfuncs.sh

REAL="real_ROOT"

work=tmp_workdir
overlay=tmp_overlay

SQ_OPTS="-no-exports -noappend -no-recovery"

function squash() {
    name=$1
    rm -fr ../${name}.sq
    mksquashfs . ../${name}.sq -comp xz $SQ_OPTS -b 1M  -Xdict-size '100%'
}

$SUDO cp -r resources/ configuration.sh ./distrib/${DISTRIB}.sh my_conf.sh "$REAL/"
$SUDO chmod 666 "$REAL/my_conf.sh"
$SUDO mkdir -f "$REAL/var/cache/pikaur"


for envname in envs/* ; do
    echo "===> $envname"

    $SUDO rm -fr $work
    $SUDO rm -fr $overlay

    mkdir $work
    mkdir $overlay

    $SUDO cp strapfuncs.sh "$REAL/inst.sh"
    $SUDO chmod 777 "$REAL/inst.sh"
    cat $envname >> "$REAL/inst.sh"

    $SUDO mount none -t overlay -o "workdir=$work,lowerdir=$REAL,upperdir=${overlay}" "$R"

    install_file  resources/sudo_conf_nopass "/etc/sudoers.d/50_nopassword"
    echo "Install the required packages, then exit:"
    ($SUDO arch-chroot "$R" || true)
    echo "Packaging..."
    $SUDO umount "$R"
    $SUDO rm -fr "$overlay/var/cache/pacman/pkg/"*
    $SUDO rm -fr "$overlay/etc/sudoers.d/50_nopassword"
    (cd $overlay && squash env-${envname#*/} )
done

