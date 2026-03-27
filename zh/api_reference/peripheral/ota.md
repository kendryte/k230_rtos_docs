# K230 OTA API 参考

## 概述

K230 提供了独立的 OTA HAL 接口，用于将 `kdimg` 镜像流式写入 OTA 设备节点。

- 用户态 HAL 头文件：`src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.h`
- 用户态 HAL 实现：`src/rtsmart/libs/rtsmart_hal/components/k230_ota/k230_ota.c`
- 参考示例：`src/rtsmart/examples/peripheral/ota/test_ota.c`

## 主要接口

### `k230_ota_create`

```c
k230_ota_t* k230_ota_create(void);
```

创建 OTA 会话并打开 OTA 设备。

- 返回值：成功返回非空句柄；失败返回 `NULL`。

### `k230_ota_update`

```c
int k230_ota_update(k230_ota_t* ctx, const void* buf, size_t size);
```

向 OTA 设备写入一段镜像数据，适合循环分块调用。

- `ctx`：由 `k230_ota_create()` 返回的会话句柄
- `buf`：待写入的数据缓冲区
- `size`：写入字节数
- 返回值：成功返回 `0`；失败返回负值

### `k230_ota_destroy`

```c
void k230_ota_destroy(k230_ota_t* ctx);
```

销毁 OTA 会话，释放资源并关闭设备。

### `k230_ota_write_file`

```c
int k230_ota_write_file(const char* image_path, size_t chunk_size);
```

便捷接口：直接把镜像文件按 `chunk_size` 分块写入 OTA 设备。

- `image_path`：镜像路径
- `chunk_size`：每次写入大小（字节）
- 返回值：成功返回 `0`；失败返回负值

## 推荐使用流程

1. 准备并校验镜像文件（建议先做大小、格式、完整性检查）
1. 调用 `k230_ota_create()` 建立会话
1. 循环读取镜像并调用 `k230_ota_update()` 分块写入
1. 调用 `k230_ota_destroy()` 关闭会话
1. 重启设备使新固件生效

## 最小示例

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

## 注意事项

1. OTA 过程中避免断电或强制重启。
1. 建议在升级前完成镜像校验与版本检查。
1. 网络下载能力可结合 [NetMgmt API 文档](./netmgmt.md) 实现。
