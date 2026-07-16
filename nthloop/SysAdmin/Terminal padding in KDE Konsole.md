---
title: Terminal padding in KDE Konsole
created: 2021-12-19
modified: 2021-12-19
tags:
  - kde
---
KDE [Konsole](https://userbase.kde.org/Konsole) supports changing the padding space in its terminal window.

![Konsole with extra padding](/assets/2021-12-19-konsole-padding.png)

This property can be set from the graphical interface of Konsole since v19.04. It is called _Margins_ and it can be found in: 

_Settings_ > _Edit Current Profile_ > _Appearance_ (left toolbox) > _Miscellaneous_ (tab) > **Margins**

Alternatively, the padding of the terminal window can also be set in your profile configuration file. Which also works in older versions of Konsole without the toggle in the GUI. Change the default padding by setting the `TerminalMargin` parameter to the desired value of pixels in the *General* section of your profile file in `~/.local/share/konsole/`

```config showLineNumbers
[General]
Name=lexming
Parent=FALLBACK/
TerminalColumns=120
TerminalMargin=12
TerminalRows=48
```
