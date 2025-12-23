# K230 OTA 功能使用说明

本文档介绍 K230 平台上 OTA（Over-The-Air）升级功能的分区布局、整体设计以及应用层接口使用方法，帮助你在 RT-Smart 应用中集成和使用 OTA 能力。

> 相关源码位置：
>
> - 应用层封装：`src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c` / `k230_ota.h`
> - 测试用例：`src/rtsmart/libs/testcases/rtsmart_hal/test_ota.c`
> - 内核 OTA 驱动：`src/rtsmart/rtsmart/kernel/bsp/maix3/components/ota/ota.c`
> - SD 卡分区布局：`boards/k230_canmv_xxxxx/genimage-sdcard.cfg`

---

## 分区布局说明

以 `boards/k230_canmv_01studio/genimage-sdcard.cfg` 为例，核心相关分区如下：

| 分区名     | 偏移 / 大小        | load/boot | 对应内容                       | 说明                         |
| ---------- | ------------------ | --------- | ------------------------------ | ---------------------------- |
| TOC        | `0xe0000`          | -         | TOC 表（最多 16 项）           | U-Boot / OTA 共用的分区表    |
| ota_meta   | `0xf0000`, `0x800` | -         | 槽位 A/B 版本块                | 2×512B，A 在前 B 在后        |
| spl        | `0x100000`         | -         | U-Boot SPL                     | 启动代码                     |
| uboot_env  | `0x1e0000`         | -         | U-Boot 环境                    |                              |
| uboot      | `0x200000`         | -         | U-Boot 主镜像                  |                              |
| rtt_a      | `10M`, `20M`       | load=1, boot=0x3 | opensbi_rtt_system.bin   | 槽位 A 的 RT-Smart 系统     |
| rtapp_a    | `30M`, `30M`       | load=1    | rtapp.elf.gz                   | 槽位 A 的应用               |
| rtt_b      | `60M`, `20M`       | load=1, boot=0x3 | opensbi_rtt_system.bin   | 槽位 B 的 RT-Smart 系统     |
| rtapp_b    | `80M`, `30M`       | load=1    | rtapp.elf.gz                   | 槽位 B 的应用               |
| bin/app    | `110M` 之后       | MBR FAT   | 用户 bin / app 分区            | 与 OTA 无直接关系           |

其中：

- `ota_meta` 分区只在 TOC 中占位，初始内容为空；
- 分区名称需要与 U-Boot、RT-Smart OTA 驱动以及打包脚本保持一致：
  - TOC 中的 name 对应 `"ota_meta"`, `"rtt_a"`, `"rtapp_a"`, `"rtt_b"`, `"rtapp_b"` 等；
  - OTA 驱动通过 `ota_find_partition("rtt_a")` 等名字来定位目标地址。

---

## 总体设计概述

K230 的 OTA 方案基于 **A/B 双槽位** 设计，结合启动介质上的 **TOC（Table of Contents）** 和 **版本元数据块（ota_meta）** 实现：

- **双系统分区**
  - `rtt_a` / `rtapp_a`：槽位 A 的内核（RT-Smart）与应用（RTAPP）。
  - `rtt_b` / `rtapp_b`：槽位 B 的内核与应用。
- **TOC（分区表）**
  - 固定放在启动介质偏移 `0x000e0000`（`K230_TOC_OFFSET`）。
  - 每个 entry 大小 64 字节，最多 16 个 entry（`K230_TOC_MAX_ENTRIES`）。
  - U-Boot 与 RT-Smart 内核共用这一份 TOC。
- **OTA 元数据（ota_meta）**
  - 在镜像打包时预留一个 `ota_meta` 分区，偏移和大小在 `genimage-sdcard.cfg` 中配置：
    - offset `0x000f0000`，size `0x800` 字节。
  - 该分区平均分成两块：
    - 前 512B 存放槽位 A 的版本块；
    - 后 512B 存放槽位 B 的版本块。
  - 版本块结构 `ota_slot_meta`：
    - `magic`：固定为 `0x4f544156u`（"OTAV"）。
    - `version`：单调递增的槽位版本号。
    - `crc32`：覆盖整个结构（`crc32` 字段置 0 后计算）的校验值。
- **OTA 镜像格式（kdimg）**
  - 使用自定义的 `kdimg` 容器：
    - 头部 512B（`KDIMG_HDR_MAGIC` + CRC32 + 元信息）。
    - 后跟若干个 `kd_img_part` 分区描述（rtt、rtapp等）。
    - 实际内容从 `KDIMG_CONTENT_START_OFF`（64KB）开始按分区存放。
  - OTA 驱动会流式解析 kdimg，按分区写入 `rtt_x` / `rtapp_x` 对应的物理区域。
- **启动流程与槽位选择**
  - U-Boot SPL 在启动时：
    1. 从 TOC 解析各分区信息。
    1. 从 `ota_meta` 分区读出 A/B 槽的版本块。
    1. 选择版本号较新的那个槽位作为 **active slot**，加载其 `rtt_x` / `rtapp_x`。
    1. 若两个槽都无效（magic 或 CRC 不通过），默认使用槽位 A。
  - OTA 驱动在写入 kdimg 时：
    1. 同样读取 A/B 槽当前版本；
    1. 选择**另一个槽位**作为本次 OTA 的 **target slot**；
    1. 将 kdimg 中的 `rtt` / `rtapp` 内容写入 target slot 对应分区；
    1. 回读写入内容计算 SHA256，与 kdimg 中记录的摘要比对；
    1. 校验通过后，将 target slot 对应版本块的 `version` 更新为 `max(ver_a, ver_b) + 1`。

这样可以保证：

- 升级时始终在非当前运行槽位上写入；
- 每次 OTA 完成后版本号单调递增；
- 启动失败时仍可通过手动清理 meta 或其他策略回退到老版本。

---

## 组件关系与数据流

整体模块关系可以简单理解为：

```text
应用程序 / 测试程序
        │
        │  调用 k230_ota_xxx 接口
        ▼
   libk230_ota （用户态封装）
        │
        │  open("/dev/ota"), write(...)
        ▼
   RT-Thread /dev/ota 设备（ota.c）
        │
        │  ota_dev_write -> ota_kd_stream_write
        ▼
  - 解析 kdimg 头部和分区表
  - 选择 target slot（A/B）
  - 写入 rtt_x / rtapp_x 分区
  - 回读 SHA256 校验
  - 更新 ota_meta 版本块
        │
        ▼
   下一次上电时：
   U-Boot SPL -> 读取 TOC / ota_meta -> 选择槽位启动
```

你在应用侧只需要关心 `k230_ota.c` 的接口和 kdimg 文件路径；底层分区选择、写入、校验和版本管理都由内核 OTA 驱动自动完成。

---

## `k230_ota.c` 接口说明

头文件：`src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.h`  
实现：`src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c`

### 类型定义

```c
typedef struct k230_ota_ctx k230_ota_t;
```

`k230_ota_t` 是一个不透明的上下文结构体，应用侧无需关心内部字段，只通过提供的函数操作即可。

### `k230_ota_create`

```c
k230_ota_t* k230_ota_create(void);
```

- 功能：创建一次 OTA 会话，内部会：
  - `malloc` 分配一个 `struct k230_ota_ctx`；
  - 以写模式打开 `/dev/ota`；
  - 将文件偏移重置到 0。
- 返回：
  - 成功：返回有效指针；
  - 失败：返回 `NULL`，并在控制台打印错误信息。
- 使用约定：
  - 一次升级流程对应一次 `k230_ota_create` / `k230_ota_destroy`；
  - 同一时刻仅建议有一个 OTA 会话（底层使用全局 `g_kdctx`）。

### `k230_ota_update`

```c
int k230_ota_update(k230_ota_t* ctx, const void* buf, size_t size);
```

- 功能：向当前 OTA 会话写入一段 kdimg 数据。
  - 内部会循环调用 `write(ctx->fd, ...)` 直到写完 `size` 字节；
  - 文件偏移由内核 `/dev/ota` 驱动维护，要求**顺序写入**。
- 参数：
  - `ctx`：`k230_ota_create` 返回的会话指针；
  - `buf`：数据缓冲区；
  - `size`：缓冲区大小（字节数）。
- 返回值：
  - `0`：成功；
  - `<0`：失败（会打印错误信息）。
- 使用建议：
  - 可以按任意 chunk 大小多次调用（例如 64KB 一次）；
  - 不要跳跃写入（即不要使用 `lseek` 修改 `/dev/ota` 的 offset），驱动只允许从 0 开始的顺序写。

### `k230_ota_destroy`

```c
void k230_ota_destroy(k230_ota_t* ctx);
```

- 功能：关闭 OTA 会话，释放资源。
  - 若 `ctx->fd` 有效，则先 `close(fd)`；
  - 打印本次 OTA 写入的总字节数；
  - 最后 `free(ctx)`。
- 使用约定：
  - 不论升级成功或失败，都应在结束时调用一次，避免 fd 泄漏。

### `k230_ota_write_file`

```c
int k230_ota_write_file(const char* image_path, size_t chunk_size);
```

- 功能：提供一个“一句式”的 OTA 工具函数：
  1. 打开指定的 kdimg 文件；
  1. 创建 OTA 会话；
  1. 按 `chunk_size` 大小循环读文件，并调用 `k230_ota_update`；
  1. 收尾关闭文件和 OTA 会话。
- 参数：
  - `image_path`：kdimg 文件路径；
  - `chunk_size`：每次读取的块大小（建议 `64 * 1024`）。
- 返回值：
  - `0`：成功；
  - `<0`：失败。
- 使用场景：
  - 适合做简单命令行工具或测试程序；
  - 若需要更细粒度的进度控制或超时管理，建议直接使用 `k230_ota_create` / `k230_ota_update` / `k230_ota_destroy`。

---

## 测试程序使用示例

测试程序：`src/rtsmart/libs/testcases/rtsmart_hal/test_ota.c`

核心逻辑如下：

```c
#define OTA_DEFAULT_IMAGE "/data/ota_test.kdimg"
#define READ_CHUNK_SIZE (64 * 1024)

int main(int argc, char* argv[])
{
    const char* image_path = OTA_DEFAULT_IMAGE;
    ...

    if (argc >= 2 && argv && argv[1])
        image_path = argv[1];

    printf("[ota_test] Starting OTA with img=%s\n", image_path);

    fd_img = open(image_path, O_RDONLY, 0);
    ...

    ota_ctx = k230_ota_create();
    ...

    buf = malloc(READ_CHUNK_SIZE);
    ...

    while ((rd = read(fd_img, buf, READ_CHUNK_SIZE)) > 0) {
        if (k230_ota_update(ota_ctx, buf, rd) < 0) {
            ...
        }
    }

    ...
    k230_ota_destroy(ota_ctx);
    ...
}
```

典型使用步骤：

1. 在 PC 上通过 SDK/build 系统生成新的 kdimg（包含新的 `rtt`/`rtapp`）。
1. 将 kdimg 拷贝到板端（例如 `/data/ota_test.kdimg`）。
1. 在板上运行：

   ```sh
   test_ota /data/your_image.kdimg
   ```

1. 等待程序打印 `OTA update successful!`，然后重启设备，检查是否从新槽位启动。

---

## OTA 流程细节

下面简要描述一次完整 OTA 的内部步骤（由 `/dev/ota` 驱动完成）：

1. 应用 `open("/dev/ota", O_WRONLY)`，触发：
   - `ota_dev_init()`：调用 `ota_storage_init()`，根据启动介质（EMMC/SD）打开底层块设备；
   - `ota_kdctx_reset()`：清空内部状态机 `g_kdctx`。
1. 应用多次 `write("/dev/ota", buf, len)`，驱动内部：
   - 累积前 512 字节到 `hdr_buf`，解析 kdimg header：
     - 校验 `KDIMG_HDR_MAGIC`；
     - 校验 header CRC；
     - 记录分区表条目数等信息。
   - 累积分区表到 `tbl_buf`，解析分区表：
     - 检查每个 `kd_img_part` 的 `part_magic`；
     - 找到 `part_name=="rtt"` 和 `part_name=="rtapp"` 对应的条目；
     - 通过 TOC 查找 `rtt_a`/`rtt_b`/`rtapp_a`/`rtapp_b` 分区。
   - 装载并检查 OTA 版本信息：
     - 从 `ota_meta` 分区读取 A/B 槽版本块；
     - 计算当前 `ver_a` / `ver_b`；
     - 选择较新的槽为 `active_slot`；
     - 将另一个槽作为 `target_slot`；
     - 目标版本号设置为 `max(ver_a, ver_b) + 1`。
   - 从 kdimg 的内容区开始，将数据按 `rtt` / `rtapp` 的 `content_offset` 和 `content_size` 流式写入目标分区。
1. 当目标槽位的 `rtt` / `rtapp` 内容全部写入完毕后：
   - 对目标分区做回读 + SHA256 校验（与 kdimg 中的摘要对比）；
   - 校验通过后，调用 `ota_meta_write_slot(target_slot, target_version)` 更新对应槽位的版本块。
1. 下一次上电时：
   - U-Boot SPL 从 `ota_meta` 读取 A/B 槽元数据；
   - 选择版本号较大的槽位启动，实现无感知的“切换槽位”。

---

## 使用注意事项与常见问题

- **必须使用合法的 kdimg 文件**
  - OTA 驱动会检查 kdimg header 和分区表的 CRC；
  - `rtt` / `rtapp` 也会做 SHA256 回读校验；
  - 任一环节校验失败，都不会更新 `ota_meta`，即不会切换槽位。

- **写入必须从 offset=0 且顺序进行**
  - `/dev/ota` 驱动内部维护 `file_pos`，若检测到非顺序写（`pos != file_pos`），会标记 `g_kdctx.invalid=RT_TRUE`，后续写入全部失败。

- **OTA 元数据初始值为 0**
  - 初始烧录的 SD 卡中 `ota_meta` 分区内容为空（magic != OTA_META_MAGIC），U-Boot 会认为两个槽都无效，默认从槽位 A 启动；
  - 第一次 OTA 完成后，对应 target slot 的版本块会被写入 `version=0x1`；
  - 之后每次 OTA 版本号会自增。

- **双槽版本差距过大时的行为**
  - 如果检测到 `ver_a` 与 `ver_b` 的差值大于 1，OTA 驱动会打印警告，但仍选择 max(ver_a, ver_b)+1 作为新版本。

- **当前实现仅支持 EMMC/SD 卡**
  - `SYSCTL_BOOT_NANDFLASH` / `SYSCTL_BOOT_NORFLASH` 在 `ota_storage_init()` 中暂未实现，会返回 `-RT_ENOSYS`。

---

## 集成建议

在自己的应用或服务中集成 OTA 时，可以按以下思路设计：

1. **固件构建与发布**
   - 在 CI/构建系统中生成 kdimg 文件（包含 rtt / rtapp 分区及 SHA256，路径在output/k230_canmv_xxxx_defconfig/xxx_ota.kdimg）
   - 放到 Web 服务器或本地 U 盘 / SD 卡上，供设备下载。
1. **设备端下载**
   - 自行实现 HTTP/FTP/MQTT 等下载逻辑，将新的 kdimg 保存到设备本地路径（例如 `/data/update.kdimg`）或者用户态buffer上（流式写入）。
1. **调用 OTA 接口**
   - 简单场景：直接调用 `k230_ota_write_file("/data/update.kdimg", 64 * 1024)`；
   - 高级场景：自己控制循环读写，使用 `k230_ota_create` / `k230_ota_update` / `k230_ota_destroy` 实现进度条、断点续传等功能。
1. **重启与验证**
   - OTA 完成后重启板子；
   - 查看串口日志中 SPL 的槽位选择信息，确认启动到了新的槽位；
   - 可以实现应用层对 `ver_a`/`ver_b` 的检测，用于进一步做“健康检查 + 自动回滚”等高级策略。

---
