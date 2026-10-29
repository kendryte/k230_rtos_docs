# VICAP Sensor Demo

## 简介

本示例 `sample_vicap_sensor` 演示如何使用 K230 VICAP 进行摄像头采集、预览与 Dump。

链路：

```text
Sensor → VICAP DEV0
     ├─ CHN0 → Dump（YUV / RGB888 / RGB888P / RAW）
     └─ CHN1 → VO → Connector（预览，YUV420SP）
```

## 功能说明

- **Sensor 探测**：按 `-width/-height/-fps/-lane` 自动匹配，或 `-stype` 强制指定
- **双通道**：CHN0 Dump，CHN1 预览（按屏幕宽高比适配）
- **工作模式**：见下文「VICAP 工作模式」
- **AE / AWB / HDR / DNR3 / Dewarp**
- **手动曝光 / 增益**（需 `-ae 0`）
- **镜像 / 翻转**（`-mirror` / `-flip`，须在 init 前生效）
- **场景加载**（`-scene_name` / `-scene_path`）
- **交互 Dump** 或 **`-dump <n>` 自动 Dump 后退出**

## 支持的参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-c` | Connector 类型（**必需**） | 无 |
| `-r` | 旋转（0 / 90 / 180 / 270） | 0 |
| `-s` | CSI 索引（0–2） | 2 |
| `-L` / `-lane` / `--lane <2\|4>` | 探测时 lane 偏好（对应 `lane_pref`） | **ANY**（不限制；同分排序偏向 2LANE） |
| `-stype <id>` | 强制 `k_vicap_sensor_type`（忽略 width/height/fps/lane） | 未设置 |
| `-width` / `-height` / `-fps` | 探测目标分辨率与帧率 | 1920 / 1080 / 30 |
| `-ofmt <0\|1\|2\|3>` | CHN0 格式：YUV / RGB888 / RGB888P / **RAW** | 0 |
| `-dump <n>` | 启动后自动 Dump n 帧并退出 | 交互模式 |
| `-ae` / `-awb` / `-hdr` / `-dw` / `-dnr3` | 各功能开关（0/1） | 1 / 1 / 0 / 0 / 1 |
| `-tile <0\|1>` | 强制 `VICAP_WORK_SW_TILE_MODE` | 0 |
| `-exp <us>` | 手动曝光（微秒，需 `-ae 0`） | — |
| `-again <x>` | 手动模拟增益（需 `-ae 0`） | — |
| `-mirror` / `-flip` | 水平镜像 / 垂直翻转（0/1） | 0 |
| `-scene_name` / `-scene_path` | 场景名与配置路径 | — |

`stype` / Connector 数值以板端 `list_sensor`、`list_connector` 为准。

### VICAP 工作模式

示例按如下规则选择 `dev_attr.mode`：

| 条件 | 模式 |
|------|------|
| `-tile 1` | 强制 **SW_TILE** |
| `-ofmt 3`（RAW Dump） | **ONLINE**（RAW 路径默认不走 SW_TILE；仍可用 `-tile 1` 强制） |
| 采集宽或高超过 VICAP 上限（约 3072×2160，如 4K YUV/RGB） | **SW_TILE** |
| 其他 | **ONLINE** |

`-ofmt 3` 时还会自动关闭 DNR3（避免 RAW Dump 路径多余开销）。

### 交互命令

| 命令 | 说明 |
|------|------|
| `d` | Dump 1 帧（CHN0） |
| `d <n>` | Dump n 帧 |
| `q` | 退出 |

## 代码位置

```shell
src/rtsmart/examples/mpp/sample_vicap_sensor/
```

- `sample_vicap_sensor.c` — 主程序

## 使用说明

### 编译

在 SDK 根目录 `make menuconfig` 勾选对应 example，再编译固件。

### 运行示例

#### 基本预览

```shell
./sample_vicap_sensor.elf -c 20
# 或指定 CSI0
./sample_vicap_sensor.elf -c 20 -s 0
```

#### 按分辨率探测 / 指定 lane

```shell
# 默认 lane=ANY；同分时排序偏向 2LANE
./sample_vicap_sensor.elf -c 20 -s 0 -width 2592 -height 1944 -fps 30

# 明确选 4LANE（需固件 CSI0 LANE NUM=4LANE 且已 Enable 4LANE Configure）
./sample_vicap_sensor.elf -c 20 -s 0 -width 2592 -height 1944 -fps 30 -lane 4

# 强制 type（id 以 list_sensor 为准）
./sample_vicap_sensor.elf -c 20 -s 0 -stype <id> -r 90
```

#### CHN0 Dump 格式

```shell
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 0          # YUV420SP
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 1          # RGB888
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 2          # RGB888P
./sample_vicap_sensor.elf -c 20 -s 0 -ofmt 3 -dump 1  # RAW，ONLINE，自动 dump 1 帧退出
```

#### 手动曝光 / 增益

```shell
./sample_vicap_sensor.elf -c 20 -ae 0 -exp 10000
./sample_vicap_sensor.elf -c 20 -ae 0 -again 2.0
```

#### 其他

```shell
./sample_vicap_sensor.elf -c 20 -dnr3 0
./sample_vicap_sensor.elf -c 20 -r 90
./sample_vicap_sensor.elf -c 20 -mirror 1 -flip 0
./sample_vicap_sensor.elf -c 20 -tile 1              # 强制 SW_TILE（调试用）
./sample_vicap_sensor.elf -c 20 -scene_name day -scene_path /etc/vicap/day/
```

### 交互与输出

```text
Preview running. CHN0 dump (ofmt=0), CHN1 preview
Commands: d / d <n> dump, q quit
Command:
```

Dump 文件示例：

```shell
vicap_dev0_chn0_1920x1080_0000.yuv420sp
vicap_dev0_chn0_1920x1080_0000.raw10
```

程序会按 stride 解包后再写文件，避免行 padding 导致花屏。

```{admonition} 提示
- `-exp` / `-again` 须配合 `-ae 0`。
- CHN0 Dump、CHN1 预览；预览宽高按屏幕比例适配，并按 ISP MI 16 / 偶数高对齐。
- Connector / Sensor type 用 `list_connector`、`list_sensor` 查询。
- 同分辨率 2L/4L 与 menuconfig（**CSI0 LANE NUM**）说明见 [如何配置 Sensor](../../userguide/how_to_configure_sensor.md)。
```

## 相关文档

- [如何配置 Sensor](../../userguide/how_to_configure_sensor.md)
- [图像传感器支持列表](../../hardware_compatibility/sensor_list.md)
- [Sensor API](../../api_reference/mpp/sensor.md)
- [VICAP API](../../api_reference/mpp/vicap.md)
- [VO 显示](./display.md)
