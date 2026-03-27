# 内存布局与配置指南

本文基于 SDK 源码中的 Kconfig、链接脚本和板级实现，说明 K230/K230D RT-Smart 的内存布局方式、配置入口和调优方法。

## 总体内存模型

在当前 SDK 中，DDR 主要划分为两块：

1. RT-Smart 系统区（内核 + 用户空间页池 + 动态堆）
1. MMZ 区（媒体相关的大块内存）

核心配置项位于 Board Configuration 的 Memory Layout：

- `CONFIG_MEM_RTSMART_BASE`：RT-Smart 起始基址（默认 `0x0`）
- `CONFIG_RTSMART_OPENSIB_MEMORY_SIZE`：OpenSBI 保留区大小（默认 `0x20000`）
- `CONFIG_MEM_RTSMART_SIZE`：RT-Smart 总内存大小
- `CONFIG_MEM_RTSMART_HEAP_SIZE`：RT-Smart 堆大小
- `CONFIG_MEM_MMZ_BASE`：MMZ 基址
- `CONFIG_MEM_MMZ_SIZE`：MMZ 大小
- `CONFIG_MEM_TOTAL_SIZE`：DDR 总大小（静态模式下配置）

源码参考：

- `boards/Kconfig`
- `boards/Kconfig.memory_static`
- `boards/Kconfig.memory_auto`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/board/board.c`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/board/board.h`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/link.lds.in`

## 两种配置模式

## 1. 静态配置模式

当 `CONFIG_AUTO_DETECT_DDR_SIZE=n` 时，使用 `Kconfig.memory_static` 中的一组固定值：

- `MEM_TOTAL_SIZE`
- `MEM_RTSMART_SIZE`
- `MEM_RTSMART_HEAP_SIZE`
- `MEM_MMZ_BASE`
- `MEM_MMZ_SIZE`

这组值会直接作为编译配置参与链接和运行时初始化。

适合场景：

- 板卡 DDR 固定（如 SiP 固定容量）
- 需要精确控制每个区域的大小

## 2. 自动 DDR 检测模式

当 `CONFIG_AUTO_DETECT_DDR_SIZE=y` 时，使用 `Kconfig.memory_auto` 中的档位配置：

- 512M 档：`*_512`
- 1024M 档：`*_1024`
- 2048M 档：`*_2048`

运行时流程（见 `board.c`）：

1. 通过 `k230_atag_get_ddr_size()` 获取 DDR 容量
1. 若获取失败，回退到 `0x20000000`（512M）
1. 按容量选择对应档位的 RT-Smart 大小、堆大小、MMZ 基址和 MMZ 大小

说明：自动模式下，`board.h` 会把 `CONFIG_MEM_*` 宏重定向到 `get_*()` 函数返回值，实现按实际 DDR 大小切换。

## 关键地址计算公式

以下公式来自 `board.c` 与 `link.lds.in`：

1. 系统起始地址

$$
RTT\_SYS\_BASE = MEM\_RTSMART\_BASE + RTSMART\_OPENSIB\_MEMORY\_SIZE
$$

1. 系统可用总区（对齐到 KB 并预留 1KB）

$$
RTT\_SYS\_SIZE = \left(\left\lfloor\frac{MEM\_RTSMART\_SIZE - RTSMART\_OPENSIB\_MEMORY\_SIZE}{1024}\right\rfloor - 1\right) \times 1024
$$

1. RAM_END（末尾再保留 4KB）

$$
RAM\_END = RTT\_SYS\_BASE + RTT\_SYS\_SIZE - 4096
$$

1. 堆区

- `RT_HW_HEAP_BEGIN = &__bss_end`
- `RT_HW_HEAP_END = RT_HW_HEAP_BEGIN + CONFIG_MEM_RTSMART_HEAP_SIZE`

1. MMZ 区

- `MEM_MMZ_BASE = CONFIG_MEM_MMZ_BASE`
- `MEM_MMZ_SIZE = CONFIG_MEM_MMZ_SIZE - 4096`（见 `board.h`）

## 默认档位（自动模式）

来自 `boards/Kconfig.memory_auto`：

1. 512M 档

- `MEM_RTSMART_SIZE_512 = 0x10000000`（256MB）
- `MEM_RTSMART_HEAP_SIZE_512 = 0x02000000`（32MB）
- `MEM_MMZ_BASE_512 = 0x10000000`
- `MEM_MMZ_SIZE_512 = 0x10000000`（256MB）

1. 1024M 档

- `MEM_RTSMART_SIZE_1024 = 0x20000000`（512MB）
- `MEM_RTSMART_HEAP_SIZE_1024 = 0x04000000`（64MB）
- `MEM_MMZ_BASE_1024 = 0x20000000`
- `MEM_MMZ_SIZE_1024 = 0x20000000`（512MB）

1. 2048M 档

- `MEM_RTSMART_SIZE_2048 = 0x20000000`（512MB）
- `MEM_RTSMART_HEAP_SIZE_2048 = 0x04000000`（64MB）
- `MEM_MMZ_BASE_2048 = 0x20000000`
- `MEM_MMZ_SIZE_2048 = 0x60000000`（1536MB）

## 典型配置入口

在 SDK 根目录执行：

```bash
make menuconfig
```

路径：

```text
Board Configuration
  -> Memory Layout
```

你可以：

1. 打开/关闭 `Auto Detect DRAM Size`
1. 自动模式下配置 512/1024/2048 各档参数
1. 静态模式下直接配置 `MEM_TOTAL_SIZE`、`MEM_RTSMART_SIZE`、`MEM_RTSMART_HEAP_SIZE`、`MEM_MMZ_BASE`、`MEM_MMZ_SIZE`

## 配置建议与约束

推荐遵循以下规则：

1. **总量约束**

- `MEM_RTSMART_SIZE + MEM_MMZ_SIZE` 不应超过 `MEM_TOTAL_SIZE`

1. **连续布局约束（推荐）**

- 建议令 `MEM_MMZ_BASE = MEM_RTSMART_SIZE`（在 `MEM_RTSMART_BASE=0` 的默认布局下）

1. **堆大小约束**

- `MEM_RTSMART_HEAP_SIZE` 需小于系统区实际可用空间（扣除内核镜像、BSS、页管理开销）

1. **媒体负载优先场景**

- 增大 `MEM_MMZ_SIZE`
- 同时确认 RT-Smart 堆仍满足应用需求

1. **应用负载优先场景**

- 增大 `MEM_RTSMART_HEAP_SIZE`
- 避免挤压 MMZ 导致媒体模块分配失败

## 变更后的验证步骤

1. 重新编译镜像：

```bash
time make log
```

1. 检查 `.config` 中目标项是否生效（例如 `CONFIG_MEM_RTSMART_SIZE`、`CONFIG_MEM_MMZ_SIZE`）
1. 板端执行典型业务场景（媒体、AI、网络）观察是否出现内存不足或分配失败

## K230D 示例（静态配置）

`configs/k230d_rtos_evb_defconfig` 中可见：

- `CONFIG_MEM_RTSMART_SIZE=0x4400000`
- `CONFIG_MEM_RTSMART_HEAP_SIZE=0x1000000`
- `CONFIG_MEM_MMZ_BASE=0x4400000`
- `CONFIG_MEM_MMZ_SIZE=0x3C00000`

这是一种典型“系统区 + MMZ 区”连续切分方案。

## 常见问题

### 1. 自动 DDR 检测下为何实际行为和预期不一致？

先确认：

1. `CONFIG_AUTO_DETECT_DDR_SIZE=y`
1. 对应档位选项是否存在（512/1024/2048）
1. 板端是否能正确拿到 ATAG DDR 大小（否则会回退 512M 档）

### 2. 修改内存配置后，编译通过但运行崩溃？

优先排查：

1. `MEM_RTSMART_HEAP_SIZE` 是否过大，侵占了后续页空间
1. `MEM_MMZ_BASE/MEM_MMZ_SIZE` 是否越界或与系统区重叠
1. 板卡实际 DDR 容量与配置是否一致
