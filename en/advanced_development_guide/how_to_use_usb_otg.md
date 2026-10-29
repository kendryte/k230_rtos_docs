# K230D USB OTG Usage Guide

## 1. OTG Function Description

K230D now supports USB OTG. K230 itself has two USB ports and does not currently support OTG.

After OTG is enabled, the system can switch between Device and Host according to the USB ID state. The same USB controller can be used as a USB Device, or it can be used as a USB Host after switching. The OTG function is disabled by default and needs to be manually enabled.

## 2. OTG Configuration Description

### Reference Configuration

The following defconfig is used as an example:

```bash
make k230d_canmv_bpi_zero_defconfig
```

Then enter menuconfig:

```bash
make rtsmart-menuconfig
```

### Enable OTG

In menuconfig, navigate to the following path:

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB OTG
```

`Enable CherryUSB OTG` is only visible under the K230D configuration.

### Required Configuration for Enabling the Host Side

If you want the OTG to switch to Host and work properly under the CanMV/MPY environment, you also need to enable the following two configurations at the same time.

The first item:

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB Host
            -> CherryUSB Host Controller Driver
                -> Using DesignWare Driver
                    -> Enable descriptor DMA mode
```

The second item:

```text
Components Configuration
    -> Enable CherryUSB
        -> Enable CherryUSB Host
            -> Enable USB Host for CanMV(Some USB Host Drivers)
```

## III. Recommended Configuration Steps

It is recommended to configure in the following order:

```bash
make k230d_canmv_bpi_zero_defconfig
make rtsmart-menuconfig
```

Then execute the following in menuconfig:

1. Enable `Components Configuration -> Enable CherryUSB -> Enable CherryUSB OTG`
1. Enter `Components Configuration -> Enable CherryUSB -> Enable CherryUSB Host -> CherryUSB Host Controller Driver -> Using DesignWare Driver`, and enable `Enable descriptor DMA mode`
1. Enter `Components Configuration -> Enable CherryUSB -> Enable CherryUSB Host`, and enable `Enable USB Host for CanMV(Some USB Host Drivers)`

After completing the configuration, recompile the firmware.

## IV. Hardware Design Reference

In addition to software configuration, the OTG switching of K230D also depends on the board-level USB_ID hardware design. Different development boards implement this differently, so you can choose based on your own needs.

### Option 1: CC Pin Linked to USB_ID

The BPI Zero K230D board corresponding to `k230d_canmv_bpi_zero_defconfig` uses this approach.

In this scheme, the Type-C CC pin is connected to USB_ID:

1. By default, USB_ID is pulled up to a high level, and the system operates in Device mode
1. After connecting an OTG cable, USB_ID is pulled low, and the system dynamically switches to Host mode

The characteristic of this approach is that dynamic switching can be triggered directly by plugging/unplugging the OTG cable.

However, it also has a limitation: since this CC pin has no pull-down resistor, this Type-C port can no longer be used as a power supply port.

### Option 2: GPIO Controls USB_ID

The Lushan Pai (K230D version) uses this approach.

In this scheme, instead of relying on the OTG cable to automatically change USB_ID, a GPIO actively controls the state of the USB_ID pin:

1. The GPIO is controlled by software to set USB_ID high or low
1. When USB_ID is high, it operates in Device mode
1. When USB_ID is low, it switches to Host mode

The characteristics of this approach are:

1. Dynamic switching cannot be achieved solely by plugging/unplugging the OTG cable
1. Role switching depends on GPIO control
1. However, this Type-C port can be retained for power supply use

### Suggestions for Option Selection

If your requirement leans more toward "automatically switch to Host when plugged in and revert to Device when unplugged," you can refer to the CC/USB_ID linked approach used by BPI Zero.

If your requirement leans more toward "retain Type-C power supply capability while allowing software to control Host/Device roles," you can refer to the GPIO-controlled USB_ID approach used by Lushan Pai (K230D version).

## V. Notes

1. Only enabling `Enable CherryUSB OTG` is not enough; if `Enable descriptor DMA mode` is not enabled at the same time, the performance in Host mode will be affected.
1. If `Enable USB Host for CanMV(Some USB Host Drivers)` is not enabled, some USB Host drivers required in the CanMV/MPY environment will not be compiled into the firmware, and after switching to Host, a "Host not working" issue will occur.
1. The actual switching of OTG depends on the board-level USB ID design; the software side is only responsible for performing role switching based on the ID state.
1. If the business also needs to use Host devices such as U-disks, UVC, HID, network cards, or serial ports, the corresponding USB Host Class Driver still needs to be enabled according to the actual peripherals.
