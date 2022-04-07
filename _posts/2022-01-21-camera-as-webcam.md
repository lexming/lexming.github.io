---
title: "Mirrorless camera as webcam in Linux"
date: 2022-01-22 16:00
categories: linux
tags: fedora audio video
---

Some modern camera models can be directly connected to the computer through USB
and be detected as a webcam. That's the easiest setup, but beware that this mode
of operation might need special programs/drivers with no support for Linux. The
more general approach is to use some video capture device that can take the HDMI
output of the camera, stream it through USB and present itself as a USB webcam.

## Camera conversion to USB webcam

In my case, the camera is a Fujifilm X-E3 which can send clean video through its
HDMI output and I use Elgato Cam Link 4K to *convert* the video signal to USB.
Once the camera is connected to the computer, it is recognized as any regular
USB webcam thanks to the open source `uvcvideo` kernel module. Linux kernel
v5.14 fixed an [issue with the reported pixel format by the Cam
Link](https://github.com/AdamGleave/elgato-camlink-workaround), so any Linux
distribution with a recent kernel (or backported patches) should work with this
device out of the box.

## Virtual webcam in OBS Studio

[OBS Studio](https://obsproject.com/) is very useful to mix audio and video
streams in real time. For instance, I use it to sync the audio of my mic or
capture my computer desktop overlaying my cam in a corner of the stream.

Since version 26.1 (Dec 2020), OBS natively provides a Virtual Camera output,
which allows to catch its stream from any video chat application. OBS itself
will appear as a new webcam device. Enabling this option requires the kernel
module [v4l2loopback](https://github.com/umlaeute/v4l2loopback), which might not
be installed by default.

In Fedora 35, [OBS Studio v26.1+ is already available as a
flatpak](https://flathub.org/apps/details/com.obsproject.Studio) and you can
install v4l2loopback with the following command:

```console
$ sudo dnf install kmod-v4l2loopback
```

Once v4l2loopback is installed, restart OBS Studio and the new option *Start
Virtual Camera* will appear below the *Start Recording* button.

**Note:** Some video call applications limit the video resolution of the webcam
device (*e.g.* MS Teams accepts 1280x720 max). In such a case, set the required
resolution of the output stream in OBS in Settings > Video > Output (Scaled)
Resolution.

## Virtual microphone

One limitation of the Virtual Camera in OBS is that it only contains the video
stream. If you want to use the audio stream from OBS in your video call as well,
you will need to redirect its audio into a virtual mic. This can be done with
[PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/) by creating
a `null-sink` device as virtual speaker and **remapping its monitor to a new
audio source** as virtual mic. These two virtual audio devices allow to redirect
the audio from any application to any other application.

1. Create virtual speaker

    ```console
    $ pactl load-module module-null-sink sink_name=Virtual-Speaker sink_properties=device.description=Virtual-Speaker
    ```

2. Remap monitor of virtual speaker as virtual mic

    ```console
    $ pactl load-module module-remap-source source_name=Virtual-Mic master=Virtual-Speaker.monitor
    ```

The advantage of this approach is that it does not depend on any specific audio
device. The previous commands should work in any system with PulseAudio.


## Redirect audio in OBS to virtual speaker

1. Set the monitoring device of your stream in OBS to *Monitor of Virtual Speaker*.
This setting is located in Settings > Audio > Advanced > Monitoring device.

2. All audio sources of your stream in OBS should be real audio devices (*i.e.*
   the real mic)

3. In the video call application:

    * choose *OBS Virtual Camera* as webcam
    * choose *Virtual Mic* as mic or, alternatively, set the *Virtual Mic* as
      default mic in PulseAudio

