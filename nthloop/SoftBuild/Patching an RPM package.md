---
title: Patching an RPM package
created: 2026-07-04
modified: 2026-07-14
tags:
  - rhel
  - rocky
  - fedora
  - rpm
---
Sometimes it is necessary to quickly fix a package in your Linux distribution. This is usually the case for critical security vulnerabilities on packages that do not yet have an updated version available. For instance, in [[Handling security issues in the Linux kernel]].

## Package sources from distribution

The first step is to obtain the source code of the package of your distribution. In our case, this is a RedHat based distribution using the [RPM package manager.](https://rpm.org/).

1. Download the _source package_ (SRPM) of the target package. These are not typically available in the RPM repositories of the system, but can be found online. For instance, [pkgs.org](https://pkgs.org/) lists the SRPM URL for each RPM package.

   Example for [libzstd-1.5.5-1.el9.x86_64.rpm](https://rockylinux.pkgs.org/9/rockylinux-baseos-x86_64/libzstd-1.5.5-1.el9.x86_64.rpm.html)
   ![[2026-07-14-pkgsorg-zstd-srpm-link.png]]

2. Install the source package

   ```bash
   rpm -i zstd-1.5.5-1.el9.src.rpm
   ```

Package sources including the tarball of the source code are unpacked into `~/rpmbuild/SOURCES`.

## Patch and rebuild the RPM

Once you have your patch file ready, place the file in `~/rpmbuild/SOURCES` . The name of the patch file has usually the form `9999-description.patch`.

Jump to `~/rpmbuild/SPECS/` which contains the _spec_ file of your RPM:

1. Update the _spec_ file to include your patch

   ```diff
   --- a/zstd.spec   2026-07-14 11:08:29.735529525 +0200
   +++ b/zstd.spec   2026-07-14 11:09:40.563386922 +0200
   @@ -26,6 +26,7 @@
    Source0:        https://github.com/facebook/zstd/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz
   
    Patch1:         man-pages-1.5.7.patch
   +Patch9999:      9999-fix-cve-2026-00000.patch
   
    BuildRequires:  cmake
    BuildRequires:  make
   @@ -72,6 +73,7 @@
    %setup -q
    find -name .gitignore -delete
    %patch 1 -p1
   +%patch 9999 -p1
   
    %build
    %if !%{with asm}
   ```

2. Define a custom release version

   Update the `Release` string in the _spec_ file with a custom one to avoid collision with the packages in your distro. Either brand it with your own custom tag or increase the release revision number.

   ```diff
   --- zstd.spec.orig      2026-07-14 11:18:25.006902972 +0200
   +++ zstd.spec   2026-07-14 11:18:31.723271235 +0200
   @@ -18,7 +18,7 @@
   
    Name:           zstd
    Version:        1.5.7
   -Release:        5%{?dist}
   +Release:        5-1%{?dist}
    Summary:        Zstd compression library
   
    License:        BSD-3-Clause OR GPL-2.0-only
   ```

3. Install the dependencies to build the RPM

   ```bash
   sudo dnf builddep zstd-1.5.5-1.el9.src.rpm
   ```

   The command `dnf builddep` usually fails to install all required packages to build the RPM. If the following commands fail due to missing packages, install those manually with `dnf install`.

4. Rebuild the RPM package

   ```bash
   rpmbuild -bb zstd.spec |& tee rpm-build.log
   ```

Once the build is complete, the new RPMS will be located in `~/rpmbuild/RPMS/`.
