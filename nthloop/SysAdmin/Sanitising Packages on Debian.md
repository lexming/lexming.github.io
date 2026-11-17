---
title: Sanitising Packages on Debian
created: 2026-11-01
modified: 2021-11-01
tags:
  - debian
---

The longer a system runs the more likely it will accumulate _broken_ or _undesired_ package installations. Even if you use some [IaC](https://en.wikipedia.org/wiki/Infrastructure_as_code) solution, some stuff might not be properly cleaned-up and just stay.

In my case this mostly happens on system upgrades to a new major [Debian release](https://www.debian.org/releases/). I do not flash the new system on the boot device, which is a hassle as that requires physically manipulating the SBC and a longer downtime. So I push the update live and deal with any package conflicts and configuration updates on-the-fly. Then I restart services one-by-one and once everything is clean and consistent, the system reboots.

## Manual Packages and Dependencies

There are two types of packages:

* _Manual packages_ are those packages explicitly installed by the distro, so-called core packages, or by the user.
* _Dependencies_ are packages installed as requirement for other packages, they are automatically determined by the package manager and ultimately all stem from manual packages.

Both manual packages and dependencies can be removed from the system with `apt remove {pkg_name}`. This command will remove the target package from the system and from the list of manually installed packages (if it was there). However, it will not remove any dependencies, potentially leaving [[#Orphan packages]] in the system.

## Orphan Packages

Orphans are packages that were needed by some other package in the past that no longer exists in the system. They are always dependencies left over from a previous package removal (_e.g._ with `apt remove`).

Orphans can be simply cleaned-up with the command

```bash
apt autoremove
```

Auto-remove will not remove any _manual packages_.

## Obsolete Packages

Manual packages can become obsolete on major system upgrades. Usually this happens with packages that do not exist on the new version of the system and have no automatic upgrade path. In that case, the package manager will leave the old package in the system as a safety measure and flag it as _obsolete_.

> [!note]
> Obsolete packages are not necessarily a problem. The package manager will basically ignore them. They can stay in the system as long as they continue to work (no broken dependencies) or they do not conflict with other modern packages.

Cleaning-up obsolete packages requires manual action:

1. List obsolete packages in the system

   ```bash
   apt list --installed '?obsolete'
   ```

2. Either replace or remove the orphan
   * If the functionality of the package is now provided by another package, manually install the new one and remove the obsolete
   * If there is no modern alternative, just remove the obsolete package (if no longer needed)

## Undesired Manual Packages

Some packages might be wrongly flagged as _manual_ and will never be removed from the system. Such packages are commonly dependencies (_e.g._ libraries) that were accidentally installed by the user with `apt install` or they could be defined by the distro as manual to protect them from removal.

Cleaning-up such packages should be done carefully, as they might be still needed and removing them can lead to a broken system:

1. Identify manual packages

   ```bash
   apt-mark showmanual
   ```

2. Check effects of removal of manual package

   ```bash
   apt remove --dry-run {pkg_name}
   ```

   If package does not cause any broken dependencies, it can be simply removed with `apt remove`.

3. Manual packages that are dependencies of other packages should not be uninstalled, but they can be removed from the list of manual packages to become regular dependencies.
   This is commonly the case with `lib*` packages. The following command will set all libraries as non-manual packages:

   ```bash
   apt-mark auto lib*
   ```

   From now on, whenever those libraries become [[#Orphan packages]], they will be automatically cleaned-up by `apt autoremove`.

   