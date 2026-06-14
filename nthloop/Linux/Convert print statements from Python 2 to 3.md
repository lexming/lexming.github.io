---
title: Convert print statements from Python 2 to 3
created: 2022-08-03
modified: 2022-08-03
tags:
  - regex
---
Little regex to convert single-line `print` statements in Python 2 to `print()` in Python 3:

```regex
s/print\s([^(\s].*)/print(\1)/g
```

Match pattern:
* `print`: match string literally
* `\s`: match a white space character
* `(`: start capture group
    * `[^(\s]`: match a single character that is not `(` or a white space
    * `.*` : match any character between zero and unlimited times
* `)`: end capture group

Substitution expression takes the first capture group (_i.e._ everything inside the `print` statement) and outputs it in-between the parentheses of `print()`.