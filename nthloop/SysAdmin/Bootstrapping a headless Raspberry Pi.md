---
title: Bootstrapping a headless Raspberry Pi
created: 2022-07-09
modified: 2022-07-09
tags:
  - debian
---
The `rpi-manager` from [Raspberry Pi OS](https://www.raspberrypi.com/software/) allows to easily bootstrap a Raspberry Pi into a working system in your network with no other interaction than inserting the SD card and powering the device. No peripherals and no display needed. 

1. Insert a blank SD card in your computer and launch `rpi-imager`
2. Select the OS image for your Raspberry Pi
3. Click the cogwheel button on the bottom right
    * Enable SSH
    * Set a custom username and password
4. Write the image into the SD card, insert the card into your Raspberry Pi and boot it up.
5. The Raspberry Pi will get its IP address by DHCP. Check your network router to get its IP. 
6. Connect with SSH using your user/password

At this point, if you can login with SSH, your Raspberry Pi is running and connected. The following are some optional configurations that I usually apply to the Raspberry Pis in my network.

## Key-based SSH authentication

1. Copy your SSH key to the Raspberry Pi

    ```shell
    ssh-copy-id -i .ssh/<some_id_rsa> username@<rpi-hostname-or-ip>
    ```

2. Once you can login with your SSH key, disable SSH connections with password

    ```shell showLineNumbers caption="/etc/ssh/sshd_config"
    PasswordAuthentication no
    ```

## Disable radios

Wi-Fi and Bluetooth might not be necessary if your Raspberry Pi is connected
with Ethernet.

>[!info]
> The boot configuration file is located at `/boot/config.txt` in Raspberry Pi OS (Raspbian) or `/boot/firmware/config.txt` in Ubuntu.

1. Append the following settings to the boot configuration file to disable
   Wi-Fi and Bluetooth

    ```shell showLineNumbers caption="/boot/config.txt"
    dtoverlay=disable-wifi
    dtoverlay=disable-bt
    ```

## Disable audio/video

Audio and video are usually not needed on a headless system. On-board audio,
HDMI output and video acceleration can be disabled with boot configuration
options.

1. Append the following settings to the boot configuration file to disable the on-board audio (HDMI audio will still work if the video core driver is loaded)

    ```shell showLineNumbers caption="/boot/config.txt"
    dtparam=audio=off
    ```

2. Remove from the boot configuration file any line loading the video driver overlay to disable video acceleration and both video and audio signals over HDMI. For instance, the overlay for the video driver for the Raspberry Pi 4 is loaded with `dtoverlay=vc4-kms-v3d`.

3. Append the following settings to the boot configuration file to switch off the HDMI ports and disable any framebuffers on boot:

    ```shell showLineNumbers caption="/boot/config.txt"
    hdmi_ignore_hotplug=1
    max_framebuffers=0
    ```

## Enable a watchdog

The Raspberry Pi board has a [watchdog timer](https://en.wikipedia.org/wiki/Watchdog_timer). This can be used to automatically reboot the system in case of problems. For instance, if the system hangs or crashes due to out-of-memory errors.

1. Append the following settings to the boot configuration file to enable the watchdog timer

    ```shell showLineNumbers caption="/boot/config.txt"
    dtparam=watchdog=on
    ```

2. Enable the watchdog service in [systemd](https://systemd.io/)

    ```shell showLineNumbers caption="/etc/systemd/system.conf"
    RuntimeWatchdogSec=15s  # hardware limitation of RPi
    RebootWatchdogSec=10min
    #KExecWatchdogSec=0
    WatchdogDevice=/dev/watchdog
    ```

    >[!note]
    > The watchdog timer in the Raspberry Pi is limited to 15 seconds (max) by hardware
   	
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

