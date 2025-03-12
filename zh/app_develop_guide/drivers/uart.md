# UART 例程

## 概述

K230 芯片内部集成了 5 个 UART 硬件模块，其中 UART0 被rtsmart占用，剩余的 UART1、UART2、UART3 和 UART4 供用户使用。用户在使用时，可通过 IOMUX 模块进行 UART 引脚的配置。

## 示例

以下代码展示了如何使用 UART 模块进行串口通信的基本操作：

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
#include <pthread.h>
#include <fcntl.h>
#include <rtthread.h>
#include <rtdevice.h>
#include <poll.h>


#define IOC_SET_BAUDRATE            _IOW('U', 0x40, int)

struct uart_configure
{
    rt_uint32_t baud_rate;

    rt_uint32_t data_bits               :4;
    rt_uint32_t stop_bits               :2;
    rt_uint32_t parity                  :2;
    rt_uint32_t fifo_lenth              :2;
    rt_uint32_t auto_flow               :1;
    rt_uint32_t reserved                :21;
};

typedef enum _uart_parity
{
    UART_PARITY_NONE,
    UART_PARITY_ODD,
    UART_PARITY_EVEN
} uart_parity_t;

typedef enum _uart_receive_trigger
{
    UART_RECEIVE_FIFO_1,
    UART_RECEIVE_FIFO_8,
    UART_RECEIVE_FIFO_16,
    UART_RECEIVE_FIFO_30,
} uart_receive_trigger_t;
#define SEND_START_STR "uart test start !\n"
int main(int argc,char *argv[])
{
    int fd;
    int ret = 0;

    fd = open("/dev/uart3", O_RDWR); //打开串口
    if (fd < 0){
        printf("open dev  failed!\n");
        return 1;
    }

    struct uart_configure config = {
        .baud_rate = 9600,
        .data_bits = 8,
        .stop_bits = 1,
        .parity = UART_PARITY_NONE,
        .fifo_lenth = UART_RECEIVE_FIFO_16,
        .auto_flow = 0,
    };
    if (ioctl(fd, IOC_SET_BAUDRATE, &config)) { //设置参数为9600
        printf("ioctl failed!\n");
        close(fd);
        return 1;
    }
    write(fd, SEND_START_STR, strlen(SEND_START_STR)); //发送字符串口
    while(1) {
        fd_set rfds;
        int retval;

        FD_ZERO(&rfds);
        FD_SET(fd, &rfds); // 监视标准输入流

        retval = select(fd+1, &rfds, NULL, NULL, NULL);  //等待数据
        if (retval < 0) {
            printf("select failed");
            break;
        }
        if(FD_ISSET(fd, &rfds)){
            char buf[256];
            memset(buf, 0, sizeof(buf));
            ret = read(fd, buf, sizeof(buf)); //读取串口数据
            printf("ret =%x read :%s\n",ret, buf);
            if(strchr(buf,'q'))
                break;
        }
    }

    close(fd);//关闭串口
    return 0;
}

```

```{admonition} 提示

有关 UART 模块的详细接口和使用方法，请参考 [API 文档](../../api_reference/peripheral/uart.md)。

```
