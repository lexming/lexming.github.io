---
title: "Cron jobs with systemd"
date: 2022-04-05 18:00
categories: linux
tags: systemd
---

[Systemd](https://systemd.io/) has timers, which can be used as an alternative
to [cron](https://en.wikipedia.org/wiki/Cron) to schedule jobs. The timers
infrastructure is quite powerful and is described in detail elsewhere
[⁽¹⁾](https://fedoramagazine.org/systemd-timers-for-scheduling-tasks/)
[⁽²⁾](https://wiki.archlinux.org/title/Systemd/Timers).

The following shows common timer examples to execute an arbitrary service unit
*myunit.service* and basic commands to control the timers.

## Monotonic timer

```
[Unit]
Description=Run myunit.service every 60 minutes

[Timer]
OnBootSec=15min
OnUnitActiveSec=60min
Unit=myunit.service

[Install]
WantedBy=timers.target
```
{: file="myunit.timer" }

## Realtime timer

```
[Unit]
Description=Run myunit.service once a week at 2:00 AM

[Timer]
OnCalendar=Tue *-*-* 02:00:00
Unit=myunit.service

[Install]
WantedBy=timers.target
```
{: file="myunit.timer" }

## Launch and monitor the timer

Timers can be added as a regular user or system-wide as root.

1. Add the timer unit file

    ```console
    $ systemctl edit --full myunit.timer
    ```
2. Enable the timer (not the service unit)

    ```console
    $ systemctl enable myunit.timer
    ```

3. Monitor the active timers

    ```console
    $ systemctl list-timers
    ```

>Timers can be manually triggered with the command `systemctl start
>myunit.timer`.
{: .prompt-info }
