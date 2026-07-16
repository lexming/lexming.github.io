---
title: Disable meta key on KDE App Launcher
created: 2021-12-19
modified: 2026-06-20
tags:
  - kde
---
The default key shortcut for KDE's Application Launcher is the meta_ key. Also known as super_ key and which I already heavily use to move across virtual desktops and position windows. Having that launcher take possession of the _meta_ key as a single key shortcut is very inconvenient, as that effectively removes the option to use the _meta_ key in any other shortcut in combination with other keys.

Therefore, one of the first things I do on a new KDE system is to disable that default shortcut of the Application Launcher.

1. Open **System Settings**
2. Go to **Keyboard** > **Shortcuts**
3. Search for _Activate Application Launcher_
4. Uncheck the shortcut for the _Meta_ key

![[2026-06-20-kde-launcher-shortcut.png]]

> [!info] Update (20/06/2026)
> Nowadays I keep all my custom KDE shortcuts on version control in a Git repo. The **Shortcuts** panel in **System Settings** has a button to _Export_ all your shortcuts. Hence, whenever I need to configure a new system I just _Import_ that file in that same panel (see screenshot above). 