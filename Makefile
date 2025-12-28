# Variables
IMAGE_NAME = xuantie-debug-server
CONTAINER_NAME = xuantie-running
INSTALLER_FILE = XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh

# Hardware IDs for CKLink-Lite (C-Sky / T-Head)
CKLINK_VID = 32bf
CKLINK_PID = b210

.PHONY: all build run stop clean help check-usb setup-udev flash test-gdb debug

help:
	@echo "XuanTie Debug Server Management"
	@echo "Usage:"
	@echo "  make setup-udev - Configure Linux USB permissions"
	@echo "  make build      - Build the Docker image"
	@echo "  make run        - Start server with USB access and host logging"
	@echo "  make flash ELF=file.elf - Flash firmware to target"
	@echo "  make debug ELF=file.elf - Launch GDB and connect to target"
	@echo "  make test-gdb   - Verify GDB connection to the running container"
	@echo "  make stop       - Stop the running container"
	@echo "  make clean      - Remove the docker image and logs"

setup-udev:
	@echo "Setting up udev rules for CKLink-Lite (ID $(CKLINK_VID):$(CKLINK_PID))..."
	@echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="$(CKLINK_VID)", ATTR{idProduct}=="$(CKLINK_PID)", MODE="0666"' | sudo tee /etc/udev/rules.d/99-cklink.rules
	@sudo udevadm control --reload-rules && sudo udevadm trigger
	@echo "Udev rules applied. Please replug your device."

check-usb:
	@echo "Checking for CKLink-Lite (ID $(CKLINK_VID):$(CKLINK_PID))..."
	@lsusb -d $(CKLINK_VID):$(CKLINK_PID) > /dev/null 2>&1 || \
		(echo "ERROR: CKLink device not found! Check your USB cable."; exit 1)
	@echo "Device found!"

build:
	@if [ ! -f $(INSTALLER_FILE) ]; then \
		echo "Error: $(INSTALLER_FILE) not found!"; exit 1; \
	fi
	docker build -t $(IMAGE_NAME) .

run: check-usb
	@mkdir -p $(shell pwd)/logs
	@echo "Starting XuanTie Debug Server..."
	@echo "Logs available at: $(shell pwd)/logs"
	docker run -it --rm \
		--privileged \
		--name $(CONTAINER_NAME) \
		--network host \
		-v /dev/bus/usb:/dev/bus/usb \
		-v $(shell pwd)/logs:/app/XUANTIE_DebugServer/logs \
		$(IMAGE_NAME)

flash:
	@if [ -z "$(ELF)" ]; then echo "Usage: make flash ELF=path/to/file.elf"; exit 1; fi
	gdb-multiarch -nx -batch -x .gdbinit $(ELF) -ex "quit"

debug:
	@if [ -z "$(ELF)" ]; then echo "Usage: make debug ELF=path/to/file.elf"; exit 1; fi
	gdb-multiarch -x .gdbinit $(ELF)

test-gdb:
	@echo "Testing GDB connection to localhost:1234..."
	gdb-multiarch -nx -batch -ex "target remote localhost:1234" -ex "detach" -ex "quit"

stop:
	docker stop $(CONTAINER_NAME) || true

clean:
	docker rmi $(IMAGE_NAME) || true
	rm -rf $(shell pwd)/logs
