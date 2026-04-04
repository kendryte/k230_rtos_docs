# FFT HAL 示例

## 简介

本示例是 FFT HAL 的基础回归测试程序，重点验证 FFT 和 IFFT 的往返精度以及不同点数下的运行耗时。

示例会按顺序测试以下点数：

- 64
- 128
- 256
- 512
- 1024
- 2048
- 4096

对每个点数，程序会：

1. 生成一组固定测试信号。
1. 执行一次 FFT。
1. 再执行一次 IFFT。
1. 比较恢复后的数据与原始输入的最大误差。
1. 打印 FFT/IFFT 的耗时统计。

## 代码位置

源码位置：`src/rtsmart/examples/peripheral/fft/test_fft.c`

## 关键接口

- `drv_fft_open()`
- `drv_fft_fft()`
- `drv_fft_ifft()`
- `drv_fft_close()`

## 编译与运行

### 编译

```shell
cd src/rtsmart/examples/peripheral/fft
make
```

### 运行

启动开发板后，进入 `/sdcard/app/examples/peripheral` 目录，运行：

```shell
./fft.elf [verbose]
```

## 参数说明

| 参数名 | 说明 | 默认值 |
| ------ | ---- | ------ |
| `verbose` | 日志详细级别。`0` 仅输出汇总，`1` 输出每个点数摘要，`2` 输出逐点差异 | `1` |

## 示例输出

```shell
./fft.elf 1
main start verbose=1
before drv_fft_open
after drv_fft_open inst=0x7f9f2030
start point=64
  point   64  fft 133 us  ifft 121 us  max_diff(real=3@45, imag=1@3)  PASS
start point=128
  point  128  fft 121 us  ifft 118 us  max_diff(real=3@15, imag=2@31)  PASS
...
start point=4096
  point 4096  fft 1099 us  ifft 1067 us  max_diff(real=5@4094, imag=2@122)  PASS
before drv_fft_close
done failures=0

7/7 tests passed
```

## 说明

- 示例中的 FFT 默认使用 `shift = 0x555`。
- IFFT 默认使用 `shift = 0xaaa`。
- 当前判定阈值为实部和虚部最大误差均不超过 `5`。

```{admonition} 提示
FFT HAL 的接口定义请参考 [FFT API 文档](../../api_reference/peripheral/fft.md)。如果需要查看音频实时频谱显示示例，请参考 [媒体章节 FFT 频谱显示 Demo](../media/fft.md)。
```
