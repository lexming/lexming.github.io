---
title: "File system loop with Btrfs and NFS"
date: 2023-01-15
tags:
- storage
---

I got the following error on a regular `find` command looking for files in the
data directory of my [Nextcloud](https://nextcloud.com/) instance:

```shell
$ find /media/nextcloud/ -name "potato"
find: File system loop detected; ‘/media/nextcloud/log’ is part of the same file system loop as ‘/media/nextcloud/’.
find: File system loop detected; ‘/media/nextcloud/data’ is part of the same file system loop as ‘/media/nextcloud/’.
find: File system loop detected; ‘/media/nextcloud/scripts’ is part of the same file system loop as ‘/media/nextcloud/’.
```

This error about a loop in the file system is very unexpected. Such loops are
commonly caused by symbolic links pointing back to some parent folder (see
below) and I know that there are none in that mount at `/media/nextcloud`
because [Nextcloud does not support symlinks](https://github.com/nextcloud/server/issues/28178).

```shell
.
└── root_folder
    └── sub_folder_1
        └── sub_folder_2 > /root_folder
            └── sub_folder_1
                └─ (...)
```

## Inodes in Btrfs and NFS

The reason that leads to this file system loop error in `/media/nextcloud` is
that its 3 sub-folders `data`, `log` and `scripts` have the same inode number,
understandanbly tricking `find` into a file system loop.

```shell
$ ls -i /media/nextcloud
256 data  256 log  256 scripts
```

The common inode number between these folders originates from the underlying
[Btrfs file system](https://btrfs.wiki.kernel.org/) of this mount. Each
sub-folder `data`, `log` and `scripts` is a
[Btrfs subvolume](https://btrfs.readthedocs.io/en/latest/Subvolumes.html)
inside another subvolume `/media/nextcloud` and one characteristic of Btrfs
subvolumes is that they all have the same
[256 inode number](https://btrfs.readthedocs.io/en/latest/Subvolumes.html#inode-numbers).
This single inode number is usually not an issue for subvolumes locally mounted
with Btrfs. The filesystem allocates a separate device number for each
subvolume, which allows to distinguish each sub-folder even if only the root
subvolume is mounted.[¹](#references)

So why the error then? In this case, the root Btrfs subvolume
`/media/nextcloud` is mounted over the network with
[NFS](https://www.linux-nfs.org) and its child subvolumes are accessible
through this single NFS mount. The NFS server of `/media/nextcloud` already
sets explictly the filesystem ID of the exported subvolume with the
[option `fsid`](https://linux.die.net/man/5/exports). However, this filesystem
ID does not help with the nested subvolumes, NFS does not expose anything else
than the inode number for those and hence, the sub-folders `data`, `log` and
`scripts` are left undistinguishable.

## Solution

The solution is to export an NFS mount for each subfolder, with their own
`fsid`, and mount each one of those on the client system:

```shell
$ mount | grep nextcloud
helios4:/cloud on /media/nextcloud type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_data on /media/nextcloud/data type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_log on /media/nextcloud/log type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_scripts on /media/nextcloud/scripts type nfs4 (rw,noatime,vers=4.2)
```

The inodes of the sub-folders will still be the common 256, but `find` will no
longer report file system loops:

```shell
$ ls -i /media/nextcloud/
256 data  256 log  256 scripts
$ find /media/nextcloud -name "potato"
/media/nextcloud/scripts/potato
```

## References
A lot more information in the two-part series of LWN.net:
1. [The Btrfs inode-number epic (part 1: the problem)](https://lwn.net/Articles/866582/)
2. [The Btrfs inode-number epic (part 2: solutions)](https://lwn.net/Articles/866709/)
