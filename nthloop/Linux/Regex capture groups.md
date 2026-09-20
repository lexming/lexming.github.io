---
title: Regex capture groups
created: 2022-08-03
modified: 2026-09-20
tags:
  - regex
---
Regex _capture groups_ is a mechanism in regular expressions to define parts of the pattern as their own entity with a unique identifier. This allows to refer to any _capture group_ on the match and execute actions on it.

## Capture groups syntax 

A _capture group_ is simply defined on a regex pattern with parenthesis

```
Hello (world)
```

Each capture group is defined by an integer ID number and  the main regex pattern always has ID 0. The previous example results in the following capture groups:
* 0: Hello world
* 1: world

*Capture groups* can be nested. The following example results in 4 groups:

```
Hello (b(eau)tiful) (world)
```
* 0: Hello beautiful world
* 1: beautiful
* 2: eau
* 3: world

## Example with capture groups

Use of regex _capture groups_ to convert single-line `print` statements in Python 2 to new function format `print()` in Python 3:

```
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

>[!note]
> On `sed` it is necessary to either escape the parenthesis of the capture groups or execute it with _extended regular expressions_ enabled with the `-r` option.

