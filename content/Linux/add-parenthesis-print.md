---
title: "Add parenthesis to print in Python"
date: 2022-08-03
tags:
- regex
---

In vim:

```
: %s/print \([^(].*\)/print(\1)/g
```
