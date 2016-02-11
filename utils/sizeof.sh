#!/bin/dash
export LC_ALL=C


get_size() {
    PKG=$1
    case $PKG in
        pam*|glib*|gcc*|None|libx11|filesystem|gnutls|bash|binutils)
        echo "0"
        return
    esac
    if pacman -${TYPE}i "$1" >/dev/null; then
        s=$(pacman -${TYPE}i "$PKG" | sed -e '/.*Installed Size/b ok ; d ;:ok s/.*: // ; s/MiB/* 1024/ ; s/KiB// ; s/[.][0-9]\+// ; s/.*B/1/')
        echo "$PKG: $(( $s / 1024 )) MiB" >&2
        echo $(( $s ))
    else
        echo "0"
    fi
}
get_deps() {
    pacman -${TYPE}i $* | sed -e '/^Depends On/b ok; d ; :ok s/.* : // ; s/[<>=][=.0-9-]\+//g' 2>/dev/null
}

compute_usage() {
    progs="$*"
    deps=$(get_deps $progs)
    echo "Getting deps for $deps..." >&2
    for dep in $deps; do
        progs="$progs $(get_deps $dep)"
    done
    progs=$(echo $progs | sed -e 's/ /\n/g' | sed 's/[.]so$//' | sort | uniq) # uniq

    total=0 # in KiB
    for p in $progs ; do
        total=$(( $total + $(get_size $p) ))
    done
    echo "$(( $total / 1024 )) MiB"
}

if [ pacman -Qq $* 2>/dev/null ]; then
    TYPE="Q" # S=remote, Q=local
else
    TYPE="S" # S=remote, Q=local
fi

compute_usage $*
