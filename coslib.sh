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
    else
        echo "Already built"
    fi
    sudo arch-chroot "$R" /resources/chroot_installer "$1"
}

function make_squashfs {
    filename=$1
    shift
    ignored=$1
    shift
    # other arguments get passed to mksquashfs

    SQ_OPTS="-no-exports -noappend -no-recovery"
    if [ -z "$COMPRESSION_TYPE" ]; then
        $SUDO mksquashfs . "$filename" -ef $ignored  -noI -noD -noF -noX $SQ_OPTS $*
    else
        if [ "$COMPRESSION_TYPE" = "xz" ]; then
            COMP="xz -Xdict-size 100%"
        elif [ "$COMPRESSION_TYPE" = "zstd" ]; then
            COMP="zstd -Xcompression-level 19"
        else # gz == gzip
            COMP="gzip"
        fi
        $SUDO mksquashfs . "$filename" -ef $ignored -comp $COMP $SQ_OPTS -b 1M $*
    fi
}
