# 如何使用 Fast Boot 与配置 RT-Smart 自动运行

## 功能说明

RTOS SDK 的 Fast Boot 会把一个 RT-Smart 用户态 ELF 单独打包为 `rtapp.elf.gz`。启动时，U-Boot 从 `rtapp` 分区读取并解压该文件，将加载地址和大小通过 ATAG 传给 RT-Smart；RT-Smart 再通过内部入口 `@preload` 直接启动内存中的 ELF，避免启动后再从文件系统读取应用。

Fast Boot 和自动运行由两组配置共同控制：

- `Fast Boot Configuration` 决定打包哪个 ELF。
- `RT-Smart Configuration > Rtsmart auto execute command string` 决定 RT-Smart 启动后是否运行该 ELF，以及向它传递哪些参数。

只配置其中一项不能完成 Fast Boot 自动运行。目标板的镜像布局还必须包含标记为 `load = true` 的 `rtapp`、`rtapp_a` 或 `rtapp_b` 分区，并使用支持 RT-App 预加载和 ATAG 的 U-Boot。SDK 提供的大多数 SD 卡和 eMMC 板级配置已包含这些设置；使用 SPI NAND 或自定义镜像布局时应先检查对应的 `boards/<board>/genimage-*.cfg`。

在此基础上，还可以通过减少启动日志、提高串口波特率，以及在支持的 eMMC 板卡上启用 HS200 来缩短启动时间。SD/TF 卡也可以使用应用预加载和日志优化，无需支持 HS200。

## 快速开始

以下命令在 SDK 根目录、已配置好的编译环境中执行。如果使用 Docker 编译助手，在宿主机上将 `make` 替换为 `k230 make`，环境准备见[固件编译](how_to_build.md)。

```bash
make list-def
make <board>_defconfig
make menuconfig
```

选择与实际硬件匹配的板级配置。在 `make menuconfig` 中设置：

| 菜单 | 设置 |
| --- | --- |
| `Fast Boot Configuration` | 启用，并把 `Fast boot file path` 指向要启动的 ELF。CanMV 固件启用 `CanMV Components Configuration` 后，可使用默认的 `${SDK_BUILD_IMAGES_DIR}/sdcard/micropython`。其他应用参考下文 HelloWorld 示例。 |
| `RT-Smart Configuration` | 将 `Rtsmart auto execute command string` 设为 `@preload`，需要时在后面添加应用参数。 |
| `Fast Boot Configuration > Reduce boot banners and DDR training progress logs` | 启用该选项，减少启动日志。 |
| `Uboot Configuration` | 关闭 `Uboot Use Prebuilt Binaries`，从源码编译本次版本的 U-Boot/SPL。 |
| `Opensbi Configuration` | 关闭 `OpenSBI Use Prebuilt FW Jump`，使 OpenSBI 的日志和波特率配置生效。 |

先保留默认的 `115200` 波特率；确认串口适配器支持后，可按下文改为 `2000000`。eMMC HS200 和 RT-Smart 的首次探测优化在子项目中配置，见下文。

保存配置后执行 `make`，确认打包日志没有 `Use fake rtapp`，然后按[固件烧录](how_to_flash.md)烧录本次构建的完整镜像。完整镜像位于 `output/<defconfig>/`，具体文件名以构建末尾的 `Generated image done, at ...` 为准；`images/` 目录保存各组件的中间产物。

## Kconfig 配置项

在 SDK 根目录选择板级 defconfig，然后进入顶层配置菜单：

```bash
make <board>_defconfig
make menuconfig
```

### Fast Boot Configuration

配置项来自 SDK 根目录的 `Kconfig.fastboot`：

| 菜单项 | Kconfig 符号 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `Fast Boot Configuration` | `CONFIG_FAST_BOOT_CONFIGURATION` | `y` | 启用 RT-App 打包。关闭时仍会生成占位的 `rtapp.elf.gz`，但其中没有可运行的 ELF。 |
| `Fast boot file path` | `CONFIG_FAST_BOOT_FILE_PATH` | `${SDK_BUILD_IMAGES_DIR}/sdcard/micropython` | 主机编译环境中待打包 ELF 的路径。支持绝对路径和构建时展开的 `${SDK_*}` 环境变量。 |
| `Delete Origin Fastboot App` | `CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE` | `y` | 打包后删除源 ELF，避免文件系统和 `rtapp` 分区各保留一份。符号中的 `ORIGIIN` 是当前源码中的实际拼写。 |
| `Reduce boot banners and DDR training progress logs` | `CONFIG_FAST_BOOT_QUIET` | Fast Boot 开启时为 `y` | 减少启动日志。OpenSBI 和 DDR 日志的变化需要相应源码支持并重新编译；预编译固件保留原来的日志行为。 |

文件路径、删除源文件和静默日志选项均位于 `if FAST_BOOT_CONFIGURATION` 内。`CONFIG_FAST_BOOT_CONFIGURATION=n` 时，这些选项不可用，`CONFIG_FAST_BOOT_QUIET` 的有效值为 `n`。表中默认值适用于依赖满足的情况，板级 defconfig 或已保存的配置可以覆盖默认值；保存菜单配置后，应检查 SDK 根目录 `.config` 中的最终结果。

`Fast boot file path` 是主机侧路径，不是板端路径。例如，应用编译后被暂存到镜像的 `/sdcard/app/helloworld`，对应的打包路径是：

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
```

```{warning}
启用 `Delete Origin Fastboot App` 后，打包脚本会直接删除 `Fast boot file path` 指向的文件。如果这里配置的是 SDK 输出目录之外的绝对路径，原始文件也会被删除。此时应关闭该选项，或者先把 ELF 复制到构建输出目录再打包。
```

### RT-Smart 自动运行命令

配置项来自 `src/rtsmart/Kconfig`：

```text
RT-Smart Configuration > Rtsmart auto execute command string
```

其 Kconfig 符号是 `CONFIG_RTT_AUTO_EXEC_CMD`。启用 Fast Boot 时默认值为 `@preload &`，未启用时默认值为空字符串。

按使用场景设置该字符串：

| 场景 | 配置示例 | 行为 |
| --- | --- | --- |
| Fast Boot，无参数 | `@preload` | 运行 U-Boot 已预加载的 RT-App。 |
| Fast Boot，带参数 | `@preload -C 1 -K /sdcard/model.kmodel` | 运行预加载的 RT-App，并将后续参数传给应用。参数中的文件路径是板端路径。 |
| 普通文件系统自启动，未启用 Firmware Secure Boot | `/sdcard/app/helloworld` | 由 `msh` 从文件系统加载并运行 ELF。 |
| 禁止自动运行 | 空字符串 | RT-Smart 启动后不自动执行用户态应用。 |

`@preload` 是 RT-Smart 内部的触发标记，不是文件系统路径，也不是可在 `msh` 中手动执行的命令。该入口直接拆分参数并调用 `exec`，不会解释管道、重定向或 `&` 等 shell 语法。当前实现最多接收 8 个以空格或制表符分隔的字段，其中第一个字段是 `@preload`。应用不需要后台符号即可由自动运行入口启动；无参数时建议明确配置为 `@preload`。

```{warning}
启用 Firmware Secure Boot 后，自动运行命令必须以 `@preload` 为第一个字段。其他命令会被跳过，系统不会回退到文件系统中的 ELF。此时还必须启用 Fast Boot，并确保 U-Boot 实际预加载了有效的 `rtapp` 镜像。
```

## 进一步缩短启动时间

### 减少日志与提高串口波特率

`CONFIG_FAST_BOOT_QUIET=y` 时，RT-Smart 将完整版本横幅缩减为一行 SDK 和 nncase 版本信息，从源码编译的 OpenSBI 关闭启动横幅。DDR 初始化和训练进度日志还要求所用 U-Boot 包含对应的静默日志支持；旧版本或预编译 SPL 可能仍输出这些日志。静默选项不会关闭错误日志，也不会隐藏 CanMV/MicroPython 的入口时间戳。

串口波特率在顶层 `make menuconfig` 中设置：

```text
RT-Smart Configuration > Console UART baudrate (RT-Smart, U-Boot and OpenSBI)
```

对应 `CONFIG_RTT_CONSOLE_BAUD`，默认 `115200`。使用支持高速通信的串口适配器时，可以设置为 `2000000`；终端同步设置为 **2000000、8 数据位、无校验、1 停止位（8N1）**。该配置用于 RT-Smart，以及从源码编译的 U-Boot/SPL 和 OpenSBI。预编译固件保持编译时的波特率。

`CONFIG_UBOOT_USE_PREBUILT=n` 时，`tools/gen_image_uboot.py` 还会同步更新 `baudrate`，以及已有 `console_port=console=<设备>,<波特率>...` 条目中的波特率。脚本将处理后的环境写入 `output/<defconfig>/images/uboot/env.txt`，再由其生成 `env.bin`，不会修改板级环境模板。使用预编译 U-Boot 时，脚本直接从板级模板生成 `env.bin`，不会应用该波特率覆盖。

如果已有 `console_port` 条目的格式不受支持，脚本会输出警告并保留该条目，应在烧录前修正板级模板。模板中没有 `console_port` 时不会自动添加。

要让各阶段都使用新配置，请在顶层菜单中关闭以下选项：

```text
# CONFIG_UBOOT_USE_PREBUILT is not set
# CONFIG_OPENSBI_USE_PREBUILT_FW_JUMP is not set
```

重新执行 `make` 并烧录包含新 U-Boot/SPL、环境和 RT-Smart/OpenSBI 的完整镜像。仅更新应用或 RT-Smart 分区不会改变已有引导程序的日志和波特率。

### eMMC HS200

HS200 用于支持该模式的 eMMC，可提高引导阶段读取固件和应用的速度。当前 K230 驱动的 HS200 路径使用 **SDIO0、1.8 V 信号电平和 4 位或 8 位数据总线**。板级供电、引脚和总线宽度必须与实际硬件一致；不要为普通 SD/TF 卡启用 eMMC 或 1.8 V 选项。

U-Boot/SPL 和 RT-Smart 分别初始化控制器并执行调谐，需要分别检查配置。从 SDK 根目录执行：

```bash
make uboot-menuconfig
```

使用菜单搜索 `/` 检查以下符号，并确认板级设备树的总线宽度、电压和时钟配置支持目标 eMMC：

```text
CONFIG_MMC_HS200_SUPPORT=y
CONFIG_SPL_MMC_HS200_SUPPORT=y
```

同时保持顶层 `CONFIG_UBOOT_USE_PREBUILT` 关闭，否则上述源码配置不会改变实际烧录的 U-Boot/SPL。

随后配置 RT-Smart：

```bash
make rtsmart-menuconfig
```

在 `InterDriver > Enable SDIO Driver` 中配置 SDIO0。以下是 **1.8 V、8 位 eMMC** 的配置示例，仅适用于对应硬件：

```text
CONFIG_RT_USING_SDIO0=y
CONFIG_RT_SDIO0_EMMC=y
CONFIG_RT_SDIO0_1V8=y
CONFIG_SDIO0_BUS_WIDTH_8BIT=y
CONFIG_RT_SDIO0_HS200=y
```

`Enable SDIO0 eMMC HS200` 依赖 eMMC 和 1.8 V 选项，默认关闭，由已验证的板级 defconfig 显式开启；仅配置为 8 位总线不会自动开启 HS200。4 位 eMMC 也可以使用 HS200：选择 `SDIO0 Bus Max Width > 4Bit`，完成板级验证后再显式启用 HS200。连接在 SDIO0 上的普通 4 位 SD/TF 卡应关闭 `SDIO0 device is emmc`，按硬件配置电压和 4 位总线；它不会进入 eMMC HS200 调谐流程。

驱动会检查 eMMC 能力并执行调谐；不支持 HS200 的器件使用其支持的模式。HS200 初始化或调谐失败时，驱动会尝试较低速模式，但这不能替代板级验证，也不代表运行中的读写错误会自动降速。新板卡或新 eMMC 型号应验证多次断电启动和持续读写；出现调谐或数据错误时，可分别关闭 U-Boot/SPL 和 RT-Smart 的 HS200 选项后重新构建定位。

### 跳过启动存储控制器的首次 SDIO 探测

在 `make rtsmart-menuconfig` 的 `InterDriver > Enable SDIO Driver` 中，`Skip SDIO probing on the first boot-storage scan`（`CONFIG_RT_SDIO_SKIP_INITIAL_PROBE`）在启用 SDIO 驱动（`CONFIG_RT_USING_SDIO`）及至少一个控制器（`CONFIG_RT_USING_SDIO0` 或 `CONFIG_RT_USING_SDIO1`）时默认值为 `y`。板级 defconfig 或已保存的内核配置可以关闭它，应在该菜单中确认最终状态。

它仅对启动存储控制器的第一次扫描跳过 SDIO CMD52 复位、复位后的等待和 CMD5 探测，保留 SD/MMC 存储卡的上电、识别和重试时序。后续扫描恢复正常探测，即使首次扫描失败也一样；其他控制器上的 SDIO Wi-Fi 等设备仍正常枚举。

如果启动控制器接的是 SDIO 设备或含 SDIO 功能的组合卡，应关闭此选项以保留首次 SDIO 枚举。该选项和 HS200 配置独立于顶层 `Fast Boot Configuration`，关闭应用预加载不会自动关闭它们。

### 保存配置与验证

`make savedefconfig` 保存顶层 SDK 配置；`make uboot-menuconfig` 和 `make rtsmart-menuconfig` 保存退出时会更新各自子项目中当前选中的板级 defconfig。需要保留配置时，应一起检查顶层和子项目的差异。完成配置后，在 SDK 根目录执行 `make` 重新生成完整镜像。

启动串口中的 `selected timing` 日志可用于确认实际模式。例如，8 位 eMMC 成功进入 HS200 后可能看到：

```text
MMC0: selected timing: HS200 (200MHz), 8-bit, clock=200000000 Hz
sd0: selected timing: HS200, 8-bit, clock=200000000 Hz
```

设备编号、总线宽度和频率以实际配置为准；部分 U-Boot 配置会输出 `mode=<数字>`。分别检查引导阶段和 RT-Smart 阶段，RT-Smart 使用 HS200 不代表 SPL 也已经启用。

CanMV 固件还会输出：

```text
CanMV K230 start in <微秒数> us
```

该数值是进入 MicroPython 时读取的计时值，不表示 Python 启动脚本、模型加载或显示初始化已经完成。比较优化效果时，应使用相同应用和存储介质，重复断电启动；若关注上电到业务就绪的时间，在应用就绪位置增加日志或 GPIO 标记进行测量。

## 完整示例：Fast Boot 启动 HelloWorld

### 1. 启用应用

执行 `make menuconfig`，打开：

```text
Applications Configuration > Enable Applications HelloWorld
```

该应用会生成到主机侧的：

```text
${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
```

### 2. 配置 Fast Boot

进入 `Fast Boot Configuration`，设置：

```text
[*] Fast Boot Configuration
Fast boot file path = ${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld
[*] Delete Origin Fastboot App
```

保持删除选项开启时，最终文件系统中不会再有 `/sdcard/app/helloworld`；应用只存在于 `rtapp` 分区。

### 3. 配置自动运行

进入 `RT-Smart Configuration`，把 `Rtsmart auto execute command string` 设置为：

```text
@preload
```

保存并退出。可在 SDK 根目录检查最终配置：

```bash
grep -E 'CONFIG_(APP_ENABLE_HELLOWORLD|FAST_BOOT|RTT_AUTO_EXEC_CMD)' .config
```

预期包含：

```text
CONFIG_APP_ENABLE_HELLOWORLD=y
CONFIG_RTT_AUTO_EXEC_CMD="@preload"
CONFIG_FAST_BOOT_CONFIGURATION=y
CONFIG_FAST_BOOT_FILE_PATH="${SDK_BUILD_IMAGES_DIR}/sdcard/app/helloworld"
CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE=y
```

### 4. 编译和烧录

```bash
make
ls -lh output/<defconfig>/images/rtapp/rtapp.elf.gz
```

`rtapp.elf.gz` 是带镜像头并经过压缩的 RT-App 镜像，不能用文件大小是否为零作为唯一的有效性判断。编译日志中不应出现 `Use fake rtapp` 或 Fast Boot 文件不存在的提示。

将 `output/<defconfig>/` 中适合目标板的完整镜像烧录后重启，文件名以 `Generated image done, at ...` 日志为准。RT-Smart 启动阶段会执行 `@preload`，串口应看到 HelloWorld 的输出。

如果希望把配置保存到当前板级 defconfig，可在确认 `.config` 后执行：

```bash
make savedefconfig
```

该命令会更新当前选中的 `configs/<defconfig>`，提交前应检查差异。

## 仅配置普通文件系统自启动

如果不需要 Fast Boot，而是希望从文件系统自动运行应用：

1. 关闭 `Fast Boot Configuration`。
1. 确保应用会被复制到文件系统镜像。
1. 将 `Rtsmart auto execute command string` 设置为板端绝对路径和参数，例如：

   ```text
   /sdcard/app/helloworld
   ```

这种方式不使用 `@preload`。启用 Firmware Secure Boot 时，RT-Smart 会拒绝从文件系统加载 ELF，因此不能使用这种配置。

## 常见问题

### 修改配置后日志没有减少，或串口出现乱码

确认 U-Boot 和 OpenSBI 的预编译选项已关闭，并烧录了包含引导程序和环境的完整新镜像。检查终端波特率是否与 `CONFIG_RTT_CONSOLE_BAUD` 一致；某些阶段正常、某些阶段乱码通常需要检查是否混用了不同波特率的固件。适配器不支持 2000000 时，将共享波特率改回 115200 并重新构建烧录。调试启动问题时，可关闭 `CONFIG_FAST_BOOT_QUIET` 恢复被该选项抑制的日志；DDR 日志是否受控取决于所用 U-Boot 版本。

### 启动时提示预加载镜像不可用

常见日志包括：

```text
Preloaded ELF magic number mismatch
Trusted preload is unavailable: missing or invalid ATAG-preloaded rtapp image
trusted preload image unavailable, enable fast boot and ensure U-Boot preloads rtapp
```

依次检查：

1. `CONFIG_FAST_BOOT_CONFIGURATION=y`。
1. `CONFIG_FAST_BOOT_FILE_PATH` 指向构建时真实存在的 RT-Smart ELF。
1. 编译日志没有 `Use fake rtapp`。当前打包脚本在源文件不存在时会生成占位镜像并继续构建，因此完整镜像生成成功不代表 RT-App 有效。
1. 板级 `genimage` 配置包含 `rtapp` 分区，并设置了 `load = true`。
1. 烧录的是本次构建产生的完整镜像，U-Boot 与 RT-Smart 来自兼容版本。

### 应用依赖的模型或配置文件找不到

Fast Boot 只把所选 ELF 放入 `rtapp` 镜像，不会自动收集它引用的模型、字库或配置文件。这些资源仍需打包到 `/sdcard`、`/data` 等板端文件系统，并在 `CONFIG_RTT_AUTO_EXEC_CMD` 的参数中使用板端路径。

### 文件系统中找不到原来的 ELF

这是 `CONFIG_FAST_BOOT_DELETE_ORIGIIN_FILE=y` 的预期行为。需要同时保留文件系统副本以便手动调试时，关闭 `Delete Origin Fastboot App` 后重新编译镜像。

### 修改后仍运行旧应用

Fast Boot 应用位于独立的 `rtapp` 分区。应烧录包含 `rtapp` 的完整镜像或对应的 RT-App 更新镜像；只更新文件系统分区不会替换已经预加载的应用。
