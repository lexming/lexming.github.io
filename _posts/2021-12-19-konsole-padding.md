---
title: "KDE Konsole padding"
date: 2021-12-19 18:00
categories: linux
tags: kde
---

[Konsole](https://userbase.kde.org/Konsole), KDE's terminal emulator, supports
changing the padding space in its terminal window. However, this setting is not
available in its user interface (on version 21.12.2) and can only be set in your
profile file.

Change the default padding by setting the `TerminalMargin` parameter to the
desired value of pixels in the *General* section of your profile file in
`~/.local/share/konsole/`

```python
[General]
Name=lexming
Parent=FALLBACK/
TerminalColumns=120
TerminalMargin=12
TerminalRows=48
```
{: file="~/.local/share/konsole/lexming.profile" }

![Konsole with extra padding](/assets/2021-12-19-konsole-padding.png)
