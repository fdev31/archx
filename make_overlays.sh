source ./strapfuncs.sh
source ./coslib.sh

REAL="$_ORIG_ROOT_FOLDER"

work=tmp_workdir
overlay=tmp_overlay

envname=$1

SQ_OPTS="-no-exports -noappend -no-recovery"

function squash() {
    name=$1
    rm -fr ../${name}.sq
    t=$(mktemp)
    cat > $t <<EOF
stdout.log
home
home/*
boot/
boot/*
.installed_hooks
.installed_hooks/*
resources
resources/*
etc/sudoers.d
etc/sudoers.d/*
var/cache
var/cache/*
var/log
var/log/*
tmp
tmp/*
EOF
    mv $t /tmp/blacklist
    rm -fr ../${name}.sq || true
    make_squashfs "../${name}.sq" "/tmp/blacklist" -wildcards
}

$SUDO cp -r resources/ configuration.sh ./distrib/${DISTRIB}.sh my_conf.sh "$REAL/"
$SUDO chmod 666 "$REAL/my_conf.sh"
#[ ! -d "$REAL/var/cache/pikaur" ] && $SUDO mkdir "$REAL/var/cache/pikaur" || true

if [ -z "$envname" ]; then
    environments=$(ls -1 envs/*)
    autoexec="/inst.sh"
else
    environments=$envname
    autoexec=
fi

for envname in $environments ; do
    step "Building environment package --> $envname"

    $SUDO rm -fr $work
    $SUDO rm -fr $overlay

    mkdir $work
    mkdir $overlay

    $SUDO cp strapfuncs.sh "$REAL/inst.sh"
    $SUDO chmod 777 "$REAL/inst.sh"
    cat $envname >> "$REAL/inst.sh"

    $SUDO mount none -t overlay -o "workdir=$work,lowerdir=$REAL,upperdir=${overlay}" "$R"

    install_file  resources/sudo_conf_nopass "/etc/sudoers.d/50_nopassword"
    [ -z "$autoexec" ] && echo "Install the required packages, then exit:"
    ($SUDO arch-chroot "$R" $autoexec || true)
    echo "Building $envname disk..."
    $SUDO rm -fr "$R/var/cache/pacman/pkg/"* || true
    $SUDO rm -fr "$R/etc/sudoers.d/50_nopassword" || true
    ./cos-makesquash.sh
    ./cos-makedisk.sh
    mv ARCHX.img ARCHX-${envname:5}.img
    $SUDO umount "$R"
    (cd $overlay && squash env-${envname#*/} )
done

