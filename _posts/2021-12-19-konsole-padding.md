---
title: "KDE Konsole padding"
date: 2021-12-19 18:00
categories: linux
tags: kde
---

[Konsole](https://userbase.kde.org/Konsole), KDE's terminal emulator, supports
changing the padding space in its terminal window.

![Konsole with extra padding](/assets/2021-12-19-konsole-padding.png)

This property can be changed from the graphical interface of Konsole since
v19.04. It is called _Margins_ and it can be found in: 

**Settings** > **Edit Current Profile** > **Appearance** (left toolbox) > 
**Miscellaneous** (tab) > **Margins**

Alternatively, the padding of the terminal window can also be set in your
profile configuration file. Which also works in older versions of Konsole
without the toggle in the GUI. Change the default padding by setting the
`TerminalMargin` parameter to the desired value of pixels in the *General*
section of your profile file in `~/.local/share/konsole/`

```python
[General]
Name=lexming
Parent=FALLBACK/
TerminalColumns=120
TerminalMargin=12
TerminalRows=48
```
{: file="~/.local/share/konsole/lexming.profile" }

