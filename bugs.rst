Tickets
=======

:total-count: 9

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

automatic sudo pacman -Rns $(pacman -Qtdq) sometimes
====================================================

:bugid: 2
:created: 2017-06-03T01:32:37
:priority: 0

--------------------------------------------------------------------------------

automatic cleaning of caches etc...
===================================

:bugid: 3
:created: 2017-06-03T01:33:25
:priority: 0

folders that are filling should be flushed from time to time

--------------------------------------------------------------------------------

Safer installer
===============

:bugid: 4
:created: 2017-06-03T01:33:59
:priority: 0

look at /.diskusage in installer to check available space after mounting

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

read usr/share/applications/*.desktop & generate menus for awesome
==================================================================

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
