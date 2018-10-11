# ArchX

## Intro

THIS PROJECT IS NOT SUPPORTED BY ARCHLINUX OR ANY OTHER COMMUNITY THAN THE ONE USING THIS SOFTWARE.

Continue reading if:

- you want a **robust, full-featured, portable** desktop
- you want to **test** "out of the box" setup of most popular **Desktop environments**
- you are a **beginner** who wants to test an ArchLinux based system without complications
- you like to **play** with LFS, Gentoo, Arch, Slackware, and need a nice, **customizable, Live system**

Here is a brief description:

- **Archlinux** (almost unmodified) + some user contributed packages
- only **4GB** storage required (including persistent data)
- **EFI** and **BIOS** support
- **12GB of software**
    - photo touching
    - sound processing
    - 3D/2D design tools
    - desktop applications
    - standard network & developpment tools
    - MATE by default (awesome also included)

## Features

- Easy to maintain "live" image **builder for ArchLinux**
- Easy **installer for ArchLinux** including with non-destructive option
- **Pre-configuration** for most elementary parts
- **Multi-lingual** with minimal effort to add a country support
- **Unmodifed** you have all the manpages, translations & co
- Installable on **pen drives** or standard hard drives
- **Storage & installation** of apps possible even in "live" mode
- Can be run from windows withe Qemu, vmware or Virtualbox
- Unmodified system **can be restored** if things get broke
- Failsafe install with **"rollback" option** [WIP]
- Fast - maybe the **fastest Linux** installer on earth
- Small - the live system usually takes less than **30% of the original size**

Here is a list of [Open issues](bugs.rst)


### Minimal configuration

- intel i3 CPU / probably any 64 bits CPU
- 1GB RAM
- 2GB disk space (for *noobs* distribution, 4GB for bigger distributions, take more if you plan to store documents)

#### Notes

- there is a huge performance boost on USB3 when running from pen drive
- size may vary from one build to another, the space reserved for software is 3.5GB

## Why ?

Because I wanted like to make custom distributions using ArchLinux, mainly for two purposes:

- **Portable desktop**: ArchLinux "on the go" with a fullfeatured desktop environment & set of apps
- **Sharing**: Shows nice applications & makes ArchLinux easier to get into for noobs
- **Experimenting**: Having a sandbox to test configurations or applications
- **Desktop environments testing**: Be able to easily switch from DE to DE quickly to compare them, without bloating my own system

Also, I might target in the future:

- Super simplified desktop environment for elder people or kids
- Graphical installer (currently using curses only)
- Better desktop and apps selection by default

## Status

Currently WIP, but starts to be usable.

Target installation modes include:

### Full disk

Takes over an entire disk with a modified Linux system.

Mainly useful to duplicate ArchX on a removable device.


*Advantages:* The system can be restored almost instantly without sacrificing your disk space


### Embed into existing partition

Copies files to your disk and allow you to run Linux without an emulator

Mainly useful to people not able to apply changes to the disk configuration, with no root/admin access on a machine

*Advantages:* Have the advantages of *Full disk* installation + don't erase any data from your (possibly Windows) disk

### Vanilla Archlinux

Takes over an entire disk with an unmodified but pre-installed ArchLinux system.

For people having a spare disk to install Archlinux on and want to take all advantages of a pre-configured Linux system and without complex installation process.

*Advantages*: Just installs an ArchLinux on your drive, so go to http://archlinux.org and enter a wonderful world !


## Available Desktop environments

From the most RAM consuming to the lightest:

- *cinnamon* - very heavy
- *gnome3* - very heavy
- *gnome3-classique* - quite heavy
- *plasma* - medium
- *xfce* - light
- *mate* - lighter

Note that **kodi** requires as little as **mate**


## Quickstart for users (TODO)

### Installation

#### Linux

    dd if=[downloaded image] of=/dev/usbstick bs=100M

#### Windows

Install https://rufus.akeo.ie/ and run it

TODO: steps

#### Secure Boot

If you have SecureBoot enabled, a popup will show on first boot.
Just select

**Enroll Hash** then **loader.efi**, **yes**, **exit**

It's only needed once.

## Quickstart for developers

- install arch-install-scripts

Get some basic help:

    make help

Generate a bootable disk image:

    make

To install packages or make 
Add some software (eg. vim) and regenerate disk image:

    sudo arch-chroot ROOT 
    <do some modifications, install packages, etc...>
    ^D
    touch hooks.flag
    make

Install it to USB stick/drive:

    dd if=ARCHX.img of=/dev/sd??

### Instructions

You can run the **reconfigure.sh** scripts, it will ask a few questions (or much more if you chose *custom*):

    % ./reconfigure.sh
     1 - custom
     2 - basic
     3 - cinnamon
     4 - full
     5 - gnome
     6 - plasma
    What distrib do you chose: 5
    Name for this distro (only ascii, no spaces): GNOMELIVE
    User id/login: toto
    Password: otot

Then follow the *Quickstart* instructions to build the OS image.

### Configuration example

Build a console distribution in german language with gzip compression:

Write a `my_conf.sh` file with this content:

    DISTRIB=console
    COMPRESSION_TYPE=gzip
    COUNTRY=DE

Then, build from scratch:

    % rm -fr ROOT
    % make

### Custom ArchLinux partitionning

- Prepare your partitions using cfdisk, parted, fdisk or gparted if you are running a graphical session
- Mount your partitions according to desired layout somewhere (ie. **/mnt**), then type:

    sudo installer-archlinux.sh /mnt

## TODO

- Share disk images for each distrib (stacked rootfs)
- More flexible partition schemes

### Maybe

- expert install mode allowing custom disk setup

## How it works ?

Look at the targets in the *Makefile*, the scripts are called ``cos-*.sh`` in the root of the repository.

Sequences are defined by profiles in the *hooks* directory, make your own profile to experiment, by executing *makeprofile.sh*

External resources are loaded from the *resources* folder

## Notice

This is alpha software: NEVER INTERRUPT THE SCRIPT WHILE RUNNING !!

I am open to contributions of course (translations, fixes, etc...)

### Known bugs

- gnome keyboard set to US at first boot even if locale available
