---
title: "Make error: Argument list too long"
date: 2022-10-27
tags:
- make
---

I got the following error compiling [nodejs](https://nodejs.org) v16.15.1 with [GCC](https://gcc.gnu.org/) v10.3.0:

> touch /theia/scratch/brussel/vo/000/bvo00000/vsc10000/easybuild/install/skylake/build/nodejs/16.15.1/GCCcore-10.3.0/node-v16.15.1/out/Release/obj.target/tools/v8_gypfiles/v8_compiler_for_mksnapshot.stamp
> 
> **make[1]: execvp: printf: Argument list too long**
> 
> make[1]: *** [/theia/scratch/brussel/vo/000/bvo00000/vsc10000/easybuild/install/skylake/build/nodejs/16.15.1/GCCcore-10.3.0/node-v16.15.1/out/Release/obj.target/tools/v8_gypfiles/libv8_base_without_compiler.a] Error 127
> 
> rm 5bbfd6c4a8f8ff3451772da37fa142cac4520fdc.intermediate c551182bfbb57b84e78564bf84990af2837af887.intermediate
> 
> make[1]: Leaving directory `/theia/scratch/brussel/vo/000/bvo00000/vsc10000/easybuild/install/skylake/build/nodejs/16.15.1/GCCcore-10.3.0/node-v16.15.1/out'
> 
> make: *** [node] Error 2

The error `printf: Argument list too long` is not related to the GCC compiler
but the build with `make`. The issue is caused by some command that becomes too
long, not only because of a large number of arguments but also because of a too
long argument line. I typically hit this type of error in nodejs and
[Qt5](https://www.qt.io/). For instance, nodejs is known to have long linker
commands aggregating many objects in static binaries
([Gentoo#809935](https://bugs.gentoo.org/809935)).

In my case, the main cause of this error is the path to the build directory:

```
/theia/scratch/brussel/vo/000/bvo00000/vsc10000/easybuild/install/skylake/build/nodejs/16.15.1/GCCcore-10.3.0/node-v16.15.1
```

The build directory is quite deep within the filesystem and, most importantly,
it is long. Commands in the build process dealing with many files referenced
with their absolute paths will become too long and trigger this error.

The solution is as simple as carrying out the build in a different directory
with a shorted absolute path. I exceptionally execute such builds in a temporary
directory in `/tmp`. [EasyBuild](https://easybuild.io/) allows to change the
location of the build directory for a single build by just setting the command
line option `--buildpath`.

