# 如何添加新的配置文件（新板子）

在开始操作之前，首先需要下载 K230 SDK，具体的下载路径请参考 ******（此处需补充完整的前面路径信息）。

接下来，我们将以 01studio 的板子为例，详细说明如何根据板子的硬件情况添加一个新的配置项。在这个过程中，涉及到改动的文件夹主要有以下几个，并且下面的每一个步骤都对应着相应目录的具体修改方法。

| 模块        | 源文件路径                                     | 说明                                                                                     |
| ----------- | ---------------------------------------------- | ---------------------------------------------------------------------------------------- |
| 全局        | ./boards/Kconfig                               | 全局文件配置信息，用于对整个系统的相关配置进行管理                                       |
| 全局        | ./boards/                                      | 存放各个板子的打包文件，这些文件包含了板子相关的各种资源和配置。                         |
| 全局        | ./config/                                      | 各个板子的defconfig文件                                                                  |
| canmv模块   | ./src/canmv/port/boards                        | 该目录存储了在 CanMV 中关于板子的配置信息，用于 CanMV 软件与板子的适配                   |
| boot模块    | ./src/uboot/uboot/arch/riscv                   | 在 U-Boot 中添加板子信息的相关目录                                                       |
| boot模块    | ./src/uboot/uboot/board/kendryte               | 存放 U-Boot 配置信息的目录                                                               |
| boot模块    | ./src/uboot/uboot/arch/riscv/dts               | 记录板子的硬件配置信息，如电源和 GPIO 等相关配置，是硬件与软件交互的重要配置文件所在目录 |
| boot模块    | ./src/uboot/uboot/config                       | 包含 U-Boot menuconfig 配置信息，用于配置 U-Boot 的菜单选项和功能                        |
| rtsmart模块 | ./src/rtsmart/rtsmart/kernel/bsp/maix3/configs | 存储 RTSmart 的 menuconfig 配置信息，用于对 RTSmart 系统的配置管理                       |

以下是具体的操作步骤：

## 修改KConfig文件，增加板子定义

在./boards/Kconfig 文件中，我们需要添加一个新的配置名字。具体的添加内容如下：

```c
        config BOARD_K230_CANMV_LCKFB
            bool "K230 CanMV LCKFB, Onboard 1GiB LPDDR4"

      + config BOARD_K230_CANMV_01STUDIO
      +     bool "K230 CanMV 01 Studio, Onboard 1GiB LPDDR4"

        config BOARD_K230D_CANMV_BPI_ZERO
            bool "K230D CanMV BPI-Zero, SiP 128MiB LPDDR4"
```

```c
    default "k230_canmv_lckfb" if BOARD_K230_CANMV_LCKFB
  + default "k230_canmv_01studio" if BOARD_K230_CANMV_01STUDIO
    default "k230d_canmv_bpi_zero" if BOARD_K230D_CANMV_BPI_ZERO
```

```c
config BOARD_NAME
        string "Board Generate Image Name"
        default "CanMV_K230_V1P0_P1" if BOARD_K230_CANMV
        default "CanMV_K230_V3P0" if BOARD_K230_CANMV_V3P0
        default "CanMV_K230_LCKFB" if BOARD_K230_CANMV_LCKFB
      + default "CanMV_K230_01Studio" if BOARD_K230_CANMV_01STUDIO
        default "CanMV_K230D_Zero" if BOARD_K230D_CANMV_BPI_ZERO
```

```c
    source "$(SDK_BOARDS_DIR)/k230_canmv_lckfb/Kconfig"
  + source "$(SDK_BOARDS_DIR)/k230_canmv_01studio/Kconfig"
    source "$(SDK_BOARDS_DIR)/k230d_canmv_bpi_zero/Kconfig"
```

## 在board目录中增加新板子的目录

新添加的目录路径需要与前面修改中`source`那段话所定义的路径保持一致。具体操作是运行以下命令：

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/boards$ cp ./k230_canmv_dongshanpi ./k230_canmv_01studio -rf
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/boards/k230_canmv_01studio$ ls
Kconfig  default.env  genimage-sdcard-kdimg.cfg  genimage-sdcard-rtos.cfg  genimage-sdcard.cfg
```

添加完成后，该目录下会有 5 个文件，分别介绍如下：

* Kconfig：是执行`make menuconfig`命令时必须依赖的文件，用于配置相关的选项make menuconfig必须依赖的文件
* default：主要用于定义 U-Boot 的启动参数，对 U-Boot 的启动过程起到关键作用定义uboot启动参数
* genimage-sdcard-kdimg.cfg：是一个分段打包文件，用于对相关内容进行分段打包处理分段打包文件
* genimage-sdcard-rtos.cfg：RTSmart 的打包文件，与 RTSmart 系统的打包相关rtsmart打包文件
* genimage-sdcard.cfg：MicroPython 的打包文件，用于 MicroPython 的打包操作 micropython打包文件

此外，还需要对新增的 Kconfig 文件进行修改，其中`BOARD`的定义必须与第一步 KConfig 中定义内容保持一致。修改内容如下

```makefile
if BOARD_K230_CANMV_01STUDIO

endif
```

## 在config中增加defconfig配置文件

在`config`目录下，我们需要添加一个新板子的配置文件。可以从已有的文件中复制一份并进行重命名，具体操作命令如下：

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/configs$ cp k230_canmv_dongshanpi_defconfig k230_canmv_01studio_defconfig
```

复制完成后，需要对新的 config 配置文件进行修改，同时仔细检查里面的配置项是否符合实际需求（即是否需要使用这些配置项）。具体修改内容如下：

```makefile
#把CONFIG_BOARD_K230_CANMV_DONGSHANPAI修改成CONFIG_BOARD_K230_CANMV_01STUDIO
CONFIG_BOARD_K230_CANMV_01STUDIO=y
#修改CONFIG_BOARD_CONFIG_NAME
CONFIG_BOARD_CONFIG_NAME="k230_canmv_01studio_defconfig"
CONFIG_MPP_DEFAULT_SENSOR_CSI_2=y
```

## 在./src/canmv/port/boards下面增加配置信息

在`boards`目录下，我们需要添加一个新板子的配置文件。可以从已有的文件中复制一份并进行重命名，具体操作命令如下：

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/canmv/port/boards$ cp -rf ./k230_canmv_dongshanpi/ ./k230_canmv_01studio
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/canmv/port/boards/k230_canmv_01studio$ ls
manifest.py  mpconfigboard.h
```

该目录下有两个文件，分别是：

* manifest.py：micropython所需配置文件
* mpconfigboard.h：micropython所需头文件

需要修改mpconfigboard.h的配置：

```cpp
//根据使用的芯片选择K230或者K230D
#define MICROPY_HW_MCU_NAME                 "K230"
#define OMV_ARCH_STR                        ""
//修改OMV_BOARD_TYPE
#define OMV_BOARD_TYPE                      "CanMV K230 01Studio - %d%c"
```

## 在./src/uboot/uboot/arch/riscv下修改Kconfig文件

```cpp
+ config TARGET_K230_CANMV_01STUDIO
+ bool "Support k230_CANMV(01STUDIO)"
+ select SYS_CACHE_SHIFT_6  

  source "board/kendryte/k230_canmv/Kconfig"
+ source "board/kendryte/k230_canmv_01studio/Kconfig"
  source "board/kendryte/k230d_canmv_bpi_zero/Kconfig"
```

## 在./src/uboot/uboot/board/kendryte增加新板子的目录和文件

新添加的目录和文件名需要与上一步`source`的路径保持一致，并且需要修改内部文件名，将其命名为`01studio`。具体操作如下：

```shell
//拷贝文件夹
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/uboot/uboot/board/kendryte$ cp -rf ./k230_canmv_dongshanpi ./k230_canmv_01studio
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/uboot/uboot/board/kendryte$ cd k230_canmv_01studio/
//修改文件名，步骤省略(使用命令 mv canmv_dongshanpi_lpddr3_init_2133.c canmv_01studio_lpddr3_init_2133.c)
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/uboot/uboot/board/kendryte/k230_canmv_01studio$ ls
Kconfig   board.c                            canmv_01studio_lpddr3_init_2133.c  canmv_01studio_lpddr4_init_32_swap_2667.c
Makefile  canmv_01studio_lpddr3_init_1600.c  canmv_01studio_lpddr3_init_800.c   canmv_01studio_lpddr4_init_32_swap_3200.c

```

* Makefile：是编译文件，用于指导编译过程，定义了编译的规则和目标编译文件
* Kconfig：存储配置信息的文件，用于配置相关的参数和选项配置信息文件
* board.c：该文件包含了硬件电源和 GPIO 引脚的相关信息，需要根据实际的硬件设置进行修改
* canmv_01studio_lpddr*.c：这是 DDR 配置文件，建议沿用参考开发板的配置信息，以确保 DDR 的正常工作。

此外，还需要对 Makefile 文件根据修改后的文件名和目录进行相应的修改。同时，Kconfig 文件需要修改的信息如下：

```makefile
+  if TARGET_K230_CANMV_01STUDIO

	config SYS_CPU
		default "k230"

	config SYS_VENDOR
		default "kendryte"

	config SYS_BOARD
+		default "k230_canmv_01studio"

	config SYS_CONFIG_NAME
+		default "k230_common"

	config BOARD_SPECIFIC_OPTIONS
		def_bool y
		select KENDRYTE_K230

	choice
		prompt "DDR Type And Frequency"
+		default CANMV_01STUDIO_LPDDR4_2667

+		config CANMV_01STUDIO_LPDDR3_2133
			bool "LPDDR3@2133"
+		config CANMV_01STUDIO_LPDDR3_1600
			bool "LPDDR3@1600"
+		config CANMV_01STUDIO_LPDDR3_800
			bool "LPDDR3@800"
+		config CANMV_01STUDIO_LPDDR4_2667
			bool "LPDDR4@2667"
+		config CANMV_01STUDIO_LPDDR4_3200
			bool "LPDDR4@3200"
	endchoice

endif

```

## 在./src/uboot/uboot/arch/riscv/dts 根据硬件确定板子的配置信息

```shell
#拷贝一份原始文件
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/uboot/uboot/arch/riscv/dts$ cp k230_canmv_dongshanpi.dts k230_canmv_01studio.dts
```

嘉楠提供了自动化配置网页（目前该网页处于待完成和上线的状态）。

## 在./src/uboot/uboot/config增加uboot配置文件

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/uboot/uboot/configs$ cp k230_canmv_dongshanpi_defconfig k230_canmv_01studio_defconfig
```

复制完成后，需要进行以下修改：

* 修改CONFIG_DEFAULT_DEVICE_TREE="k230_canmv_01studio"
* 修改CONFIG_TARGET_K230_CANMV_DONGSHANPAI为CONFIG_K230_CANMV_01STUDIO

## ./src/rtsmart/rtsmart/kernel/bsp/maix3/configs./src/rtsmart/boards下面增加新板子menuconfig文件

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/src/rtsmart/rtsmart/kernel/bsp/maix3/configs$ cp k230_canmv_dongshanpi_defconfig k230_canmv_01studio_defconfig
```

也需要根据硬件的情况对config文件进行配置。

## 编译运行

以上步骤就完成配置，接下来我们进入系统的编译和运行：

```shell
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard$ make list-def
Available configs:
1 [ ] k230_canmv_01studio_defconfig
2 [ ] k230_canmv_defconfig
3 [ ] k230_canmv_dongshanpi_defconfig
4 [ ] k230_canmv_labplus_1956_defconfig
5 [ ] k230_canmv_lckfb_defconfig
6 [ ] k230_canmv_v3p0_defconfig
7 [ ] k230_rtos_01studio_defconfig
8 [ ] k230_rtos_aihardware_defconfig
9 [ ] k230_rtos_evb_defconfig
10 [ ] k230_rtos_lckfb_defconfig
11 [ ] k230d_canmv_atk_dnk230d_defconfig
12 [ ] k230d_canmv_bpi_zero_defconfig
13 [ ] k230d_canmv_labplus_ai_camera_defconfig
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard$ make k230_canmv_01studio_defconfig
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard$ make
#等待生成IMG文件
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard$ cd output/k230_canmv_01studio_defconfig/
aaa@DESKTOP-OSN5BJK:~/canmv_k230_demoboard/output/k230_canmv_01studio_defconfig$ ls
CanMV_K230_01Studio_micropython_local_nncase_v2.9.0.img         Kconfig.app           applications  opensbi        rtsmart
CanMV_K230_01Studio_micropython_local_nncase_v2.9.0.img.gz      Kconfig.canmv         canmv         repo_info      uboot
CanMV_K230_01Studio_micropython_local_nncase_v2.9.0.img.gz.md5  Kconfig.rtt_examples  images        repo_info.tmp
```

编译完成后，可以将生成的*.img文件拷贝出来，用于对设备进行升级操作。
