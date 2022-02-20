---
title: "Poor man's history fuzzy finder"
date: 2022-02-19 16:00
categories: linux
tags: bash
---

[Fuzzy finders](https://en.wikipedia.org/wiki/Fuzzy_finder) are very useful
tools to skim through long lists of results by filtering those items that
approximately match a given string(s). In linux, we can get a fuzzy finder right
in the terminal with [fzf](https://github.com/junegunn/fzf).

We can also make a very simple fuzzy finder by using `grep` in a recursive
function in `bash`. The goal is to consecutively match the input text with each
and all pattern strings in the argument list. This can serve as a rudimentary
solution if `fzf` is not available in your system (or, you know, just for fun!
:sunglasses:).

## Recursive grep

The recursive function will pick the top pattern string in the argument list,
execute `grep` on the input to match that pattern, shift the arguments and pass
the result to itself. I call this function `rgrep`

```bash
function rgrep {
    if [ "$1" ]; then
        local pattern="$1"
        if [ "$2" ]; then
            shift
            grep -- "$pattern" | rgrep "$@"
        else
            grep -- "$pattern"
        fi
    fi
}
```

The result is equivalent to perform a logical *AND* on all patterns with the
command

```console
$ cat input.txt | grep 'pattern1' | grep 'pattern2' | grep 'pattern3'
```

But with a simpler syntax, similar to a fuzzy finder

```console
$ cat input.txt | rgrep 'pattern1' 'pattern2' 'pattern3'
```

## History fuzzy finder

Our new command `rgrep` can be easily applied to any command that prints lists of results, such
as `history`. For instance, I set `hgrep` as the following alias to easily find commands in
my history log

```console
$ alias hgrep='history | rgrep'
```

Example:

```console
$ hgrep dnf openssl
  611  dnf install openssl-devel
  623  sudo dnf autoremove openssl-devel
 1014  hgrep dnf openssl
```
