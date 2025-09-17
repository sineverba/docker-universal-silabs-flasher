IMAGE_NAME=sineverba/universal-silabs-flasher
CONTAINER_NAME=universal-silabs-flasher
VERSION=0.1.0-dev
PYTHON_VERSION=3.13.7
TOPDIR=$(PWD)

build:
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--tag $(IMAGE_NAME):$(VERSION) \
		--file Dockerfile \
		"."

upgrade:
	pip install --upgrade pip
	sed -i 's/==/>=/' requirements.txt
	pip install -r requirements.txt
	pip freeze > requirements.txt
	sed -i 's/>=/==/' requirements.txt

inspect:
	docker run \
	--privileged \
	-e "FILENAME=firmware.gbl" \
	-v $(TOPDIR)/firmware/:/home/flash/app \
	-v /dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_aaaaaaaaaaaaa-if00-port0:/dev/USB0 \
	-v /run/udev:/run/udev:ro \
	--rm -it \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION) \
	/bin/sh

spin:
	docker run \
	--privileged \
	-e "FILENAME=firmware.gbl" \
	-v $(TOPDIR)/firmware/:/home/flash/app \
	-v /dev/serial/by-id/usb-Itead_Sonoff_Zigbee_3.0_USB_Dongle_Plus_V2_aaaaaaaaaaaaa-if00-port0:/dev/USB0 \
	-v /run/udev:/run/udev:ro \
	--rm -it \
	--name $(CONTAINER_NAME) \
	$(IMAGE_NAME):$(VERSION)

test:
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) cat /etc/os-release | grep "Alpine Linux"
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) python --version | grep $(PYTHON_VERSION)
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) pip3 --version | grep "pip 24.0"
	
destroy:
	# Remove all images with no current tag
	docker rmi $$(docker images $(IMAGE_NAME):* --format "{{.Repository}}:{{.Tag}}" | grep -v '$(APP_VERSION)') || exit 0;
	# Remove all python images
	docker rmi $$(docker images python --format "{{.Repository}}:{{.Tag}}") || exit 0;
	# Remove all dangling images
	docker rmi $$(docker images -f "dangling=true" -q) || exit 0;
	# Remove cached builder
	docker builder prune -f
