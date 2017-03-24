Running the command:
usb_modeswitch -v 0x12d1 -p 0x1f01 -V 0x12d1 -P 0x14dc -M "55534243123456780000000000000a11062000000000000100000000000000"
Created this device
ID 12d1:14dc Huawei Technologies Co., Ltd.
and dmesg shows:
eth1: register 'cdc_ether' at usb-0000:00:1a.0-1.3, CDC Ethernet Device, 58:2c:80:13:92:63
scsi13 : SCSI emulation for USB Mass Storage devices
usb-storage: device found at 12
so this created eth1 and /dev/sdc (the micro SD card)

Running the command:
usb_modeswitch -v 0x12d1 -p 0x1f01 -V 0x12d1 -P 0x14dc -M "55534243000000000000000000000011060000000000000000000000000000"
Created this device
ID 12d1:1001 Huawei Technologies Co., Ltd. E169/E620/E800 HSDPA Modem
and dmesg shows:
usb 1-1.3: Product: HUAWEI HiLink
usb 1-1.3: Manufacturer: HUAWEI
usb 1-1.3: configuration #1 chosen from 1 choice
option 1-1.3:1.0: GSM modem (1-port) converter detected
usb 1-1.3: GSM modem (1-port) converter now attached to ttyUSB0
option 1-1.3:1.1: GSM modem (1-port) converter detected
usb 1-1.3: GSM modem (1-port) converter now attached to ttyUSB1
option 1-1.3:1.2: GSM modem (1-port) converter detected
usb 1-1.3: GSM modem (1-port) converter now attached to ttyUSB2
