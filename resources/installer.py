#!/bin/python
# TODO:
# - do something clever about EFI / boot partitions
# - add arch standard mode
# - base min-size on build-time information ( /.volume_size ?)

DEBUG=0

import os
import sys
import math
import json
import pprint
import gettext
import subprocess
from time import sleep
from os.path import join as joinp , getsize

gettext.install('installer')

def fake_trans():
    _('Install')

class DiskInfo:
    def __init__(self):
        self.refresh()

    def refresh(self):
        os.system('lsblk -blJ -o NAME,UUID,LABEL,PARTUUID,MOUNTPOINT,TYPE,FSTYPE,PARTFLAGS,RO,SIZE,STATE,VENDOR,TRAN,MODEL > /tmp/diskinfo.js')
        self.__info = json.load(open('/tmp/diskinfo.js'))
        self.efi = [] # efi partitions

        for d in self.devices:
            if 'size' in d:
                d['size'] = int(d['size'])

        for disk in self.disks:
            for num, line in enumerate(subprocess.check_output(['fdisk', '-l', '/dev/%(name)s'%disk], encoding='utf-8').split('\n')):
                if not line.startswith('/dev/'):
                    continue
                line = line.replace('*', ' ')
                p = line.split(None, 1)[0].split('/')[-1]
                t = line.split(None, 5)[-1]
                self.get(p)['parttype'] = t
                if 'EFI' in t:
                    self.efi.append(p)

        self.owndisk = self.get(mountpoint='/')['name'][:-1]
        self.squashfs = [line for line in open('/proc/mounts') if 'squashfs' in line][0].split()[0]

        if DEBUG:
            pprint.pprint(self.__info)
            print("Detected EFI in %s"%', '.join(self.efi))

    def get(self, name=None, mountpoint=None):
        if name:
            for dev in self.devices:
                if dev['name'] == name:
                    return dev
        else:
            for dev in self.devices:
                if dev['mountpoint'] == mountpoint:
                    return dev

    @property
    def devices(self):
        return self.__info['blockdevices']

    @property
    def disks(self):
        return [d for d in self.devices if d['type'] == 'disk']

    def get_partitions(self, disk):
        return [d for d in self.devices if d['type'] == 'part' and d['name'].startswith(disk)]


    def __repr__(self):
        ret = []
        for disk in self.disks:
            ret.append('%s disk (%s) %s'%(
                disk['tran'].upper(),
                Unit(disk['size']),
                disk['model'],
                ))
            for part in self.get_partitions(disk['name']):
                if part['name'] in self.efi:
                    ret.append(' - EFI BOOT SYSTEM (%s)'%Unit(part['size']))
                else:
                    ret.append('    %s %s (%s,%s) - %s'%(Unit(part['size']), part['label'] or 'N/A', part['fstype'], part['name'], part['parttype'], ))
        return '\n'.join(ret)

class Installer:
    TGT = '/tmp/install_target'
    GRUB_MOD = "normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp ext2 btrfs xfs jfs"

    def __init__(self):
        if not os.path.exists(self.TGT):
            os.mkdir(self.TGT)
        self.di = DiskInfo()
        self.current_root_part = self.di.get(mountpoint="/")

    def run(self):
        choices = [getattr(self, x) for x in dir(self) if x.startswith('MENU_')]
        choices.sort(key=lambda x: x.__name__)
        while True:
            tag = UI.menu(_("Select the installation modes"),
                    _("All modes are installing the same application set"),
                    choices=( (str(o[0]+1), getattr(self, o[1].__name__[5:])) for o in enumerate(choices) )
                )
            if tag and choices[int(tag)-1]():
                    print(_("When finished, type \"sudo halt -p\" in the shell and remove the installation drive !"))
                    break
            elif not tag: # cancel
                break

    Z_exit = _("Exit")
    def MENU_Z_exit(self):
        raise SystemExit(0)

    A_embed_compact = _('Safe install or upgrade (can be uninstalled, SAFE for data)')
    def MENU_A_embed_compact(self, drive=None, partno=None):
        drive = drive or self.select_disk(2500000)
        if not drive: return
        try:
            partno = partno or self.select_partition(drive, 2500000, show_ro=False)
        except NoPartFound:
            UI.message(_('No partition found !'))
        else:
            if not partno:
                return
            else:
                UI.message(_('Mounting partition'))
                try:
                    runcmd(['mount', '/dev/'+partno, self.TGT])
                except RuntimeError:
                    if not safe and UI.confirm(_('Space not formatted!'),_('Proceed rebuilding a filesystem ?')):
                        DEFAULT_DISKLABEL = UI.get_word(_("What label you want to use (ie. %s)?")%DEFAULT_DISKLABEL)
                        mkfs('/dev/'+partno, DEFAULT_DISKLABEL, 'ext4')
                        runcmd(['mount', '/dev/'+partno, self.TGT])
                    else:
                        raise
                runcmd(['dd', 'if=/dev/'+drive, 'of=%s/backup.mbr'%self.TGT, 'bs=512', 'count=1'])
                UI.message(_('Installing...'))
                runcmd(['installer-embed.sh', self.TGT])
                runcmd(['umount', self.TGT])
                return True

    B_install_compact = _('Dedicate a disk (RECOMMENDED, requires an unused disk)')
    def MENU_B_install_compact(self, drive=None):
        drive = drive or self.select_disk(2500000)
        if not drive: return
        UI.message(_('Installing...'))
        os.system('partprobe')
        runcmd(['installer-standard.sh', "/dev/"+drive, "50", self.di.squashfs], env={'DISKLABEL': 'ARCHX'})
        return True

    C_install_archlinux = _('Install ArchLinux instead')
    def MENU_C_install_archlinux(self, drive=None):
        drive = drive or self.select_disk(2500000)
        if not drive: return
        UI.message(_('Installing...'))
        os.system('partprobe')
        runcmd(['installer-archlinux.sh', "/dev/"+drive, "50", self.di.squashfs], env={'DISKLABEL': 'ARCHX'})
        return True

    def select_disk(self, min_size=0):
        choices = [(d['name'], prettify(d)) for d in self.di.disks if d['name'] != self.di.owndisk and d['size'] > min_size]

        if len(choices) > 1:
            drive = UI.menu(_("Select the storage device"), "", choices)
            if not drive:
                return
        elif not choices:
            UI.message(_("No acceptable drive found"))
            sleep(2)
            return
        else:
            if not UI.confirm(_('Drive selected'), '%s: %s'%tuple(choices[0])):
                return
            drive = choices[0][0]
        return drive

    def select_partition(self, drive, min_size=0, show_ro=True):
        # TODO: mount parts to really know available size
        choices = [(d['name'], prettify(d)) for d in self.di.get_partitions(drive) if d['size'] > min_size]

        if len(choices) > 1:
            partno = UI.menu(_("Select the partition"), "", choices)
        elif not choices:
            raise NoPartFound()
        else:
            if not UI.confirm(_('Selected partition'), '%s'%choices[0][1]):
                raise SystemExit()
            partno = choices[0][0]

        if not partno: return False
        return partno


##############" UI

global UI

class UI:
    def __init__(self):
        from dialog import Dialog
        self.d = Dialog()
        self.w=0
        self.h=0

    def message(self, text, title=None):
        self.d.infobox( text )

    def get_word(self, title):
        return self.d.inputbox(title)[1]

    def menu(self, title, subtitle, choices):
        return self.d.menu( subtitle, title=title, choices=choices, width=self.w, height=self.h)[1]

    def confirm(self, title, question):
        return "cancel" != self.d.yesno(question, title=title, width=50, height=5)


UI = UI()

############"" utils

def mkfs(drive, label, fmt='fat'):
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


def optimistic_number(n):
    try:
        ip = 10 * (str(n).index('.') -1 )
    except ValueError: # integer
        ip = 10 * (len(n) - 1 )

    if ip:
        return math.ceil(int(n) / ip) * ip
    else:
        return n

def prettify(infos):
    if infos['type'] == 'disk':
        return '%s disk (%s) %s'%(
            infos['tran'].upper(),
            Unit(infos['size']),
            infos['model'])
    else:
        return '%s %s (%s,%s) - %s'%(Unit(infos['size']), infos['label'] or 'N/A', infos['fstype'], infos['name'], infos['parttype'], )

class Unit:
    def __init__(self, value):
        self.value = int(value)

    def human(self, use_kib=False, suffix='B'):
        units = iter('okMGTPEZY')
        dec = 1024 if use_kib else 1000
        th = dec * 1.0 # > 1.0 to not change as soon as it's > 1
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

class NoPartFound(Exception): pass

if __name__ == '__main__':
    installer = Installer()
    installer.run()
