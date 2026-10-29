# How to Add a New Screen Driver

This document describes the recommended process for adding a new screen under the current display driver framework. The new framework has removed the old `DSI Debugger` debugging path. When adding a new screen, you should first complete the display driver, pin, and panel selection in `make menuconfig`, and then fill in the code according to the current connector/panel framework.

This document still uses a `368(H) x 552(V)` `MIPI DSI` screen as an example to illustrate the complete process from menuconfig to code integration.

## Overall Process

It is recommended to follow the order below when adding a new screen:

1. Enable the corresponding display driver in `make menuconfig` and configure the pins.
1. Select an existing panel in `Display Panel Drivers Configuration`, or add a new panel driver for a new panel.
1. Compile and run the display sample, and use `list_connector` and existing samples to verify that the configuration takes effect.
1. If the panel is not yet in the SDK, supplement `connector_type`, `panel_desc`, initialization sequence, and CanMV mapping according to the current framework.

## First Complete the Display Configuration in menuconfig

Run in the project root directory:

```bash
make menuconfig
```

Enter the menu:

```text
MPP Configuration -> Display Configuration
```

![display](https://www.kendryte.com/api/post/attachment?id=866)

### Select the Display Driver Type

Depending on the hardware connection method, first enable the correct display driver:

- `Enable HDMI Display Driver`
- `Enable LCD Display Driver`
- `Enable SPI LCD Display Driver`
- `Enable QSPI LCD Display Driver`
- `Enable OSPI LCD Display Driver`

If the screen is a `MIPI DSI LCD`, you usually need to enable `Enable LCD Display Driver`.

### Configure Display-Related Pins

Configure the pins used by the current board in the same menu.

For `MIPI DSI LCD`, at least the following need to be confirmed:

- `DSI-LCD Reset GPIO`
- `DSI-LCD BackLight GPIO`

For `HDMI`, you need to confirm:

- `DSI-HDMI Reset GPIO`
- `DSI-HDMI I2c Bus`

For `SPI/QSPI/OSPI LCD`, in addition to reset/backlight, you also need to confirm the bus and FPIOA-related configurations, such as:

- `Data/Command GPIO`
- `Chip Select GPIO`
- `Reset GPIO`
- `Backlight GPIO`
- `Clock Pin`
- `Data0/MOSI Pin`
- `QSPI Bus`

![display](https://www.kendryte.com/api/post/attachment?id=865)

### Select the Panel Driver

After completing the driver type and pin configuration, continue to select the panel driver in the following menu:

```text
Display Panel Drivers Configuration
```

The panel/bridge chip drivers that can be directly selected in the current SDK include:

- `Enable HDMI Display Panel Driver LT9611`
- `Enable LCD Display Panel Driver HX8399`
- `Enable LCD Display Panel Driver ST7701`
- `Enable LCD Display Panel Driver ili9806`
- `Enable LCD Display Panel Driver ili9881`
- `Enable LCD Display Panel Driver nt35516`
- `Enable LCD Display Panel Driver nt35532`
- `Enable LCD Display Panel Driver gc9503`
- `Enable LCD Display Panel Driver st7102`
- `Enable LCD Display Panel Driver aml020t`
- `Enable LCD Display Panel Driver JD9852`
- `Enable SPI LCD Panel Driver ST7789`

If your screen model is already here, first directly enable the corresponding item to verify the pins and display link. If there is no corresponding model here, continue to the following "Adding a Screen in the Project Code".

![display](https://www.kendryte.com/api/post/attachment?id=866)

Save the configuration and recompile the firmware.

## Verify Whether the Current Configuration Takes Effect

It is recommended to first verify that the menuconfig configuration is correct before starting to add new code.

### Enable and Compile Display-Related Samples

In `RT-Smart UserSpace Examples Configuration`, enable at least:

- `Enable MPP examples`
- One or more VO/display-related samples, such as `sample_vo_video`, `sample_vo_osd`

After rebuilding the image, look for the samples on the board:

### View the Connectors Supported by the Current Firmware

After entering the board shell, you can first execute:

```shell
list_connector
```

This command lists the connector types and enumeration values that have been compiled into the current firmware. It helps you confirm:

- Whether the panel driver selected in menuconfig has taken effect
- Whether the newly added panel driver has been included in the final image
- Which `connector_type` should be passed when running the sample

### Run the Display Sample

For example:

```shell
./mpp/sample_vo_video.elf <connector_type>
```

If the sample can light up the already enabled panel, it indicates that the current display link, pins, and basic timing are working properly; at this point, when you start adding new panel code, the localization will be clearer.

## Information Needed Before Adding a New Panel

Before adding a new panel driver, you typically need to prepare two types of information:

1. Screen timing parameters
1. Initialization sequence provided by the screen manufacturer

These two types of information will ultimately be embedded into the panel driver source code, rather than being written to the SDCard configuration file as in the old process.

### Screen Timing

Taking the example screen in this document as an example, the timing information typically includes:

```shell
pclk_hz=27000000
fps=60
lane_num=2

hactive=368
hsync=8
hbp=16
hfp=16

vactive=552
vsync=48
vbp=250
vfp=250
```

These values will correspond to the `timing` field in `panel_desc`, for example:

- `pclk_hz` / `pclk_khz`
- `hactive`
- `hsync_len`
- `hback_porch`
- `hfront_porch`
- `vactive`
- `vsync_len`
- `vback_porch`
- `vfront_porch`

You can still use the timing calculation tool in the project to assist with calculations:

[K230 MIPI DSI Connector Info Generator](https://download.kendryte.com/developer/common/K230_MIPI_DSI_Connector_Info_Generator.html)

> Can only be used to verify whether the timing can be generated

### Initialization Sequence

The manufacturer usually provides a set of register initialization tables, for example:

```shell
{0xFF,5,{0x77,0x01,0x00,0x00,0x13}},
{0xEF,1,{0x08}},
{0xFF,5,{0x77,0x01,0x00,0x00,0x10}},
{0xC0,2,{0x44,0x00}},
{0xC1,2,{0x0B,0x02}},
{0xC2,2,{0x07,0x1F}},
```

In the current framework, this data is generally converted into a command sequence array in the panel source file, for example in `mipi_st7701.c`:

```c
const k_u8 init_sequence[] = {
    0x39, 0, 6, 0xFF, 0x77, 0x01, 0x00, 0x00, 0x13,
    0x15, 0, 2, 0xEF, 0x08,
    0x39, 0, 3, 0xC0, 0x44, 0x00,
};
```

The command format is still:

```text
cmd_type, delay_ms, cmd_data_length, cmd_data0 ... cmd_dataN
```

The commonly used `cmd_type` values are:

- `0x05`: single-byte command, no parameters
- `0x15`: single-byte command, with one parameter
- `0x39`: long command, with multiple parameters

Let's still give two conversion examples:

```shell
{0xB0,16,{0x0F,0x1E,0x25,0x0D,0x11,0x06,0x12,0x08,0x08,0x2A,0x05,0x12,0x10,0x2B,0x32,0x1F}},

# Remove the outer {}
# 0xB0 is the command, followed by 16 bytes of parameters, so use 0x39
# length = 1 command byte + 16 parameter bytes = 17

0x39,0,17,0xB0,0x0F,0x1E,0x25,0x0D,0x11,0x06,0x12,0x08,0x08,0x2A,0x05,0x12,0x10,0x2B,0x32,0x1F
```

```shell
{0x11,0,{0x00}},
{REGFLAG_DELAY,120,{}},

# This group can also be converted into the init_sequence array
# If processed as "1 command + 1 parameter", it can be written as:

0x15,120,2,0x11,0x00
```

## Adding a Screen to the Engineering Code

The current framework does not simply copy an old panel file and rename it. Instead, it is organized around `connector_type`, `panel_desc`, `panel_ops`, and `panel_drv`.

### 1. First Define or Confirm `connector_type`

The screen type definition is located at:

- `src/rtsmart/mpp/include/comm/k_connector_comm.h`

The current project uses `K_CONN_TYPE(chip, bus, w, h, ver)` to generate `k_connector_type`. When adding a new panel, first add a new type constant for the new model. The naming style should follow the existing definitions:

- `ST7701_480_800_DSI_V1`
- `ST7701_480_854_DSI_V1`
- `ST7701_480_640_DSI_V1`
- `ST7701_368_544_DSI_V1`

Even if you are only adding a new resolution variant for an existing chip, you should still follow the existing chip naming convention rather than inventing a separate type encoding.

### 2. Complete the Initialization and Descriptor in the Panel Source File

The implementation of DSI panels is usually located at:

- `src/rtsmart/mpp/kernel/connector/src/panels/`

For example, the ST7701 implementation file is:

- `src/rtsmart/mpp/kernel/connector/src/panels/mipi_st7701.c`

A new panel typically requires at least the following:

1. An initialization function corresponding to `init_sequence`
1. A `panel_ops`
1. A `panel_desc`
1. A `panel_drv` or a new variant attached to an existing `panel_drv`

The key fields of `panel_desc` include:

- `name`
- `connector_type`
- `bus_type`
- `timing`
- `gpio`
- `bus`
- `bus_ops`
- `ops`

Taking a DSI panel as an example, `gpio` usually references the pins configured through menuconfig:

```c
.gpio = {
    .reset_pin = CONFIG_MPP_DSI_LCD_RESET_PIN,
    .backlight_pin = CONFIG_MPP_DSI_LCD_BACKLIGHT_PIN,
    .reset_delay_ms = 10,
    .backlight_delay_ms = 0,
    .reset_active_low = K_TRUE,
    .backlight_active_low = K_FALSE,
},
```

This is also why the pins should be configured clearly in `Display Configuration` before adding a new screen.

### 3. Hook the New Panel into the Current Driver Framework

The connector core will look up available panels from `connector_drv_list[]`. The related logic is located at:

- `src/rtsmart/mpp/kernel/connector/src/connector_dev.c`

The current lookup flow is:

1. Iterate through `connector_drv_list[]`
1. Iterate through the `panel_variants` of each driver
1. Match the target panel by `connector_type`

Therefore, when adding a new panel, you need to ensure that the new panel ultimately ends up in the `panel_variants` of some `panel_drv`, and that the driver itself is compiled into the image.

### 4. Wire the New Panel into Kconfig and Makefile

After completing the panel source code, you also need to wire it into the build system.

Related files:

- `src/rtsmart/mpp/Kconfig`
- `src/rtsmart/mpp/kernel/connector/Makefile`

Kconfig is responsible for exposing the new panel under:

```text
MPP Configuration -> Display Configuration -> Display Panel Drivers Configuration
```

Makefile is responsible for deciding whether to compile the corresponding source file based on the Kconfig option. For example, the current DSI panel wiring is:

```make
src-$(CONFIG_MPP_DSI_ENABLE_LCD_ST7701) += src/panels/mipi_st7701.c
```

When adding a new panel, you should add an entry in the same way, and add a corresponding `config` entry in `Kconfig`.

### 5. Add Mapping if CanMV Python Interface Support Is Required

If the panel is not only used in C samples but is also expected to be optional in the CanMV Python interface, you also need to modify:

- `src/canmv/port/modules/modmedia.display.c`

There are mainly two parts here:

1. The `PY_PANEL_TYPE_*` enumeration
1. The `py_display_panel_map[]` mapping table

Only after the new `connector_type` is mapped to `py_display_panel_map[]` can the CanMV Python layer select it based on the panel type and resolution.

## Minimum Checklist for Adding a New Screen

Before submitting code, it is recommended to check at least the following items:

1. The new panel option is visible in `make menuconfig`.
1. The reset/backlight/bus pins in `Display Configuration` match the actual hardware.
1. The `Makefile` compiles the corresponding panel source file based on the new Kconfig option.
1. `connector_type` is defined in `k_connector_comm.h`.
1. The timing, lane count, GPIO, and initialization sequence of `panel_desc` are all filled in.
1. The lookup path in `connector_drv_list[]` can hit the new panel.
1. The new panel is visible via `list_connector` on the board.
1. `sample_vo_video` or other display samples can light up the screen.
1. If Python support is required, `py_display_panel_map[]` has been updated accordingly.

## Frequently Asked Questions

### 1. A panel option is not visible in menuconfig

Priorities to check:

1. Whether the corresponding display driver is enabled first, such as `Enable LCD Display Driver` or `Enable SPI LCD Display Driver`
1. Whether the Kconfig entry `depends on` an upper-level driver switch
1. Whether the Kconfig configuration corresponding to the new panel has been connected

### 2. Compilation succeeds, but the new panel is not visible in `list_connector`

Priorities to check:

1. Whether the `Makefile` compiles the corresponding panel source file
1. Whether the driver list in `connector_dev.c` includes the `panel_drv` corresponding to the panel
1. Whether the new `panel_desc` is actually registered in `panel_variants`

> `list_connector` is only compiled in the RTOS SDK

### 3. The screen is powered on but no image is displayed

Priorities to check:

1. Whether the reset/backlight GPIO is correct
1. Whether the DSI lane, pixel clock, porch, and sync parameters are correct
1. Whether the manufacturer's initialization sequence is complete and the delays are preserved
1. Whether the `connector_type` used by the sample matches the newly added panel
1. Check the serial port logs. If the issue is still not resolved, you can post on the forum for help

## Reference

- Current display driver switch and panel list: [`../hardware_compatibility/display_list.md`](../hardware_compatibility/display_list.md)
- Display sample usage instructions: [`../app_develop_guide/media/display.md`](../app_develop_guide/media/display.md)
- VO/Display API description: [`../api_reference/mpp/display.md`](../api_reference/mpp/display.md)
