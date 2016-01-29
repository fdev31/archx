# Arch movable root builder

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

## TODO

- i18n at build time

- propose ways to keep persistent data (/etc & /home ?)
    - Existing partition
    - Compressed loopback FS in FAT partition

- propose a way to save current session (/usr etc...) in the base filesystem

- "Profiles" including package sets

- UI to select packages

## How it works ?

The main script *mkbootstrap.sh* just runs scripts in sequence.

Sequences are defined by profiles in the *hooks* directory, make your own profile to experiment, by executing *makeprofile.sh*

External resources are loaded from the *resources* folder

## Notice

This is alpha software: NEVER INTERRUPT THE SCRIPT WHILE RUNNING !!

I am open to contributions
