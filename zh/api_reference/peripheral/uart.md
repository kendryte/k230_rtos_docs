
# K230 UART API参考

## k230串口说明

K230 内部集成了五个 UART（通用异步收发传输器）硬件模块，其中rtsmart系统占用一个串口，其他串口可以供用户使用。使用串口时需要确保对应管脚PAD(iomux配置)为串口功能,iomux也叫fpioa请参考文档。

串口驱动代码说明：

| 串口代码路径                                                 | 说明                      |      |
| ------------------------------------------------------------ | ------------------------- | ---- |
| src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/uart/drv_uart.c | rtsmart系统使用串口的驱动 |      |
| src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/uart_canaan/drv_uart.c | k230串口驱动              |      |

串口驱动相关的配置说明：

| 配置                   | 说明                                 |
| ---------------------- | ------------------------------------ |
| RT_USING_UART_CANAAN_1 | 使能串口1,make rtsmart-menuconfig    |
| RT_USING_UART_CANAAN_2 | 使能串口2,make rtsmart-menuconfig    |
| RT_USING_UART_CANAAN_3 | 使能串口3,make rtsmart-menuconfig    |
| RT_USING_UART_CANAAN_4 | 使能串口4,make rtsmart-menuconfig    |
| RT_CONSOLE_DEVICE_NAME | rtsmart使用的串口,make rtsmart-menuconfig    |
| RTT_CONSOLE_ID         | rtsmart使用的串口号，make menuconfig |

## 串口api

[示例代码](../../app_develop_guide/drivers/uart.md)

串口对的设备名字是uart0 uart1 uart2 uart3 uart4，支持标准的  posix文件操作接口如下，具体使用请参考[rtthread官网](https://www.rt-thread.org/document/site/#/rt-thread-version/rt-thread-standard/programming-manual/filesystem/filesystem?id=%e6%96%87%e4%bb%b6%e7%ae%a1%e7%90%86)。

```c
int open(const char *file, int flags, ...);
int close(int d);
ssize_t read(int fd, void *buf, size_t len);
ssize_t write(int fd, const void *buf, size_t len);
int select( int nfds,fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```

### ioctl控制API

```c
int ioctl(int fildes, int cmd, ...)
```

支持的cmd,及cmd对应参数定义如下：

| cmd              | 参数                    | 说明                 |
| ---------------- | ----------------------- | -------------------- |
| IOC_SET_BAUDRATE | struct uart_configure * | 设置串口波特率等参数 |

struct uart_configure 结构体定义及接口示例代码如下：

```c
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
struct uart_configure config = {
    .baud_rate = 9600,
    .data_bits = 8,
    .stop_bits = 1,
    .parity = UART_PARITY_NONE,
    .fifo_lenth = UART_RECEIVE_FIFO_16,
    .auto_flow = 0,
};

if (ioctl(fd, IOC_SET_BAUDRATE, &config)) {
    printf("ioctl failed!\n");
    close(fd);
    return 1;
}
```
