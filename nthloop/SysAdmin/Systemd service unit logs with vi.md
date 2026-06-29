---
title: Systemd service unit logs with vi
created: 2026-06-29
modified: 2026-06-29
tags:
  - systemd
---
Using the built-in pager in `journalctl` is sufficient as long as the relevant information can be easily spotted at the end or beginning of the log file. For instance to check the end of the log journal of a given service unit, we can simply do:

```bash
journalctl -e -u example.service
```

It is even possible to _follow_ the logs in real time:
 
```bash
journalctl -ef -u example.service
```

However, if you seek an event or error message without a known timestamp, then it is more efficient to use an external such as `vi` to read and navigate the log journal.

```bash
journalctl --no-pager -u example.service | vi -
```