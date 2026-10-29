# K230 OTA API Reference

## Overview

K230 provides an independent OTA HAL interface for streaming `kdimg` images to the OTA device node.

- User-space HAL header file: `src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.h`
- User-space HAL implementation: `src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c`
- Reference example: `src/rtsmart/examples/peripheral/ota/test_ota.c`

## Main Interfaces

### `k230_ota_create`

```c
k230_ota_t* k230_ota_create(void);
```

Creates an OTA session and opens the OTA device.

- Return value: returns a non-NULL handle on success; returns `NULL` on failure.

### `k230_ota_update`

```c
int k230_ota_update(k230_ota_t* ctx, const void* buf, size_t size);
```

Writes a chunk of image data to the OTA device, suitable for loop-based chunked calls.

- `ctx`: session handle returned by `k230_ota_create()`
- `buf`: data buffer to be written
- `size`: number of bytes to write
- Return value: returns `0` on success; returns a negative value on failure

### `k230_ota_destroy`

```c
void k230_ota_destroy(k230_ota_t* ctx);
```

Destroys the OTA session, releases resources, and closes the device.

### `k230_ota_write_file`

```c
int k230_ota_write_file(const char* image_path, size_t chunk_size);
```

Convenience interface: directly writes the image file to the OTA device in chunks of `chunk_size`.

- `image_path`: image path
- `chunk_size`: size of each write (in bytes)
- Return value: returns `0` on success; returns a negative value on failure

## Recommended Usage Flow

1. Prepare and verify the image file (recommended to first perform size, format, and integrity checks)
1. Call `k230_ota_create()` to establish a session
1. Loop to read the image and call `k230_ota_update()` to write in chunks
1. Call `k230_ota_destroy()` to close the session
1. Reboot the device for the new firmware to take effect

## Minimal Example

```c
#include "k230_ota.h"
#include <fcntl.h>
#include <unistd.h>

int ota_from_file(const char *path)
{
    int fd = -1;
    int ret = -1;
    char buf[64 * 1024];
    ssize_t rd;
    k230_ota_t *ctx = NULL;

    fd = open(path, O_RDONLY, 0);
    if (fd < 0)
        return -1;

    ctx = k230_ota_create();
    if (!ctx)
        goto out;

    while ((rd = read(fd, buf, sizeof(buf))) > 0) {
        if (k230_ota_update(ctx, buf, (size_t)rd) < 0)
            goto out;
    }

    ret = (rd < 0) ? -1 : 0;

out:
    if (ctx)
        k230_ota_destroy(ctx);
    if (fd >= 0)
        close(fd);
    return ret;
}
```

## Notes

1. Avoid power loss or forced reboot during the OTA process.
1. It is recommended to complete image verification and version check before upgrading.
1. Network download capability can be implemented in combination with the [NetMgmt API Documentation](./netmgmt.md).
