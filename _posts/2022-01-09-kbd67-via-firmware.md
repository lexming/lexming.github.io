---
title: "Upgrade KBD67v2 to VIA compatible firmware"
date: 2022-01-09 16:00
categories: linux
tags: keyboards
---

Keyboards with [VIA](https://caniusevia.com/) compatible firmwares can have
their layouts easily configured with the
[VIA Configurator](https://github.com/the-via/releases/releases), a user-space
application that can be run without any special permissions and that supports
Linux! :tada: This method removes the need to build and re-flash a new firmware
into the keyboard each time that it has to be re-programmed, which is time
consuming and requires tools not supporting Linux.

Even though the factory firmware in my [KBDfans KBD67v2](https://kbdfans.com/)
is not VIA compatible, it is actually supported by VIA and they provide a new
firmware for this keyboard. So, let's upgrade it:

1. Download VIA compatible firmware from
   <https://caniusevia.com/docs/download_firmware/>

    * The file for KBDv2 is `kbdfans_kbd67_rev2_via.hex`

2. Flash VIA firmware to KDB67v2 with [QMK
   Toolbox](https://github.com/qmk/qmk_toolbox)

    :warning: QMK Toolbox only works on **Windows** or **Mac** systems

    1. (Re-)Connect the keyboard in bootloader mode by pressing `Space + B`
       while you plug its USB cable
    2. Launch QMK Toolbox
    3. Select `kbdfans_kbd67_rev2_via.hex` as *Local file*
    4. Select `atmega32u4` as *Microcontroller*
    5. Select `kbdfans/kbd67/rev2` as *Keyboard*
    6. Click `Flash` (disabled if the keyboard is not in bootloader mode, see
       step 2.1)

3. Download and install
   [VIA Configurator](https://github.com/the-via/releases/releases){: .shadow }

With this new firmware, VIA Configurator now recognizes my KBD67v2 on launch and
I can not only configure its multiple layout layers, but also control the
backlight settings. All changes are applied and stored in the keyboard
on-the-fly as well.

![KBD67v2 on VIA Configurator](/assets/2022-01-09-kbd67-via-firmware_via-conf.png)
