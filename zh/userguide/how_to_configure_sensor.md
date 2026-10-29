# 如何配置 Sensor 驱动

## 概述

K230 RTOS SDK 中，Sensor 驱动是否编入固件、挂在哪一路 CSI、CSI0 使用 2-lane 还是 4-lane、是否使用片内 MCLK，以及 ISP 参数如何打包与加载，均由 **MPP Kconfig** 与 VICAP API 共同决定。

配置入口统一走 SDK 根目录：

```bash
make menuconfig
# Docker 流程：k230 make menuconfig
```

相关代码与配置位置：

| 内容 | 路径 |
| :--- | :--- |
| Sensor / CSI / ISP 安装开关 | `src/rtsmart/mpp/Kconfig` → `MPP Configuration` → `Sensor Configuration` |
| Sensor 驱动与模式表 | `src/rtsmart/mpp/kernel/sensor/` |
| 板端 `list_sensor` 命令 | `src/rtsmart/mpp/kernel/sensor/src/sensor_dev.c` |
| Sensor type 枚举 | `src/rtsmart/mpp/include/comm/k_sensor_comm.h` |
| 应用层 Sensor 信息表 / 探测匹配 | `src/rtsmart/mpp/userapps/src/sensor/mpi_sensor.c`（`kd_mpi_sensor_adapt_get_ex`） |
| ISP 标定 / 调优源文件 | `src/rtsmart/mpp/userapps/src/sensor/config/` |
| ISP 安装规则 | `src/rtsmart/mpp/userapps/src/sensor/Makefile` |
| ISP 加载与解析模式 | `src/rtsmart/mpp/userapps/src/vicap/src/mpi_vicap.c` |

型号与分辨率一览见 [图像传感器支持列表](../hardware_compatibility/sensor_list.md)。从零接入新型号见 [如何增加 Sensor](../advanced_development_guide/how_to_add_sensor.md)。

## 打开 menuconfig

- 先选择板级 defconfig（示例）：

   ```bash
   make k230_rtos_01studio_defconfig
   ```

- 进入交互配置：

   ```bash
   make menuconfig
   ```

- 导航到：

   ```text
   MPP Configuration
     └── Sensor Configuration
   ```

- 重新编译并烧录后生效：

   ```bash
   make
   ```

菜单示意（`Sensor Configuration`）：

![menuconfig Sensor Configuration](https://www.kendryte.com/api/imagecdn/zh/sensorconfig.png)

> 上图为 menuconfig 界面示意，具体条目以当前 SDK 的 `mpp/Kconfig` 为准。

## 如何查看当前支持的 Sensor

### 方法一：menuconfig 查看（编译前）

在 `Sensor Configuration` 下找到 **`Sensor Drivers Configuration`**，每一项 `Enable <型号>` 对应已接入 SDK 的一种驱动，例如：

- `Enable GC2093`
- `Enable OV5647`

- **勾选**：驱动编入内核，对应模式会出现在板端 `list_sensor` 中，且匹配的 ISP 配置会按规则安装进镜像。
- **未勾选**：该型号不会出现在当前固件中。

列表以 `src/rtsmart/mpp/Kconfig` 为准，会随版本增加。

### 方法二：查看板级 defconfig

```bash
grep CONFIG_MPP_ENABLE_SENSOR_ configs/<your_board>_defconfig
grep CONFIG_MPP_CSI0_LINK_MODE_ configs/<your_board>_defconfig
```

示例：

```text
CONFIG_MPP_CSI0_LINK_MODE_2LANE=y
CONFIG_MPP_ENABLE_SENSOR_IMX335=y
CONFIG_MPP_ENABLE_SENSOR_GC2093=y
```

### 方法三：板端 `list_sensor`（确认驱动是否打开）

`list_sensor` 是 RT-Smart `msh` 命令，由 `sensor_dev.c` 导出。它先按 CSI 打印当前检测到的驱动、支持的模式和 lane 数，再列出所有配置的 Sensor type，并标记为 `SUPPORTED` 或 `NOT DETECTED`。

在串口进入 `msh` 后执行：

```bash
list_sensor
```

示意输出：

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

用法说明：

| 现象 | 含义 |
| :--- | :--- |
| `CSI<n>: <driver> (...)` | 该 CSI 检测到驱动，括号内为驱动模式数量 |
| `CSI<n>: no sensor driver detected` | 该 CSI 没有检测到已加载的 Sensor 驱动 |
| `[SUPPORTED]` | 配置的 type 出现在检测到的驱动模式表中 |
| `[NOT DETECTED]` | 该 type 已配置但当前板端未检测到对应驱动 / 模式 |
| 条目中的 `2 lanes` / `4 lanes` | 当前检测到的模式使用的 MIPI lane 数 |
| 有 type 但预览黑屏 | 驱动已加载，问题更可能在硬件接线、MIPI 链路或 ISP 参数 |

应用层选 sensor 时，应使用 `list_sensor` 打出的 **名称 / type**，不要硬编码易变的数字序号（序号随 Kconfig 组合变化）。

CSI0 / CSI1 / CSI2 的 type 在枚举（`k_sensor_comm.h`）、`list_sensor` 表、`mpi_sensor.c` 适配表中均按 `CONFIG_MPP_ENABLE_CSI_DEV_n` 隔离：某路 CSI 未启用时，对应 type 不会编入固件。

## CSI0 LANE NUM（2LANE / 4LANE）

在 `Sensor Hardware Configuration` 最上方有独立选项 **`CSI0 LANE NUM`**（默认 **2LANE**）：

```text
MPP Configuration
  └── Sensor Configuration
        ├── CSI0 LANE NUM (2LANE) --->
        │     ├── (X) 2LANE          # 默认；各 Sensor 的 4LANE 选项隐藏
        │     └── ( ) 4LANE          # CSI0 可用 2L+4L；各 Sensor 可开 4LANE Configure
        ├── [*] Enable CSI0  --->    # GPIO / I2C / MCLK
        ├── [*] Enable CSI1          # 可编译共存；运行时不能与 CSI0 4LANE 同时初始化
        └── [*] Enable CSI2
```

| `CSI0 LANE NUM` | 宏 | 效果 |
| :--- | :--- | :--- |
| 2LANE（默认） | `CONFIG_MPP_CSI0_LINK_MODE_2LANE=y` | 各 `*_ENABLE_4LANE_CONFIGURE` / IMX415 不可见、不编译 |
| 4LANE | `CONFIG_MPP_CSI0_LINK_MODE_4LANE=y` | CSI0 可同时保留 2-lane 与 4-lane 模式；`Enable CSI1` 仍可选 |

硬件说明：默认板卡上 CSI0 做 4-lane 聚合会占用与 CSI1 共用的 PHY。软件**不再**因此隐藏 CSI1，以便客户飞线/改板后使用 CSI1；在未改板的原厂接线时，勿同时开 CSI0 4LANE 与 CSI1。

### 如何切换成 4LANE 模式

目前提供 per-sensor 4-lane 开关的型号包括 **IMX335**、**OV13850**、**IMX415**（IMX415 整传感器仅在 4LANE link mode 下可见）。

1. `make menuconfig` → `Sensor Configuration`
2. **`CSI0 LANE NUM` → 选 `4LANE`**
3. 确认 `[*] Enable CSI0`
4. 打开目标 Sensor，并勾选其子菜单中的 **`Enable 4LANE Configure`**（IMX335 / OV13850 在 4LANE 下默认打开；IMX415 默认打开）
5. （可选）若改板后仍要用 CSI1，可继续勾选 `Enable CSI1`

```text
CSI0 LANE NUM (4LANE) --->
[*] Enable CSI0
[ ] Enable CSI1          # 默认可不选；飞线改板后再开
[*] Enable IMX335
  └── [*] IMX335 Enable 4LANE Configure
```

OV13850 / IMX415 同理。

对应 Kconfig 宏：

| 选项 | 宏 |
| :--- | :--- |
| CSI0 2LANE | `CONFIG_MPP_CSI0_LINK_MODE_2LANE` |
| CSI0 4LANE | `CONFIG_MPP_CSI0_LINK_MODE_4LANE` |
| IMX335 4-lane 模式 | `CONFIG_MPP_SENSOR_IMX335_ENABLE_4LANE_CONFIGURE` |
| OV13850 4-lane 模式 | `CONFIG_MPP_SENSOR_OV13850_ENABLE_4LANE_CONFIGURE` |
| IMX415 4-lane 模式 | `CONFIG_MPP_SENSOR_IMX415_ENABLE_4LANE_CONFIGURE` |

IMX335 子菜单示意：

![IMX335 4LANE menuconfig](https://www.kendryte.com/api/imagecdn/zh/imx335config.png)

### 打开后如何确认

- `.config` / defconfig 中为 `CONFIG_MPP_CSI0_LINK_MODE_4LANE=y`
- 板端 `list_sensor` 的 `Detected Sensor Drivers` 中有对应 `*_CSI0_4LANE_*` 模式（以及仍可用的 CSI0 2LANE 模式）
- 未启用 `Enable CSI1` 时不会出现 `*_CSI1_*`；启用后会出现
- 应用侧用分辨率探测时加 **`-lane 4`**，或用 `-stype` 指定 4LANE type（见下一节）
- 模组与排线必须真实支持 4-lane；仅软件打开而硬件只有 2-lane 时，会出现链路错误或黑屏

> 4K Sensor（如 OV13850、IMX415）还受 VICAP 工作模式限制，见 [sensor_list.md](../hardware_compatibility/sensor_list.md)。

## 应用层如何按分辨率 / FPS / Lane 匹配 Sensor

`sample_vicap_sensor` 等示例通过 `kd_mpi_sensor_adapt_get_ex(config, info, lane_pref)`（`mpi_sensor.c`）按参数探测模式；也可用 `-stype` 强制指定枚举。旧接口 `kd_mpi_sensor_adapt_get()` 保留兼容性，但始终使用 `ANY`，不能指定 lane 偏好。

### 命令行参数（`sample_vicap_sensor`）

完整参数表与示例见 [VICAP Sensor Demo](../app_develop_guide/media/vicap.md)。与探测相关的常用项：

| 参数 | 含义 | 默认 |
| :--- | :--- | :--- |
| `-s <0\|1\|2>` | CSI 口 | 2 |
| `-width` / `-height` / `-fps` | 期望分辨率与帧率 | 1920 / 1080 / 30 |
| `-lane <2\|4>` | 同分辨率时 lane 偏好（`lane_pref`） | **ANY**（不限制；同分排序偏向 2LANE） |
| `-stype <id>` | 强制 `k_vicap_sensor_type` | 未设置 |
| `-ofmt <0\|1\|2\|3>` | CHN0：YUV / RGB888 / RGB888P / RAW | 0 |
| `-dump <n>` | 自动 Dump n 帧后退出 | 交互 |
| `-tile <0\|1>` | 强制 SW_TILE（调试） | 0 |

工作模式摘要：`-ofmt 3`（RAW）默认 **ONLINE**；4K 等超限的 YUV/RGB 预览用 **SW_TILE**；`-tile 1` 可强制 SW_TILE。

示例：

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

### `kd_mpi_sensor_adapt_get_ex` 匹配规则

探测结构体 `k_vicap_probe_config` 含 `csi_num`、`width`、`height`、`fps` 等条件，不再包含 `lane_pref`。调用方应对结构体清零，并通过 `kd_mpi_sensor_adapt_get_ex()` 的第三个参数传入 lane 偏好；使用 `VICAP_MIPI_LANE_PREF_ANY=0` 时不按 lane 过滤，4LANE-only 如 IMX415 / OV13850 1080p 仍可被探测到。

1. **候选过滤**
   - CSI 口必须等于请求的 `csi_num`
   - `lane_pref=ANY`：不过滤；`=2LANE`：保留非 4LANE（含 1LANE）；`=4LANE`：只保留 `VICAP_MIPI_4LANE`；非法值按 `ANY` 处理；4LANE 仅支持 CSI0
   - 能成功 `open` 的 sensor 才进入候选（板上实际存在）
2. **排序**：fps 高 → width 大 → height 大 → 同分辨率时 **2LANE 优先于 4LANE**
3. **匹配优先级**
   1. `fps != 0` 时先找 **width + height + fps 全相等**
   2. 再找 **width + height 相等**（fps 可不同）
   3. 再找 **不小于** 请求宽高的更大分辨率
   4. 仍无则失败

因此同一分辨率下的 2LANE / 4LANE：默认 `ANY` 时由排序偏向 2LANE；需要强制某一侧时用 `-lane` / `lane_pref`。编译侧再用 `CSI0 LANE NUM` 决定 4LANE type 是否编进固件；应用运行时不能在 CSI1/CSI2 上请求 4LANE，也不能同时初始化 CSI0 4LANE 与 CSI1。

## CSI 与驱动公共选项

### 默认 CSI

- **`Default SENSOR on CSI`**：默认 CSI 口（0 / 1 / 2）。

### Sensor Hardware Configuration

| 选项 | 含义 |
| :--- | :--- |
| **CSI0 LANE NUM** | `2LANE`（默认）/ `4LANE`；见上一节 |
| Enable CSI0 | 打开后配置 PowerDown / Reset / I2C / MCLK |
| Enable CSI1 | 可与 4LANE 一起编译；运行时 CSI0 4LANE 与 CSI1 不能同时初始化 |
| Enable CSI2 | 与 4LANE 无 PHY 冲突，可按需开启 |

每路 CSI（启用后）公共项：

| 选项 | 含义 |
| :--- | :--- |
| PowerDown GPIO | 电源脚；无则设 `-1` |
| Reset GPIO | 复位脚；无则设 `-1` |
| I2c Bus | 如 `i2c0` |
| MCLK num | 片内 MCLK1/2/3，或外部晶振 |

### Sensor 子选项

| 选项 | 含义 |
| :--- | :--- |
| `On CSI0/1/2 Use CHIP MCLK` | 该 Sensor 在对应 CSI 上是否用片内 MCLK |
| `Enable 4LANE Configure` | 额外编译 CSI0 4-lane 模式；**仅在 `CSI0 LANE NUM=4LANE` 时出现** |

### AutoFocus（可选）

`Enable AutoFocus` → 可再勾选音圈马达驱动（如 DW9714P），仅硬件有 AF 时需要。

## ISP 配置：bin 与 XML/JSON 切换

### 源文件与安装

ISP 参数源文件目录：

```text
src/rtsmart/mpp/userapps/src/sensor/config/
```

命名约定（以 IMX335 2592×1944 为例）：

| 文件 | 用途 |
| :--- | :--- |
| `imx335-2592x1944_auto.json` | 自动档；生成 `.bin` 的输入之一 |
| `imx335-2592x1944_manual.json` | 手动档 |
| `imx335-2592x1944.xml` | XML 标定 / 调优参数 |

`Sensor Configuration` 顶部两个安装开关：

| 选项 | 宏 | 作用 |
| :--- | :--- | :--- |
| Install binary ISP configurations | `CONFIG_MPP_ISP_CONFIG_INSTALL_BIN` | 生成并安装 `*.bin` 到镜像 `bin/` |
| Install JSON and XML ISP configurations | `CONFIG_MPP_ISP_CONFIG_INSTALL_JSON_XML` | 拷贝匹配的 `.json` / `.xml` 到镜像 `bin/` |

只有 **已 Enable 的 Sensor**，其前缀匹配的 ISP 文件才会被安装（见 `userapps/src/sensor/Makefile`）。

编译产物一般在：

```text
output/<defconfig>/images/bin/
```

板端路径通常为 `/bin/`，例如 `/bin/imx335-2592x1944.bin`、`/bin/imx335-2592x1944.xml`。

### 为何 bin 模式无法“实时换 ISP 文件”

默认逻辑（未显式指定解析模式时）：

- `kd_mpi_vicap_init()` 会探测 `/bin/<database_name>.bin`。
- 若 `.bin` 存在且加载成功，则走 **bin 模式**（内部枚举为 `VICAP_DATABASE_PARSE_HEADER`）。
- bin 是编译期由 `gen_isp_config_bin` 把 xml/json **固化** 后的二进制；运行时再改板端 `.xml` / `.json` **不会**自动反映到已加载的 bin 里。
- 要让新参数进 bin，必须改源文件 → 重新 `make` 生成 bin → 重新烧录 / 替换 `/bin/*.bin` → 再启动应用。

因此：**调优阶段若需要频繁改 ISP 参数，应切换到 XML/JSON 解析模式。**

### 如何切换成 XML/JSON 模式（代码）

在 **`kd_mpi_vicap_init()` 之前** 调用：

```c
#include "mpi_vicap_api.h"
#include "k_vicap_comm.h"

k_vicap_dev vicap_dev = VICAP_DEV_ID_0;

/* 强制从 /bin/<database>.xml 与 *_auto.json / *_manual.json 加载 */
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
if (ret) {
    printf("set_database_parse_mode failed, ret=%d\n", ret);
    return ret;
}

ret = kd_mpi_vicap_init(vicap_dev);
```

枚举含义（`k_vicap_comm.h`）：

| 枚举 | 值 | 实际行为 |
| :--- | :--- | :--- |
| `VICAP_DATABASE_PARSE_XML_JSON` | 0 | 使用 XML + JSON，**不优先加载 bin** |
| `VICAP_DATABASE_PARSE_HEADER` | 1 | 强制 bin；bin 不存在则初始化失败 |

> API 注释里 HEADER 曾表示“头文件模式”；当前实现中它对应 **二进制 bin 配置**。

SDK 中大量示例（如 `examples/ai/yolo/src/pipeline.cc`）在 `vicap_init` 前显式设置为 XML/JSON：

```c
ret = kd_mpi_vicap_set_database_parse_mode(vicap_dev, VICAP_DATABASE_PARSE_XML_JSON);
ret = kd_mpi_vicap_init(vicap_dev);
```

而 `sample_vicap_sensor` 等未调用该接口时，会在有 `.bin` 的情况下自动走 bin。

### XML/JSON 模式下如何更换参数

- menuconfig 保持 **`Install JSON and XML ISP configurations`** 为 y，确保镜像里有 xml/json。
- 应用里按上一节切换到 `VICAP_DATABASE_PARSE_XML_JSON`。
- 修改并替换板端文件，例如：

   ```bash
   # 主机侧推送（路径以实际文件系统为准）
   adb push imx335-2592x1944.xml /bin/
   adb push imx335-2592x1944_auto.json /bin/
   adb push imx335-2592x1944_manual.json /bin/
   ```

- **重新运行应用**（需再次 `vicap_init`）。ISP 在 init 时加载，**不能**在保持同一路 stream 的情况下热替换已生效的 bin 内存镜像。

默认加载路径由 `database_name`（如 `imx335-2592x1944`）与 ISP config path（默认 `/bin/`）拼出：

```text
/bin/imx335-2592x1944.xml
/bin/imx335-2592x1944_auto.json
/bin/imx335-2592x1944_manual.json
```

### 模式选择建议

| 场景 | 建议 |
| :--- | :--- |
| 量产 / 快速启动 | bin（默认探测即可），参数固化 |
| ISP 标定 / 调优 / 频繁改参 | 代码设为 `VICAP_DATABASE_PARSE_XML_JSON`，改 xml/json 后重启应用 |
| 显式要求必须用 bin | `kd_mpi_vicap_set_database_parse_mode(..., VICAP_DATABASE_PARSE_HEADER)` |

标定与调优细节：

- [如何进行 ISP 标定](../advanced_development_guide/how_to_calibrate_isp.md)
- [如何进行 ISP 调优](../advanced_development_guide/how_to_tune_isp.md)

## 配置检查清单

- **`CSI0 LANE NUM`**：默认 2LANE；需要 CSI0 4-lane 时改为 4LANE（CSI1 可编译，但不能与 CSI0 4LANE 同时初始化）。
- `Enable CSIx` 与板级接线一致（GPIO / I2C / MCLK）。
- 勾选目标 `Enable <Sensor>`；4LANE 下再确认 `Enable 4LANE Configure`。
- 同分辨率 2L/4L：默认 `lane_pref=ANY`（同分排序偏向 2LANE）；需强制时用 `-lane 2|4` 或 `-stype`。
- ISP：量产用 bin；调优用代码切到 XML/JSON，并保证 json/xml 已安装到 `/bin/`。
- `make` → 烧录 → **`list_sensor`** 确认检测到的 CSI / type / lane → 再跑 VICAP / Sensor 示例。

## 相关文档

- [图像传感器支持列表](../hardware_compatibility/sensor_list.md)
- [如何增加 Sensor](../advanced_development_guide/how_to_add_sensor.md)
- [如何编译固件](./how_to_build.md)
- [如何运行示例程序](./how_to_run_samples.md)
