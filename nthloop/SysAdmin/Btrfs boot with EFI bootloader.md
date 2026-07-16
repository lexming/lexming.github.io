---
title: Btrfs boot with EFI bootloader
created: 2022-07-18
tags:
  - gentoo
  - kernel
---
We can directly boot into the Linux kernel without any external bootloader (*e.g.* [GRUB](https://www.gnu.org/software/grub/)) by enabling support in the kernel for the [EFI bootloader](https://wiki.gentoo.org/wiki/EFI_stub).

```text caption="Linux kernel configuration options to enable EFI bootloader"
Processor type and features  --->
    [*] EFI runtime service support 
    [*]   EFI stub support
    [ ]     EFI mixed-mode support
```

The EFI bootloader also supports an [initramfs](https://wiki.gentoo.org/wiki/Initramfs) to handle more complex tasks early in the boot process. Typically, mounting important filesystems that need specific kernel modules, mounting encrypted filesystems or loading firmware for hardware devices.

```text caption="Linux kernel configuration options to enable initramfs"
General setup  --->
    [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
    ()    Initramfs source file(s)
Processor type and features  --->
    [ ] Built-in kernel command line
Device Drivers --->
    Generic Driver Options --->
        [*] Maintain a devtmpfs filesystem to mount at /dev
```

The _initramfs_ image does not have to be embedded into the kernel with the option `Initramfs source file(s)`, as it will be directly loaded by the EFI bootloader from the boot drive. Moreover, the _initramfs_ will also take care of passing the appropriate command line options to the kernel, so it is not necessary to define any in the `Built-in kernel command line` configuration.
## EFI bootloader setup

1. Compile the Linux kernel
   ```shell
   cd /usr/src/linux
   make && make modules_install
   ```

2. Copy the kernel image to the [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition)

   ```shell
   cp arch/x86/boot/bzImage /boot/efi/EFI/Gentoo/bzImage-x.y.z.efi
   ```

3. Generate the _initramfs_ with [dracut](https://github.com/dracutdevs/dracut) (optionally compressed with [ZSTD](https://github.com/facebook/zstd))

   ```shell
   dracut --kver=x.y.z-gentoo --zstd
   ```

4. Copy the new _initramfs_ image to the [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition)

   ```shell
   cp /boot/initramfs-x.y.z-gentoo.img /boot/efi/EFI/Gentoo/initramfs-x.y.z.img
   ```

5. Generate a new boot entry for this new kernel in the EFI bootloader

   ```shell
   efibootmgr --create --disk /dev/nvme0n1 --part 1 --label 'Gentoo' --loader '\efi\gentoo\bzImage-x.y.z.efi' --unicode 'initrd=\efi\gentoo\initramfs-x.y.z.img'
   ```

   In this example, the partition `/dev/nvme0n1p1` is the [EFI System Partition](https://wiki.gentoo.org/wiki/EFI_System_Partition) and paths are relative to its root.

## Btrfs root partition

The previous setup allows to easily boot from a [Btrfs](https://btrfs.wiki.kernel.org) root partition by using the _initramfs_ to mount it. _Btrfs_ can be compiled into the kernel or added as module.

```text caption="Linux kernel configuration to enable Btrfs"
File systems  --->
    <*/M> Btrfs filesystem
```

Dracut will auto-detect the format of the root partition as long as it is already mounted. Alternatively, _btrfs_ can be manually added to the _initramfs_ image with the following option in the configuration of Dracut (_e.g._ `/etc/dracut.conf`)

```text caption="Enable btrfs support in Dracut"
filesystems+=" btrfs "
```
