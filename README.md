# docker-domoticz
A Domoticz container based on Debian stretch-slim
[![Build Status](https://travis-ci.org/iamthemitch/docker-domoticz.svg?branch=master)](https://travis-ci.org/iamthemitch/docker-domoticz) [![Build status](https://ci.appveyor.com/api/projects/status/miaha45xx76jy8ul?svg=true)](https://ci.appveyor.com/project/iamthemitch/docker-domoticz) [![](https://images.microbadger.com/badges/image/glaurent/docker-domoticz.svg)](https://microbadger.com/images/glaurent/docker-domoticz "Get your own image badge on microbadger.com") [![](https://images.microbadger.com/badges/version/glaurent/docker-domoticz.svg)](https://microbadger.com/images/glaurent/docker-domoticz "Get your own version badge on microbadger.com")

[![domoticz](https://github.com/domoticz/domoticz/raw/master/www/images/logo.png)](http://www.domoticz.com)

[Domoticz](http://www.domoticz.com) is a Home Automation System that lets you monitor and configure various devices like: Lights, Switches, various sensors/meters like Temperature, Rain, Wind, UV, Electra, Gas, Water and much more. Notifications/Alerts can be sent to any mobile device.

### Pull image
`docker pull glaurent/docker-domoticz`

### Usage
#### Create named volume:
~~~bash
docker volume create domoticz_data
~~~
#### Create container:
~~~bash
docker create --name=domoticz \
  -v domoticz_data:/data \
  --device <path to device> \
  -p 8080:8080 \
  -v /etc/localtime:/etc/localtime:ro \
  -v /etc/timezone:/etc/timezone:ro \
  glaurent/docker-domoticz
~~~

### Parameters
* `-v domoticz_data:/data` - Volume for database persistence.
* `-p 8080:8080` - Map HTTP GUI port.
* `--device <path to device>` - for passing through USB devices. Add as many as required.

#### Passing Through USB Devices
To get full use of *Domoticz*, you probably have a USB device you want to pass through.
To figure out which device to pass through, you have to connect the device and look in `dmesg` for the device node created.
Issue the command `dmesg | tail` after you connected your device and you should see something like below.

~~~log
usb 1-1.2: new full-speed USB device number 7 using ehci-pci
ftdi_sio 1-1.2:1.0: FTDI USB Serial Device converter detected
usb 1-1.2: Detected FT232RL
usb 1-1.2: FTDI USB Serial Device converter now attached to ttyUSB0
~~~
As you can see above, the device node created is `ttyUSB0`.
It does not say where, but it's almost always in `/dev/`.
The correct tag for passing through this USB device is `--device=/dev/ttyUSB0`.

### Access Domoticz
    http://<host ip>:8080
