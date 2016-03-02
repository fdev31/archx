#!/bin/python

import os
import sys
import math
import pprint
import subprocess
from os.path import join as joinp , getsize

class NoPartFound(Exception): pass

def runcmd(*a, stdin=None, err=False):
    p = subprocess.Popen(*a, bufsize=1, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=(None if err else subprocess.PIPE))
    if isinstance(stdin, str):
        stdin = stdin.encode('utf-8')
    t = p.communicate(stdin)
    return t[0]

def optimistic_number(n):
    try:
        ip = 10 * (str(n).index('.') -1 )
    except ValueError: # integer
        ip = 10 * (len(n) - 1 )

    if ip:
        return math.ceil(int(n) / ip) * ip
    else:
        return n

class Unit:
    def __init__(self, value):
        self.value = int(value)

    def human(self, use_kib=False, suffix='B'):
        units = iter('okMGTPEZY')
        dec = 1024 if use_kib else 1000
        th = 2.5*dec
        index = 0
        v = self.value
        while v > th:
            next(units)
            v /= dec
        u = next(units)
        if use_kib:
            u = u.upper()
        return '%d%s%s'%(optimistic_number(v), u, suffix)

    __repr__ = human

class O:
    def __init__(self, **kw):
        self.__dict__.update(kw)

    def __repr__(self):
        if not hasattr(self, 'uuid'):
            return pprint.pformat(self.__dict__)
        return """%(label)s %(fstype)s (%(size)s)"""%dict( fstype=getattr(self, 'type', '- not found -'),
                label=getattr(self, 'label', 'NONE'),
                size=getattr(self, 'size', 0.0))

class Installer:
    _parts = {}
    _disks = {}
    info = O()
    info.boot_part_size = 0

    USE_EFI = True
    TGT = '/mnt/install_target'
    MODZ = "normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp ext2 btrfs xfs jfs"

    def __init__(self):
        # Detect live boot devicea
        if not os.path.exists(self.TGT):
            os.mkdir(self.TGT)
        for line in runcmd(['mount']).split(b'\n'):
            if b' /boot ' in line:
                self.info.boot_partition = line.split(None, 1)[0].decode()
                self.info.boot_device = self.info.boot_partition[:-1]
                break

        # Compute required size
        for root, dirs, files in os.walk('/boot'):
            self.info.boot_part_size += sum(getsize(joinp(root, name)) for name in files)

        # List all partitions & store them in self.parts
        global cur_part
        cur_part = O()
        out = runcmd(['blkid', '-o', 'export'])
        for line in out.split(b'\n'):
            if not line.strip(): # empty line = new device
                if hasattr(cur_part, 'type') and cur_part.type in ('iso9660', 'squashfs', 'udf', 'cramfs'):
                    cur_part.ro = True
                self._parts[cur_part.devname] = cur_part
                cur_part = O()
            else:
                k, v = line.split(b'=')
                setattr(cur_part, k.lower().decode(), v.decode())

        self.DISKLABEL = self._parts[self.info.boot_partition].label

        self._list_disks()

    def _get_dev_info(self, devname, what='size'):
        if '/' in devname:
            devname = devname.split('/')[-1]
        val = open('/sys/class/block/%s/%s'%(devname, what), encoding='ascii').read().strip()
        if what == 'size':
            return int(val)*512 # convert blocks to bytes
        return val

    def _list_disks(self):
        import re
        rex = re.compile('.*/([^0-9]+)[0-9]+') # <letter><digits>
        dm_rex = re.compile(r'.*\[([^\s[]+)\].*') # blah blah [<drive>] blah blah
        drives = set( rex.match(x).groups()[0] for x in self._parts if not 'loop' in x)
        for line in runcmd('dmesg').split(b'\n'):
            if b'Attached SCSI' in line:
                removable = b'removable' in line # currently unused
                drives.add( dm_rex.match(line.decode('latin1')).groups()[0] )

        drives.discard(self.info.boot_device.split('/')[-1])
        for drive in drives:
            try:
                self._disks[drive] = O(
                        size  = Unit(self._get_dev_info(drive)),
                        label = "[%s] %s"%(self._get_dev_info(drive, 'device/vendor'), self._get_dev_info(drive, 'device/model'))
                        )
            except KeyError as e:
                pass
        # cleanup parts
        for part in list(self._parts):
            if not any(part.startswith(x) for x in self._disks):
                del self._parts[part]

        # compute size for partitions as well
        for part in self._parts:
            self._parts[part].size = self._get_dev_info(part)

    def get_partitions(self, disk, filter_ro=False):
        if not '/' in disk:
            disk = '/dev/'+disk
        p = []
        for part in sorted(self._parts):
            if part.startswith(disk):
                d = self._parts[part]
                if filter_ro and d.ro:
                    continue
                d.disk = disk
                p.append( d )
        return p

    def mkfs(self, drive, label, fmt='fat'):
        if not '/' in drive:
            drive = '/dev/'+drive
        if fmt == 'fat':
            runcmd(['mkdosfs', '-F', '32', '-n', label, drive])
        else:
            if fmt.startswith('ext'):
                opts = ['-F', '-L', label]
            elif fmt == 'reiserfs':
                opts = ['-L', label]
            elif fmt == 'jfs':
                opts = ['-l', label]
            else:
                opts = ['-f', '-L', label]
            runcmd(['mkfs.'+fmt] + opts + [drive])

    def mount_and_fullcopy(self, device, where, disk):
        if not '/' in device:
            device = '/dev/'+device
        if not '/' in disk:
            disk = '/dev/'+disk
        UI.message('Installing EFI bootloader')
        runcmd(['mount', device, where])
        runcmd(['grub-install', '--target', 'x86_64-efi', '--modules', self.MODZ, '--boot-directory', where, '--efi-directory', where])
        UI.message('Installing BIOS bootloader')
        runcmd(['grub-install', '--target', 'i386-pc',    '--modules', self.MODZ, '--boot-directory', where, disk])
        UI.message('Last settings...')
        runcmd(['cp', '-ar', '/boot/.', where]) # TODO: only copy needed files
        runcmd(['umount', where])

    def select_disk(self, min_size=0):
        choices = [(x.split('/')[-1], "%(size)s %(label)s"%dict(
                size=self._disks[x].size,
                label=self._disks[x].label,
                )) for x in sorted(self._disks) if self._disks[x].size.value > min_size] # skip devices < 2.5GB

        if len(choices) > 1:
            drive = UI.menu("Select the storage device", "", choices)
        elif not choices:
            print("No acceptable drive found")
            raise SystemExit()
        else:
            if not UI.confirm('Drive selected', '%s: %s'%tuple(choices[0])):
                raise SystemExit()
            drive = choices[0][0]
        return drive

    def select_partition(self, drive, min_size=0, show_ro=True):
        # TODO: mount parts to really know available size
        choices = [ (str(i+1), str(p)) for i,p in enumerate(self.get_partitions(drive, not show_ro))
                if p.size.value > min_size]

        if len(choices) > 1:
            partno = UI.menu("Select the partition", "", choices)
        elif not choices:
            raise NoPartFound()
        else:
            if not UI.confirm('Partition n°%s %s'%tuple(choices[0])):
                raise SystemExit()
            partno = choices[0][0]

        if not partno: raise SystemExit()
        return partno

    def make_partition(self, disk, partno, size=None, boot=False):
        suffix = 'a\n' if boot else ''
        if self.USE_EFI:
            suffix = "t\nef\n"+suffix
        pat = "n\np\n%(part)s\n\n%(size)s\n%(suffix)sw"%dict(
                part   = partno,
                size   = ('+%s'%size) if size else '',
                suffix = suffix
                )
        runcmd(['fdisk', '/dev/'+disk], stdin=pat)

    # Instalation modes:

    def install_manual(self):
        # Partition & mount everything under self.TGT & then run this
        pass

    def install_standard(self):
        pass

    def MENU_B_install_compact(self, drive=None):
        'Dedicate a disk (RECOMMENDED, requires an unused disk)'
        drive = drive or self.select_disk(2500000)
        UI.message('Preparing Disks')
        runcmd(['dd', 'if=/dev/zero', 'of=/dev/'+drive, 'bs=512', 'count=1'])
        self.make_partition(drive, 1,
                Unit(self.info.boot_part_size * 2.2).human(False, ''),
                boot=True)
        self.mkfs(drive+'1', self.DISKLABEL)
        self.MENU_A_embed_compact(drive, '1')
        return True

    def MENU_A_embed_compact(self, drive=None, partno=None):
        " Safe install or upgrade (can be uninstalled, SAFE for data) "
        drive = drive or self.select_disk(2500000)
        try:
            partno = partno or self.select_partition(drive, 2500000, show_ro=False)
        except NoPartFound:
            return self.MENU_B_install_compact(drive)
        else:
            self.mount_and_fullcopy(drive+partno, self.TGT, drive)
            return True

    def MENU_Z_exit(self):
        "Exit"
        raise SystemExit(0)

global UI

class UI:
    def __init__(self):
        from dialog import Dialog
        self.d = Dialog()
        self.w=0
        self.h=0

    def message(self, text, title=None):
        self.d.infobox( text )

    def menu(self, title, subtitle, choices):
        return self.d.menu( subtitle, title=title, choices=choices, width=self.w, height=self.h)[1]

    def confirm(self, title, question):
        return self.d.yesno(question, title=title, width=50, height=5)


#            ('4', '[TODO] Replace existing partition'),
#            ('4', '[TODO] Use empty space of some disk'),
#            ('5', '[TODO] Use entire disk, 10GB+ needed (ARCHLINUX with all packages)'),
#            ('6', '[TODO] Manual (EXPERTS)'),
UI = UI()

# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# Standard install
#  Partition schemes:
# - 6G [EFI 150% sqfs] => /boot
# - 6G [SQUASHFS / dd] => /
# - *  [EXT4] /
#    - if drive<10G: => /home
#    - if drive > 10G:
#        - separate partition for /home (direct mount)
#    - other "standard" paths in last partition
#
#  Erasing Removable partition schemes (autodetect removable):
# - 100M [EFI 100% sqfs] => /boot
# - 3G [SQUASHFS / dd] => /
# - *  [NTFS w/ loop EXT4] => overlay
#
# ====> on first boot, after creating xdg-folders, rm them & make symlinks from storage
#
#  Preserving Removable partition schemes (autodetect removable):
# - ~100M [EFI 100% sqfs] => /boot
# - <squashfs> => / (found in /boot/rootfs.s)
# - * [loopback EXT4 fs, from another partition if possible] => overlay
#
# Noob install (fully automatic, detects everything), not destructive
# - <existing EFI/DOS> => /boot
# - <squashfs> => / (found in /boot/rootfs.s or $(cat /boot/grub/rootfs.location)
# - <growable file storage> => $(cat /boot/grub/storage.location)
# ====> on first boot, after creating xdg-folders, rm them & make symlinks from storage

def main():
    I = Installer()
    choices = [getattr(I, x) for x in dir(I) if x.startswith('MENU_')]
    choices.sort(key=lambda x: x.__name__)
    tag = UI.menu("Select the installation modes",
            "All modes are installing the same application set",
            choices=( (str(o[0]+1), o[1].__doc__) for o in enumerate(choices) )
        )

    if tag:
        if choices[int(tag)-1]():
            print("Reboot computer and have fun !")

if __name__ == '__main__':
    main()

