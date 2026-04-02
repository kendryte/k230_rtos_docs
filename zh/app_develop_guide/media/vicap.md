# VICAP Sensor Demo

## 简介

本示例 `sample_vicap_sensor` 演示了如何使用 K230 的 VICAP（Video Capture）模块进行摄像头图像采集和显示。VICAP 模块支持多种摄像头传感器，可以实现视频输入、图像捕获、Dump 等功能。

## 功能说明

### VICAP 功能

本示例展示了 VICAP 模块的主要功能：

- **摄像头初始化**：自动检测和初始化摄像头传感器
- **图像采集**：实时采集图像数据
- **分辨率配置**：支持自定义传感器分辨率和帧率
- **宽高比适配**：自动根据屏幕比例调整输出，保持画面不变形
- **双通道输出**：
  - **CHN0**：用于 Dump（支持 YUV/RGB/RAW 多种格式）
  - **CHN1**：用于预览显示（YUV420SP）
- **曝光控制**：支持自动和手动曝光（微秒单位）
- **白平衡**：支持自动白平衡（AWB）
- **HDR**：支持 HDR 功能
- **DNR3**：支持 3D 降噪（默认开启）
- **Dewarp**：支持图像畸变校正

### 支持的参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-c` | Connector 类型（必需） | 无 |
| `-r` | 旋转角度（0/90/180/270） | 0 |
| `-s` | CSI 索引（0-2） | 2 |
| `-ae` | AE 状态（0: 禁用，1: 启用） | 1 |
| `-awb` | AWB 状态（0: 禁用，1: 启用） | 1 |
| `-hdr` | HDR 状态（0: 禁用，1: 启用） | 0 |
| `-dw` | Dewarp 状态（0: 禁用，1: 启用） | 0 |
| `-exp` | 手动曝光时间（微秒） | - |
| `-width` | 传感器宽度 | 1920 |
| `-height` | 传感器高度 | 1080 |
| `-fps` | 传感器帧率 | 30 |
| `-ofmt` | CHN0 输出格式（0:YUV, 1:RGB888, 2:RGB888P, 3:RAW） | 0 |
| `-dnr3` | DNR3 状态（0: 禁用，1: 启用） | 1 |
| `-again` | 手动模拟增益（必须设置 -ae 0） | - |

### 交互命令

程序运行后，可以通过以下命令进行交互：

| 命令 | 说明 |
|------|------|
| `d` | Dump 一帧（从 CHN0） |
| `d <n>` | Dump n 帧（从 CHN0） |
| `q` | 退出程序 |

## 代码位置

```shell
src/rtsmart/examples/mpp/sample_vicap_sensor/
```

主要文件：

- `sample_vicap_sensor.c` - 主程序源码

## 使用说明

### 编译方法

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将 VICAP Sensor 示例编译进固件，然后编译固件。

### 运行示例

#### 基本预览

```shell
./sample_vicap_sensor.elf -c 20
```

#### 自定义分辨率和帧率

```shell
./sample_vicap_sensor.elf -c 20 -width 1280 -height 720 -fps 60
```

#### 启用 CHN0 Dump（YUV 格式）

```shell
./sample_vicap_sensor.elf -c 20 -ofmt 0
```

#### 手动曝光设置

```shell
# 设置曝光时间为 10000 微秒（10ms），必须关闭 AE
./sample_vicap_sensor.elf -c 20 -ae 0 -exp 10000
```

#### 禁用 DNR3

#### 手动增益设置

```shell
# 设置增益为 2.0，必须关闭 AE
./sample_vicap_sensor.elf -c 20 -ae 0 -again 1.0
```

```shell
./sample_vicap_sensor.elf -c 20 -dnr3 0
```

#### 旋转显示

```shell
# 旋转 90 度
./sample_vicap_sensor.elf -c 20 -r 90
```

### 交互操作

程序启动后，会显示命令菜单：

```text
Preview running.
CHN0: dump (format=0), CHN1: preview
Commands: d=dump 1 frame, d <n>=dump n frames, q=quit

---------------------------------------
 Input command:
   d      - Dump one frame
   d <n>  - Dump n frames
   q      - Quit
---------------------------------------
Command:
```

输入 `d` 或 `d 5` 即可 Dump 图像到文件。

### 查看结果

程序运行后会：

- 检测并初始化摄像头传感器
- 获取传感器分辨率和曝光范围
- 根据屏幕比例计算输出分辨率（保持宽高比）
- 配置 VICAP 双通道（CHN0 用于 Dump，CHN1 用于预览）
- 绑定 VICAP 到 VO 显示层
- 启动图像采集和显示

输出示例：

```text
INFO: Sensor resolution: 1920x1080
INFO: Sensor fd = 5
sample_vicap_sensor: connector=20, screen_size=1920x1080, output_size=1920x1080, layer=1, rotate=0, csi=2
Aspect ratio mode: sensor=1.78, screen=1.78
CHN0 format: 0 (0=yuv, 1=rgb888, 2=rgb888p, 3=raw)
Fullscreen mode (offset_x=0, offset_y=0)
VICAP features: AE=1, AWB=1, HDR=0, Dewarp=0, DNR3=1, Again=1.00
Bind VICAP(dev=0, ch=1) -> VO(layer=1) OK
Starting VICAP stream on dev0 ch0 ...
INFO: Manual exposure set to 10000 us (0.010000 sec), range: 0.000030-0.033333 sec
Preview running.
CHN0: dump (format=0), CHN1: preview
Commands: d=dump 1 frame, d <n>=dump n frames, q=quit
```

Dump 文件保存格式：

```shell
vicap_dev0_chn0_1920x1080_0000.yuv420sp
vicap_dev0_chn0_1920x1080_0001.yuv420sp
...
```

```{admonition} 提示
- 手动曝光设置时，必须先关闭 AE（`-ae 0`），否则会报错。
- 曝光值必须在传感器支持的范围内，程序会自动检查并提示有效范围。
- CHN0 用于 Dump，支持多种格式；CHN1 用于预览，固定为 YUV420SP 格式。
- 输出分辨率会自动根据屏幕比例调整，保持画面不变形。
```

```{admonition} 注意事项
- 使用 `-exp` 参数时，必须同时设置 `-ae 0`。
- 使用 `-again` 参数时，必须同时设置 `-ae 0`。
- 曝光值单位为微秒（us），例如 10000 表示 10ms。
- 增益值范围为传感器支持的范围，程序会自动检查并提示有效范围。
- Dump 功能通过交互命令触发，不在命令行参数中配置。
- 宽度会自动调整为 8 的倍数（硬件要求）。
```

## 相关文档

- [Sensor API 文档](../../api_reference/mpp/sensor.md)
- [VICAP API 文档](../../api_reference/mpp/vicap.md)
- [VO 显示文档](./display.md)
