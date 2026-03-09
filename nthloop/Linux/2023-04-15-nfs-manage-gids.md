---
title: "Disable manage GID in NFS"
date: 2023-04-15 16:00
categories: linux
tags: storage
---

  535  omv-env set -- OMV_NFSD_MOUNTDOPTS "--no-nfs-version 3"
  536  omv-salt stage run prepare
  537  omv-salt deploy run nfs

umount and mount
