---
title: "Make systemd service wait for mount"
date: 2021-11-18 16:00
categories: linux
tags: debian storage nextcloud
---

Services in [systemd](https://systemd.io/) can be set to wait on the
availability of any specific mount point in the local filesystem. This is very
useful for NFS mounts as those require the network to be up and running, which
can take a while.

This feature is controlled through the
[RequiresMountsFor](https://www.freedesktop.org/software/systemd/man/systemd.unit.html#RequiresMountsFor=)
option in the unit file of the service.

For instance, I use `RequiresMountsFor` in the [fail2ban](https://www.fail2ban.org)
service that is running alongside the reverse proxy of a [NextCloud](https://nextcloud.com/)
instance. Hence, I can give access to fail2ban to the logs from the remote
NextCloud and block connections in the reverse proxy not only based on its own
activity, but also based on the activity in NextCloud itself.

The following steps show how to modify the existing service for fail2ban to wait
for the folder with remote log files that is mounted with NFS:

1. Edit the unit file

    ```shell
    $ sudo systemctl edit fail2ban.service
    ```

2. Set ``RequiresMountsFor`` in the *Unit* section to the **absolute path**
   needed by the service

    ```
    [Unit]
    RequiresMountsFor=/var/log/nextcloud
    ```
    {: file="/etc/systemd/system/fail2ban.service.d/override.conf" }


:warning: systemd will mount all mounts needed to access the path in
`RequiresMountsFor`, even those with `noauto`.

