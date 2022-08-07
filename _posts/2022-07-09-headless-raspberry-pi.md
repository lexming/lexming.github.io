---
title: "Bootstrap a headless Raspberry Pi"
date: 2022-07-09 20:00
categories: linux
tags: debian
---

Nowadays, thanks to the `rpi-manager` from [Raspberry Pi
OS](https://www.raspberrypi.com/software/), it is quite trivial to bootstrap a
Raspberry Pi into a working system in your network with no other interaction
than inserting the SD card and plugging in the device. No peripherals and no
display needed. 

1. Insert a blank SD card in your computer and launch `rpi-imager`
2. Select the OS image for your Raspberry Pi
3. Click the cogwheel button on the bottom right
    * Enable SSH
    * Set a custom username and password
4. Write the image into the SD card, insert the card into your Raspberry Pi and
   boot it up.
5. The Raspberry Pi will get its IP address by DHCP. Check your network router
   to get its IP. 
6. Connect with SSH using your user/password

At this point, if you can login with SSH, your Raspberry Pi is running and
connected. The following are some optional configurations that I usually apply
to the Raspberry Pis in my network.

## Key-based SSH authentication

1. Copy your SSH key to the Raspberry Pi

    ```
    ssh-copy-id -i .ssh/<some_id_rsa> username@<rpi-hostname-or-ip>
    ```
2. Once you can login with your SSH key, disable SSH connections with password

    ```
    PasswordAuthentication no
    ```
    {: file="/etc/ssh/sshd_config" }

## Disable the radios

Wi-Fi and Bluetooth might not be necessary if your Raspberry Pi is connected
with Ethernet.

1. Edit `/boot/config.txt` in Raspberry Pi OS (Raspbian) or `/boot/firmware/config.txt`
   in Ubuntu and append the following settings to disable Wi-Fi and Bluetooth
    ```
    [pi4]
    # Disable all radios
    dtoverlay=disable-wifi
    dtoverlay=disable-bt
    ```
    {: file="/boot/config.txt" }

## Enable a watchdog

The Raspberry Pi board has a [watchdog timer](https://en.wikipedia.org/wiki/Watchdog_timer).
This can be used to automatically reboot the system in case of problems. For
instance, if the system hangs due to out-of-memory errors.

1. Edit `/boot/config.txt` in Raspberry Pi OS (Raspbian) or
   `/boot/firmware/config.txt` in Ubuntu and append the following to enable the
   watchdog timer
    ```
    [pi4]
    # Enable watchdog
    dtparam=watchdog=on
    ```
    {: file="/boot/config.txt" }

2. Enable the watchdog service in [systemd](https://systemd.io/)
    ```
    RuntimeWatchdogSec=15s  # hardware limitation of RPi
    RebootWatchdogSec=10min
    #KExecWatchdogSec=0
    WatchdogDevice=/dev/watchdog
    ```
    {: file="/etc/systemd/system.conf" }

    > The watchdog timer in the Raspberry Pi is limited to 15 seconds (max) by hardware
    {: .prompt-info }
   	
3. Reload config and reboot
    ```console
    $ systemctl daemon-reload
    $ systemctl reboot
    ```

4. Check after boot that watchdog is active
    ```console
    # dmesg | grep watchdog
    [    1.792121] bcm2835-wdt bcm2835-wdt: Broadcom BCM2835 watchdog timer
    [    3.552959] systemd[1]: Using hardware watchdog 'Broadcom BCM2835 Watchdog timer', version 0, device /dev/watchdog
    [    3.563591] systemd[1]: Set hardware watchdog to 15s.
    ```

