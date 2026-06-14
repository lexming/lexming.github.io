---
title: NFS server options in openmediavault 7
created: 2023-04-15 16:00
modified: 2023-04-15
tags:
  - storage
  - omv
---
[openmediavault](https://www.openmediavault.org/) v7 uses a [SaltStack](https://saltproject.io/) as configuration management system. This means that making changes to services managed by OMV, such as NFS, should be done through its own tooling instead of directly modifying the configuration files of the target service.

The options of the NFS daemon in OMV can be set with the custom `OMV_NFSD_MOUNTDOPTS` variable. Once the change is done, it is necessary to _stage_ and _deploy_ the configuration with Salt to get that change translated into the actual configuration files of _nfsd_:

```bash
omv-env set -- OMV_NFSD_MOUNTDOPTS "--no-nfs-version 3"
omv-salt stage run prepare
omv-salt deploy run nfs
```

It must be noted that the command `omv-env set` overwrites the given variable. Hence, the previous example not only  disables NFSv3 on the server side but also removes any other options passed by default to _nfsd_ in OMV. For instance, the option `--manage-gids` will be removed and as a side-effect become disabled.