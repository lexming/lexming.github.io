---
title: "Inspecting CPIO images"
date: 2023-09-28
tags:
- storage
---

skipcpio skips over the first (noncompressed) ASCII cpio block and prints the rest.

/usr/lib/dracut/skipcpio ../initramfs-4.18.0-477.21.1.el8_8.x86_64.img | zcat | cpio -idmv
