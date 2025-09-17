Universal Silabs Flasher Docker
===============================

> Docker image to flash firmware on Silicon Labs EFR32MG21 Zigbee keys, like the Sonoff ZBDongle-E (ZigBee 3.0 USB Dongle Plus v2)

| CI / CD | Status |
| ------- | ------ |
| Semaphore | [![Build Status](https://sineverba.semaphoreci.com/badges/docker-universal-silabs-flasher/branches/master.svg?style=shields&key=177dc3d1-ccb5-43c5-95ad-06fb51346f81)](https://sineverba.semaphoreci.com/projects/docker-universal-silabs-flasher) |
| CircleCI | [![CircleCI](https://dl.circleci.com/status-badge/img/gh/sineverba/docker-universal-silabs-flasher/tree/master.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/sineverba/docker-universal-silabs-flasher/tree/master) |


## Available architectures

+ linux/arm64
+ linux/arm/v6
+ linux/arm/v7

## How to use

1. Get the serial by ID `/dev/serial/by-id/`
2. Download the firmware to write
3. Run Docker with (replace your serial ID)

```shell
docker run \
	--privileged \
	-e "FILENAME=firmware.gbl" \
	-v $(TOPDIR)/firmware/:/home/flash/app \
	-v /dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_aaaaaaaaaa-if00-port0:/dev/USB0 \
	-v /run/udev:/run/udev:ro \
	--rm -it \
	--name usf \
	sineverba/universal-silabs-flasher:0.1.0
```
