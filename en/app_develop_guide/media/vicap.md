# VICAP Sensor Demo

## Introduction

This example `sample_vicap_sensor` demonstrates how to use K230 VICAP for camera capture, preview, and Dump.

Pipeline:

```text
Sensor → VICAP DEV0
     ├─ CHN0 → Dump（YUV / RGB888 / RGB888P / RAW）
     └─ CHN1 → VO → Connector（preview, YUV420SP）
```

## Function Description

- **Sensor detection**: automatically matches according to `-width/-height/-fps/-lane`, or is force-specified via `-stype`
- **Dual channels**: CHN0 Dump, CHN1 preview (adapted to screen aspect ratio)
- **Working mode**: see "VICAP Working Mode" below
- **AE / AWB / HDR / DNR3 / Dewarp**
- **Manual exposure / gain** (requires `-ae 0`)
- **Mirror / flip** (`-mirror` / `-flip`, must take effect before init)
- **Scene loading** (`-scene_name` / `-scene_path`)
- **Interactive Dump** or **`-dump <n>` auto Dump and exit**

## Supported Parameters

| Parameter | Description | Default |
|------|------|--------|
| `-c` | Connector type (**required**) | None |
| `-r` | Rotation (0 / 90 / 180 / 270) | 0 |
| `-s` | CSI index (0–2) | 2 |
| `-L` / `-lane` / `--lane <2\|4>` | lane preference during detection (corresponds to `lane_pref`) | **ANY** (unrestricted; ties prefer 2LANE) |
| `-stype <id>` | Force `k_vicap_sensor_type` (ignore width/height/fps/lane) | Not set |
| `-width` / `-height` / `-fps` | Target resolution and frame rate for detection | 1920 / 1080 / 30 |
| `-ofmt <0\|1\|2\|3>` | CHN0 format: YUV / RGB888 / RGB888P / **RAW** | 0 |
| `-dump <n>` | Automatically dump n frames after startup and exit | Interactive mode |
| `-ae` / `-awb` / `-hdr` / `-dw` / `-dnr3` | Function switches (0/1) | 1 / 1 / 0 / 0 / 1 |
| `-tile <0\|1>` | Force `VICAP_WORK_SW_TILE_MODE` | 0 |
| `-exp <us>` | Manual exposure (microseconds, requires `-ae 0`) | — |
| `-again <x>` | Manual analog gain (requires `-ae 0`) | — |
| `-mirror` / `-flip` | Horizontal mirroring / vertical flipping (0/1) | 0 |
| `-scene_name` / `-scene_path` | Scene name and configuration path | — |

`stype` / Connector values are subject to the board-side `list_sensor` and `list_connector`.

### VICAP Operating Mode

Examples select `dev_attr.mode` according to the following rules:

| Condition | Mode |
|------|------|
| `-tile 1` | Force **SW_TILE** |
| `-ofmt 3` (RAW Dump) | **ONLINE** (the RAW path does not use SW_TILE by default; `-tile 1` can still be used to force it) |
| The capture width or height exceeds the VICAP limit (approximately 3072×2160, such as 4K YUV/RGB) | **SW_TILE** |
| Other | **ONLINE** |

When `-ofmt 3` is used, DNR3 is also automatically disabled (to avoid unnecessary overhead on the RAW Dump path).

### Interactive Commands

| Command | Description |
|------|------|
| `d` | Dump 1 frame (CHN0) |
| `d <n>` | Dump n frames |
| `q` | Exit |

## Code Location

```shell
src/rtsmart/examples/mpp/sample_vicap_sensor/
```

- `sample_vicap_sensor.c` — Main program

## Usage Instructions

### Compilation

In the SDK root directory, use `make menuconfig` to select the corresponding example, then compile the firmware.

### Running Examples

#### Basic Preview

```shell
./sample_vicap_sensor.elf -c 20
# or specify CSI0
./sample_vicap_sensor.elf -c 20 -s 0
```

#### Probe by Resolution / Specify lane

```shell
# Default lane=ANY; in a tie, sorting favors 2LANE
./sample_vicap_sensor.elf -c 20 -s 0 -width 2592 -height 1944 -fps 30

# Explicitly select 4LANE (requires firmware CSI0 LANE NUM=4LANE and 4LANE Configure to be enabled)
./sample_vicap_sensor.elf -c 20 -s 0 -width 2592 -height 1944 -fps 30 -lane 4

# Force type (id is based on list_sensor)
./sample_vicap_sensor.elf -c 20 -s 0 -stype <id> -r 90
```

#### CHN0 Dump Format

```shell
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 0          # YUV420SP
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 1          # RGB888
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 2          # RGB888P
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 3 -dump 1  # RAW, ONLINE, automatically dump 1 frame and exit
```

#### Manual Exposure / Gain

```shell
./sample_vicap_sensor.elf -c 20 -ae 0 -exp 10000
./sample_vicap_sensor.elf -c 20 -ae 0 -again 2.0
```

#### Other

```shell
./sample_vicap_sensor.elf -c 20 -dnr3 0
./sample_vicap_sensor.elf -c 20 -r 90
./sample_vicap_sensor.elf -c 20 -mirror 1 -flip 0
./sample_vicap_sensor.elf -c 20 -tile 1              # Force SW_TILE (for debugging)
./sample_vicap_sensor.elf -c 20 -scene_name day -scene_path /etc/vicap/day/
```

### Interaction and Output

```text
Preview running. CHN0 dump (ofmt=0), CHN1 preview
Commands: d / d <n> dump, q quit
Command:
```

Dump file example:

```shell
vicap_dev0_chn0_1920x1080_0000.yuv420sp
vicap_dev0_chn0_1920x1080_0000.raw10
```

The program unpacks according to stride before writing the file, preventing image corruption caused by line padding.

```{admonition} 提示
- `-exp` / `-again` 须配合 `-ae 0`。
- CHN0 Dump、CHN1 预览；预览宽高按屏幕比例适配，并按 ISP MI 16 / 偶数高对齐。
- Connector / Sensor type 用 `list_connector`、`list_sensor` 查询。
- 同分辨率 2L/4L 与 menuconfig（**CSI0 LANE NUM**）说明见 [如何配置 Sensor](../../userguide/how_to_configure_sensor.md)。
```

## Related Documentation

- [How to Configure the Sensor](../../userguide/how_to_configure_sensor.md)
- [Image Sensor Support List](../../hardware_compatibility/sensor_list.md)
- [Sensor API](../../api_reference/mpp/sensor.md)
- [VICAP API](../../api_reference/mpp/vicap.md)
- [VO Display](./display.md)
