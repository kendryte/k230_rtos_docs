
# K230 GPIO API参考

## 概述

K230 芯片内部集成了 64 个 GPIO 引脚（GPIO Pin），每个引脚都可以配置为输入或输出模式，并支持上下拉电阻配置。GPIO 引脚的灵活配置使得它在多种场景下具有广泛的应用。

| GPIO驱动代码路径                                                            | 说明          |
| ---------------------------------------------------------------------- | --------------|
| src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/gpio/drv_gpio.c  | K230 GPIO驱动 |

## API说明

GPIO 对应的设备路径为 /dev/gpio，支持open，ioctl等系统调用。

### IOCTL 参数定义

| cmd               | 参数                    | 说明                 |
| ----------------  | ----------------------- | -------------------- |
| KD_GPIO_DM_OUTPUT | struct rt_device_gpio * | 设置GPIO为输出模式 |
| KD_GPIO_DM_INPUT  | struct rt_device_gpio * | 设置GPIO为输入模式 |
| KD_GPIO_DM_INPUT_PULL_UP | struct rt_device_gpio * | 设置上拉模式 |
| KD_GPIO_DM_INPUT_PULL_DOWN | struct rt_device_gpio * | 设置下拉模式 |
| KD_GPIO_WRITE_LOW | struct rt_device_gpio * | 设置gpio为低电平（输出）  |
| KD_GPIO_WRITE_HIGH | struct rt_device_gpio * | 设置gpio为高电平（输出） |
| KD_GPIO_READ_VALUE | struct rt_device_gpio * | 读取gpio当前电平 |

代码定义如下：

```c

/* 以下定义都在驱动层，若用户态使用，暂需自行定义 */
#define KD_GPIO_DM_OUTPUT           _IOW('G', 0, int)
#define KD_GPIO_DM_INPUT            _IOW('G', 1, int)
#define KD_GPIO_DM_INPUT_PULL_UP    _IOW('G', 2, int)
#define KD_GPIO_DM_INPUT_PULL_DOWN  _IOW('G', 3, int)
#define KD_GPIO_WRITE_LOW           _IOW('G', 4, int)
#define KD_GPIO_WRITE_HIGH          _IOW('G', 5, int)

#define KD_GPIO_READ_VALUE          _IOW('G', 12, int)

struct rt_device_gpio
{
    rt_uint16_t pin;            /* pin number, from 0 to 63 */
    rt_uint16_t value;          /* pin level status, 0 low level, 1 high level */
};

```

## 3. 示例程序

可将该示例程序放入`src/rtsmart/mpp/userapps/sample/sample_gpio/sample_gpio.c`编译运行，运行该示例程序之前，需要自己先将对应的IO配置为GPIO功能。
以01studio的板子为例，可以直接在`src/uboot/uboot/arch/riscv/dts/k230_canmv_01studio.dts`文件上修改iomux功能。

```c
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdbool.h>
#include <signal.h>
#include "sys/ioctl.h"

/* 这两个GPIO分别控制01studio开发板上的，按键和LED灯 */
#define LED_PIN_NUM (52)
#define KEY_PIN_NUM (21)

#define KD_GPIO_HIGH     1
#define KD_GPIO_LOW      0

/* ioctl */
#define GPIO_DM_OUTPUT           _IOW('G', 0, int)
#define GPIO_DM_INPUT            _IOW('G', 1, int)
#define GPIO_DM_INPUT_PULL_UP    _IOW('G', 2, int)
#define GPIO_DM_INPUT_PULL_DOWN  _IOW('G', 3, int)
#define GPIO_WRITE_LOW           _IOW('G', 4, int)
#define GPIO_WRITE_HIGH          _IOW('G', 5, int)

#define GPIO_READ_VALUE         _IOW('G', 12, int)

typedef struct kd_pin_mode
{
    unsigned short pin;         /* pin number, from 0 to 63 */
    unsigned short val;         /* pin level status, 0 low level, 1 high level */
} pin_mode_t;

static bool exit_flag;

static void sig_handler(int sig_no) {

    exit_flag = true;

    printf("exit sig = %d\n", sig_no);
}

int main(void)
{
    int fd, ret = 0;;
    pin_mode_t led, key;

    signal(SIGINT, sig_handler);
    signal(SIGPIPE, SIG_IGN);

    fd = open("/dev/gpio", O_RDWR);
    if (fd < 0) {
        perror("open /dev/gpio err\n");
        return -1;
    }

    key.pin = KEY_PIN_NUM;
    ret = ioctl(fd, GPIO_DM_INPUT, &key);
    if (ret) {
        perror("set key pin mode fail\n");
        ret = -1;
        goto out;
    }

    led.pin = LED_PIN_NUM;
    ret = ioctl(fd, GPIO_DM_OUTPUT, &led);
    if (ret) {
        perror("set led pin mode fail\n");
        ret = -1;
        goto out;
    }

    do {
        ret = ioctl(fd, GPIO_READ_VALUE, &key);

        if (ret || exit_flag) {
            break;
        }

        if (key.val == KD_GPIO_LOW) {
            ret = ioctl(fd, GPIO_WRITE_HIGH, &led);
            printf("Key press -> light on\n");
        } else {
            ret = ioctl(fd, GPIO_WRITE_LOW, &led);
        }

        usleep(10000);
    } while (1);

out:
    close(fd);

    return ret;
}

```

## 附录

每个GPIO的管脚定义可以在如下链接下载得到：
<https://kendryte-download.canaan-creative.com/developer/k230/HDK/K230%E7%A1%AC%E4%BB%B6%E6%96%87%E6%A1%A3/K230_PINOUT_V1.2_20240822.xlsx>
