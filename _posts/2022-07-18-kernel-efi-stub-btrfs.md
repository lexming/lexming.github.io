---
title: "Kernel EFI stub boot with Btrfs root"
date: 2022-07-18 20:00
categories: linux
tags: gentoo
---

We can directly boot into the Linux kernel without any secondary bootloader
(*e.g.* [GRUB](https://www.gnu.org/software/grub/)) by enabling support in the
kernel for the [EFI bootloader](https://wiki.gentoo.org/wiki/EFI_stub).

```
Processor type and features  --->
    [*] EFI runtime service support 
    [*]   EFI stub support
    [ ]     EFI mixed-mode support
```
{: file="/usr/src/linux/.config" }

The EFI bootloader also supports [initramfs](https://wiki.gentoo.org/wiki/Initramfs)
to handle more complex tasks early in the boot process. Typically, mounting
important filesystems that need any kernel modules, mounting encrypted
filesystems or loading firmware for the kernel drivers.

```
General setup  --->
    [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
    ()    Initramfs source file(s)
Processor type and features  --->
    [ ] Built-in kernel command line
Device Drivers --->
    Generic Driver Options --->
        [*] Maintain a devtmpfs filesystem to mount at /dev
```
{: file="/usr/src/linux/.config" }

The initramfs image does not have to be embedded into the kernel with the
option `Initramfs source file(s)`, as it will be directly loaded by the EFI
bootloader. Moreover, the initramfs will also take care of passing the
appropriate command line options to the kernel, so it is not necessary to
define any in the `Built-in kernel command line` configuration.

## EFI bootloader setup
1. Compile the Linux kernel
    ```console
    $ cd /usr/src/linux
    $ make && make modules_install
    ```
2. Copy the kernel image to the [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition)
   
   ```console
   $ cp arch/x86/boot/bzImage /boot/efi/EFI/Gentoo/bzImage-x.y.z.efi
   ```
3. Generate the initramfs with [dracut](https://github.com/dracutdevs/dracut)
   (optional: compressed with [ZSTD](https://github.com/facebook/zstd))
   ```console
   $ dracut --kver=x.y.z-gentoo --zstd
   ```
4. Copy the new initramfs image to the [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition)
   ```console
   $ cp /boot/initramfs-x.y.z-gentoo.img /boot/efi/EFI/Gentoo/initramfs-x.y.z.img
   ```
5. Generate a new boot entry for this new kernel in the EFI bootloader
   ```console
   $ efibootmgr --create --disk /dev/nvme0n1 --part 1 --label 'Gentoo' --loader '\efi\gentoo\bzImage-x.y.z.efi' --unicode 'initrd=\efi\gentoo\initramfs-x.y.z.img'
   ```
   > In this example, the partition `/dev/nvme0n1p1` is the
   > [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition)
   > and paths are relative to its root.
   {: .prompt-info }


## Btrfs root partition

The previous setup allows to easily boot from a
[Btrfs](https://btrfs.wiki.kernel.org) root partition by using the initramfs to
mount it. Btrfs can be compiled into the kernel or added as module.

```
File systems  --->
    <*/M> Btrfs filesystem
```
{: file="/usr/src/linux/.config" }

Dracut will auto-detect the format of the root partition as long as it is
already mounted. Alternatively, btrfs can be manually added to the initramfs
image with

```bash
filesystems+=" btrfs "
```
{: file="/etc/dracut.conf" }

