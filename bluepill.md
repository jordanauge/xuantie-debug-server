# **Converting STM32 Blue Pill to CKLink-Lite (Linux/Debian)**

This guide is a streamlined adaptation of the approach found in the [Elektroda Community Discussion](https://www.elektroda.com/rtvforum/topic4120455.html). While the original guide often references Windows-based tools or J-Link, the process is significantly simpler on **Linux (Debian-based distributions)** using the open-source stlink-tools and an **ST-Link v2** programmer.

This conversion allows an STM32F103C8T6 (Blue Pill) to act as a JTAG/SWD debugger for C-Sky and RISC-V targets.

## **1\. Hardware Connections**

Connect the **ST-Link v2** to the **STM32 Blue Pill** using the following pin mapping:

### **ST-Link v2 Pinout**

| ST-Link v2 Pin | Blue Pill Pin | Cable Color (Typical) |
| :---- | :---- | :---- |
| **SWCLK** | **CLK** (PA14) | Green |
| **SWDIO** | **DIO** (PA13) | Purple |
| **GND** | **GND** | Blue |
| **3.3V** | **3.3V** | Gray |

## **2\. Environment Setup (Debian/Ubuntu)**

The Linux workflow eliminates the need for complex drivers. Install the necessary tools directly via apt:

```bash
sudo apt update
sudo apt install stlink-tools binutils
```

Verify that your ST-Link v2 is detected by the system:

```bash
st-info \--probe
```

*You should see output indicating Found 1 stlink programmers with a dev-type: STM32F1xx\_MD.*

## **3\. Obtain the Firmware**

We use version 2.37 of the firmware. It is recommended to use the conversion PR branch which contains the necessary .hex files for the STM32F103.

```bash
\# Clone the converter repository
git clone \[https://github.com/cjacker/cklink-lite-fw-convertor\](https://github.com/cjacker/cklink-lite-fw-convertor)
cd cklink-lite-fw-convertor

\# Fetch and checkout the recommended community PR branch
git fetch origin pull/1/head:pr-conversion-update
git checkout pr-conversion-update
```

## **4\. Flashing the Firmware**

Directly flashing .hex files on Linux can occasionally fail with Cannot parse ... as Intel-HEX file due to carriage return differences (CRLF). The most robust Linux method is to convert to a raw binary first.

### **Step 4a: Convert Hex to Binary**

```bash
objcopy \-I ihex \-O binary cklink\_lite-2.37\_for-stm32f103.hex cklink.bin
```

### **Step 4b: Write to Flash**

Write the binary to the STM32 starting at the internal flash base address (0x8000000):

```bash
st-flash write cklink.bin 0x8000000
```

*Expected output: Flash written and verified\! jolly good\!*

## **5\. Verification**

Disconnect the ST-Link and plug the **Blue Pill's USB port** directly into your computer. Check the kernel logs to confirm the device has "morphed" into a CKLink-Lite:

```bash
sudo dmesg | tail
```

**Success criteria:**

* idVendor=32bf, idProduct=b210
* Product: C-Sky CKLink-Lite
* Manufacturer: C-Sky MicroSystem Co., Ltd.

## **6\. JTAG Pinout for CKLink-Lite**

Your Blue Pill is now a dedicated debugger. Use the following pins to connect to your target board (e.g., W806/RISC-V):

| Blue Pill Pin | CKLink Function |
| :---- | :---- |
| **A0** | **TRST** |
| **A1** | **TCK** |
| **A4** | **TDO** |
| **A5** | **TMS** |
| **B9** | **TDI** |
| **3V3** | **3.3V Power** |
| **GND** | **Ground** |
