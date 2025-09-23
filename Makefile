IMAGE_NAME=sineverba/universal-silabs-flasher
CONTAINER_NAME=universal-silabs-flasher
VERSION=0.1.0-dev
PYTHON_VERSION=3.13.7
PIP_VERSION=25.2
TOPDIR=$(PWD)

build:
	docker build \
		--build-arg PYTHON_VERSION=$(PYTHON_VERSION) \
		--build-arg PIP_VERSION=$(PIP_VERSION) \
		--tag $(IMAGE_NAME):$(VERSION) \
		--file Dockerfile \
		"."

# Get latest available pip version
get-latest-pip:
	@echo "Checking latest available pip version..."
	@LATEST_PIP=$$(docker run --rm python:$(PYTHON_VERSION)-alpine3.22 /bin/sh -c "pip install --upgrade pip > /dev/null 2>&1 && pip --version | awk '{print \$$2}'"); \
	echo "Latest pip version: $$LATEST_PIP"

# Update PIP_VERSION variable in Makefile
update-pip-version:
	@echo "Updating PIP_VERSION in Makefile..."
	@LATEST_PIP=$$(docker run --rm python:$(PYTHON_VERSION)-alpine3.22 /bin/sh -c "pip --version | cut -d' ' -f2"); \
	echo "Updating from $(PIP_VERSION) to $$LATEST_PIP"; \
	sed -i "s/^PIP_VERSION=.*/PIP_VERSION=$$LATEST_PIP/" Makefile; \
	echo "PIP_VERSION updated to $$LATEST_PIP"

# Upgrade Python dependencies
upgrade-deps:
	docker run --rm \
		-v $(TOPDIR):/workspace \
		-w /workspace \
		$(IMAGE_NAME):$(VERSION) \
		/bin/sh -c " \
			pip install pip==$(PIP_VERSION) && \
			pip list --outdated && \
			cp requirements.txt requirements.txt.bak && \
			sed 's/==/>=/' requirements.txt.bak > requirements.txt && \
			pip install -r requirements.txt --upgrade && \
			pip freeze > requirements.txt.new && \
			sed 's/>=/==/' requirements.txt.new > requirements.txt && \
			rm requirements.txt.bak requirements.txt.new \
		"

# Main command that does everything
upgrade: update-pip-version upgrade-deps
	@echo "Full upgrade completed!"

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
	docker run --rm -it --name $(CONTAINER_NAME) $(IMAGE_NAME):$(VERSION) pip3 --version | grep "pip $(PIP_VERSION)"
