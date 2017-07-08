#!/usr/bin/env sh
set -e

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
# vars:

# function make_squash_root() {
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
#}

