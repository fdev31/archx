#!/bin/python

import os
import math
import pprint
import subprocess
from os.path import join as joinp , getsize

def runcmd(*a, **kw):
    return subprocess.check_output(*a, **kw)

# py3 compat'
try:
    raw_input
except NameError:
    raw_input = input

def optimistic_number(n):
    try:
        ip = 10 * (str(n).index('.') -1 )
    except ValueError: # integer
        ip = 10 * (len(n) - 1 )

    return math.ceil(int(n) / ip) * ip

class Unit:
    def __init__(self, value):
        self.value = int(value)

    def __repr__(self):
        kib = 0
        kb  = 0
        units = iter('kMGTPEZY')
        index = 0
        v = self.value
        vi = self.value
        while v > 2400:
            next(units)
            vi /= 1024
            v /= 1000
        u = next(units)
        return '%d%sB'%(optimistic_number(v), u)


class O:
    def __init__(self, **kw):
        self.__dict__.update(kw)

    def __repr__(self):
        if not hasattr(self, 'uuid'):
            return pprint.pformat(self.__dict__)
        return """%(label)s %(fstype)s (%(size)s)"""%dict(
#        name   = self.devname,
#        uuid   = self.uuid,
        fstype = getattr(self, 'type', '- not found -'),
#        ptype  = getattr(self, 'part_type', 'N/A'),
        label  = getattr(self, 'label', 'NONE'),
        size   = getattr(self, 'size', 0.0),
        )

class Installer:
    _parts = {}
    _disks = {}
    info = O()
    info.boot_part_size = 0

    TGT = '/mnt/install_target'
    MODZ = "normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp ext2 btrfs xfs"

    def __init__(self):
        # Detect live boot devicea
        for line in runcmd(['mount']).split(b'\n'):
            if b' /boot ' in line:
                self.info.boot_partition = line.split(None, 1)[0].decode()
                self.info.boot_device = self.info.boot_partition[:-1]
                break

        # Compute required size
        for root, files, dirs in os.walk('/boot'):
            self.info.boot_part_size += sum(getsize(joinp(root, name)) for name in files)

        # Detect devices
        global cur_part
        cur_part = O()
        out = runcmd(['blkid', '-o', 'export'])
        for line in out.split(b'\n'):
            if not line.strip(): # empty line = new device
                if cur_part.type in ('iso9660', 'squashfs'):
                    cur_part.ro = True
                self._parts[cur_part.devname] = cur_part
                cur_part = O()
            else:
                k, v = line.split(b'=')
                setattr(cur_part, k.lower().decode(), v.decode())
        del cur_part

        try:
            self.DISKLABEL = self._parts[self.info.boot_device].label
        except:
            self.DISKLABEL = 'DONOTCHANGE'

        self._parts_size = {}
        for line in open('/proc/partitions', encoding='ascii'):
            if not line.strip() or line[0] not in ' \t':
                continue
            x = line.split()
            self._parts_size[x[-1]] = Unit(x[-2])
        self._list_disks()

    def _get_dev_info(self, devname, what='size'):
        if '/' in devname:
            devname = devname.split('/')[-1]
        if what == 'size':
            return self._parts_size[devname]
        else:
            return open('/sys/class/block/%s/%s'%(devname, what), encoding='ascii').read().strip()

    def _list_disks(self):
        import re
        rex = re.compile('([^0-9]+)[0-9]+')
        drives = set( rex.match(x).groups()[0] for x in self._parts )
        for drive in drives:
            try:
                self._disks[drive] = O(
                        size  = self._get_dev_info(drive),
                        label = "[%s] %s"%(self._get_dev_info(drive, 'device/vendor'), self._get_dev_info(drive, 'device/model'))
                        )
            except KeyError as e:
                pass
#                print("E(%s): %s"%(drive, e))
        # cleanup parts
        for part in list(self._parts):
            if not any(part.startswith(x) for x in self._disks):
                del self._parts[part]

        # compute size for partitions as well
        for part in self._parts:
            self._parts[part].size = self._get_dev_info(part)

    def get_partitions(self, disk):
        if not '/' in disk:
            disk = '/dev/'+disk
        p = []
        for part in sorted(self._parts):
            if part.startswith(disk):
                d = self._parts[part]
                d.disk = disk
                p.append( d )
        return p

    def mkfs(self, drive, label, fmt='fat'):
        if fmt == 'fat':
            runcmd(['mkdosfs', '-F', '32', '-n', label, drive])
        else:
            if fmt.startswith('ext'):
                opts = ['-F']
            else:
                opts = ['-f']
            runcmd(['mkfs.'+fmt, '-L', label] + opts + [drive])

    def mount_and_fullcopy(self, device, where, disk):
        if not '/' in device:
            device = '/dev/'+device
        if not '/' in disk:
            disk = '/dev/'+disk
        runcmd(['mount', device, where])
        runcmd(['cp', '-ar', '/boot/.', where])
        runcmd(['grub-install', '--target', 'x86_64-efi', '--modules', self.MODZ, '--efi-directory', where, disk])
        runcmd(['grub-install', '--target', 'i386-pc',    '--modules', self.MODZ, '--efi-directory', where, disk])

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
            drive = choices[0][0]
        return drive

    def select_partition(self, min_size=0):
        # TODO: mount parts to really know available size
        choices = [ (str(i+1), str(p)) for i,p in enumerate(self.get_partitions(drive)) if p.size.value > min_size]

        if len(choices) > 1:
            partno = UI.menu("Select the partition", "", choices)
        else:
            partno = choices[0][0]

        if not partno: raise SystemExit()
        return partno

    # Instalation modes:

    def install_manual(self):
        pass

    def install_compact(self):
        drive = self.select_disk(2500000)
        runcmd(['dd', 'if=/dev/zero', 'of=/dev/'+drive, 'bs=512', 'count=1'])
        print(self.info.boot_part_size)
#        self.make_partition(1, self.info.boot_part_size * 2.5, boot=True)
#        self.mkfs(drive, self.DISKLABEL)
#        self.mount_and_fullcopy(drive+'1', self.TGT, drive)

    def install_standard(self):
        pass

    def embed_compact(self):
        # DONE
        drive = self.select_disk(2500000)
        partno = self.select_partition(2500000)
        self.mount_and_fullcopy(drive+partno, self.TGT, drive)

    def w_fdisk(self):
        return subprocess.check_output(['fdisk', self.info.install_disk])

global UI

class UI:
    def __init__(self):
        from dialog import Dialog
        self.d = Dialog()
        self.w=0
        self.h=0

    def menu(self, title, subtitle, choices):
        return self.d.menu( subtitle, title=title, choices=choices, width=self.w, height=self.h)[1]


if __name__ == '__main__':
    UI = UI()
    I = Installer()

    tag = UI.menu("Select the installation modes",
            "All modes are installing the same application set",
        choices=[
            ('1', 'Safe install or upgrade (can be uninstalled, SAFE for data)'),
            ('2', 'Use entire disk, 2GB+ needed (RECOMMENDED)'),
            ('3', 'Use entire disk, 10GB+ needed (ARCHLINUX with all packages)'),
            ('4', 'Manual (EXPERTS)'),
            ]
        )

    if tag:
        mode = [I.embed_compact, I.install_compact, I.install_standard, I.install_manual][int(tag)-1]
        mode()


    # DONE !
#    for part in I._parts:
#        print(I._parts[part])
