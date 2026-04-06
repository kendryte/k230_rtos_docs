# K230 FFT API参考

## 概述

当前 SDK 中对 FFT 硬件的用户态访问接口已经调整为 RT-Smart HAL 封装，公共头文件为 `drv_fft.h`。

当前接口的特点如下：

- 通过 `drv_fft_open()` 打开 `/dev/fft` 设备并获取实例句柄。
- `drv_fft_open()` 会预先申请输入/输出 MMZ 缓冲区，默认可覆盖最大 4096 点场景。
- 通过 `drv_fft_run()` 或 `drv_fft_fft()` / `drv_fft_ifft()` 进行 FFT 计算。
- HAL 内部负责 MMZ 缓冲区申请、缓存同步和 ioctl 调用，应用层只需要提供输入输出数组。
- 支持查询和调整 HAL 内部 DMA/MMZ 缓冲区大小。
- 支持 64、128、256、512、1024、2048、4096 点。
- 输入输出数据均为 `short`（`int16_t`）格式。
- 支持 `RIRI`、`RRRR`、`RR_II` 三种输入格式，以及 `RIRI_OUT`、`RR_II_OUT` 两种输出格式。

## 头文件与链接

- 头文件：`drv_fft.h`
- 示例工程中通常通过 `librtsmart_hal.mk` 引入 FFT HAL 库

## API 列表

- [drv_fft_open](#drv_fft_open)
- [drv_fft_close](#drv_fft_close)
- [drv_fft_set_input_alloc_size](#drv_fft_set_input_alloc_size)
- [drv_fft_set_output_alloc_size](#drv_fft_set_output_alloc_size)
- [drv_fft_get_input_alloc_size](#drv_fft_get_input_alloc_size)
- [drv_fft_get_output_alloc_size](#drv_fft_get_output_alloc_size)
- [drv_fft_run](#drv_fft_run)
- [drv_fft_fft](#drv_fft_fft)
- [drv_fft_ifft](#drv_fft_ifft)

## 函数说明

### drv_fft_open

【描述】

打开 FFT 设备，创建 HAL 实例。

【语法】

```c
int drv_fft_open(drv_fft_inst_t **inst);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
| -------- | ---- | --------- |
| inst | 返回 FFT 实例句柄 | 输出 |

【返回值】

| 返回值 | 描述 |
| ------ | ---- |
| 0 | 成功 |
| 负数 | 失败，返回负的 errno 风格错误码 |

【注意】

- 成功后必须配对调用 `drv_fft_close()` 释放。
- 如果 `/dev/fft` 不存在或驱动未初始化，打开会失败。
- 当前实现会在打开阶段预申请输入/输出 MMZ 缓冲区，默认大小均为最大 FFT 场景所需容量。

### drv_fft_close

【描述】

关闭 FFT 设备并释放实例。

【语法】

```c
void drv_fft_close(drv_fft_inst_t **inst);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
| -------- | ---- | --------- |
| inst | 要关闭的 FFT 实例句柄地址 | 输入/输出 |

【注意】

- 传入 `NULL` 或 `*inst == NULL` 时函数直接返回。
- 调用成功后，`*inst` 会被置为 `NULL`。
- `drv_fft_close()` 会同时释放内部 MMZ 输入/输出缓冲区。

### drv_fft_set_input_alloc_size

【描述】

调整 FFT HAL 内部输入 MMZ 缓冲区大小。

【语法】

```c
int drv_fft_set_input_alloc_size(drv_fft_inst_t *inst, uint32_t size);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
| -------- | ---- | --------- |
| inst | FFT 实例句柄 | 输入 |
| size | 新的输入缓冲区字节数 | 输入 |

【返回值】

| 返回值 | 描述 |
| ------ | ---- |
| 0 | 成功 |
| 负数 | 失败，返回负的 errno 风格错误码 |

【注意】

- 若当前大小已经等于 `size`，函数会直接返回成功。
- 若调整成功，会释放旧 MMZ 缓冲区并替换为新缓冲区。

### drv_fft_set_output_alloc_size

【描述】

调整 FFT HAL 内部输出 MMZ 缓冲区大小。

【语法】

```c
int drv_fft_set_output_alloc_size(drv_fft_inst_t *inst, uint32_t size);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
| -------- | ---- | --------- |
| inst | FFT 实例句柄 | 输入 |
| size | 新的输出缓冲区字节数 | 输入 |

【返回值】

| 返回值 | 描述 |
| ------ | ---- |
| 0 | 成功 |
| 负数 | 失败，返回负的 errno 风格错误码 |

### drv_fft_get_input_alloc_size

【描述】

获取当前输入 MMZ 缓冲区大小。

【语法】

```c
uint32_t drv_fft_get_input_alloc_size(const drv_fft_inst_t *inst);
```

### drv_fft_get_output_alloc_size

【描述】

获取当前输出 MMZ 缓冲区大小。

【语法】

```c
uint32_t drv_fft_get_output_alloc_size(const drv_fft_inst_t *inst);
```

【说明】

- 当 `inst == NULL` 时，上述查询接口返回 `0`。
- 默认打开后，输入和输出缓冲区都已经预分配。

### drv_fft_run

【描述】

按 `drv_fft_cfg_t` 中指定的模式直接执行一次 FFT 或 IFFT。

【语法】

```c
int drv_fft_run(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

【参数】

| 参数名称 | 描述 | 输入/输出 |
| -------- | ---- | --------- |
| inst | FFT 实例句柄 | 输入 |
| cfg | FFT 配置结构，见 [drv_fft_cfg_t](#drv_fft_cfg_t) | 输入 |
| in_real | 输入实部数组，长度为 `cfg->point` | 输入 |
| in_imag | 输入虚部数组，长度为 `cfg->point`；当 `input_mode == RRRR` 时可为 `NULL` | 输入 |
| out_real | 输出实部数组，长度为 `cfg->point` | 输出 |
| out_imag | 输出虚部数组，长度为 `cfg->point` | 输出 |

【返回值】

| 返回值 | 描述 |
| ------ | ---- |
| 0 | 成功 |
| 负数 | 失败，返回负的 errno 风格错误码 |

【注意】

- `cfg->point` 仅支持 `64/128/256/512/1024/2048/4096`。
- `cfg->mode` 决定执行 FFT 还是 IFFT。
- `timeout_ms` 写 `0` 表示不启用 FFT 超时上报；当前示例默认使用 `0`。
- 若本次运行所需输入/输出字节数超过当前内部缓冲区大小，会返回 `-ENOMEM`。
- `RRRR` 输入模式下，`in_imag` 可为 `NULL`。

### drv_fft_fft

【描述】

执行 FFT。该接口会忽略调用者传入的 `cfg->mode`，内部强制设置为 `FFT_MODE`。

【语法】

```c
int drv_fft_fft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                const short *in_real, const short *in_imag,
                short *out_real, short *out_imag);
```

【参数】

与 [drv_fft_run](#drv_fft_run) 相同。

### drv_fft_ifft

【描述】

执行 IFFT。该接口会忽略调用者传入的 `cfg->mode`，内部强制设置为 `IFFT_MODE`。

【语法】

```c
int drv_fft_ifft(drv_fft_inst_t *inst, const drv_fft_cfg_t *cfg,
                 const short *in_real, const short *in_imag,
                 short *out_real, short *out_imag);
```

【参数】

与 [drv_fft_run](#drv_fft_run) 相同。

## 数据类型

### drv_fft_inst_t

【说明】

FFT HAL 句柄类型，不透明结构体，仅通过指针使用。

### drv_fft_cfg_t

【说明】

FFT 运行配置。

【定义】

```c
typedef struct {
    uint32_t           point;
    k_fft_mode_e       mode;
    k_fft_input_mode_e input_mode;
    k_fft_out_mode_e   output_mode;
    uint16_t           shift;
    uint32_t           timeout_ms;
} drv_fft_cfg_t;
```

【成员】

| 成员名称 | 描述 |
| -------- | ---- |
| point | FFT/IFFT 点数，支持 `64 ~ 4096` 的 2 的幂 |
| mode | 运行模式，见 [k_fft_mode_e](#k_fft_mode_e) |
| input_mode | 输入格式，见 [k_fft_input_mode_e](#k_fft_input_mode_e) |
| output_mode | 输出格式，见 [k_fft_out_mode_e](#k_fft_out_mode_e) |
| shift | 每级缩放控制位 |
| timeout_ms | 超时配置，`0` 表示禁用超时上报 |

### k_fft_mode_e

【定义】

```c
typedef enum {
    FFT_MODE = 0,
    IFFT_MODE,
} k_fft_mode_e;
```

### k_fft_input_mode_e

【定义】

```c
typedef enum {
    RIRI = 0,
    RRRR,
    RR_II,
} k_fft_input_mode_e;
```

【说明】

- `RIRI`：输入按 `real0, imag0, real1, imag1...` 排列
- `RRRR`：纯实数输入，仅使用 `in_real`
- `RR_II`：先全部实部，再全部虚部

### k_fft_out_mode_e

【定义】

```c
typedef enum {
    RIRI_OUT = 0,
    RR_II_OUT,
} k_fft_out_mode_e;
```

【说明】

- `RIRI_OUT`：输出按交错格式返回
- `RR_II_OUT`：输出拆分到 `out_real[]` 与 `out_imag[]`

## 使用示例

```c
#include <stdio.h>
#include <string.h>

#include "drv_fft.h"

int main(void)
{
    drv_fft_inst_t *inst = NULL;
    short in_real[512] = {0};
    short in_imag[512] = {0};
    short out_real[512] = {0};
    short out_imag[512] = {0};
    drv_fft_cfg_t cfg = {
        .point = 512,
        .mode = FFT_MODE,
        .input_mode = RIRI,
        .output_mode = RR_II_OUT,
        .shift = 0x555,
        .timeout_ms = 0,
    };

    if (drv_fft_open(&inst) != 0)
        return -1;

    printf("fft in alloc = %u, out alloc = %u\n",
           drv_fft_get_input_alloc_size(inst),
           drv_fft_get_output_alloc_size(inst));

    if (drv_fft_fft(inst, &cfg, in_real, in_imag, out_real, out_imag) != 0) {
        drv_fft_close(&inst);
        return -1;
    }

    drv_fft_close(&inst);
    return 0;
}
```

## 示例与相关文档

- FFT HAL 回归示例：`src/rtsmart/examples/peripheral/fft/test_fft.c`
- 音频频谱显示示例：`src/rtsmart/examples/mpp/sample_fft_display/main.c`
- 外设示例文档： [FFT 外设示例](../../app_develop_guide/peripheral/fft.md)
- 媒体示例文档： [FFT 频谱显示示例](../../app_develop_guide/media/fft.md)

## 缓冲区尺寸建议

- 默认 `drv_fft_open()` 已经为最大 4096 点场景预分配缓冲区，通常不需要手动调整。
- 若后续 HAL 需要在更小内存占用场景下运行固定点数 FFT，可通过 `drv_fft_set_input_alloc_size()` / `drv_fft_set_output_alloc_size()` 缩小内部缓冲区。
- 如果手动缩小过缓冲区，再执行更大点数或更大输入布局的 FFT，`drv_fft_run()` 会返回 `-ENOMEM`。
