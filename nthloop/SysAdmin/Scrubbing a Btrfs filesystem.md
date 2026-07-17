---
title: Scrubbing a Btrfs filesystem
created: 2021-09-18
modified: 2021-09-18
tags:
  - debian
  - storage
  - systemd
  - btrfs
---
[Btrfs](https://btrfs.wiki.kernel.org) provides a tool called [btrfs-scrub](https://btrfs.readthedocs.io/en/latest/btrfs-scrub.html) that serves to scrub the filesystem. It can automatically read all data and metadata blocks, verify checksums and repair corrupted blocks if there's a correct copy available.
## Periodic scrubbing

1. Install [btrfsmaintenance](https://github.com/kdave/btrfsmaintenance)

   The tool `btrfs-scrub` is provided by the `btrfsmaintenance` package, which is a project with extra maintenance tools developed by the btrfs maintainers and not found in `btrfs-progs`. This article focuses on the scrubber but there is also a _defrag_.

   ```shell
   apt install btrfsmaintenance
   ```

   Once installed, all provided services and timers should be disabled by default.

2. Edit the configuration

   The configuration settings for all tools in `btrfsmaintenance` are centralised in `/etc/default/btrfsmaintenance` in Debian. Set the `BTRFS_SCRUB_*` variables in it as needed.

3. Simplify the timer for `btrfs-scrub`

   By default, the timers are controlled through the `btrfsmaintenance-refresh.service`, which reads `$BTRFS_SCRUB_PERIOD` from the main configuration file. However, I prefer to simplify this setup by directly configuring the periodicity in a [systemd timer](https://www.freedesktop.org/software/systemd/man/systemd.timer.html) for `btrfs-scrub`

   ```shell
   systemctl edit --full btrfs-scrub.timer
   ```

   Contents of `btrfs-scrub.timer` with fixed monthly execution (every 8th day at 5 AM)

   ```text showLineNumbers caption="Contents of /etc/systemd/system/btrfs-scrub.timer"
   [Unit]
   Description=Scrub btrfs filesystem, verify block checksums
   Documentation=man:btrfs-scrub

   [Timer]
   OnCalendar=*-*-8 5:00:00
   RandomizedDelaySec=1h
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

4. Start the scrubbing timer

   ```shell
   systemctl enable btrfs-scrub.timer
   systemctl start btrfs-scrub.timer
   ```

   The time of next execution can be checked with the command `systemctl list-timers --all`.

## Manual raw scrub of the drive

Alternatively, if any underlying drive has faulty blocks, those can be identified with the command `badblocks` and manually evicted with `hdparm`:

1. Tests from S.M.A.R.T.

   Check the test reports from the SMART system in the drive to verify its health status. For instance, the `sda` drive in our affected system reports a read failure.

   ```shell
   smartctl -l selftest /dev/sda
   ```
   ```
   smartctl 6.6 2017-11-05 r4594 [armv7l-linux-5.10.34-mvebu] (local build)
   Copyright (C) 2002-17, Bruce Allen, Christian Franke, www.smartmontools.org

   === START OF READ SMART DATA SECTION ===
   SMART Self-test log structure revision number 1
   Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
   # 1  Short offline       Completed: read failure       20%     30351         4409
   [...]
   ```

2. Identify bad blocks

   Check the block size of the drive with `fdisk -l` and execute `badblocks` to identify all faulty blocks in the disk. Example in our `sda` drive with blocks of 512 bytes:

   ```shell
   badblocks -b 512 /dev/sda
   ```
   ```
   [...]
   4409
   ```

3. Verify state of reported bad blocks

   ```shell
   hdparm --read-sector 4409 /dev/sda
   ```

4. Repair bad blocks

   > [!warning] 
   > This step will not recover any data! Just disable the faulty sectors.
   
   The faulty blocks will be disabled from the drive, which will (probably) continue to function with the remaining healthy blocks. The filesystem will only be able to recover the lost data if there is redundancy.

   ```shell
   hdparm --yes-i-know-what-i-am-doing --repair-sector 4409 /dev/sda
   ```
