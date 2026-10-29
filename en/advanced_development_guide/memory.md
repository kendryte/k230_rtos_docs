# Memory Layout and Configuration Guide

This document is based on the Kconfig, linker scripts, and board-level implementation in the SDK source code, and describes the memory layout, configuration entries, and tuning methods for the K230/K230D RT-Smart.

## Overall Memory Model

In the current SDK, DDR is mainly divided into two regions:

1. RT-Smart system region (kernel + user space page pool + dynamic heap)
1. MMZ region (media-related large block memory)

The core configuration items are located in Board Configuration under Memory Layout:

- `CONFIG_MEM_RTSMART_BASE`: RT-Smart start base address (default `0x0`)
- `CONFIG_RTSMART_OPENSIB_MEMORY_SIZE`: OpenSBI reserved region size (default `0x20000`)
- `CONFIG_MEM_RTSMART_SIZE`: RT-Smart total memory size
- `CONFIG_MEM_RTSMART_HEAP_SIZE`: RT-Smart heap size
- `CONFIG_MEM_MMZ_BASE`: MMZ base address
- `CONFIG_MEM_MMZ_SIZE`: MMZ size
- `CONFIG_MEM_TOTAL_SIZE`: DDR total size (configured in static mode)

Source code reference:

- `boards/Kconfig`
- `boards/Kconfig.memory_static`
- `boards/Kconfig.memory_auto`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/board/board.c`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/board/board.h`
- `src/rtsmart/rtsmart/kernel/bsp/maix3/link.lds.in`

## Two Configuration Modes

## 1. Static Configuration Mode

When `CONFIG_AUTO_DETECT_DDR_SIZE=n`, a set of fixed values from `Kconfig.memory_static` is used:

- `MEM_TOTAL_SIZE`
- `MEM_RTSMART_SIZE`
- `MEM_RTSMART_HEAP_SIZE`
- `MEM_MMZ_BASE`
- `MEM_MMZ_SIZE`

These values are directly used as compilation configuration for linking and runtime initialization.

Applicable scenarios:

- Board DDR is fixed (e.g., SiP with fixed capacity)
- Need precise control over the size of each region

## 2. Auto DDR Detection Mode

When `CONFIG_AUTO_DETECT_DDR_SIZE=y`, the tier configurations in `Kconfig.memory_auto` are used:

- 512M tier: `*_512`
- 1024M tier: `*_1024`
- 2048M tier: `*_2048`

Runtime flow (see `board.c`):

1. Obtain DDR capacity via `k230_atag_get_ddr_size()`
1. If the retrieval fails, fall back to `0x20000000` (512M)
1. Select the corresponding tier's RT-Smart size, heap size, MMZ base address, and MMZ size based on capacity

Note: In auto mode, `board.h` redirects the `CONFIG_MEM_*` macros to the return values of `get_*()` functions, implementing switching based on the actual DDR size.

## Key Address Calculation Formulas

The following formulas come from `board.c` and `link.lds.in`:

1. System start address

$$
RTT\_SYS\_BASE = MEM\_RTSMART\_BASE + RTSMART\_OPENSIB\_MEMORY\_SIZE
$$

1. System available total region (aligned to KB and reserving 1KB)

$$
RTT\_SYS\_SIZE = \left(\left\lfloor\frac{MEM\_RTSMART\_SIZE - RTSMART\_OPENSIB\_MEMORY\_SIZE}{1024}\right\rfloor - 1\right) \times 1024
$$

1. RAM_END (reserve an additional 4KB at the end)

$$
RAM\_END = RTT\_SYS\_BASE + RTT\_SYS\_SIZE - 4096
$$

1. Heap region

- `RT_HW_HEAP_BEGIN = &__bss_end`
- `RT_HW_HEAP_END = RT_HW_HEAP_BEGIN + CONFIG_MEM_RTSMART_HEAP_SIZE`

1. MMZ region

- `MEM_MMZ_BASE = CONFIG_MEM_MMZ_BASE`
- `MEM_MMZ_SIZE = CONFIG_MEM_MMZ_SIZE - 4096` (see `board.h`)

## Default Tiers (Auto Mode)

From `boards/Kconfig.memory_auto`:

1. 512M tier

- `MEM_RTSMART_SIZE_512 = 0x10000000` (256MB)
- `MEM_RTSMART_HEAP_SIZE_512 = 0x02000000` (32MB)
- `MEM_MMZ_BASE_512 = 0x10000000`
- `MEM_MMZ_SIZE_512 = 0x10000000` (256MB)

1. 1024M tier

- `MEM_RTSMART_SIZE_1024 = 0x20000000` (512MB)
- `MEM_RTSMART_HEAP_SIZE_1024 = 0x04000000` (64MB)
- `MEM_MMZ_BASE_1024 = 0x20000000`
- `MEM_MMZ_SIZE_1024 = 0x20000000` (512MB)

1. 2048M tier

- `MEM_RTSMART_SIZE_2048 = 0x20000000` (512MB)
- `MEM_RTSMART_HEAP_SIZE_2048 = 0x04000000` (64MB)
- `MEM_MMZ_BASE_2048 = 0x20000000`
- `MEM_MMZ_SIZE_2048 = 0x60000000` (1536MB)

## Typical Configuration Entry

Execute in the SDK root directory:

```bash
make menuconfig
```

Path:

```text
Board Configuration
  -> Memory Layout
```

You can:

1. Enable/disable `Auto Detect DRAM Size`
1. Configure 512/1024/2048 tier parameters in auto mode
1. Directly configure `MEM_TOTAL_SIZE`, `MEM_RTSMART_SIZE`, `MEM_RTSMART_HEAP_SIZE`, `MEM_MMZ_BASE`, `MEM_MMZ_SIZE` in static mode

## Configuration Recommendations and Constraints

It is recommended to follow these rules:

1. **Total size constraint**

- `MEM_RTSMART_SIZE + MEM_MMZ_SIZE` should not exceed `MEM_TOTAL_SIZE`

1. **Contiguous layout constraint (recommended)**

- It is recommended to set `MEM_MMZ_BASE = MEM_RTSMART_SIZE` (under the default layout where `MEM_RTSMART_BASE=0`)

1. **Heap size constraint**

- `MEM_RTSMART_HEAP_SIZE` must be smaller than the actual available space in the system region (after deducting kernel image, BSS, and page management overhead)

1. **Media workload priority scenarios**

- Increase `MEM_MMZ_SIZE`
- At the same time, confirm that the RT-Smart heap still meets application requirements

1. **Application workload priority scenarios**

- Increase `MEM_RTSMART_HEAP_SIZE`
- Avoid squeezing MMZ and causing media module allocation failures

## Verification Steps After Changes

1. Recompile the image:

```bash
time make log
```

1. Check whether the target items in `.config` take effect (e.g., `CONFIG_MEM_RTSMART_SIZE`, `CONFIG_MEM_MMZ_SIZE`)
1. Execute typical business scenarios (media, AI, network) on the board side and observe whether out-of-memory or allocation failures occur

## K230D Example (Static Configuration)

Visible in `configs/k230d_rtos_evb_defconfig`:

- `CONFIG_MEM_RTSMART_SIZE=0x4400000`
- `CONFIG_MEM_RTSMART_HEAP_SIZE=0x1000000`
- `CONFIG_MEM_MMZ_BASE=0x4400000`
- `CONFIG_MEM_MMZ_SIZE=0x3C00000`

This is a typical "system region + MMZ region" contiguous partitioning scheme.

## Frequently Asked Questions

### 1. Why does the actual behavior not match expectations under auto DDR detection?

First confirm:

1. `CONFIG_AUTO_DETECT_DDR_SIZE=y`
1. Whether the corresponding tier option exists (512/1024/2048)
1. Whether the board side can correctly obtain the ATAG DDR size (otherwise it will fall back to the 512M tier)

### 2. After modifying the memory configuration, compilation passes but runtime crashes?

Priority troubleshooting:

1. Whether `MEM_RTSMART_HEAP_SIZE` is too large and encroaches on subsequent page space
1. Whether `MEM_MMZ_BASE/MEM_MMZ_SIZE` is out of bounds or overlaps with the system region
1. Whether the actual DDR capacity of the board matches the configuration
