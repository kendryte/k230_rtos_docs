
# K230 WDT API参考

## 概述

WDT（Watchdog Timer）是一种硬件定时器，用于监控系统的运行状态。软件程序需要定期“喂狗”（即重置计数器），以表明系统运行正常。如果软件由于某种原因（如程序卡死、跑飞或陷入死循环）未能及时喂狗，WDT会在超时后触发预设的响应机制：产生中断信号或复位信号。通过这种方式，WDT能够检测并恢复系统的异常状态，防止系统长时间无响应或运行异常。对于K230芯片，我们在RTsmart上，我们提供了一个WDT供用户使用。

| WDT驱动代码路径                                           | 说明          |
| ---------------------------------------------------------| --------------|
| src/rtsmart/mpp/userapps/sample/sample_wdt/sample_wdt.c  | K230 WDT驱动 |

## API说明

DWT 对应的设备路径为 /dev/watchdog1，支持open，ioctl等系统调用。

### IOCTL 参数定义

| cmd                            | 参数            | 说明                 |
| -------------------------------| ---------------| -------------------- |
| KD_DEVICE_CTRL_WDT_GET_TIMEOUT | unsigned int * | 获取超时时间      |
| KD_DEVICE_CTRL_WDT_SET_TIMEOUT | unsigned int * | 设置超时时间      |
| KD_DEVICE_CTRL_WDT_KEEPALIVE   | NULL           | 刷新看门狗（喂狗） |
| KD_DEVICE_CTRL_WDT_START       | NULL           | 开启看门狗        |
| KD_DEVICE_CTRL_WDT_STOP        | NULL           | 关闭看门狗        |

代码定义如下：

```c

/* 以下定义都在驱动层，若用户态使用，暂需自行定义 */

#define KD_DEVICE_CTRL_WDT_GET_TIMEOUT    _IOW('W', 1, int) /* get timeout(in seconds) */
#define KD_DEVICE_CTRL_WDT_SET_TIMEOUT    _IOW('W', 2, int) /* set timeout(in seconds) */
#define KD_DEVICE_CTRL_WDT_KEEPALIVE      _IOW('W', 4, int) /* refresh watchdog */
#define KD_DEVICE_CTRL_WDT_START          _IOW('W', 5, int) /* start watchdog */
#define KD_DEVICE_CTRL_WDT_STOP           _IOW('W', 6, int) /* stop watchdog */
```

## 示例程序

在src/rtsmart/mpp/userapps/sample/sample_wdt/sample_wdt.c下有个示例程序：

```c
/*
 * 示例程序说明：
 * 默认超时时间是2秒，默认喂狗时间是1秒。
 * 可以通过传参的方式修改该默认值，参数一可以修改超时时间，参数二可以修改喂狗时间
 * 例如想将超时时间和喂狗时间修改成11秒和20秒，则可以像如下运行该程序：
 * ./sample_wdt.elf 11 20
 * 因为喂狗时间大于超时时间，故11秒后，系统将自动重启。
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>
#include "sys/ioctl.h"

#define WDT_DEVICE_NAME    "/dev/watchdog1"    /* 看门狗设备名称 */

#define CTRL_WDT_GET_TIMEOUT    _IOW('W', 1, int) /* get timeout(in seconds) */
#define CTRL_WDT_SET_TIMEOUT    _IOW('W', 2, int) /* set timeout(in seconds) */
#define CTRL_WDT_GET_TIMELEFT   _IOW('W', 3, int) /* get the left time before reboot(in seconds) */
#define CTRL_WDT_KEEPALIVE      _IOW('W', 4, int) /* refresh watchdog */
#define CTRL_WDT_START          _IOW('W', 5, int) /* start watchdog */
#define CTRL_WDT_STOP           _IOW('W', 6, int) /* stop watchdog */

static unsigned int keepalive = 1;     /* 喂狗时间 */

static void *feed_dog_handle(void *arg)
{
    int wdt_fd = *(int*)arg;

    /* watchdog 开始计时 */
    if (ioctl(wdt_fd, CTRL_WDT_START, NULL))
    {
        printf("start watchdog1 err\n");
        return NULL;
    }

    while(1)
    {
        if(ioctl(wdt_fd, CTRL_WDT_KEEPALIVE, NULL))
        {
            printf("feed watchdog1 err\n");
            if (ioctl(wdt_fd, CTRL_WDT_STOP, NULL))
            {
                printf("close watchdog1 err\n");
            }
        }
        sleep(keepalive);
    }

    close(wdt_fd);
    return NULL;
}

int main(int argc, char *argv[])
{
    int ret;
    pthread_attr_t attr;
    struct sched_param sp;
    pthread_t feeddog_thread_handle;
    unsigned int timeout = 2;    /* 溢出时间 s */
    int wdt_fd;

    /* 判断命令行参数是否指定了超时时间和喂狗时间 */
    if (argc == 2)
    {
        timeout = atoi(argv[1]);
    } else if (argc == 3)
    {
        timeout = atoi(argv[1]);
        keepalive = atoi(argv[2]);
        printf("keep alive time is %ds\n", keepalive);
    }

    wdt_fd = open(WDT_DEVICE_NAME, O_RDWR);
    if (wdt_fd < 0)
    {
        perror("open /dev/watchdog1 err\n");
        pthread_exit((void *) "thread exit!");
    }

    if (ioctl(wdt_fd, CTRL_WDT_SET_TIMEOUT, &timeout))
    {
        perror("set timeout to watchdog1 err\n");
        pthread_exit((void *) "thread exit!");
    }
    printf("set timeout to wdt is %ds.\n", timeout);

    timeout = 0;
    if (ioctl(wdt_fd, CTRL_WDT_GET_TIMEOUT, &timeout))
    {
        perror("set timeout to watchdog1 err\n");
        pthread_exit((void *) "thread exit!");
    }

    printf("get timeout from wdt is %ds.\n", timeout);

    ret = pthread_attr_init(&attr);
    if (ret != 0) {
        printf("pthread_attr_init error");
        return -1;
    }

    sp.sched_priority = 4;

    ret = pthread_attr_setinheritsched(&attr, PTHREAD_EXPLICIT_SCHED);
    if (ret != 0)
        goto error;

    ret = pthread_attr_setschedpolicy(&attr, SCHED_FIFO);
    if (ret != 0)
        goto error;

    ret = pthread_attr_setschedparam(&attr, &sp);
    if (ret != 0)
        goto error;

    pthread_create(&feeddog_thread_handle, &attr, feed_dog_handle, (void*)&wdt_fd);


    while(1);
    pthread_join(feeddog_thread_handle, NULL);
    return 0;
error:
    pthread_attr_destroy(&attr);

    return 0;
}

```

## 注意事项

WDT仅提供16个超时时间，所以当设置完超时时间后，需要调用KD_DEVICE_CTRL_WDT_GET_TIMEOUT来获取实际的超时时间。
