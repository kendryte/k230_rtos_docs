# k230 spi参考

## k230 spi说明

K230 内部集成了三个 QSPI(兼容SPI) 硬件模块，支持片选极性配置和可调时钟速率。通道输出的 I/O 配置可参考 IOMUX 模块。

spi驱动代码说明：

| spi驱动代码路径                                              | 说明         |
| ------------------------------------------------------------ | ------------ |
| src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/spi/drv_spi.c | k230 spi驱动 |

串口驱动相关的配置说明：

| 配置          | 说明                                                 |
| ------------- | ---------------------------------------------------- |
| RT_USING_SPI  | 使能spi ,make rtsmart-menuconfig                     |
| RT_USING_SPI0 | 使能spi0 (OSPI,0x91584000),make rtsmart-menuconfig   |
| RT_USING_SPI1 | 使能spi1 (Qspi0,0x91582000),make rtsmart-menuconfig  |
| RT_USING_SPI2 | 使能spi2 (Qspi1,0x91583000) ,make rtsmart-menuconfig |

## 串口设备api说明

[示例代码](../../app_develop_guide/drivers/spi.md)

### 支持POSIX 文件标准api

串口设备对的设备名字是spi0 spi1 spi2，支持标准的posix文件操作接口如下，具体使用请参考[rtthread官网](https://www.rt-thread.org/document/site/#/rt-thread-version/rt-thread-standard/programming-manual/filesystem/filesystem?id=%e6%96%87%e4%bb%b6%e7%ae%a1%e7%90%86)。

```c
int open(const char *file, int flags, ...);
int close(int d);
ssize_t read(int fd, void *buf, size_t len);
ssize_t write(int fd, const void *buf, size_t len);
```

### ioctl设置

```c
int ioctl(int fildes, int cmd, ...)
```

支持的cmd,及cmd对应参数定义如下：

| cmd              | 参数                    | 说明                 |
| ---------------- | ----------------------- | -------------------- |
| RT_SPI_DEV_CTRL_CONFIG | struct rt_qspi_configuration *| 设置总线模式速率等参数 |
| RT_SPI_DEV_CTRL_RW | struct rt_qspi_message * | 传输数据 |

相关结构体定义及接口示例代码如下：

```c
#define RT_SPI_DEV_CTRL_CONFIG      (12 * 0x100 + 0x01)
#define RT_SPI_DEV_CTRL_RW          (12 * 0x100 + 0x02)

struct rt_spi_message
{
    const void *send_buf;
    void *recv_buf;
    size_t length;
    struct rt_spi_message *next;

    unsigned cs_take    : 1;
    unsigned cs_release : 1;
};

struct rt_qspi_message
{
    struct rt_spi_message parent;

    /* instruction stage */
    struct {
        uint32_t content;
        uint8_t size;
        uint8_t qspi_lines;
    } instruction;

    /* address and alternate_bytes stage */
    struct {
        uint32_t content;
        uint8_t size;
        uint8_t qspi_lines;
    } address, alternate_bytes;

    /* dummy_cycles stage */
    uint32_t dummy_cycles;

    /* number of lines in qspi data stage, the other configuration items are in parent */
    uint8_t qspi_data_lines;
};

/**
 * SPI configuration structure
 */
struct rt_spi_configuration
{
    uint8_t mode;
    uint8_t data_width;

    union {
        struct {
            uint16_t hard_cs : 8; // hard spi cs configure
            uint16_t soft_cs : 8; // 0x80 | pin
        };
        uint16_t reserved;
    };

    uint32_t max_hz;
};

struct rt_qspi_configuration
{
    struct rt_spi_configuration parent;
    /* The size of medium */
    uint32_t medium_size;
    /* double data rate mode */
    uint8_t ddr_mode;
    /* the data lines max width which QSPI bus supported, such as 1, 2, 4 */
    uint8_t qspi_dl_width;
};


        struct rt_qspi_configuration spi_config;

        memset(&spi_config, 0, sizeof(spi_config));
        spi_config.parent.mode = mode;
        spi_config.parent.data_width = 8;
        spi_config.parent.hard_cs = 0x80|(1<<cs);
        spi_config.parent.max_hz = spped;
        spi_config.qspi_dl_width = 1;

        ret = ioctl(fd, RT_SPI_DEV_CTRL_CONFIG, &spi_config); //设置总线模式及速率


    {
        struct rt_qspi_message msg;

        memset(&msg,0,sizeof(msg));
        msg.parent.send_buf = send_buff;
        msg.parent.length = strlen(send_buff);
        msg.qspi_data_lines = 1;

        ret = ioctl(fd, RT_SPI_DEV_CTRL_RW, &msg); //通过spi总线发送数据
    }
```
