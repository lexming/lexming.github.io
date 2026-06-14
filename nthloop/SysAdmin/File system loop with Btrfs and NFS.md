---
title: File system loop with Btrfs and NFS
created: 2023-01-15
modified: 2023-01-15
tags:
  - storage
---
I got the following error on a regular `find` command looking for files in the data directory of my [Nextcloud](https://nextcloud.com/) instance:

```shell
$ find /media/nextcloud/ -name "potato"
find: File system loop detected; ‘/media/nextcloud/log’ is part of the same file system loop as ‘/media/nextcloud/’.
find: File system loop detected; ‘/media/nextcloud/data’ is part of the same file system loop as ‘/media/nextcloud/’.
find: File system loop detected; ‘/media/nextcloud/scripts’ is part of the same file system loop as ‘/media/nextcloud/’.
```

Hitting a loop in that particular file system is very unexpected. Such loops are commonly caused by symbolic links pointing back to one of its parent folders (see example below) and I know that there are none in that mount at `/media/nextcloud` because [Nextcloud does not support symlinks](https://github.com/nextcloud/server/issues/28178).

```text
.
└── root_folder
    └── sub_folder_1
        └── sub_folder_2 > /root_folder
            └── sub_folder_1
                └─ sub_folder_2 > /root_folder
                    └── sub_folder_1
                        └── (...)
```

## Inodes in Btrfs and NFS

The cause of this file system loop error in `/media/nextcloud` is that its 3 sub-folders `data`, `log` and `scripts` have the same inode number, which understandably tricks `find` into a file system loop.

```shell
$ ls -i /media/nextcloud
256 data  256 log  256 scripts
```

**How can these folders share the same inode?** That's because the file system of this volume is [Btrfs](https://btrfs.wiki.kernel.org/) and each sub-folder `data`, `log` and `scripts` is a [Btrfs subvolume](https://btrfs.readthedocs.io/en/latest/Subvolumes.html)  and one important characteristic of Btrfs sub-volumes is that they all have the same [256 inode number](https://btrfs.readthedocs.io/en/latest/Subvolumes.html#inode-numbers).

This common inode number is usually not an issue for sub-volumes locally mounted
by Btrfs as the file system allocates a separate device number for each sub-volume, which allows to distinguish each sub-folder even if only the root sub-volume is mounted.[¹](#references)

**Why the error then?** In this case, the parent Btrfs sub-volume `/media/nextcloud` is mounted over the network with [NFS](https://www.linux-nfs.org) and its child sub-volumes are accessible through this **single NFS mount**.

The NFS server of `/media/nextcloud` already sets and explicit file system ID for the exported sub-volume `/media/nextcloud` ([option `fsid`](https://linux.die.net/man/5/exports)). However, this file system ID does not help with the nested sub-volumes, NFS does not expose anything else than the raw inode number for those _directories_ and hence, `data`, `log` and `scripts` are left indistinguishable.

## Solution

The solution is to export an NFS mount for each of the Btrfs sub-volumes with their own
`fsid`, and mount each one of those separately on the client system:

```shell
$ mount | grep nextcloud
helios4:/cloud on /media/nextcloud type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_data on /media/nextcloud/data type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_log on /media/nextcloud/log type nfs4 (rw,noatime,vers=4.2)
helios4:/cloud_scripts on /media/nextcloud/scripts type nfs4 (rw,noatime,vers=4.2)
```

The inodes of the sub-folders will still be the common 256, but `find` will no
longer report file system loops as they will have a different _fsid_:

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