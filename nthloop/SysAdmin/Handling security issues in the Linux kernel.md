---
title: Handling security issues in the Linux kernel
created: 2026-07-04
modified: 2026-07-14
tags:
  - rhel
  - rocky
  - fedora
  - rpm
  - kernel
---
Linux distributions typically release with some hand-picked version of the Linux kernel that is several months behind upstream kernel development. That kernel code base is kept as the foundation of the release and will only receive minor updates during its lifetime. Those updates are mostly bug fixes and do not add new features or drivers to the kernel.

This approach ensures the stability of the system until the next release, as the kernel will not drastically change behaviour with day-to-day updates. On the other hand, receiving the most recent fixes for security vulnerabilities requires extra work from maintainers of the distribution in backporting the corresponding patches from the most recent kernel version to the version used in their distro.

The usual disclosure timeline of 90 days for security vulnerabilities allows enough time to maintainers to backport, package and release kernel fixes. However, the recent influx of exploits published for the Linux kernel is stressing this system, with publications of exploits ignoring those disclosure timelines and maintainers not having enough time to deal with so many new vulnerabilities.

This is specially critical on HPC systems as there has been many local privilege escalation (LPE) vulnerabilities released in the past months:
* [DirtyClone](https://thehackernews.com/2026/06/new-dirtyclone-linux-kernel-flaw-lets.html?m=1)
* [pedit COW](https://tuxcare.com/blog/pedit-cow-cve/)
* [Bad Epoll](https://github.com/J-jaeyoung/bad-epoll)

LPEs are critical on HPC as our users (_i.e._ researchers) are non-root local users allowed to execute any arbitrary code they wish in the system. So, every time that there is a new LPE disclosed to the public without an existing fix in our distribution kernel, we are forced to lock-down access to our clusters.

Therefore, we find ourselves with the need to patch the kernel as fast as possible; which in many cases means to patch it on our own without waiting for the distribution to release their fixes, as that can delay our operations by weeks.
## Patch and rebuild the kernel RPM

Patching and rebuilding the Linux kernel follows the same procedure as [[Patching an RPM package]].

The hardest part is to get the patch file ready for your specific version of the Linux kernel. If you are lucky, this can be as easy as reusing the same patch for the current upstream version of the kernel; but usually those do not apply and you will need to back-port it with obscure arts.

1. Get the source package (SRPM) of your kernel and install it with its build dependencies. See [[Patching an RPM package]]
   ![[2026-07-04-pkgsorg-srpm-link.png]]
   
2. Once you have your patch file, place it in `~/rpmbuild/SOURCES`. The name of the patch file has usually the form `9999-description.patch`.

3. Jump to `~/rpmbuild/SPECS/` which contains the _spec_ file to build the kernel RPM and update it to apply your patch

   ```diff
   --- kernel.spec 2026-07-04 18:58:04.061731102 +0200
   +++ kernel.spec 2026-07-04 18:53:08.555763833 +0200
   @@ -959,6 +959,7 @@
    # empty final patch to facilitate testing of kernel patches
    Patch999999: linux-kernel-test.patch
    Patch1000000: 1000-debrand-some-messages.patch
   +Patch9000000: 9000-fix-cve-2026-00000.patch
   
    # END OF PATCH DEFINITIONS
   
   @@ -1663,6 +1664,7 @@
   
    ApplyOptionalPatch linux-kernel-test.patch
    ApplyOptionalPatch 1000-debrand-some-messages.patch
   +ApplyOptionalPatch 9000-fix-cve-2026-00000.patch
    
    # END OF PATCH APPLICATIONS
   ```

4. Rebuild the kernel

   ```bash
   rpmbuild --define "buildid .lex.1" -bb kernel.spec |& tee kernel-build.log
   ```

   Defining a custom `buildid` helps identify this specific kernel image and avoid name collisions with those from your distro.
   
   It is possible to speed up the build by disabling unneeded features. Adding the option `--with baseonly` to the `rpmbuild` command will skip most extra kernel variants such as the _real-time kernel (rt)_.

Once the build is complete, the new RPMS will be located in `~/rpmbuild/RPMS/x86_64/`.
