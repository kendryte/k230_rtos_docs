
# k230 I2C说明

## k230 I2C说明

K230 芯片内部配备 5 个 I2C 硬件模块，可以配置为主或者从，支持标准 100 kb/s、快速 400 kb/s 以及高速 3.4 Mb/s 的通信模式。通道输出的 IO 配置请参考 IOMUX 模块。

I2C驱动代码说明：

| 串口代码路径                                                 | 说明                      |
| ------------------------------------------------------------ | -------|
| src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/i2c/drv_i2c.c | k230 I2C 驱动             |

I2C驱动相关的配置说明：

| 配置                   | 说明                                      |
| ---------------------- | ----------------------------------------- |
| RT_USING_I2C0          | 使能I2c0 模式 ,make rtsmart-menuconfig   |
| RT_USING_I2C1 | 使能I2c1 模式,make rtsmart-menuconfig    |
| RT_USING_I2C2 | 使能I2c2模式,make rtsmart-menuconfig     |
| RT_USING_I2C3 | 使能I2c3 模式,make rtsmart-menuconfig    |
| RT_USING_I2C4 | 使能I2c4 模式, make rtsmart-menuconfig |
| RT_USING_I2C0_SLAVE | 使能I2c0 从模式 ,make rtsmart-menuconfig |
| RT_USING_I2C1_SLAVE | 使能I2c1 从模式 ,make rtsmart-menuconfig |
| RT_USING_I2C2_SLAVE | 使能I2c2 从模式 ,make rtsmart-menuconfig |
| RT_USING_I2C3_SLAVE | 使能I2c3 从模式 ,make rtsmart-menuconfig |
| RT_USING_I2C4_SLAVE | 使能I2c4 从模式 ,make rtsmart-menuconfig |

## i2c总线api

[示例代码](../../app_develop_guide/drivers/i2c.md#示例1)

i2c总线对应设备名字是 i2c0 i2c1 i2c3 i2c4，支持标准的 [posix文件操作](https://www.rt-thread.org/document/site/#/rt-thread-version/rt-thread-standard/programming-manual/filesystem/filesystem?id=%e6%96%87%e4%bb%b6%e7%ae%a1%e7%90%86)接口(open,close,ioctl等)。

### ioctl API

```c
int ioctl(int fildes, int cmd, ...)
```

支持的cmd,及cmd对应参数定义如下：

| cmd                 | 参数              | 说明            |
| ------------------- | ----------------- | --------------- |
| RT_I2C_DEV_CTRL_CLK | rt_uint32_t       | 设置i2c总线频率 |
| RT_I2C_DEV_CTRL_RW  | i2c_priv_data_t * | i2c总线读写     |

i2c_priv_data_t  结构体定义如下：

```c
#define RT_I2C_DEV_CTRL_10BIT (0x800 + 0x01)
#define RT_I2C_DEV_CTRL_TIMEOUT (0x800 + 0x03)
#define RT_I2C_DEV_CTRL_RW (0x800 + 0x04)
#define RT_I2C_DEV_CTRL_CLK (0x800 + 0x05)

enum dm_i2c_msg_flags
{
    I2C_M_TEN           = 0x0010, /* ten-bit chip address */
    I2C_M_RD            = 0x0001, /* read data, from slave to master */
    I2C_M_STOP          = 0x8000, /* send stop after this message */
    I2C_M_NOSTART       = 0x4000, /* no start before this message */
    I2C_M_REV_DIR_ADDR  = 0x2000, /* invert polarity of R/W bit */
    I2C_M_IGNORE_NAK    = 0x1000, /* continue after NAK */
    I2C_M_NO_RD_ACK     = 0x0800, /* skip the Ack bit on reads */
    I2C_M_RECV_LEN      = 0x0400, /* length is first received byte */
    I2C_M_RESTART       = 0x0002, /* restart before this message */
    I2C_M_START         = 0x0004, /* start before this message */
};



typedef struct {
    uint16_t addr;
    uint16_t flags;
    uint16_t len;
    uint8_t *buf;
} i2c_msg_t;

typedef struct {
    i2c_msg_t *msgs;
    size_t number;
} i2c_priv_data_t;
```

## i2c做从设备API

[示例代码](../../app_develop_guide/drivers/i2c.md#示例2)

使能如下配置就可以把对应i2c总线配置为从设备，比如：如果使能RT_USING_I2C1_SLAVE，i2c1会配置成从设备，/dev目录下会创建i2c1_slave设备节点。

| 配置                | 说明                                                 |
| ------------------- | ---------------------------------------------------- |
| RT_USING_I2C0_SLAVE | 使能I2c0 从模式 ,make rtsmart-menuconfig，i2c0_slave |
| RT_USING_I2C1_SLAVE | 使能I2c1 从模式 ,make rtsmart-menuconfig，i2c1_slave |
| RT_USING_I2C2_SLAVE | 使能I2c2 从模式 ,make rtsmart-menuconfig，i2c2_slave |
| RT_USING_I2C3_SLAVE | 使能I2c3 从模式 ,make rtsmart-menuconfig，i2c3_slave |
| RT_USING_I2C4_SLAVE | 使能I2c4 从模式 ,make rtsmart-menuconfig，i2c4_slave |

i2c做从设备时支持标准的 [posix文件操作](https://www.rt-thread.org/document/site/#/rt-thread-version/rt-thread-standard/programming-manual/filesystem/filesystem?id=%e6%96%87%e4%bb%b6%e7%ae%a1%e7%90%86)接口，比如open,close,read,write,ioctl等

### ioctl控制API

```c
int ioctl(int fildes, int cmd, ...)
```

支持的cmd,及cmd对应参数定义如下：

| cmd                             | 参数     | 说明                    |
| ------------------------------- | -------- | ----------------------- |
| I2C_SLAVE_IOCTL_SET_ADDR        | uint8_t  | 设置i2c从设备地址       |
| I2C_SLAVE_IOCTL_SET_BUFFER_SIZE | uint32_t | 设置i2c从设备寄存器长度 |

使用示例如下：

```c
#define I2C_SLAVE_IOCTL_SET_BUFFER_SIZE               0
#define I2C_SLAVE_IOCTL_SET_ADDR                      1
 if(argc >= 3) {
        add = atoi(argv[2]);
        ret = ioctl(fd, I2C_SLAVE_IOCTL_SET_ADDR, &add);
        if (ret) {
            rt_kprintf("set add  %x failed!\n", add);
            return;
        }
    }
    if(argc >= 4) {
        size = atoi(argv[3]);
        ret = ioctl(fd, I2C_SLAVE_IOCTL_SET_BUFFER_SIZE, &size);
        if (ret) {
            rt_kprintf("set size  %d failed!\n", size);
            return;
        }
    }
```
