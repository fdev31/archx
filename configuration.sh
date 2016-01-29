DISKLABEL="ARCHX"

PROFILE="default" # minimal, multi-env or default

PREFERRED_TOOLKIT="gtk" # or "qt" , keep LOWERCASE !

PASSWORD="plop"

# Advanced users only:

DISK_MARGIN=1 # in megabytes
DEFAULT_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel"
ADMIN_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel,adm,tty,log,sys,daemon"
R="$PWD/ROOT"
D="diskimage.raw"
SQ="rootfs.s"
