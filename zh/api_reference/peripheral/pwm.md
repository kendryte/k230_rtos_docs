
# K230 PWM API参考

## 概述

K230集成了两路PWM，每一路各有3个channel，故共有6个PWM channel，对应《K230芯片引脚定义》里的pwm0 ~ pwm5，《K230芯片引脚定义》可在此处下载：<https://kendryte-download.canaan-creative.com/developer/k230/HDK/K230%E7%A1%AC%E4%BB%B6%E6%96%87%E6%A1%A3/K230_PINOUT_V1.2_20240822.xlsx>

| PWM驱动代码路径                                                                            | 说明          |
| -------------------------------------------------------------------------------------------| --------------|
| /home/rlk/work/canaan/src/rtsmart/rtsmart/kernel/bsp/maix3/drivers/interdrv/pwm/drv_pwm.c  | K230 PWM驱动 |

## API说明

PWM 对应的设备路径为 /dev/pwm，支持open，ioctl等系统调用。

### IOCTL 参数定义

| cmd                       | 参数                          | 说明                 |
| --------------------------| ------------------------------| -------------------- |
| KD_PWM_CMD_ENABLE         | struct rt_pwm_configuration * | 开启对应PWM通道      |
| KD_PWM_CMD_DISABLE        | struct rt_pwm_configuration * | 关闭对应PWM通道      |
| KD_PWM_CMD_SET            | struct rt_pwm_configuration * | 设置通道参数（通道，周期，占空比） |
| KD_PWM_CMD_GET            | struct rt_pwm_configuration * | 获取通道参数（通道，周期，占空比） |

代码定义如下：

```c

/* 以下定义都在驱动层，若用户态使用，暂需自行定义 */

struct rt_pwm_configuration
{
    rt_uint32_t channel; /* 0-5 */
    rt_uint32_t period;  /* unit:ns 1ns~4.29s:1Ghz~0.23hz */
    rt_uint32_t pulse;   /* unit:ns (pulse<=period) */
};

#define KD_PWM_CMD_ENABLE           _IOW('P', 0, int)
#define KD_PWM_CMD_DISABLE          _IOW('P', 1, int)
#define KD_PWM_CMD_SET              _IOW('P', 2, int)
#define KD_PWM_CMD_GET              _IOW('P', 3, int)

```

## 示例程序

在`src/rtsmart/mpp/userapps/sample/sample_pwm/sample_pwm.c`下有个示例程序，运行该示例程序之前，需要自己先将对应的IO配置为PWM功能。
以01studio的板子为例，可以直接在`src/uboot/uboot/arch/riscv/dts/k230_canmv_01studio.dts`文件上修改iomux功能。

```c

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <fcntl.h>
#include <unistd.h>
#include "sys/ioctl.h"

/**
 * @brief
 * io52  pwm4
 * io7   pwm2 测量点R77
 * io8   pwm3 测量点R79
 *
 * pwm0-
 *      |_channel0
 *      |_channel1
 *      |_channel2
 *
 * pwm1-
 *      |_channel3
 *      |_channel4
 *      |_channel5
 */

#define PWM_DEVICE_NAME     "/dev/pwm"
#define PWM_CHANNEL2           2
#define PWM_CHANNEL3           3
#define PWM_CHANNEL4           4
#define KD_PWM_CMD_ENABLE           _IOW('P', 0, int)
#define KD_PWM_CMD_DISABLE          _IOW('P', 1, int)
#define KD_PWM_CMD_SET              _IOW('P', 2, int)
#define KD_PWM_CMD_GET              _IOW('P', 3, int)

typedef struct
{
    unsigned int channel; /* 0-n */
    unsigned int period;  /* unit:ns 1ns~4.29s:1Ghz~0.23hz */
    unsigned int pulse;   /* unit:ns (pulse<=period) */
} pwm_config_t;

int main(int argc, char *argv[])
{
    int fd;
    pwm_config_t config;

    printf("open %s\n", PWM_DEVICE_NAME);
    fd = open(PWM_DEVICE_NAME, O_RDWR);
    if (fd < 0)
    {
        perror("open /dev/pwm err\n");
        pthread_exit((void *) "thread exit!");
    }
    printf("open %s OK!\n", PWM_DEVICE_NAME);
    config.channel = PWM_CHANNEL4;
    config.period = 100000;
    config.pulse = 25000;
    if (ioctl(fd, KD_PWM_CMD_SET, &config))
    {
        perror("set pwm err\n");
        pthread_exit((void *) "thread exit!");
    }
    config.channel = PWM_CHANNEL3;
    config.period = 100000;
    config.pulse = 50000;
    ioctl(fd, KD_PWM_CMD_SET, &config);
    ioctl(fd, KD_PWM_CMD_ENABLE, &config);


    config.channel = PWM_CHANNEL2;
    config.period = 100000;
    config.pulse = 75000;
    ioctl(fd, KD_PWM_CMD_SET, &config);
    ioctl(fd, KD_PWM_CMD_ENABLE, &config);
    printf("pwm 2 duty 75;\n");
    printf("pwm 3 duty 50;\n");
    printf("pwm 4 duty 25;\n");
    return 0;
}
```

## 注意事项

K230共有6个PWM通道，其中channel 0 ~ 2（pwm 0 ~ 2）同属一路PWM，channel 3 ~ 5（pwm 3 ~ 5）同属一路PWM，在同时使用多通道PWM时，同属一路的PWM，仅需任意使能其中一个channel即可（如上述代码使能channel 3 和channel 4，仅调用一次enable），另外注意同一路PWM只能使用相同的频率，但是占空比可以不同。
