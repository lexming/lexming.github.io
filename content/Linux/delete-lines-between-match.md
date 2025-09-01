---
title: "Delete lines between matches in regex"
date: 2022-07-07
tags:
- regex
---

Delete all lines between two matching patterns including the matchings patterns

sed '/pattern1/,/pattern2/d' input.txt

(apply delete command `d` to whole match)

https://stackoverflow.com/questions/57845053/using-sed-to-delete-all-lines-between-two-matching-patterns-including-the-matche

Delete all lines between two mathing patterns, excluding the matchings patterns

sed '/pattern1/,/pattern/{//!d}' input.txt

(apply delete command `d` only if line does not match the pattern)

https://stackoverflow.com/questions/6287755/using-sed-to-delete-all-lines-between-two-matching-patterns

Note: the d operator can be any other sed operator

```careful with this, NEW_STUFF will be substituted on each line between the patterns
 sed '/pattern1/,/^pattern2/{//!s|.*|NEW_STUFF|)|}' CMakeLists.txt
```
