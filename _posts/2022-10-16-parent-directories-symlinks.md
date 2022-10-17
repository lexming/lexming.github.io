---
title: "Navigating through the parent directory of symlinks in bash"
date: 2022-10-16 12:00
categories: linux
tags: bash
---

Changing directory `cd` to a [symlinked](https://en.wikipedia.org/wiki/Symbolic_link)
folder can have unexpected consequence on how certain commands in bash behave.

For instance, assume that we have the following file structure where
`active_project` is a symlink to a folder nested in another file tree:

```
.
├── data
│   ├── project1
│   │   ├── 01-01.csv
│   │   ├── 01-02.csv
│   │   └── 01-03.csv
│   └── project2
│       ├── 02-aa.csv
│       └── 02-ab.csv
└── active_project -> data/project2

4 directories, 5 files
```

Once we change directory into `active_project`, the commands `ls` and `cd` will
interpret `..` differently and show different contents for its parent folder:

```shell
$ cd active_project/

$ ls ..
project1  project2

$ (cd .. && ls)
data  project
```

This different outcome is due to how `cd` works. The command `cd` is a built-in
command in bash and as such, it works with the path reported by `pwd` which is
aware of the actual file path followed by the user. Hence, `cd` will follow the
symlink backwards. On the other hand, the command `ls` is a regular executable
and it works with the real path or physical path of the current folder.
Therefore, in the previous example, `ls` will jump to the actual folder that
contains `project2`.

TAB completion can also behave differently depending on the default settings of
bash in your Linux distribution or if extra bash completions are included. The
built-in completion for `cd` in bash should follow the symlink on `..`
backwards, as `cd` does. If that's not the case, an external bash completion
might be interfering. You can switch back to the built-in completion for `cd`
with the following command in your `.bashrc`:

```shell
complete -r cd
```
{: file="~/.bashrc" }
