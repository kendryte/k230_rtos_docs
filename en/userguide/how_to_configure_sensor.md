# How to Configure the Sensor Driver

## Overview

In the K230 RTOS SDK, whether the Sensor driver is built into the firmware, which CSI it is connected to, whether CSI0 uses 2-lane or 4-lane, whether the on-chip MCLK is used, and how ISP parameters are packaged and loaded are jointly determined by **MPP Kconfig** and the VICAP API.

The configuration entry point is uniformly accessed from the SDK root directory:

```bash
make menuconfig
# Docker workflow: k230 make menuconfig
```

Related code and configuration locations:

| Content | Path |
| :--- | :--- |
| Sensor / CSI / ISP installation switches | `src/rtsmart/mpp/Kconfig` → `MPP Configuration` → `Sensor Configuration` |
| Sensor drivers and mode tables | `src/rtsmart/mpp/kernel/sensor/` |
| On-board `list_sensor` command | `src/rtsmart/mpp/kernel/sensor/src/sensor_dev.c` |
| Sensor type enumeration | `src/rtsmart/mpp/include/comm/k_sensor_comm.h` |
| Application-layer Sensor information table / detection matching | `src/rtsmart/mpp/userapps/src/sensor/mpi_sensor.c` (`kd_mpi_sensor_adapt_get_ex`) |
| ISP calibration / tuning source files | `src/rtsmart/mpp/userapps/src/sensor/config/` |
| ISP installation rules | `src/rtsmart/mpp/userapps/src/sensor/Makefile` |
| ISP loading and parsing mode | `src/rtsmart/mpp/userapps/src/vicap/src/mpi_vicap.c` |

For an overview of models and resolutions, see the [Image Sensor Support List](../hardware_compatibility/sensor_list.md). To add a new model from scratch, see [How to Add a Sensor](../advanced_development_guide/how_to_add_sensor.md).

## Opening menuconfig

- First select the board-level defconfig (example):

   ```bash
   make k230_rtos_01studio_defconfig
   ```

- Enter the interactive configuration:

   ```bash
   make menuconfig
   ```

- Navigate to:

   ```text
   MPP Configuration
     └── Sensor Configuration
   ```

- The settings take effect after rebuilding and flashing:

   ```bash
   make
   ```

Menu example (`Sensor Configuration`):

![menuconfig Sensor Configuration](https://www.kendryte.com/api/imagecdn/zh/sensorconfig.png)

> The image above is an example of the menuconfig interface. For the specific entries, refer to the current SDK's `mpp/Kconfig`.

## How to View the Currently Supported Sensors

### Method 1: Check with menuconfig (before compilation)

Under `Sensor Configuration`, find **`Sensor Drivers Configuration`**. Each `Enable <型号>` entry corresponds to a driver already integrated into the SDK, for example:

- `Enable GC2093`
- `Enable OV5647`

- **Checked**: The driver is built into the kernel, its corresponding modes appear in the on-board `list_sensor`, and the matching ISP configurations are installed into the image according to the rules.
- **Unchecked**: This model will not appear in the current firmware.

The authoritative list is in `src/rtsmart/mpp/Kconfig` and increases with each version.

### Method 2: Check the board-level defconfig

```bash
grep CONFIG_MPP_ENABLE_SENSOR_ configs/<your_board>_defconfig
grep CONFIG_MPP_CSI0_LINK_MODE_ configs/<your_board>_defconfig
```

Example:

```text
CONFIG_MPP_CSI0_LINK_MODE_2LANE=y
CONFIG_MPP_ENABLE_SENSOR_IMX335=y
CONFIG_MPP_ENABLE_SENSOR_GC2093=y
```

### Method 3: On-board `list_sensor` (confirm whether the driver is enabled)

`list_sensor` is an RT-Smart `msh` command exported by `sensor_dev.c`. It first prints the currently detected drivers, supported modes, and lane count for each CSI, then lists all configured Sensor types and marks them as `SUPPORTED` or `NOT DETECTED`.

After entering `msh` through the serial port, run:

```bash
list_sensor
```

Example output:

```text
Detected Sensor Drivers:
CSI0: ov5647_csi0 (2 supported modes)
  Sensor Type List:
                  7 -> OV5647_MIPI_CSI0 (..., 2 lanes)
CSI1: no sensor driver detected
CSI2: no sensor driver detected

All Configured Sensor Types:
  [SUPPORTED]    CSI0                 7 -> OV5647_MIPI_CSI0 (..., 2 lanes)
  [NOT DETECTED]                     23 -> GC2093_MIPI_CSI0
```

Usage notes:

| Symptom | Meaning |
| :--- | :--- |
| `CSI<n>: <driver> (...)` | A driver has been detected on this CSI. The number in parentheses indicates the number of driver modes. |
| `CSI<n>: no sensor driver detected` | No loaded Sensor driver has been detected on this CSI. |
| `[SUPPORTED]` | The configured type appears in the detected driver mode table. |
| `[NOT DETECTED]` | The type has been configured, but the corresponding driver / mode was not detected on the current board. |
| `2 lanes` / `4 lanes` in an entry | The number of MIPI lanes used by the currently detected mode. |
| A type is present, but the preview is black | The driver has been loaded. The problem is more likely related to hardware wiring, the MIPI link, or ISP parameters. |

When selecting a sensor at the application layer, use the **name / type** printed by `list_sensor`. Do not hard-code the volatile numeric sequence, as it changes with the Kconfig combination.

The types for CSI0 / CSI1 / CSI2 are isolated by `CONFIG_MPP_ENABLE_CSI_DEV_n` in the enumeration (`k_sensor_comm.h`), the `list_sensor` table, and the `mpi_sensor.c` adaptation table: when a CSI is not enabled, its corresponding types are not built into the firmware.

## CSI0 LANE NUM（2LANE / 4LANE）

At the top of `Sensor Hardware Configuration`, there is an independent option **`CSI0 LANE NUM`** (default: **2LANE**):

```text
MPP Configuration
  └── Sensor Configuration
        ├── CSI0 LANE NUM (2LANE) --->
        │     ├── (X) 2LANE          # Default; the 4LANE option for each Sensor is hidden
        │     └── ( ) 4LANE          # CSI0 can use 2L+4L; each Sensor can enable 4LANE Configure
        ├── [*] Enable CSI0  --->    # GPIO / I2C / MCLK
        ├── [*] Enable CSI1          # Can be compiled to coexist; cannot be initialized simultaneously with CSI0 4LANE at runtime
        └── [*] Enable CSI2
```

| `CSI0 LANE NUM` | Macro | Effect |
| :--- | :--- | :--- |
| 2LANE (default) | `CONFIG_MPP_CSI0_LINK_MODE_2LANE=y` | Each `*_ENABLE_4LANE_CONFIGURE` / IMX415 is hidden and not compiled |
| 4LANE | `CONFIG_MPP_CSI0_LINK_MODE_4LANE=y` | CSI0 can retain both 2-lane and 4-lane modes; `Enable CSI1` remains selectable |

Hardware note: By default, using CSI0 for 4-lane aggregation on the board consumes the PHY shared with CSI1. The software **no longer** hides CSI1 for this reason, so that customers can use CSI1 after fly-wire modification or board revision; with the original factory wiring on an unmodified board, do not enable CSI0 4LANE and CSI1 simultaneously.

### How to switch to 4LANE mode

The models currently providing a per-sensor 4-lane switch include **IMX335**, **OV13850**, and **IMX415** (the entire IMX415 sensor is visible only in 4LANE link mode).

1. `make menuconfig` → `Sensor Configuration`
2. **`CSI0 LANE NUM` → select `4LANE`**
3. Confirm `[*] Enable CSI0`
4. Open the target Sensor and select **`Enable 4LANE Configure`** in its submenu (IMX335 / OV13850 are enabled by default under 4LANE; IMX415 is enabled by default)
5. (Optional) If CSI1 is still needed after modifying the board, you may continue to select `Enable CSI1`

```text
CSI0 LANE NUM (4LANE) --->
[*] Enable CSI0
[ ] Enable CSI1          # May remain unselected by default; enable it after fly-wire modification or board revision
[*] Enable IMX335
  └── [*] IMX335 Enable 4LANE Configure
```

The same applies to OV13850 / IMX415.

Corresponding Kconfig macros:

| Option | Macro |
| :--- | :--- |
| CSI0 2LANE | `CONFIG_MPP_CSI0_LINK_MODE_2LANE` |
| CSI0 4LANE | `CONFIG_MPP_CSI0_LINK_MODE_4LANE` |
| IMX335 4-lane mode | `CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE` |
| OV13850 4-lane mode | `CONFIG_MPP_SENSOR_OV13850_ENABLE_4LANE_CONFIGURE` |
| IMX415 4-lane mode | `CONFIG_MPP_SENSOR_IMX415_ENABLE_4LANE_CONFIGURE` |

IMX335 submenu example:

![IMX335 4LANE menuconfig](https://www.kendryte.com/api/imagecdn/zh/imx335config.png)

### How to confirm after enabling

- In `.config` / defconfig, it is `CONFIG_MPP_CSI0_LINK_MODE_4LANE=y`
- Under `Detected Sensor Drivers` in the on-device `list_sensor`, the corresponding `*_CSI0_4LANE_*` mode is present (along with the still-available CSI0 2LANE mode)
- When `Enable CSI1` is not enabled, `*_CSI1_*` does not appear; after it is enabled, it appears
- On the application side, add **`-lane 4`** when detecting the resolution, or specify the 4LANE type using `-stype` (see the next section)
- The module and ribbon cable must genuinely support 4-lane; if the software is enabled but the hardware supports only 2-lane, link errors or a black screen will occur

> 4K Sensors (such as OV13850 and IMX415) are also subject to the VICAP operating mode restrictions. See [sensor_list.md](../hardware_compatibility/sensor_list.md).

## How the Application Layer Matches Sensors by Resolution / FPS / Lane

Samples such as `sample_vicap_sensor` probe modes by parameters through `kd_mpi_sensor_adapt_get_ex(config, info, lane_pref)` (`mpi_sensor.c`); you can also use `-stype` to force a specified enumeration. The legacy interface `kd_mpi_sensor_adapt_get()` is retained for compatibility, but it always uses `ANY` and cannot specify a lane preference.

### Command-Line Parameters (`sample_vicap_sensor`）

See [VICAP Sensor Demo](../app_develop_guide/media/vicap.md) for the complete parameter table and examples. Common probe-related options include:

| Parameter | Meaning | Default |
| :--- | :--- | :--- |
| `-s <0\|1\|2>` | CSI port | 2 |
| `-width` / `-height` / `-fps` | Expected resolution and frame rate | 1920 / 1080 / 30 |
| `-lane <2\|4>` | Lane preference when resolutions are identical (`lane_pref`) | **ANY** (unrestricted; ties are ranked in favor of 2LANE) |
| `-stype <id>` | Force `k_vicap_sensor_type` | Not set |
| `-ofmt <0\|1\|2\|3>` | CHN0: YUV / RGB888 / RGB888P / RAW | 0 |
| `-dump <n>` | Automatically dump n frames and then exit | Interactive |
| `-tile <0\|1>` | Force SW_TILE (debugging) | 0 |

Working mode summary: `-ofmt 3` (RAW) defaults to **ONLINE**; YUV/RGB previews that exceed limits, such as 4K, use **SW_TILE**; `-tile 1` can force SW_TILE.

Examples:

```bash
# IMX335 2592×1944@30，CSI0；默认 ANY，同分时选 2-lane
./sample_vicap_sensor.elf -c <connector> -s 0 -width 2592 -height 1944 -fps 30

# 同上分辨率，明确选 4-lane（需固件 CSI0 LANE NUM=4LANE 且已 Enable 4LANE Configure）
./sample_vicap_sensor.elf -c <connector> -s 0 -width 2592 -height 1944 -fps 30 -lane 4

# RAW Dump（ONLINE）并自动存 1 帧
./sample_vicap_sensor.elf -c <connector> -s 0 -ofmt 3 -dump 1

# 强制 type（以板端 list_sensor 打印为准）
./sample_vicap_sensor.elf -c <connector> -s 0 -stype <id>
```

### `kd_mpi_sensor_adapt_get_ex` Matching Rules

The probing structure `k_vicap_probe_config` contains conditions such as `csi_num`, `width`, `height`, and `fps`, and no longer contains `lane_pref`. The caller should zero out the structure and pass the lane preference through the third parameter of `kd_mpi_sensor_adapt_get_ex()`; when using `VICAP_MIPI_LANE_PREF_ANY=0`, candidates are not filtered by lane, so 4LANE-only sensors such as IMX415 / OV13850 at 1080p can still be detected.

1. **Candidate filtering**
   - The CSI port must equal the requested `csi_num`
   - `lane_pref=ANY`: no filtering; `=2LANE`: retain non-4LANE (including 1LANE); `=4LANE`: retain only `VICAP_MIPI_4LANE`; illegal values are treated as `ANY`; 4LANE is supported only on CSI0
   - Only sensors that can be successfully `open`ed become candidates (actually present on the board)
2. **Ranking**: higher fps → larger width → larger height → when resolutions are identical, **2LANE takes precedence over 4LANE**
3. **Matching priority**
   1. When `fps != 0`, first find a match where **width + height + fps are all equal**
   2. Then find a match where **width + height are equal** (fps may differ)
   3. Then find a **larger resolution not smaller than** the requested width and height
   4. If none is found, fail

Therefore, for 2LANE / 4LANE at the same resolution: the default `ANY` ranking favors 2LANE; use `-lane` / `lane_pref` to force a specific option. On the compilation side, `CSI0 LANE NUM` determines whether the 4LANE type is compiled into the firmware; at application runtime, 4LANE cannot be requested on CSI1/CSI2, and CSI0 4LANE and CSI1 cannot be initialized simultaneously.

## Common Options for CSI and Drivers

### Default CSI

- **`Default SENSOR on CSI`**：Default CSI port (0 / 1 / 2).

### Sensor Hardware Configuration

| Option | Description |
| :--- | :--- |
| **CSI0 LANE NUM** | `2LANE` (default) / `4LANE`; see the previous section |
| Enable CSI0 | When enabled, configure PowerDown / Reset / I2C / MCLK |
| Enable CSI1 | Can be compiled together with 4LANE; at runtime, CSI0 4LANE and CSI1 cannot be initialized simultaneously |
| Enable CSI2 | Has no PHY conflict with 4LANE and can be enabled as needed |

Common options for each CSI (after enabling):

| Option | Description |
| :--- | :--- |
| PowerDown GPIO | Power pin; set to `-1` if unavailable |
| Reset GPIO | Reset pin; set to `-1` if unavailable |
| I2c Bus | Such as `i2c0` |
| MCLK num | On-chip MCLK1/2/3, or an external crystal oscillator |

### Sensor Sub-options

| Option | Description |
| :--- | :--- |
| `On CSI0/1/2 Use CHIP MCLK` | Whether the Sensor uses the on-chip MCLK on the corresponding CSI |
| `Enable 4LANE Configure` | Additionally compile the CSI0 4-lane mode; **appears only when `CSI0 LANE NUM=4LANE`** |

### AutoFocus (optional)

`Enable AutoFocus` → A voice coil motor driver can then be selected (such as DW9714P); this is required only when the hardware supports AF.

## ISP Configuration: Switching Between bin and XML/JSON

### Source Files and Installation

ISP parameter source file directory:

```text
src/rtsmart/mpp/userapps/src/sensor/config/
```

Naming convention (using IMX335 2592×1944 as an example):

| File | Purpose |
| :--- | :--- |
| `imx335-2592x1944_auto.json` | Auto mode; one of the inputs for generating `.bin` |
| `imx335-2592x1944_manual.json` | Manual mode |
| `imx335-2592x1944.xml` | XML calibration / tuning parameters |

The two installation switches at the top of `Sensor Configuration`:

| Option | Macro | Function |
| :--- | :--- | :--- |
| Install binary ISP configurations | `CONFIG_MPP_ISP_CONFIG_INSTALL_BIN` | Generate and install `*.bin` into the image `bin/` directory |
| Install JSON and XML ISP configurations | `CONFIG_MPP_ISP_CONFIG_INSTALL_JSON_XML` | Copy matching `.json` / `.xml` files into the image `bin/` directory |

Only **Enabled Sensors** have their prefix-matched ISP files installed (see `userapps/src/sensor/Makefile`).

Build artifacts are generally located in:

```text
output/<defconfig>/images/bin/
```

The path on the device is usually `/bin/`, for example, `/bin/imx335-2592x1944.bin` and `/bin/imx335-2592x1944.xml`.

### Why bin Mode Cannot “Swap ISP Files in Real Time”

Default logic (when no parsing mode is explicitly specified):

- `kd_mpi_vicap_init()` probes for `/bin/<database_name>.bin`.
- If the `.bin` file exists and loads successfully, **bin mode** is used (internally enumerated as `VICAP_DATABASE_PARSE_HEADER`).
- A bin file is the binary produced at build time by `gen_isp_config_bin` after **baking in** the xml/json; changing the `.xml` / `.json` files on the device at runtime **will not** automatically be reflected in the loaded bin.
- To incorporate new parameters into the bin, you must modify the source files → run `make` again to generate the bin → reflashing / replacing `/bin/*.bin` → and then restart the application.

Therefore: **During the tuning phase, if ISP parameters need to be changed frequently, switch to XML/JSON parsing mode.**

### How to Switch to XML/JSON Mode (Code)

Call the following **before `kd_mpi_vicap_init()`**:

```c
#include "mpi_vicap_api.h"
#include "k_vicap_comm.h"

k_vicap_dev vicap_dev = VICAP_DEV_ID_0;

/* Force loading from /bin/<database>.xml and *_auto.json / *_manual.json */
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
if (ret) {
    printf("set_database_parse_mode failed, ret=%d\n", ret);
    return ret;
}

ret = kd_mpi_vicap_init(vicap_dev);
```

Enum meanings (`k_vicap_comm.h`):

| Enum | Value | Actual Behavior |
| :--- | :--- | :--- |
| `VICAP_DATABASE_PARSE_XML_JSON` | 0 | Use XML + JSON, **without prioritizing bin** |
| `VICAP_DATABASE_PARSE_HEADER` | 1 | Force bin; initialization fails if the bin does not exist |

> In the API comments, HEADER once meant “header file mode”; in the current implementation, it corresponds to **binary bin configuration**.

Many examples in the SDK (such as `examples/ai/yolo/src/pipeline.cc`) explicitly set XML/JSON before `vicap_init`:

```c
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
ret = kd_mpi_vicap_init(vicap_dev);
```

Meanwhile, when programs such as `sample_vicap_sensor` do not call this interface, they automatically use bin if a `.bin` file is present.

### How to Change Parameters in XML/JSON Mode

- Keep **`Install JSON and XML ISP configurations`** set to y in menuconfig to ensure that xml/json files are included in the image.
- In the application, switch to `VICAP_DATABASE_PARSE_XML_JSON` as described in the previous section.
- Modify and replace the files on the device, for example:

   ```bash
   # Push from the host (adjust the path according to the actual file system)
   adb push imx335-2592x1944.xml /bin/
   adb push imx335-2592x1944_auto.json /bin/
   adb push imx335-2592x1944_manual.json /bin/
   ```

- **Rerun the application** (`vicap_init` is required again). The ISP is loaded during init, so **the active bin memory image cannot be hot-swapped** while the same stream remains active.

The default loading paths are constructed from `database_name` (such as `imx335-2592x1944`) and the ISP config path (default: `/bin/`):

```text
/bin/imx335-2592x1944.xml
/bin/imx335-2592x1944_auto.json
/bin/imx335-2592x1944_manual.json
```

### Mode Selection Recommendations

| Scenario | Recommendation |
| :--- | :--- |
| Mass production / fast startup | bin (default probing is sufficient), with parameters baked in |
| ISP calibration / tuning / frequent parameter changes | Set the code to `VICAP_DATABASE_PARSE_XML_JSON`, and restart the application after changing xml/json |
| Explicit requirement to use bin | `kd_mpi_vicap_set_database_parse_mode(..., VICAP_DATABASE_PARSE_HEADER)` |

For calibration and tuning details, see:

- [How to Perform ISP Calibration](../advanced_development_guide/how_to_calibrate_isp.md)
- [How to Perform ISP Tuning](../advanced_development_guide/how_to_tune_isp.md)

## Configuration Checklist

- **`CSI0 LANE NUM`**: Defaults to 2LANE; change it to 4LANE when CSI0 4-lane is required (CSI1 can be compiled, but cannot be initialized simultaneously with CSI0 4LANE).
- `Enable CSIx` must match the board wiring (GPIO / I2C / MCLK).
- Check the target `Enable <Sensor>`; under 4LANE, also confirm `Enable 4LANE Configure`.
- For 2L/4L at the same resolution: the default is `lane_pref=ANY` (equal-score sorting favors 2LANE); use `-lane 2|4` or `-stype` to force a preference.
- ISP: use bin for mass production; for tuning, switch to XML/JSON in code and ensure json/xml has been installed in `/bin/`.
- `make` → Flash → **`list_sensor`** to confirm the detected CSI / type / lane → Then run the VICAP / Sensor example.

## Related Documentation

- [Image Sensor Support List](../hardware_compatibility/sensor_list.md)
- [How to Add a Sensor](../advanced_development_guide/how_to_add_sensor.md)
- [How to Build the Firmware](./how_to_build.md)
- [How to Run the Sample Programs](./how_to_run_samples.md)
