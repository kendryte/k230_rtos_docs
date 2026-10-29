# PMU HAL 接口文档

## 概述

K230 提供了 PMU HAL 接口，用于在系统运行态处理中长按关机流程，以及配置 RTC 定时关机/定时开机。

- 用户态 HAL 头文件：`src/rtsmart/libs/rtsmart_hal/drivers/pmu/drv_pmu.h`
- 用户态 HAL 实现：`src/rtsmart/libs/rtsmart_hal/drivers/pmu/drv_pmu.c`
- 参考示例：`src/rtsmart/examples/peripheral/pmu/test_pmu.c`

PMU HAL 当前主要覆盖五类能力：

1. 长按电源键关机通知与用户态确认
1. 应用主动立即关机
1. RTC 定时关机、定时开机（power cycle）
1. 读取关机唤醒 PAD 的当前电平
1. 读取本次启动捕获到的唤醒源

> 注意：RTC 普通读写时间、普通 alarm/tick 中断配置属于 RTC 设备接口能力，不在 `drv_pmu.h` 这个 HAL 头文件内。

接口按功能分组：`key_*` 只处理电源键长按事件，`rtc_*` 只处理 RTC 定时 power cycle，`drv_pmu_shutdown_now()` 是应用主动立即关机接口。

---

## 内核配置

PMU 驱动和关机后唤醒源需要在 RT-Smart 内核配置中打开。配置入口：

```text
Drivers Configuration
  -> InterDriver
    -> Using RTC/PMU device drivers
```

启用 `Using RTC/PMU device drivers` 后，对应的 Kconfig 符号为 `RT_USING_RTC_PMU`。该选项会启用 PMU/RTC 内核驱动，并生成 `/dev/pmu_pwrkey` 等设备节点。

### PAD64 长按参数

在 `Using RTC/PMU device drivers` 下进入：

```text
PMU PAD64 long press
```

该菜单包含两个相互独立的修改开关：

| 配置项 | Kconfig 符号 | 作用 |
| --- | --- | --- |
| Modify PMU long press shutdown seconds | `RT_PMU_LONG_PRESS_SHUTDOWN_CONFIG` | 打开后显示 `PMU long press shutdown seconds`，设置系统运行态软件长按关机时间，单位为秒，范围 1 ~ 30，默认 5。 |
| Modify PMU long press poweron seconds | `RT_PMU_LONG_PRESS_POWERON_CONFIG` | 打开后显示 `PMU long press poweron seconds`，设置 PAD64 关机后长按开机硬件阈值，单位为秒，范围 1 ~ 30，默认 5。 |

两个修改开关默认关闭。关闭 `Modify PMU long press shutdown seconds` 时，运行态软件长按关机时间使用默认 5 秒；关闭 `Modify PMU long press poweron seconds` 时，驱动不写入 PMU 的硬件长按开机阈值寄存器。

### 关机后 PAD 唤醒

在 `Using RTC/PMU device drivers` 下打开：

```text
PMU shutdown wakeup PADs
```

对应符号为 `RT_PMU_SHUTDOWN_WAKEUP`。打开后，可以分别启用 PAD64、PAD65、PAD66、PAD67、PAD68、PAD69；多个 PAD 可以同时启用。

PAD64 即电源键（int0），默认保留给电源键长按开机/关机流程。如需把它当作普通的边沿/电平唤醒源使用，可打开 `RT_PMU_SHUTDOWN_WAKEUP_PAD64`（菜单项 `Enable PAD64 (power key) as edge/level shutdown wakeup`）。启用后 PAD64 与 PAD65 ~ PAD68 完全一致：运行态可作为 GPIO 读取当前电平，关机时按配置武装为 PMU 边沿/电平唤醒源；但**会放弃 PAD64 的运行态长按开机/关机功能**。不启用时保持长按行为，PAD64 不作为通用唤醒 PAD。

> **选型建议**：PAD64 是电源键专用输入，其"长按 N 秒方可开机"的阈值本质上是对开机动作的防抖与防误触保护。**默认应让 PAD64 承担电源键长按开机/关机，而不要像 PAD68 那样把它配成通用电平/边沿唤醒源**。一旦启用通用唤醒，任意一次按键（甚至瞬时触碰，或满足所配电平条件）都会立即唤醒系统——"长按方可开机"的语义随之失效，电源键退化为普通唤醒触发，极易误唤醒。因此仅当硬件未引出其他 PMU 唤醒 PAD（PAD65 ~ PAD69）、确实没有可用唤醒引脚时，才建议改用 PAD64 作为通用唤醒源；此时应结合触发类型与上下拉配置，尽量降低误唤醒概率。

每个 PAD 都是一个独立的 `Enable PAD* shutdown wakeup` 子菜单。只有启用对应 PAD 后，才会显示该 PAD 的以下配置，并且三项配置彼此平级：

```text
Enable PAD68 shutdown wakeup
  PAD68 wakeup source name
  PAD68 wakeup trigger type
  PAD68 wakeup PAD pull bias
```

PAD64、PAD65、PAD66、PAD67 还会显示各自的 debounce 配置。对应的 Kconfig 符号如下：

| 配置内容 | PAD65 示例 | 其他 PAD（PAD64、PAD66 ~ PAD69） |
| --- | --- | --- |
| 启用 PAD | `RT_PMU_SHUTDOWN_WAKEUP_PAD65` | 将 `PAD65` 替换为对应 PAD |
| 唤醒源名称 | `RT_PMU_SHUTDOWN_WAKEUP_SOURCE_PAD65` | 将 `PAD65` 替换为对应 PAD |
| 触发类型 | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_TRIGGER` | 将 `PAD65` 替换为对应 PAD |
| PAD 上下拉 | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_BIAS` | 将 `PAD65` 替换为对应 PAD |
| debounce ticks | `RT_PMU_SHUTDOWN_WAKEUP_PAD65_DEBOUNCE_TICKS` | 仅 PAD64、PAD65、PAD66、PAD67 支持 |

PAD64 启用为通用唤醒后，其配置符号同样遵循上表规则：`RT_PMU_SHUTDOWN_WAKEUP_SOURCE_PAD64`、`RT_PMU_SHUTDOWN_WAKEUP_PAD64_TRIGGER`、`RT_PMU_SHUTDOWN_WAKEUP_PAD64_BIAS`、`RT_PMU_SHUTDOWN_WAKEUP_PAD64_DEBOUNCE_TICKS`，源名默认 `PAD64_WAKEUP`。

触发类型可选高电平、低电平、上升沿和下降沿，默认是上升沿。PAD 上下拉可选保持当前设置、上拉、下拉和关闭上下拉，默认是保持当前 `PMU_IO_CFG_x` 设置。PAD64、PAD65、PAD66、PAD67 的 debounce ticks 单位为 32 KHz PMU 时钟周期，取值范围为 0 ~ 4095，默认 256；PAD68 和 PAD69 没有对应 debounce 寄存器。

`wakeup source name` 是编译进内核的字符串，例如可以填写 `PIR_WAKEUP` 或 `4G_WAKEUP`。字符串缓冲区为 64 字节，建议填写 63 个字符以内的非空名称。系统由该 PAD 唤醒后，`drv_pmu_wakeup_source_get()` 返回该名称。

说明：

1. `PMU_IO_CFG_0` ~ `PMU_IO_CFG_5` 分别对应 PAD64 ~ PAD69。运行态初始化完成后，所有已启用的唤醒 PAD 会切换为 GPIO 输入，便于读取当前电平；进入关机流程时，驱动会将它们切回 PMU 输入并写入各自的触发类型、上下拉和 debounce 配置。
1. `drv_pmu_wakeup_pad_get_level()` 只能读取已经启用的 PAD，调用者必须传入 PAD 编号；未启用的 PAD 返回失败。
1. 读取的 PAD 电平是当前运行态 GPIO 电平，不是触发条件判断结果。
1. 如果同时配置了 RTC 定时开机，关机前驱动会同时打开 RTC alarm 唤醒源和已启用的 PAD 唤醒源。
1. PAD64（启用为通用唤醒后）、PAD65 ~ PAD69 均支持高电平、低电平、上升沿和下降沿唤醒触发配置。

配置完成后重新编译并烧录内核。下次系统执行 PMU 关机流程时，驱动会在关机前根据每个已启用 PAD 的配置写入 PMU 中断检测和唤醒路由。

---

## 按键关机模型

短按、长按计时和按键松开均由内核驱动处理，用户态不接收这些底层事件。

1. 用户态调用 `drv_pmu_key_register_notify()` 注册电源键关机请求通知
1. 内核过滤短按；达到长按阈值后，只向用户态发送一次关机请求通知
1. 用户态调用 `drv_pmu_key_wait_shutdown()` 等待关机请求
1. 用户态完成保存状态、卸载文件系统等清理动作
1. 用户态调用 `drv_pmu_key_confirm_shutdown()` 确认清理完成
1. 接口返回后，驱动继续等待用户释放电源键；确认按键已经释放后才执行真正关机

如果用户态不发送确认，系统会保持当前运行状态，不会自动关机。

---

## 数据结构说明

### `drv_pmu_inst_t`

**描述**：PMU HAL 实例句柄，内部封装了 `/dev/pmu_pwrkey` 设备节点、信号等待集和通知注册状态。该类型对用户透明。

---

## 函数接口说明

### `int drv_pmu_inst_create(drv_pmu_inst_t **inst);`

**功能**：创建 PMU HAL 实例并打开 `/dev/pmu_pwrkey`。

**参数**：

- `inst`：返回创建好的 PMU 实例

**返回值**：

- `0`：成功
- `-1`：失败

---

### `void drv_pmu_inst_destroy(drv_pmu_inst_t **inst);`

**功能**：销毁 PMU HAL 实例，自动注销通知并关闭设备。

**参数**：

- `inst`：PMU 实例指针的指针

---

### `int drv_pmu_key_register_notify(drv_pmu_inst_t *inst, int signo);`

**功能**：注册 PMU 事件通知。

注册成功后，驱动会向当前进程发送指定信号，用户态可通过 `drv_pmu_key_wait_shutdown()` 等待关机请求。

**参数**：

- `inst`：PMU 实例
- `signo`：通知信号编号；小于等于 `0` 时默认使用 `SIGUSR1`

**返回值**：

- `0`：成功
- `-1`：失败

**说明**：

- HAL 内部会自动阻塞该信号，并在销毁或注销时恢复
- 重复调用会先注销旧通知，再重新注册

---

### `int drv_pmu_key_unregister_notify(drv_pmu_inst_t *inst);`

**功能**：注销 PMU 事件通知。

**参数**：

- `inst`：PMU 实例

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pmu_key_wait_shutdown(drv_pmu_inst_t *inst, int timeout_ms);`

**功能**：等待内核确认过的长按关机请求。

**参数**：

- `inst`：PMU 实例
- `timeout_ms`：等待超时，单位 ms；小于 `0` 表示永久等待

**返回值**：

- `0`：收到关机请求
- `1`：超时，或等待被信号中断
- `-1`：失败

**说明**：

- 调用前必须已经执行 `drv_pmu_key_register_notify()`
- 短按不会返回关机请求

---

### `int drv_pmu_key_confirm_shutdown(drv_pmu_inst_t *inst);`

**功能**：确认电源键长按关机流程中的用户态清理已经完成。

收到 `drv_pmu_key_wait_shutdown()` 返回成功后，完成用户态清理即可调用。调用后驱动会继续等待用户释放电源键，用户态不需要等待或判断松开事件。

**参数**：

- `inst`：PMU 实例

**返回值**：

- `0`：成功
- `-1`：失败

---

### `int drv_pmu_shutdown_now(drv_pmu_inst_t *inst);`

**功能**：立即执行 PMU 关机。

该接口不依赖电源键长按事件，也不会等待 `KEY_RELEASE`，因此会绕过“必须长按才能关机”的按键策略。应用调用前应自行完成必要的清理动作。正常产品的电源键关机流程不应调用此接口。

---

### `int drv_pmu_wakeup_pad_get_level(drv_pmu_inst_t *inst, uint32_t pad, int *level);`

**功能**：读取指定的、已启用的关机唤醒 PAD 的当前 IO 电平。

**参数**：

- `inst`：PMU 实例
- `pad`：PAD 编号，支持 PAD64（需启用 `RT_PMU_SHUTDOWN_WAKEUP_PAD64`）、PAD65 ~ PAD69；只有内核配置中已启用的 PAD 才能读取
- `level`：输出当前电平，`0` 表示低电平，`1` 表示高电平

**返回值**：

- `0`：成功
- `-1`：失败；未启用关机唤醒 PAD 配置时也会失败

**说明**：

- 系统初始化后会将所有已启用的唤醒 PAD 配置为 GPIO 输入，接口可以直接读取当前电平，不会在每次调用时切换复用功能
- 进入关机流程时，驱动会将所有已启用的 PAD 切回 PMU 输入功能，再配置各自的唤醒检测
- 读取的是当前运行态电平，不是 PMU 唤醒触发条件的逻辑判断结果

---

### `int drv_pmu_wakeup_source_get(drv_pmu_inst_t *inst, char *name, size_t name_size);`

**功能**：读取系统本次启动时捕获的唤醒源名称。

**参数**：

- `inst`：PMU 实例
- `name`：输出唤醒源名称的缓冲区
- `name_size`：`name` 缓冲区大小，单位为字节

**返回值**：

- `0`：成功
- `-1`：失败

**可能的唤醒源名称**：

- PAD 唤醒：返回对应 PAD 的 Kconfig `wakeup source name`，例如 `PIR_WAKEUP`；PAD64 启用为通用唤醒时返回其源名（默认 `PAD64_WAKEUP`）
- PAD64 长按开机（未启用 `RT_PMU_SHUTDOWN_WAKEUP_PAD64` 时）：`long press key wake up`
- RTC 唤醒：`RTC`

**说明**：

- 该接口读取的是 PMU 初始化时保存的启动唤醒状态，不是运行过程中实时产生的事件
- 正常冷启动或没有识别到唤醒源时，接口返回失败
- 如果 PMU 同时报告多个唤醒源，接口返回失败，应用不应把返回的单个名称当作唯一来源
- 该接口不需要传入 PAD 编号；PAD 与名称的对应关系由内核配置和本次启动时的 PMU 状态共同决定

---

### `int drv_pmu_rtc_schedule_power_cycle(drv_pmu_inst_t *inst, uint32_t shutdown_after_s, uint32_t poweron_after_s);`

**功能**：配置一次 RTC 定时关机/开机流程。

系统会在 `shutdown_after_s` 秒后关机，并在关机后再等待 `poweron_after_s` 秒自动开机。

**参数**：

- `inst`：PMU 实例
- `shutdown_after_s`：距离关机的延迟时间，单位秒
- `poweron_after_s`：距离重新开机的延迟时间，单位秒

**返回值**：

- `0`：成功
- `-1`：失败

**说明**：

- `shutdown_after_s` 和 `poweron_after_s` 都必须不小于 `DRV_PMU_POWER_CYCLE_MIN_DELAY_S`，当前值为 `2` 秒
- `poweron_after_s` 是从关机时刻开始计时，不是从调用接口时刻开始计时
- 该接口只配置一次 power cycle；如需取消尚未开始执行的任务，调用 `drv_pmu_rtc_cancel_power_cycle()`
- 如果 RTC 关机流程已经进入实际关机阶段，再调用取消接口不能保证阻止关机

---

### `int drv_pmu_rtc_cancel_power_cycle(drv_pmu_inst_t *inst);`

**功能**：取消当前已配置的 RTC 定时关机/开机流程。

**参数**：

- `inst`：PMU 实例

**返回值**：

- `0`：成功
- `-1`：失败

---

## 推荐使用流程

### 应用主动立即关机

1. 调用 `drv_pmu_inst_create()` 创建实例
1. 应用完成必要的资源清理
1. 调用 `drv_pmu_shutdown_now()` 立即关机

该接口不代表电源键策略，也不会检查长按状态。若产品要求“只有长按才能关机”，业务代码不应调用该接口，而应只使用下面的电源键监听流程。

### 长按关机场景

1. 调用 `drv_pmu_inst_create()` 创建设备句柄
1. 调用 `drv_pmu_key_register_notify()` 注册电源键事件通知
1. 循环调用 `drv_pmu_key_wait_shutdown()` 等待关机请求
1. 收到关机请求后执行用户态清理
1. 调用 `drv_pmu_key_confirm_shutdown()` 确认清理完成
1. 退出前调用 `drv_pmu_inst_destroy()` 释放资源

### RTC 定时开关机场景

1. 调用 `drv_pmu_inst_create()` 创建设备句柄
1. 调用 `drv_pmu_rtc_schedule_power_cycle()` 配置关机与开机延时
1. 如需取消，调用 `drv_pmu_rtc_cancel_power_cycle()`
1. 结束后调用 `drv_pmu_inst_destroy()` 释放资源

---

## 最小示例

### 长按关机监听示例

```c
#include <stdio.h>
#include "drv_pmu.h"

int pmu_wait_shutdown(void)
{
    drv_pmu_inst_t *pmu = NULL;
    if (drv_pmu_inst_create(&pmu) < 0)
        return -1;

    if (drv_pmu_key_register_notify(pmu, 0) < 0)
        goto err;

    for (;;) {
        int ret = drv_pmu_key_wait_shutdown(pmu, -1);

        if (ret < 0)
            goto err;
        if (ret > 0)
            continue;

        /* 执行用户态清理 */
        if (drv_pmu_key_confirm_shutdown(pmu) < 0)
            goto err;
        break;
    }

    drv_pmu_inst_destroy(&pmu);
    return 0;

err:
    drv_pmu_inst_destroy(&pmu);
    return -1;
}
```

### RTC 定时开关机示例

```c
#include <stdint.h>
#include "drv_pmu.h"

int pmu_schedule_cycle(uint32_t shutdown_after_s, uint32_t poweron_after_s)
{
    drv_pmu_inst_t *pmu = NULL;
    int ret = -1;

    if (drv_pmu_inst_create(&pmu) < 0)
        return -1;

    if (drv_pmu_rtc_schedule_power_cycle(pmu,
                                     shutdown_after_s,
                                     poweron_after_s) < 0)
        goto out;

    ret = 0;

out:
    drv_pmu_inst_destroy(&pmu);
    return ret;
}
```

---

## 注意事项

1. 使用前需要确保系统已启用 `RT_USING_RTC_PMU`，并且存在设备节点 `/dev/pmu_pwrkey`。
1. `drv_pmu_key_wait_shutdown()` 依赖信号通知机制，建议由专门线程统一等待和处理。
1. `drv_pmu_key_confirm_shutdown()` 只适用于内核发出的关机请求；调用确认后驱动会等待电源键释放，再执行关机。短按会在内核侧直接消化，不会触发通知或关机。
1. `drv_pmu_shutdown_now()` 会绕过长按策略，使用时必须由应用自行负责清理。
1. 如果应用决定不关机，可以不调用 `drv_pmu_key_confirm_shutdown()`，系统会继续运行。
1. `drv_pmu_rtc_schedule_power_cycle()` 依赖 RTC 当前时间正确，使用前建议先确认 RTC 时间已设置。
1. `drv_pmu_wakeup_source_get()` 应在启动后尽早调用；它读取的是本次启动保存的状态，不能用于监听后续唤醒事件。
1. `RT_PMU_LONG_PRESS_POWERON_CONFIG` 打开后，驱动会按 `RT_PMU_LONG_PRESS_POWERON_SECONDS` 写入 PAD64 的 PMU 硬件长按开机阈值；关闭时不修改该寄存器。
1. 修改 Kconfig 后必须重新生成内核配置、编译并烧录内核；用户态 HAL 和 `pmu.elf` 也要使用与内核 ABI 一致的新版本。

---

## 使用示例

请参考 `src/rtsmart/examples/peripheral/pmu/test_pmu.c`。示例程序通过 ELF 命令参数调用，不是 msh 内置的 `pmu` 命令：

```text
/sdcard/app/examples/peripheral/pmu.elf wakeup_source
/sdcard/app/examples/peripheral/pmu.elf wakeup_level 68
/sdcard/app/examples/peripheral/pmu.elf powercycle 10 30
/sdcard/app/examples/peripheral/pmu.elf cancel
```

其中：

- `wakeup_source`：读取本次启动的唤醒源；可以是配置的 PAD 名称、`long press key wake up` 或 `RTC`
- `wakeup_level <pad>`：持续读取指定已启用 PAD 的当前电平
- `powercycle <shutdown_after_s> <poweron_after_s>`：至少传入 `2 2`
