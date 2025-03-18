# I2C 例程

## 概述

K230 芯片内部集成了 5 个 I2C 硬件模块，支持标准模式（100 kb/s）、快速模式（400 kb/s）以及高速模式（3.4 Mb/s）。这些模块非常适合在开发板上进行 I2C 通信，例如连接外设（如传感器或显示器）。I2C 通道的输出 IO 可通过 IOMUX 模块进行配置。

## 示例1

以下示例展示了如何使用 I2C 4 模块读写数据的例子。

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


int  main(int argc, char *argv[])
{
    int fd;
    char *name = "/dev/i2c4";
    rt_uint32_t spped=100000;

    if (argc >= 2)
        name = argv[1];

    if (argc >= 3)
        spped = atoi(argv[2]);

    fd = open(name, O_RDWR); //打开设备
    if (fd < 0 ){
        printf(" %s device open failed\n", name);
        return -1;
    }

    if (ioctl(fd, RT_I2C_DEV_CTRL_CLK, &spped) != RT_EOK){ //设置速率
        printf("set %s speed %d failed!\n", name, spped);
    }

    for (int i = 0x08; i < 0x78; i++){
        unsigned char data;
        i2c_msg_t msgs={i, I2C_M_RD, 1, &data};
        i2c_priv_data_t privdata={&msgs, 1};

        if (ioctl(fd, RT_I2C_DEV_CTRL_RW, &privdata) == 0){ //读写数据
            printf("find device at add 0x%02hx and data=%x\n", i, data);
        }
    }

    close(fd);
}

```

## 示例2

以下示例展示了i2c做从设备时如何动态修改设备的地址及大小的例子。

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
 #include <dfs_poll.h>


 #define I2C_SLAVE_IOCTL_SET_BUFFER_SIZE               0
 #define I2C_SLAVE_IOCTL_SET_ADDR                      1

 int  main(int argc, char *argv[])
 {
    int fd;
    char add = 0x22;
    int size = 20;
    int ret = 0;
    if(argc < 2) {
        printf("examlpe: i2c_slave.elf /dev/i2c1_slave [slave_add] [dev_size] [data]]\n");
        printf("examlpe: i2c_slave.elf  /dev/i2c1_slave 33  32 90\n");
        return 1;
    }
    fd = open(argv[1], O_RDWR);
    if (fd < 0) {
        printf("Can't open %s\n", argv[1]);
        return 1;
    }
    if(argc >= 3) {
        add = atoi(argv[2]);
        ret = ioctl(fd, I2C_SLAVE_IOCTL_SET_ADDR, &add);
        if (ret) {
            printf("set add  %x failed!\n", add);
            return 1;
        }
    }
    if(argc >= 4) {
        size = atoi(argv[3]);
        ret = ioctl(fd, I2C_SLAVE_IOCTL_SET_BUFFER_SIZE, &size);
        if (ret) {
            printf("set size  %d failed!\n", size);
            return 1 ;
        }
    }

    if(argc >= 5) {
        unsigned char  data = atoi(argv[4]);
        lseek(fd, 0,SEEK_SET);
        for(int i = 0; i < size; i++,data++)
            write(fd, &data, 1);
    }


    {
        char buffer[16];
        int size = 0;
        lseek(fd, 0,SEEK_SET);
        //do {

            size = read(fd, buffer, sizeof(buffer));
            for (unsigned i = 0; i < size; i++) {
                printf("%02x ", buffer[i]);
            }
            printf("\n");
        //} while (size != 0);
    }

    {
        struct pollfd pfd;
        pfd.fd = fd;
        pfd.events = POLLIN;
        ret = poll(&pfd, 1, -1);
    }


    //printf("ret=%x\n",ret);
    usleep(1000);
    //printf("func =%s l=%d \n", __func__, __LINE__);
    {
        char buffer[16];
        int size = 0;
        lseek(fd, 0,SEEK_SET);
        //do {

            size = read(fd, buffer, sizeof(buffer));
            printf("func =%s l=%d size=%X  \n", __func__, __LINE__, size);
            for (unsigned i = 0; i < size; i++) {
                printf("%02x ", buffer[i]);
            }
            printf("\n");
        //} while (size != 0);
    }



    printf("i2c_slave_addr: 0x%02x, mem_size: %d\r\n",add,size);
    usleep(1000);
    close(fd);
    return 0;
}
```

```{admonition} 提示

有关 I2C 模块的详细接口和使用方法，请参考[API文档](../drivers/i2c.md)
```
