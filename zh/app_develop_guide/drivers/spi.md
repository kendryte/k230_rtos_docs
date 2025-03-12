# SPI 例程

## 1. 概述

K230 内部集成了三个 SPI 硬件模块，支持配置片选的极性和时钟速率。SPI 通道的输出 IO 可以通过 IOMUX 模块进行配置，非常适合高速数据传输。

## 2. 示例

以下示例展示了如何使用 SPI 接口。

```c
#include<stdio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>

#include <rtthread.h>
#include <rtdevice.h>

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

int  main(int argc, char *argv[])
{
    int fd;
    char bus_name[100];
    int cs = 0;
    rt_uint32_t spped = 10000000;
    int mode = 0;
    char *send_buff = "0x9f000000";
    int ret;

    if(argc < 2) {
        printf("Usage: spi_test [spi0/spi1/spi2] [cs] [speed] [mode] [cmd]\n");
        return -1;
    }


    sprintf(bus_name, "/dev/%s", argv[1]);
    if (argc > 2)
        cs = atoi(argv[2]);

    if (argc > 3)
        spped = atoi(argv[3]);

    if (argc > 4)
        mode = atoi(argv[4]);

    if (argc > 5)
        send_buff = argv[5];

    fd = open(bus_name, O_RDWR);  //打开spi总线
    if (fd < 0 ){
        printf(" %s device open failed\n", bus_name);
        return -1;
    }
    printf("bus_name=%s cs=%d spped=%d mode=%d send_buff=%s\n", bus_name, cs, spped, mode, send_buff);

    {
        struct rt_qspi_configuration spi_config;

        memset(&spi_config, 0, sizeof(spi_config));
        spi_config.parent.mode = mode;
        spi_config.parent.data_width = 8;
        spi_config.parent.hard_cs = 0x80|(1<<cs);
        spi_config.parent.max_hz = spped;
        spi_config.qspi_dl_width = 1;

        ret = ioctl(fd, RT_SPI_DEV_CTRL_CONFIG, &spi_config); //设置总线模式及速率
        printf("f=%s l=%d ret=%x\n", __func__, __LINE__, ret);
    }

    {
        struct rt_qspi_message msg;

        memset(&msg,0,sizeof(msg));
        msg.parent.send_buf = send_buff;
        msg.parent.length = strlen(send_buff);
        msg.qspi_data_lines = 1;

        ret = ioctl(fd, RT_SPI_DEV_CTRL_RW, &msg); //通过spi总线发送数据
        printf("f=%s l=%d ret=%x\n", __func__, __LINE__, ret);
    }

    close(fd);
}

```

```{admonition} 提示
有关 SPI 模块的详细接口和使用方法，请参考[API文档](../drivers/spi.md)
```
