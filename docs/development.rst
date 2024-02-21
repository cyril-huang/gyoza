====================
Development of GYOZA
====================

Been eager to have a boot device with multiple OS which can be selected for
demostration, installation, test or rescue of a PC system long time ago.
This is the result of such software to manage device. There are many tools
available from opensource community as well such as Ventoy which can boot
from any ISO file from USB or even local disk file system. However, this tool
can download many lastest Linux distro, bsd, omnios, freedos and importing
ESXi, Microsoft Windows ISO into the USB device with standard utilities
without modification of GRUB/wimboot and so forth.

Background
==========

Thanks for the utilities from opensource community to make this happened

* GNU bash
* parted/fdisk/mkfs.fat/losetup/mount
* grub/syslinux/ipxe
* wget/curl
* udisksctl/kernel with 9p shared filesystem
* qemu
* python3/python3 json library/dialog
* optional: wimtools, dialog

Make it as simple/clean as possible

* 1 normal FAT32 partition
* standard opensource community tools without hacking/re-compiling
* pure BASH without fancy shell syntax
* practice JSON handling in shell with python
* use tools as capable as possible

However, still buggy, I think :-)

Linux
-----

The most important to boot Linux is to have kernel and initramfs 2 files.
If the small system, initramfs, has the ability to download required packages
from network then it can install a new system. On the other hand, if the
initramfs inside ISO knows how to find the squash filesystem of ISO then it
can start a new Live system without extracting the files inside ISO. Not all
distributions support those functionality though.

Steps for Linux

* create a device with FAT32/FAT label and grub i386-pc/x86_64 on it.
* download the latest supported distribution by examining distribution
  release URL.
* extract the files required, the kernel and initramfs, for UEFI booting.
* write the grub menu to /boot/grub/grub.cfg and /boot/grub/grub.cfg.d.
* If qemu-system available, test the device just created.

DOS
---

There is freedos supported that it uses syslinux/memdisk to load the image
so as other DOS such as MS-DOS and DR-DOS imported.

ESXi 6.x,7.x,8.x
----------------

ESXi boot from their modified mboot.c32 which is only loaded from syslinux
4.07. There is no syslinux 4.07 64 bits binary to be downloaded so we need
to download the source and make a new syslinux 4.07 binary and embedded to
executable gyoza.

Steps for ESXi

* a 'exit 0' in the end of executable and this is the delimiter of the start
  of binary.
* extract syslinux from the binary we embedded and run

  - mkdir -p path-to-hold-esxi

  - syslinux -d path-to-hold-esxi -i /dev/sdx1

  - dd if=/dev/sdx1 of=path-to-hold-esxi/syslinux.bin

* copy all files to path-to-hold-esxi
* modify isolinux.cfg to syslinux.cfg
* modify original boot.cfg
* modify the menuentry of GRUB cfg file in device

Microsoft Windows 7,8,9,10,11
-----------------------------

Windows 7~11 currently use a WinPE, similar to initramfs environment, boot.wim
to boot the system and from that small system to invoke

* setup.exe /installfrom:d:/sources/install.wim

The standard boot sequence of Windows 7~11 is

* 1st bootloader -> 
* /bootmgr ->
* /boot/bcd ->
* /sources/boot.wim -> (image #2 is the image used for installation)
* inside boot.wim filesystem -> see the flow below
* /sources/install.wim -> installer

boot.wim/winpe startup flow, X: is the boot.wim filesystem

* winpeshl.exe, if winpeshl.ini exists, run [LaunchApp] in
  X:\Windows\System32\winpeshl.ini
* winpeshl.ini exists but invalid, a cmd shell will be opened and stop
* winpeshl.ini not exist -> if X:\setup.exe existed, run it.
* X:\setup.exe prompts the user to choose a language then either Repair or
  Install. -> choose Install then start X:\sources\setup.exe.
* X:\sources\setup.exe will look on all drives for a \sources containing both
  “setup.exe” and a install.wim, install.swm or install.esd file in the same
  folder -> if not found it will prompt you to install USB/CD/DVD drivers.
  This is where we see "Media Driver needed missing" or 
  "Windows can not find \sources\install.wim" in some old edition.
* no winpeshl.ini is found and no X:\setup.exe found then run 
  "cmd /k X:\Windows\System32\startnet.cmd"
* boot.wim contains the X:\Windows\System32\startnet.cmd which just contains
  the command "wpeinit".
* wpeinit.exe loads network resources such as DHCP. It also loads a wpeinit
  unattend XML file if it can find X:\unattend.xml.
* Usually put netuse.exe in startnet.cmd to connect remote SMB server for
  installation in PXE environment or unattend installation

Unfortunateely it's likely that finding insatll.wim is hardcoded in setup.exe
for \sources\install.wim so even we change the directory sources in bcd, the
boot.wim can not find install.wim unless \sources\install.wim used.

Take advantage of ipxe/wimboot, we can start the sources/boot.wim without the
hassle of modifying bcd/bootmgr but we still need to give winpeshl.ini and
startup script to wimboot. On the other hand it may need to modify the
bootx64.efi and bcd under /efi to make the UEFI booting successful (After
testing, this can be done by chainload from GRUB2->ipxe->wimboot without
modifying the bootx64.efi and efi bcd in UEFI environment).

Gyoza just take advantage of qemu to run the boot.wim itself and use all tools
inside boot.wim such as extracting files, modifing bcd and so on.

There is also wimtools package available from http://wimlib.net if want to
inject new drivers, winpeshl.ini or startup script into the boot.wim without
running qemu but in Linux environment. There are some compression APIs
implemented in wimlib such as LZNT1, XpressHuffmen and so on which can be used.

Steps for Windows

* extract the boot.wim from ISO into the device
* write the Windows CMD script to modify BCD, bootx64.efi, get version info,
  split install.wim if required and copy files then put this script into
  device.
* create a temporary new grub.cfg in device to boot the boot.wim in ISO and
  run the script just created.
* recover back to original grub.cfg
* modify the menuentry of GRUB cfg file in device.

GRUB cfg
--------

The difficult thing is requiring to pass information such as distribution
version, download status and prompt title into different steps. GRUB cfg is
also great for small text database we maintain in device. ESXi and Windows
path are configurable and those information from user are stored in --id
of menuentry. It will start from /boot/grub/grub.cfg for general global setup
and /boot/grub/grub.cfg.d/root.cfg for root menu. All other cfgs will be like
tree node using GRUB's configfile/source command.

Theme
-----

Take advantage of effort from opensource community and put a small background
, icons and setup as "default" theme into the binary embedded in exeutable
with syslinux. All themes will be stored under /theme/<theme-name> and there
should be a theme.txt file inside for GRUB theme setup.

Some UEFI systems do not display the MS Windows installation screen well so
just no gfx terminal output when booting from UEFI and no theme by default
even there is a default theme embedded.

APIs
====

All bash APIs are with general usage APIs and gyoza framework special handling
APIs.

Logger:
-------

simple logger for use through whole project

::

 * gz_log
 * gz_log_err ~ gz_log_debug
 * gz_log_stderr
 * gz_log_stdout
 * gz_set_log_level
 * gz_set_log_action
 * gz_msg
 * gz_log_err_exit

Create Device:
--------------

create a device with FAT32 filesystem created and a FAT label created.

::

 * gz_create
 * gz_cleanup_create

File Progress Drawing:
----------------------

If there is dialog available, it will use dialog to draw the progress bar.
If there is no dialog in the system, it will draw progress bar with terminal
drawing ability.

For drawing the progress bar, there should be a while loop to keep sending the
current file size, expected full file size and the title information to drawing
API. There is a JSON format for this information object with 2 APIs provided
to get/set the global information object, the gz_draw_info_get() and
gz_draw_info_add()

::

 * gz_draw_file_progress         : terminal drawing single file progress function
 * gz_draw_dialog_mixedgauge     : dialog drawing with mixedgauge
 * gz_draw_all_files_progress    : draw all files progress in one shot.
 * gz_cleanup_draw_file_progress : cleanup for trap INT or after drawing.

Linux Download:
---------------

predefined framework for some files and directories location to download
the distribution image supported.

::

 * gz_url_to           : download url to a file
 * gz_url_to_stdout    : download url to stdout
 * gz_url_header       : get the http header of url
 * gz_download_distros : download distros supported
 * gz_cleanup_download_distros : cleanup download job

Image Extraction:
-----------------

extract files from ISO image or raw disk image file with get/put operations.
Currently only udisksctl, qemu with 9p file system and root mount supported.

::

 * gz_img             : extract files from image file
 * gz_get_dev_mnt     : get the mount point of a device/image mount
 * gz_cleanup_img     : cleanup loop device, mount points used in operations
 * gz_cleanup_dev_mnt : cleanup loop device, mount points used in operations

GRUG menu system
----------------

It will create a /boot/grub/grub.cfg then put the root node configuration in 
/boot/grub/grub.cfg.d/root.cfg. After the root node created, create submenu
and menuentry as tree structure and tree node. The submenu and menu API
provide add/remove/update actions for menu operations.

::

 * gz_rootmenu     : create grub.cfg
 * gz_menu         : api to operate grub menuentry, add/remove/update
 * gz_submenu      : api to operate grub submenu, add/remove/update
 * gz_menu_distros : operation for add/remomve/update all supported distros

ESXi & Windows Import/Deport
----------------------------

::

 * gz_import         : import DOS,ESXi and Windows image/ISO file.
 * gz_deport         : remove import system from device
 * gz_import_dos     : real implementation of importing DOS
 * gz_import_esxi    : real implementation of importing ESXi
 * gz_import_windows : real implementation of importing Windows

GYOZA
-----

There are corresponding API to each command in gyoza implementation such as
create -> gyoza_create, test -> gyoza_test. There is also a corresponding
usage_command such as usage_create, usage_test implemented.

TODO List
=========

Ask help and todo list 

::

 * archlinux package for archlinux,manjaro
 * management of pxeboot directory structure for pxeboot deployment
 * support for Linux/Windows Unattend installation
 * openindiana integration of live ISO
 * freebsd integration of live ISO
 * OpenBSD, NetBSD UEFI booting
 * more user space mount tools support such as fuse, guestfsmount
 * shell I18n gettext supported
 * GUI integration
 * self system ISO with storage/network/security tools inside for PC rescue
 * GYOZA logo

BUGS

::

 * Currently no filename with space handling well since it's a shell script
