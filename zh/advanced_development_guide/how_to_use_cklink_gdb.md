# 使用 CKLINK 和 GDB 调试 RT-Smart

本文介绍如何使用 CKLINK、XuanTie DebugServer 和 GDB 调试 K230 RT-Smart，包括内核调试和用户态 ELF 程序调试。

本文默认：

1. SDK 已经完成配置和编译。
1. 开发板可以正常启动 RT-Smart。
1. 板端命令通过串口终端执行。
1. 命令在 SDK 根目录下执行。

## 调试链路

调试链路由四部分组成：

```text
GDB  <---- TCP/IP ---->  XuanTie DebugServer  <---- USB ---->  CKLINK  <---- JTAG ---->  K230
```

各部分作用如下：

1. CKLINK 通过 JTAG 连接 K230。
1. XuanTie DebugServer 运行在 PC 上，负责连接 CKLINK，并向 GDB 提供调试端口。
1. GDB 运行在 PC 或开发机上，通过 `target remote` 连接 DebugServer。
1. 串口终端用于查看 RT-Smart 日志，并在板端启动用户态程序。

调试内核和调试用户态程序使用同一个 GDB 连接。区别在于：内核 ELF 本身带符号信息；用户态程序需要额外编译出带符号信息的 ELF，并在 GDB 中手动加载。

## 准备硬件

### 连接串口终端

串口终端用于查看启动日志和执行板端命令。常见串口参数为：

```text
115200 8N1
```

串口号、波特率和接线方式以具体开发板说明为准。

### 连接 CKLINK

通常需要连接以下 JTAG 信号：

```text
CKLINK        K230 开发板
------        ----------
VTREF/VREF -> 目标板 IO 电平参考
GND        -> GND
TCK        -> JTAG_TCK
TMS        -> JTAG_TMS
TDI        -> JTAG_TDI
TDO        -> JTAG_TDO
nTRST      -> JTAG_TRST
nSRST      -> RESET，可选
```

注意事项：

1. CKLINK 和开发板必须共地。
1. `VTREF/VREF` 是电平参考，不要当作开发板供电使用。
1. JTAG 电平需要和开发板 IO 电平一致。
1. 开发板固件需要将 JTAG 相关 IO 配置为 JTAG iomux。01 Studio 固件默认已经完成该配置。
1. 如果连接不稳定，优先检查接线、供电和共地。

下图以 01 Studio 开发板为例，展示 CKLINK 与开发板的连接方式。不同开发板的 JTAG 排针位置和丝印可能不同，实际连接请以开发板原理图和硬件手册为准。

![CKLINK 与开发板连接示意图](https://www.kendryte.com/api/imagecdn/zh/CKLINK.png?v=1784256915604)

## 准备 DebugServer

如果 PC 上还没有安装 XuanTie DebugServer，可以在玄铁社区下载页面获取。DebugServer 也提供 Linux 版本，本文只按 Windows 版本说明，不展开 Linux 用法。下图仅用于说明下载入口，实际页面展示可能随版本调整。

![XuanTie DebugServer 下载入口示意图](https://www.kendryte.com/api/imagecdn/zh/DebugServer_DL.png?v=1784257303954)

下载地址：

[XuanTie 工具下载](https://www.xrvm.cn/community/download)

安装完成后，在 Windows 上启动 XuanTie DebugServer，并通过 `Control --> RunDebuggerServer` 启动 GDB Server 服务。本文不展开说明 DebugServer 图形界面的具体操作。

GDB Server 启动后，需要记录两个信息：

1. DebugServer 所在 PC 的 IP 地址。下文示例使用 `172.23.176.1`。
1. DebugServer 显示的 GDB 端口。下文示例使用 `1030`。

下图展示的是 DebugServer 启动后的状态。后续 GDB 连接时，需要使用图中对应的 IP 地址和端口号。

![XuanTie DebugServer 启动示意图](https://www.kendryte.com/api/imagecdn/zh/XuanTieDebugServer.png?v=1784257296561)

后续命令中：

```text
<DEBUGSERVER_IP> 表示运行 DebugServer 的 PC 的 IP 地址，例如：172.23.176.1
<GDB_PORT>       表示 DebugServer 显示的 GDB 端口，例如：1030，以实际显示为准
```

## 准备符号文件

### 内核符号文件

RT-Smart 内核 ELF 默认带符号信息。构建完成后，文件通常位于：

```text
src/rtsmart/rtsmart/kernel/bsp/maix3/rtthread.elf
```

调试内核时，GDB 直接加载该文件。

### 用户态程序符号文件

用户态程序需要自行编译出带调试信息、未 strip 的 ELF。板端运行的 ELF 必须和 PC 端 GDB 加载的 ELF 是同一次构建产物。

建议用户态程序使用以下调试编译选项：

```make
-Og -g3 -gdwarf-4 -fno-omit-frame-pointer
```

链接完成后不要执行 `strip`。

以 timer 示例为例：

```text
PC 端符号文件：src/rtsmart/examples/elf/peripheral/timer.elf
板端运行文件：/sdcard/app/examples/peripheral/timer.elf
```

可以用下面命令检查 ELF 是否包含调试信息：

```bash
readelf -S src/rtsmart/examples/elf/peripheral/timer.elf | grep debug
```

如果没有输出，说明该 ELF 不包含调试信息，需要重新编译。

## 启动 GDB

建议使用 SDK 随带的 RISC-V GDB。该 GDB 与 SDK 工具链、RISC-V 架构和 DebugServer 的 remote 调试协议匹配，适合作为默认选择。

Ubuntu 默认安装的 `/usr/bin/gdb` 通常是 x86_64 本机 GDB，不能直接用于调试 RISC-V 目标，可能无法识别 RISC-V ELF，或在连接 DebugServer 后无法正确处理目标寄存器描述。如果需要使用系统包，请使用支持 RISC-V 的 `gdb-multiarch`，但本文后续命令仍以 SDK 随带的 RISC-V GDB 为准。

在 SDK 根目录执行以下命令，启动 SDK 提供的 RISC-V GDB，并加载内核符号：

```bash
~/.kendryte/k230_toolchains/riscv64-linux-musleabi_for_x86_64-pc-linux-gnu/bin/riscv64-unknown-linux-musl-gdb \
    src/rtsmart/rtsmart/kernel/bsp/maix3/rtthread.elf
```

如果工具链安装路径不同，请将命令中的 GDB 路径替换为实际路径。

GDB 启动后，连接 DebugServer：

```gdb
target remote <DEBUGSERVER_IP>:<GDB_PORT>
```

示例：

```gdb
target remote 172.23.176.1:1030
```

连接成功后，GDB 会停在目标当前运行位置。此时已经可以调试内核。

## 调试内核

内核符号已经随 `rtthread.elf` 加载，可以直接对内核函数下断点。

例如：

```gdb
b rt_thread_startup
c
```

常用命令：

```gdb
bt
info registers
n
s
p variable_name
```

说明：

1. `b` 设置普通软件断点。
1. `c` 继续运行。
1. `bt` 查看调用栈。
1. `n` 单步执行，不进入函数。
1. `s` 单步执行，进入函数。

内核代码通常可以直接使用 `break`。如果某些位置软件断点失败，可以改用硬件断点：

```gdb
hbreak function_name
```

## 调试用户态 ELF 程序

用户态程序的符号不会自动随内核 ELF 加载，需要在同一个 GDB 会话中额外执行 `add-symbol-file`。

以 timer 示例为例，加载用户态 ELF 符号：

```gdb
add-symbol-file src/rtsmart/examples/elf/peripheral/timer.elf 0x200000000
```

`0x200000000` 是当前 RT-Smart 用户态 ELF 的虚拟加载地址。这里填写的是用户态程序运行时的虚拟地址，不是物理地址。

然后给用户态函数下硬件断点：

```gdb
hbreak test_hard_timer
c
```

在串口终端中运行用户态程序：

```sh
/sdcard/app/examples/peripheral/timer.elf
```

程序运行到断点后，GDB 会停住。此时可以查看调用栈、变量和源码位置：

```gdb
bt
n
p ret
p/x ret
```

如果希望程序刚进入用户态 ELF 时就停住，可以对入口地址设置一次性硬件断点：

```gdb
thbreak *0x200000000
c
```

## 常用命令汇总

连接 DebugServer：

```gdb
target remote <DEBUGSERVER_IP>:<GDB_PORT>
```

内核断点：

```gdb
b rt_thread_startup
hbreak function_name
```

加载用户态 ELF 符号：

```gdb
add-symbol-file src/rtsmart/examples/elf/peripheral/timer.elf 0x200000000
```

用户态断点：

```gdb
hbreak test_hard_timer
thbreak *0x200000000
```

运行和单步：

```gdb
c
n
s
```

查看信息：

```gdb
bt
info registers
p variable_name
p/x variable_name
```

## 常见问题

### 用户态程序为什么建议使用 `hbreak`

`break` 是软件断点，需要 GDB 修改目标内存。用户态 ELF 尚未加载、用户页表尚未切换，或者代码页不可写时，软件断点可能失败。

`hbreak` 是硬件断点，由 CPU debug trigger 比较 PC 地址。调试用户态程序时，建议优先使用 `hbreak` 或 `thbreak`。

### 用户态断点地址为什么是虚拟地址

用户态程序执行时，PC 是用户虚拟地址。硬件断点比较的是执行中的 PC，因此应使用用户态虚拟地址，例如 `0x200000000`。

### 打印局部变量时报 DWARF 错误

如果 GDB 打印局部变量时报类似错误：

```text
dwarf2_find_location_expression: Corrupted DWARF expression.
```

通常是 GDB 对当前 ELF 中的 DWARF 调试信息兼容性不好。建议使用 `-gdwarf-4` 重新编译用户态程序。

### 用户态断点不触发

按顺序检查：

1. 板端运行的 ELF 是否和 PC 端加载符号的 ELF 是同一次构建产物。
1. 用户态 ELF 是否未 strip 且包含调试信息。
1. 是否已经执行 `add-symbol-file ... 0x200000000`。
1. 是否使用了 `hbreak`。
1. 是否已经在串口终端运行目标程序。

## 推荐流程

完整流程如下：

1. 连接 CKLINK JTAG。
1. 连接串口终端。
1. 启动开发板。
1. 在 Windows 上启动 XuanTie DebugServer 和 GDB Server。
1. 记录 DebugServer 的 IP 和 GDB 端口。
1. 启动 GDB，并加载 `rtthread.elf`。
1. GDB 执行 `target remote <DEBUGSERVER_IP>:<GDB_PORT>`。
1. 调试内核时，直接对内核函数下断点。
1. 调试用户态程序时，先用 `add-symbol-file` 加载用户态 ELF 符号。
1. 使用 `hbreak` 设置用户态断点。
1. 在串口终端运行用户态程序。
1. GDB 命中断点后开始单步、查看变量和调用栈。

## RT-Smart 调试注意事项

调试时不要关闭 CPU0 的 power domain，也不要关闭 `SYSCTL_CLK_CPU_0_PCLK`。

例如在 `src/rtsmart/rtsmart/kernel/bsp/maix3/app_canmv/main.c` 中，如果有下面这类代码，调试时应屏蔽掉：

```c
sysctl_pwr_off(SYSCTL_PD_CPU0);
```

如果为了降低 CPU0 功耗，只关闭 CPU0 的部分 clock，需要保留 `SYSCTL_CLK_CPU_0_PCLK`。关闭该时钟会导致 DebugServer 无法访问 RISC-V Debug Module，常见报错如下：

```text
WARNING: Can not access a Debug Module with base address 0x0.
```

此时 DebugServer 无法继续检测 CPU1，GDB 也无法正常连接目标。
