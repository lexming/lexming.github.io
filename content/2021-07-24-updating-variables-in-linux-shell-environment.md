---
title: "Updating variables in Linux shell environment"
date: 2021-07-24 12:00
categories: linux
tags: bash
---

Manipulating environment variables can be tedious as it is almost always necessary to check if the target variable already exists, its value and act in consequence. Fortunately, [shell parameter expansion in bash](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) provides an effective mechanism to quickly deal with those checks and it is specially useful in handling default values and expanding lists of paths.

# Default values

The minus ``-`` operator in the expansion will substitute the preceding parameter if it is unset with the result of the expansion of the *word* after it. Hence, ``-`` allows to easily assign default values to any shell variables. It is also possible to use an extra colon in the operator ``:-`` to substitute parameters that are **unset or null**.

```console
PARAMETER=${PARAMETER:-default}
```

# Expand a list of paths

Environment variables defining a collection of paths (*i.e.* ``$PATH``, ``$LD_LIBRARY_PATH``) are usually formed as a simple colon-separated list of paths. In this case, the goal is to set or update those variables avoiding any trailing ``:`` characters.

The plus ``+`` operator in the expansion only performs the substitution if the preceding parameter already exists. Such a substitution can be used on the target list of paths to automatically prepend/append an extra colon. Therefore, combining this substitution with any path in the definition of the shell variable will cleanly set or update it with the new path.

```console
# Prepend path if $PATH exists
export PATH=${PATH+${PATH}:}$HOME/new/bin
# Append path if $PATH exists
export PATH=$HOME/new/bin${PATH+:${PATH}}
```
