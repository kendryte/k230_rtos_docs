# FFT 频谱显示 Demo

## 简介

当前媒体章节中的 FFT 示例已经调整为音频实时频谱显示 Demo。该示例从 AI 采集单声道音频，调用 FFT HAL 完成硬件 FFT 计算，再通过 OSD 图层把频谱柱状图绘制到显示屏上。

与旧版仅做 FFT/IFFT 回归测试的 `sample_fft` 不同，当前示例更关注完整媒体链路联调，覆盖以下模块：

- 音频采集（AI / I2S）
- FFT HAL 调用
- VB/MMZ 缓冲区使用
- OSD 图层绘制与屏幕显示
- 自动横屏布局与频率坐标轴显示

如果您只想验证 FFT HAL 的基础正确性，请参考外设章节中的 [FFT HAL 示例](../peripheral/fft.md)。

## 功能说明

- 实时采集音频数据并执行硬件 FFT
- 自动使用显示面板的横屏布局，尽量获得更大的频谱横向分辨率
- 在频谱底部绘制频率刻度和 `Hz` 轴标识
- 支持自定义采样率、FFT 点数、旋转角度、显示尺寸与显示增益

## 代码位置

Demo 源码位置：`src/rtsmart/examples/mpp/sample_fft_display/main.c`

## 编译与运行

### 编译

在 SDK 根目录编译固件后，示例 ELF 会生成到 RT-Smart 示例目录中。

### 运行

启动开发板后，进入 `/sdcard/app/examples/mpp` 目录，运行：

```shell
./sample_fft_display.elf -c <connector_type> [选项]
```

例如，01Studio 480x800 屏幕可使用：

```shell
./sample_fft_display.elf -c 20 -s 44100 -p 512
```

## 参数说明

可通过 `./sample_fft_display.elf -h` 查看帮助。当前版本支持以下参数：

| 参数名 | 说明 | 默认值 |
| ------ | ---- | ------ |
| `-c <type>` | 连接器类型，必填，可结合 `list_connector` 查看 | 无 |
| `-w <width>` | OSD 宽度 | 根据旋转后的面板尺寸自动推导 |
| `-h <height>` | OSD 高度 | 根据旋转后的面板尺寸自动推导 |
| `-r <deg>` | 旋转角度，支持 `0/90/180/270` | 自动横屏 |
| `-s <rate>` | 音频采样率 | `44100` |
| `-p <points>` | FFT 点数，支持 `64~4096` 的 2 的幂 | `512` |
| `-g <gain>` | 显示增益，单位 dB | `0` |

## 运行效果

启动后，程序会输出类似以下日志：

```shell
./sample_fft_display.elf -c 20 -s 44100 -p 512
FFT Spectrum: connector=20, panel=480x800, OSD=800x480, rotate=90, rate=44100, points=512, gain=0.0 dB
main start connector=20 panel=480x800 osd=800x480 rotate=90 rate=44100 points=512
before drv_fft_open
after drv_fft_open inst=0x7f9f2030
Running... press Ctrl+C to stop
```

此时屏幕上会持续显示：

- 频谱柱状图
- 底部频率坐标轴
- 顶部标题与实时刷新率

按 `Ctrl+C` 可退出示例。

```{admonition} 提示
当前示例使用的是 FFT HAL 接口 `drv_fft_*`，不再使用旧版 `kd_mpi_fft*` API。接口细节请参考 [FFT API 文档](../../api_reference/peripheral/fft.md)。
```
