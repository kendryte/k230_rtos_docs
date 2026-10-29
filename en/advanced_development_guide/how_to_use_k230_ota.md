# K230 OTA Feature Usage Instructions

This document describes the partition layout, overall design, and application-layer interface usage of the OTA (Over-The-Air) upgrade feature on the K230 platform, helping you integrate and use OTA capabilities in RT-Smart applications.

> Related source code locations:
>
> - Application layer wrapper: `src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c` / `k230_ota.h`
> - Test case: `src/rtsmart/libs/testcases/rtsmart_hal/test_ota.c`
> - Kernel OTA driver: `src/rtsmart/rtsmart/kernel/bsp/maix3/components/ota/ota.c`
> - SD card partition layout: `boards/k230_canmv_xxxxx/genimage-sdcard.cfg`

---

## Partition Layout Description

Taking `boards/k230_canmv_01studio/genimage-sdcard.cfg` as an example, the core related partitions are as follows:

| Partition Name | Offset / Size | load/boot | Corresponding Content | Description |
| --- | --- | --- | --- | --- |
| TOC | `0xe0000` | - | TOC table (up to 16 entries) | Partition table shared by U-Boot / OTA |
| ota_meta | `0xf0000`, `0x800` | - | Slot A/B version blocks | 2×512B, A in front, B behind |
| spl | `0x100000` | - | U-Boot SPL | Boot code |
| uboot_env | `0x1e0000` | - | U-Boot environment | |
| uboot | `0x200000` | - | U-Boot main image | |
| rtt_a | `10M`, `20M` | `load=1, boot=0x3` | opensbi_rtt_system.bin | RT-Smart system for slot A |
| rtapp_a | `30M`, `30M` | `load=1` | rtapp.elf.gz | Application for slot A |
| rtt_b | `60M`, `20M` | `load=1, boot=0x3` | opensbi_rtt_system.bin | RT-Smart system for slot B |
| rtapp_b | `80M`, `30M` | `load=1` | rtapp.elf.gz | Application for slot B |
| bin/app | After `110M` | MBR FAT | User bin / app partition | Not directly related to OTA |

Where:

- The `ota_meta` partition only occupies a placeholder in the TOC, with initial content empty;
- The partition names need to be consistent with U-Boot, RT-Smart OTA driver, and packaging scripts:
  - The name in TOC corresponds to `"ota_meta"`, `"rtt_a"`, `"rtapp_a"`, `"rtt_b"`, `"rtapp_b"`, etc.;
  - The OTA driver locates the target address through names like `ota_find_partition("rtt_a")`.

---

## Overall Design Overview

The K230 OTA solution is based on the **A/B dual-slot** design, combined with the **TOC (Table of Contents)** and **version metadata block (ota_meta)** on the boot medium:

- **Dual System Partitions**
  - `rtt_a` / `rtapp_a`: Kernel (RT-Smart) and application (RTAPP) for slot A.
  - `rtt_b` / `rtapp_b`: Kernel and application for slot B.
- **TOC (Partition Table)**
  - Fixed at boot medium offset `0x000e0000` (`K230_TOC_OFFSET`).
  - Each entry is 64 bytes, with up to 16 entries (`K230_TOC_MAX_ENTRIES`).
  - U-Boot and RT-Smart kernel share this TOC.
- **OTA Metadata (ota_meta)**
  - Reserve an `ota_meta` partition during image packaging, with offset and size configured in `genimage-sdcard.cfg`:
    - offset `0x000f0000`, size `0x800` bytes.
  - This partition is evenly divided into two blocks:
    - The first 512B stores the version block for slot A;
    - The last 512B stores the version block for slot B.
  - Version block structure `ota_slot_meta`:
    - `magic`: Fixed as `0x4f544156u` ("OTAV").
    - `version`: Monotonically increasing slot version number.
    - `crc32`: Checksum covering the entire structure (calculated after the `crc32` field is set to 0).
- **OTA Image Format (kdimg)**
  - Uses a custom `kdimg` container:
    - 512B header (`KDIMG_HDR_MAGIC` + CRC32 + meta information).
    - Followed by several `kd_img_part` partition descriptors (rtt, rtapp, etc.).
    - Actual content starts at `KDIMG_CONTENT_START_OFF` (64KB) and is stored by partition.
  - The OTA driver will stream-parse kdimg and write to the physical areas corresponding to `rtt_x` / `rtapp_x` by partition.
- **Boot Flow and Slot Selection**
  - When U-Boot SPL starts:
    1. Parse partition information from TOC.
    1. Read the A/B slot version blocks from the `ota_meta` partition.
    1. Select the slot with the newer version number as the **active slot**, and load its `rtt_x` / `rtapp_x`.
    1. If both slots are invalid (magic or CRC fails), slot A is used by default.
  - When the OTA driver writes kdimg:
    1. Similarly read the current versions of A/B slots;
    1. Select **the other slot** as the **target slot** for this OTA;
    1. Write the `rtt` / `rtapp` content from kdimg to the target slot's corresponding partition;
    1. Read back the written content and calculate SHA256, comparing with the digest recorded in kdimg;
    1. After verification passes, update the target slot's version block `version` to `max(ver_a, ver_b) + 1`.

This ensures:

- During upgrade, writes always go to the non-currently running slot;
- The version number monotonically increases after each OTA;
- If startup fails, you can still roll back to the old version by manually clearing meta or using other strategies.

---

## Component Relationships and Data Flow

The overall module relationship can be simply understood as:

```text
Application / Test Program
        │
        │  Calls k230_ota_xxx interface
        ▼
   libk230_ota (user-space wrapper)
        │
        │  open("/dev/ota"), write(...)
        ▼
   RT-Thread /dev/ota device (ota.c)
        │
        │  ota_dev_write -> ota_kd_stream_write
        ▼
  - Parse kdimg header and partition table
  - Select target slot (A/B)
  - Write to rtt_x / rtapp_x partitions
  - Read-back SHA256 verification
  - Update ota_meta version block
        │
        ▼
   On next power-on:
   U-Boot SPL -> Read TOC / ota_meta -> Select slot to boot
```

On the application side, you only need to care about the `k230_ota.c` interface and the kdimg file path; the underlying partition selection, writing, verification, and version management are all automatically handled by the kernel OTA driver.

---

## `k230_ota.c` Interface Description

Header file: `src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.h`  
Implementation: `src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c`

### Type Definitions

```c
typedef struct k230_ota_ctx k230_ota_t;
```

`k230_ota_t` is an opaque context structure. The application side does not need to care about internal fields; just operate through the provided functions.

### `k230_ota_create`

```c
k230_ota_t* k230_ota_create(void);
```

- Function: Creates an OTA session, which internally:
  - `malloc` allocates a `struct k230_ota_ctx`;
  - Opens `/dev/ota` in write mode;
  - Resets the file offset to 0.
- Returns:
  - Success: returns a valid pointer;
  - Failure: returns `NULL`, and prints error information on the console.
- Usage conventions:
  - One upgrade process corresponds to one `k230_ota_create` / `k230_ota_destroy`;
  - Only one OTA session is recommended at a time (the underlying layer uses the global `g_kdctx`).

### `k230_ota_update`

```c
int k230_ota_update(k230_ota_t* ctx, const void* buf, size_t size);
```

- Function: Writes a segment of kdimg data to the current OTA session.
  - Internally loops calling `write(ctx->fd, ...)` until `size` bytes are written;
  - The file offset is maintained by the kernel `/dev/ota` driver, requiring **sequential writes**.
- Parameters:
  - `ctx`: Session pointer returned by `k230_ota_create`;
  - `buf`: Data buffer;
  - `size`: Buffer size (in bytes).
- Return value:
  - `0`: Success;
  - `<0`: Failure (will print error information).
- Usage recommendations:
  - Can be called multiple times with any chunk size (e.g., 64KB at a time);
  - Do not perform random writes (i.e., do not use `lseek` to modify the offset of `/dev/ota`); the driver only allows sequential writes starting from 0.

### `k230_ota_destroy`

```c
void k230_ota_destroy(k230_ota_t* ctx);
```

- Function: Closes the OTA session and releases resources.
  - If `ctx->fd` is valid, `close(fd)` is called first;
  - Prints the total number of bytes written in this OTA;
  - Finally `free(ctx)`.
- Usage conventions:
  - Regardless of whether the upgrade succeeds or fails, it should be called once at the end to avoid fd leaks.

### `k230_ota_write_file`

```c
int k230_ota_write_file(const char* image_path, size_t chunk_size);
```

- Function: Provides a "one-liner" OTA utility function:
  1. Opens the specified kdimg file;
  1. Creates an OTA session;
  1. Loops reading the file in `chunk_size` chunks and calls `k230_ota_update`;
  1. Closes the file and OTA session at the end.
- Parameters:
  - `image_path`: kdimg file path;
  - `chunk_size`: Size of each read block (recommended `64 * 1024`).
- Return value:
  - `0`: Success;
  - `<0`: Failure.
- Usage scenarios:
  - Suitable for simple command-line tools or test programs;
  - If you need more fine-grained progress control or timeout management, it is recommended to use `k230_ota_create` / `k230_ota_update` / `k230_ota_destroy` directly.

---

## Test Program Usage Example

Test program: `src/rtsmart/libs/testcases/rtsmart_hal/test_ota.c`

Core logic is as follows:

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

Typical usage steps:

1. On the PC, generate a new kdimg (containing the new `rtt`/`rtapp`) through the SDK/build system.
1. Copy the kdimg to the board (e.g., `/data/ota_test.kdimg`).
1. Run on the board:

   ```sh
   test_ota /data/your_image.kdimg
   ```

1. Wait for the program to print `OTA update successful!`, then reboot the device and check whether it boots from the new slot.

---

## OTA Flow Details

The following briefly describes the internal steps of a complete OTA (performed by the `/dev/ota` driver):

1. The application calls `open("/dev/ota", O_WRONLY)`, which triggers:
   - `ota_dev_init()`: calls `ota_storage_init()`, which opens the underlying block device according to the boot medium (EMMC/SD);
   - `ota_kdctx_reset()`: clears the internal state machine `g_kdctx`.
1. The application performs multiple `write("/dev/ota", buf, len)` calls; internally the driver:
   - Accumulates the first 512 bytes into `hdr_buf`, and parses the kdimg header:
     - Verifies `KDIMG_HDR_MAGIC`;
     - Verifies the header CRC;
     - Records information such as the number of partition table entries.
   - Accumulates the partition table into `tbl_buf`, and parses the partition table:
     - Checks the `part_magic` of each `kd_img_part`;
     - Finds the entries corresponding to `part_name=="rtt"` and `part_name=="rtapp"`;
     - Locates the `rtt_a`/`rtt_b`/`rtapp_a`/`rtapp_b` partitions through the TOC.
   - Loads and checks the OTA version information:
     - Reads the A/B slot version blocks from the `ota_meta` partition;
     - Calculates the current `ver_a` / `ver_b`;
     - Selects the newer slot as `active_slot`;
     - Treats the other slot as `target_slot`;
     - Sets the target version number to `max(ver_a, ver_b) + 1`.
   - Starting from the content area of the kdimg, streams data into the target partition according to the `content_offset` and `content_size` of `rtt` / `rtapp`.
1. After the `rtt` / `rtapp` content of the target slot is fully written:
   - Performs a read-back + SHA256 check on the target partition (compared against the digest in the kdimg);
   - If the check passes, calls `ota_meta_write_slot(target_slot, target_version)` to update the version block of the corresponding slot.
1. On the next power-on:
   - U-Boot SPL reads the A/B slot metadata from `ota_meta`;
   - Selects the slot with the larger version number to boot, achieving a seamless "slot switch".

---

## Usage Notes and Common Issues

- **A valid kdimg file must be used**
  - The OTA driver checks the kdimg header and partition table CRC;
  - `rtt` / `rtapp` also undergoes SHA256 read-back verification;
  - If any verification step fails, `ota_meta` will not be updated, i.e., the slot will not be switched.

- **Writes must start from offset=0 and proceed sequentially**
  - The `/dev/ota` driver internally maintains `file_pos`. If it detects non-sequential writes (`pos != file_pos`), it sets `g_kdctx.invalid=RT_TRUE`, and all subsequent writes will fail.

- **The initial value of OTA metadata is 0**
  - In the initially flashed SD card, the content of the `ota_meta` partition is empty (magic != OTA_META_MAGIC). U-Boot will consider both slots invalid and default to booting from slot A;
  - After the first OTA completes, the version block of the corresponding target slot will be written with `version=0x1`;
  - The version number auto-increments with each subsequent OTA.

- **Behavior when the version difference between the two slots is too large**
  - If the difference between `ver_a` and `ver_b` is greater than 1, the OTA driver will print a warning, but still selects `max(ver_a, ver_b)+1` as the new version.

- **The current implementation only supports EMMC/SD card**
  - `SYSCTL_BOOT_NANDFLASH` / `SYSCTL_BOOT_NORFLASH` are not yet implemented in `ota_storage_init()` and will return `-RT_ENOSYS`.

- **How to specify rt_app**
  - Run `make menuconfig`, navigate to `Fast Boot Configuration`, and modify `Fast boot file path`. The variables can refer to the paths exported in `tools/mkenv.mk`.

---

## Integration Recommendations

When integrating OTA into your own application or service, you can follow this design approach:

1. **Firmware build and release**
   - Generate the kdimg file in the CI/build system (containing the rtt / rtapp partitions and SHA256, located at output/k230_canmv_xxxx_defconfig/xxx_ota.kdimg)
   - Place it on a Web server or local USB drive / SD card for the device to download.
1. **Device-side download**
   - Implement your own HTTP/FTP/MQTT download logic to save the new kdimg to a local path on the device (e.g., `/data/update.kdimg`) or to a user-mode buffer (streaming write).
1. **Call the OTA interface**
   - Simple scenario: directly call `k230_ota_write_file("/data/update.kdimg", 64 * 1024)`;
   - Advanced scenario: control the read/write loop yourself, using `k230_ota_create` / `k230_ota_update` / `k230_ota_destroy` to implement features like progress bar and resumable transfer.

1. **Reboot and verification**: Reboot the board after OTA completes; check the slot selection information of SPL in the serial port log to confirm that the new slot has booted; you can implement application-layer detection of `ver_a`/`ver_b` for further advanced strategies such as "health check + automatic rollback".
