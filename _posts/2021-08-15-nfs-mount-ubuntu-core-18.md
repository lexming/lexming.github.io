---
title: "NFS mount in Ubuntu Core 18"
date: 2021-08-15 12:00
categories: nextcloud
tags: ubuntu snap storage
---

[Ubuntu Core](https://ubuntu.com/core) is based on [snaps](https://snapcraft.io/), which means that all software (even the system kernel!) has to be provided by a snap container. The main consequence of this design is that the system lacks many tools commonly found in other Linux distros (*eg* `wget`), rendering a simple task such as mounting a NFS volume to be not trivial.

## The good, the bad and the ugly

1. Real solution: use Ubuntu Server instead of Ubuntu Core if you need NFS mounts, the base of the system is the traditional Ubuntu with its common array of tools and it is possible to use snaps as well.
2. Time sink solution: make your own snap for `nfs-common`, the kernel in Ubuntu Core already provides support for NFS. The only missing pieces are the NFS tools in userland.
3. Quick solution: use [BusyBox](https://www.busybox.net/), it can be easily side-loaded into the system and provides support for NFS.

## Install BusyBox into Ubuntu Core 18

The easiest approach is to download BusyBox into some local machine and transfer the tarball to the Ubuntu Core system with `ssh`. However, in the following I'll show a solution that only relies on the Ubuntu Core system itself:

1. Install the [classic snap](https://github.com/snapcore/classic-snap)

    The classic snap allows to run a classic Ubuntu environment that includes `apt`. Beware that it was released for Ubuntu Core 16 and it has not been updated for v18. Nonetheless, we will just use it to download BusyBox into the system and unistall it afterwards

    ```console
    $ snap install classic --edge --devmode
    classic (beta) 16.04 from Canonical✓ installed
    Channel latest/edge for classic is closed; temporarily forwarding to beta.
    ```

    Running in [*devmode*](https://snapcraft.io/docs/snap-confinement) lightens the confinement of the snap, giving it access to the host system.

2. Install GNU Wget within snap classic

    ```console
    $ sudo classic
    Creating classic environment
    [...]
    (classic) $ sudo apt install wget
    ```

3. Download BusyBox

    Since my system runs on a Raspberry Pi 4 rev B, I took the build for `armv8l`. Choose the one most appropriate for your system from [busybox.net](https://www.busybox.net/downloads/binaries/).

    ```console
    (classic) $ wget https://www.busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv8l
    ```

    The downloaded busybox binary can be moved out of the classic snap as we are running in *devmode*.

4. (optional) Uninstall classic

    The classic snap will not be needed in the following sections

    ```console
    $ sudo snap remove classic
    ```

## Mount NFS volume with BusyBox

Execute `mount` as usual from within the `busybox` binary image

```console
$ chmod u+x /root/busybox-armv8l
$ sudo /root/busybox-armv8l mount -t nfs4 -o rw nfs_server:/cloud /media/nextcloud
```

## Automatize NFS mount with systemd

We can create a simple systemd service to emulate the corresponding systemd unit mount for the NFS volume. The custom service will mount/unmount the NFS volume on system boot/shutdown using BusyBox

```
[Unit]
Description=Mount NFS volume with Nextcloud media
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
RemainAfterExit=yes
ExecStartPre=/bin/mkdir -p /media/nextcloud
ExecStart=/root/busybox-armv8l mount -t nfs4 -o rw nfs_server:/cloud /media/nextcloud
ExecStop=/root/busybox-armv8l umount /media/nextcloud

[Install]
WantedBy=remote-fs.target
```
{: file="/etc/systemd/system/nextcloud-nfs-mount.service" }

*Note*: `ExecStartPre` ensures that the mount point for the NFS volume exists on service start.

# Use the NFS volume in NextCloud

At this point, you can see that I carried out this process in a
[NextCloud](https://nextcloud.com/) instance. Here are the steps to use the NFS
volume as the data storage of a NextCloud snap:

1. Enable access to `/media` to NextCloud snap

    ```console
    $ sudo snap connect nextcloud:removable-media
    ```

2. Change the data directory in NextCloud by following the steps in the [NextCloud Wiki](https://github.com/nextcloud-snap/nextcloud-snap/wiki/Change-data-directory-to-use-another-disk-partition)

Beware that the folder in `/media` is not persistent across reboots.
