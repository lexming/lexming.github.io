---
title: "Edit systemd units"
date: 2022-06-15
tags:
- systemd
---

Unit files in [systemd](https://systemd.io/) can be mended without modifying
the actual unit file. This is useful to apply custom modifications to systemd
services that will survive updates of the package, as system updates might
reset the original unit file.

For instance, at the time of writting, issue
[haveged#41](https://github.com/jirka-h/haveged/issues/41) was still present in
Armbian 22.05.1 Bullseye. We can manually apply the fix to haveged service from
commit [haveged@159dcde2](https://github.com/jirka-h/haveged/commit/159dcde28fa2deb3c6d5722dce9fe384f08202b7)
with the following steps:

1. Edit haveged service file

    ```console
    $ systemctl edit haveged.service
    ```

2. Add any modified or new parameters to the unit file

    ```
    ### Editing /etc/systemd/system/haveged.service.d/override.conf
    ### Anything between here and the comment below will become the new contents of the file
    
    [Service]
    SystemCallFilter=@system-service
    SystemCallFilter=~@mount
    SystemCallErrorNumber=EPERM
    
    ### Lines below this comment will be discarded
    ```
    
    > Keep in mind to always specify the section of the parameters.
    {: .prompt-warning }

