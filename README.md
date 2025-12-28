# **XuanTie Debug Server (Dockerized)**

A portable, isolated environment for the T-Head/XuanTie Debug Server. This setup is optimized for the **CKLink-Lite** (STM32 Blue Pill) hardware (ID 32bf:b210).

## **Hardware Preparation**

Before running the server, you must have a compatible debugger. If you are using an STM32 Blue Pill, follow our conversion guide:

* [**Blue Pill CKLink-Lite Tutorial**](bluepill.md): How to flash the firmware using Linux/Debian.

## **Prerequisites**

* Linux Host (x86\_64)
* Docker installed
* gdb-multiarch (on the host)

## **Setup & Usage**

### **1\. USB Permissions**

First, configure your Linux system to allow non-root access to the USB device.
This will allow Docker to access the USB debugger:

```bash
make setup-udev
```

*Unplug and replug the USB device after running this.*

### **2\. Download binary**

Ensure the .sh installer is in this directory (eg. XuanTie-DebugServer-linux-x86_64-V5.18.5-20250612.sh).

You can register and download it from https://www.xrvm.cn/community/download?id=4380347564587814912 and extract the .sh file from the .tar.gz

### **3\. Build and Run**

```bash
make build
make run
```

The server will start and listen on port 1234\. Logs are mirrored to the local ./logs directory for easy troubleshooting.

## **Debugging Workflow**

### **Command Line**

To connect and flash your binary:

```bash
gdb-multiarch \-x .gdbinit your\_firmware.elf
```

### **VS Code**

1. Open this project in VS Code.
2. Ensure the **C/C++ Extension** is installed.
3. Open the "Run and Debug" view and select **XuanTie Remote Debug**.
4. Press F5.

### **Quick Flash**

To upload code without entering the debugger:

```bash
make flash ELF=path/to/your\_binary.elf
```

## Troubleshooting

Device not found: Run lsusb to ensure the device is visible on the host. If the IDs differ from 32bf:b210, update the Makefile.

Permissions Error: Ensure you ran make setup-udev. Inside Docker, we use --privileged to ensure raw access to the USB bus.

Network Info
The container uses --network host.

GDB Port: 1234

Server Port: 1025 Connect your GDB client to localhost:1234.

## **Project Structure**

* Dockerfile: Minimal Debian-slim image containing the XuanTie server.
* Makefile: Automation for build, run, udev, and flashing.
* .gdbinit: Hardware reset and loading logic.
* .vscode/launch.json: VS Code integration.
* logs/: Directory for server communication logs.
