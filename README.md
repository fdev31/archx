# A4D (Arch for Dummies, say "afford")

U-AI

## Project

- "live" image builder for archlinux
- Graphical environments provided
- Installable on USB storages / keys
- Runnable with Qemu/vmware/etc
- Fast
- Configurable

### Minimal configuration

- intel i3 CPU / probably any 64 bits CPU
- 1GB RAM
- 2GB Hard drive or USB stick (USB3 is a huge boost)
    - A larger storages allows persistent settings & documents

## Why ?

Because ArchLinux is a pure, lean and fast distribution, fitting most opensource standards.
Unfortunately it's not accessible for general users that just want to browse on the web,
write documents, print, scan, etc...
A4D aims at providing a smooth experience for unexperimented users,
providing latest versions of popular graphical environments, allowing "real/normal" people to
use this amazing opensource operating system.


## Quickstart

Get some basic help:

    ./mkbootstrap.sh help 

Generate a bootable disk image:

    ./mkbootstrap.sh

Add some software (eg. vim) and regenerate disk image:

    ./mkbootstrap.sh install vim
    ./mkbootstrap.sh

Run it using qemu:

    ./mkbootstrap.sh run

Install it to USB stick/drive with FAT partition (eg. sde1):

    ./mkbootstrap.sh flash /dev/sde1

## Instructions

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

## TODO

- i18n at build time

- propose ways to keep persistent data (/etc & /home ?)
    - Existing partition
    - Compressed loopback FS in FAT partition

- propose a way to save current session (/usr etc...) in the base filesystem

- "Profiles" including package sets

- UI to select packages / installer (file or drive)

- share disk images with popular desktop environments

### Maybe

- installation on windows drive

This is already possible manually:

- Create a bootable USB stick of A4D using USBWriter for instance

## How it works ?

The main script *mkbootstrap.sh* just runs scripts in sequence.

Sequences are defined by profiles in the *hooks* directory, make your own profile to experiment, by executing *makeprofile.sh*

External resources are loaded from the *resources* folder

## Notice

This is alpha software: NEVER INTERRUPT THE SCRIPT WHILE RUNNING !!

I am open to contributions


##### UI

[ Install ]
    [ USB ]
        [CHOICES]
    [ DISK]
        [CHOICES]

[Trigger upgrade]
    - check if already here, propose reboot
