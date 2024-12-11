# ASIX AX88179 DKMS driver

This program will install the official ASIX AX88179 driver from the [manufacturer's website](https://www.asix.com.tw/en/product/USBEthernet/Super-Speed_USB_Ethernet/AX88179A) using [DKMS](https://github.com/dell/dkms).

## How to install

> Obviously, you need an Internet connection to allow the installation program to download the driver's source code tarball.

1. Clone this repository: `git clone https://github.com/FlorianLaunay/asix-ax88179-dkms.git && cd asix-ax88179-dkms`
2. Checkout to wanted version: `git checkout 3.4.0`
3. Run the installation program: `sudo ./install.sh`
4. Connect/reconnect your device

## How to uninstall

3. Simply run the installation program with the uninstall option: `sudo ./install.sh -u`
4. Connect/reconnect your device

## Licence

Please see [LICENCE](LICENCE).