---
title: "List sets of specific march options in GCC"
date: 2023-04-09
tags:
- compilers
---

I got the following error on a regular `find` command looking for files in the
data directory of my [Nextcloud](https://nextcloud.com/) instance:

```shell
$ gcc -march=native -v -Q --help=target
```

