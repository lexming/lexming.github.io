---
date: 2025-07-18
tags:
  - c/cpp
  - linker
---
Compilation completes, the linker comes in and surprise!

```
/bin/ld: path/to/libfoo.so: undefined reference to `some_symbol`
error: ld returned 1 exit status
```

The linker cannot find some symbols used in the program from third-party libraries. This errors usually happens due to:
* the list of linker flags (`-l`) lacks the library name providing those missing symbols, being either shared or static libraries
* the collection of shared libraries used by the linker do not depend (or have a broken dependency) on the library providing those missing symbols
## Listing symbols in library

The `nm` command in GNU Linux is the common tool used to print all symbols found in a shared library:

### Shared libraries

```bash
$ nm -D /usr/lib64/libc.so.6
000000000001ac00 T a64l@@GLIBC_2.2.5
00000000000016aa T abort@@GLIBC_2.2.5
00000000001e9b40 B __abort_msg@@GLIBC_PRIVATE
000000000001ad00 T abs@@GLIBC_2.2.5
```

The output of `nm` for a shared library shows all symbols defined or referenced in the library. Each line corresponds to one symbol and it contains its _value_, _type_ and _name_.

### Static libraries

```bash
$ nm -C /lib/gcc/x86_64-redhat-linux/15/libgcc.a

_muldi3.o:
0000000000000000 T __multi3

_negdi2.o:
0000000000000000 T __negti2
```

The output of `nm` for a static library shows the name of all objects contained in it and all the symbols defined or referenced in them. Each line corresponds to one symbol and it contains its _value_, _type_ and _name_.

> [!note]
> The [man page of nm](https://linux.die.net/man/1/nm) defines the meaning of all single character symbol types.

## Finding libraries with a symbol

Finding which library in your system provides a given symbol can be simply done by executing `nm` on all shared or static libraries found in some given directory:

### Shared libraries

```bash
fd '.*\.so$' /path/to/target/libdir -x bash -c \
    "nm -D --defined-only {} 2>/dev/null \
    | grep 'symbol_name' && echo '╰╴>>> found in: {}'"
```
ref: [stackoverflow.com](https://stackoverflow.com//questions/19916119/how-do-i-find-where-a-symbol-is-defined-among-static-libraries#answer-56305840)

### Static libraries

```bash
fd '.*\.a$' /path/to/target/libdir -x bash -c \
    "nm --defined-only {} 2>/dev/null \
    | grep 'symbol_name' && echo '╰╴>>> found in: {}'"
```
ref: [stackoverflow.com](https://stackoverflow.com//questions/19916119/how-do-i-find-where-a-symbol-is-defined-among-static-libraries#answer-56305840)

Remove the `--defined-only` option from `nm` to find libraries referencing the given `symbol_name` in any way.

### Usual suspects

The first place to look are the library search paths defined in the active shell. GCC searches for linker files in the locations defined in `$LIBRARY_PATH`, while `$LD_LIBRARY_PATH` is used at runtime.

```bash
IFS=:
for libdir in $LD_LIBRARY_PATH; do
    echo "=== checking $libdir ..."
    fd '.*\.so$' $libdir -x bash -c \
        "nm -D {} 2>/dev/null \
        | grep 'symbol_name' && echo '╰╴>>> found in: {}'"
done
```