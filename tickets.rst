Tickets
=======

:total-count: 26

--------------------------------------------------------------------------------

Better EFI handling
===================

:bugid: 0
:created: 2017-06-03T01:31:31
:priority: 0

- detect EFI partition
- be able to format with GPT scheme

ex::

    DISK=$1
    SEC_SIZE=$(sgdisk -F)

    sgdisk -Z $DISK # zap
    sgdisk -og $DISK
    END_SECTOR=$(sgdisk -E $DISK)
    sgdisk -n 1:$SEC_SIZE:+10M -c 1:"BIOS Boot Partition" -t 1:ef02 $DISK
    sgdisk -n 2:+0:+100M       -c 2:"EFI System Partition" -t 2:ef00 $DISK
    sgdisk -n 3:+0:$END_SECTOR -c 3:"Linux" -t 3:8300 $DISK

--------------------------------------------------------------------------------

some pacman keys update tricks
==============================

:bugid: 1
:created: 2017-06-03T01:32:20
:priority: 0

--------------------------------------------------------------------------------

check if ldconfig trick must be undone for real install
=======================================================

:bugid: 5
:created: 2017-06-03T01:34:21
:priority: 0

--------------------------------------------------------------------------------

check ~/.cache  is in tmpfs
===========================

:bugid: 6
:created: 2017-06-03T01:34:32
:priority: 0

--------------------------------------------------------------------------------

read usr/share/applications/\*.desktop & generate menus for awesome
===================================================================

:bugid: 7
:created: 2017-06-03T01:34:46
:priority: 0

--------------------------------------------------------------------------------

Include some useful tools
=========================

:bugid: 8
:created: 2017-06-03T01:36:46
:priority: 0

One could add

- qemu
- rufus ( https://rufus.akeo.ie/ )

A zip file with all tools + img file would be fine

--------------------------------------------------------------------------------

Check mirror.conf (pacman)
==========================

:bugid: 9
:created: 2017-06-30T21:51:42
:priority: 0

Looks the same as my computer
should be the result of something like:

   reflector --age 12 --latest 5 --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist

--------------------------------------------------------------------------------

Package manager GUI should be installed only with squash-free installations
===========================================================================

:bugid: 18
:created: 2017-07-09T04:04:49
:priority: 0

Relationale
    It's good to not make user make updates himself
    . updates will be provided as atomic squash image.
    Those updates should cancel apps installed by user.

--------------------------------------------------------------------------------

No big update
=============

:bugid: 19
:created: 2017-07-09T04:06:15
:priority: 0

Now one could update the system by just downloading a fresh squash image into the data partition.

--------------------------------------------------------------------------------

Shortcut should be provided to extend data partition
====================================================

:bugid: 20
:created: 2017-07-09T04:06:36
:priority: 0

--------------------------------------------------------------------------------

Option should be provided to allow external ntfs (or fat ?) partition for home's folders
========================================================================================

:bugid: 21
:created: 2017-07-09T04:07:20
:priority: 0

--------------------------------------------------------------------------------

clean /usr/share/locale/
========================

:bugid: 24
:created: 2019-04-19T00:47:59
:priority: 0

As a post install hook

--------------------------------------------------------------------------------

Install some extra packages for envs
====================================

:bugid: 26
:created: 2019-11-20T23:26:27
:priority: 0


- plank

--------------------------------------------------------------------------------

rm: cannot remove '11-*lcdfilter*': No such file or directory
=============================================================

:bugid: 15
:created: 2017-07-08T02:49:06
:priority: 10


This has to be fixed :)

--------------------------------------------------------------------------------

provide high-level chroot command
=================================

:bugid: 23
:created: 2019-04-17T23:11:10
:priority: 10

allowing to not chroot when it's already in the chroot (R=".")

--------------------------------------------------------------------------------

Code cleanup / better safety
============================

:bugid: 25
:created: 2019-11-18T23:19:45
:prio: 10
:priority: 10

Split the codde shared
- stop making strapfuncs usage in cos-*
- simplify strapfuncs.sh

allow the host code to be something else than .sh (eg: python)
