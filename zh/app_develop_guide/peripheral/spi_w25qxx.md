# SPI W25QXX 示例

## 简介

本示例演示了如何使用 K230 的 SPI 外设访问 SPI NOR Flash（W25QXX 及兼容器件），并执行设备识别、擦写校验、边界测试与性能测试。

## 功能说明

### 功能特性

当前版本样例具备以下能力：

- **设备识别**：读取 JEDEC ID 并在设备表中匹配参数
- **地址模式**：按容量自动处理 3 字节/4 字节地址模式
- **读写校验**：擦除、写入、回读比对
- **边界测试**：关键边界地址读写测试
- **性能测试**：擦写/读取速率统计
- **命令行参数**：可指定 SPI 控制器、CS 引脚、波特率、测试类型、地址和大小

### 硬件连接

W25QXX Flash芯片通过SPI接口连接到K230：

| W25QXX 引脚 | K230 引脚 | 功能说明 |
|-------------|-----------|----------|
| VCC | 3.3V | 电源正极 |
| GND | GND | 电源地 |
| CLK | SPI SCLK 引脚 | SPI时钟线 |
| DO | SPI MISO 引脚 | SPI数据输出线 |
| DI | SPI MOSI 引脚 | SPI数据输入线 |
| CS | SPI CS 引脚 | 片选信号 |
| WP/HOLD | 3.3V | 写保护/保持（接高电平禁用） |

说明：当前样例支持通过参数选择 SPI 控制器，常见默认配置为 QSPI1。

### Flash规格

- 接口：标准 SPI（样例默认 `SPI_HAL_MODE_0`）
- 容量：W25Q16（2MB）、W25Q32（4MB）、W25Q64（8MB）、W25Q128（16MB）等
- 页大小：256字节
- 扇区大小：4KB
- 块大小：32KB/64KB

### 样例覆盖的常见指令

| 指令 | 说明 |
|------|------|
| 0x05 | 读状态寄存器 |
| 0x06 | 写使能 |
| 0x20 | 扇区擦除（4KB） |
| 0x52 | 块擦除（32KB） |
| 0xD8 | 块擦除（64KB） |
| 0xC7 | 全片擦除 |
| 0x02 | 页编程（256字节） |
| 0x03 | 读数据 |
| 0x9F | 读JEDEC ID |

### 主要函数（当前源码）

- `flash_create()`
- `flash_detect_device()`
- `flash_erase_sector()`
- `flash_write()`
- `flash_read_data()`
- `test_read_write_with_params()`
- `test_performance_with_params()`

## 代码位置

Demo 源码位置：`src/rtsmart/examples/peripheral/spi_w25qxx`

主文件：`test_spi_wq128.c`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将SPI W25QXX示例编译进固件，然后编译固件。

#### 独立编译

进入SPI W25QXX示例目录，使用Makefile进行编译：

```shell
cd src/rtsmart/examples/peripheral/spi_w25qxx
make
```

编译成功后会生成可执行文件。

### 硬件准备

1. 准备W25QXX系列Flash芯片模块
1. 按照上述引脚连接表格连接Flash到K230开发板
1. 确保电源连接正确

### 运行示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
cd /sdcard/app/examples/peripheral
./spi_w25qxx.elf
```

### 命令行参数

该示例支持以下命令行参数：

| 参数 | 缩写 | 类型 | 默认值 | 说明 |
|------|------|------|--------|------|
| `--help` | `-h` | 无 | - | 显示帮助信息 |
| `--spi-id` | `-i` | 整数 | 2 | SPI 控制器 ID (0: OSPI, 1: QSPI0, 2: QSPI1) |
| `--cs-pin` | `-c` | 整数 | 11 | CS 片选 GPIO 引脚号 |
| `--baudrate` | `-b` | 整数 | 10 | SPI 波特率，单位 MHz |
| `--test` | `-t` | 字符串 | all | 运行指定测试：info/basic/rw/boundary/perf/all |
| `--address` | `-a` | 十六进制 | auto | 测试起始地址，十六进制格式 |
| `--size` | `-s` | 整数 | auto | 测试大小，单位 KB |

#### test 参数选项说明

- `info` - 仅显示设备信息（JEDEC ID、容量、地址模式等）
- `basic` - 基础功能测试（写使能、写禁止等）
- `rw` - 读写功能测试（擦除、写入、回读校验）
- `boundary` - 边界地址测试（关键地址边界读写验证）
- `perf` - 性能测试（擦写/读取速率统计）
- `all` - 运行所有测试（默认）

#### SPI 控制器 ID 说明

| ID | 控制器 | 说明 |
|----|--------|------|
| 0 | OSPI | Ok Spi 通用控制器 |
| 1 | QSPI0 | 快速 SPI 控制器 0 |
| 2 | QSPI1 | 快速 SPI 控制器 1（默认） |

#### 地址和大小说明

- `--address` 参数为十六进制格式，示例：`0x100000`、`0x200000`
- `--size` 参数为十进制，单位为 KB，示例：`64`、`128`
- 当未指定地址和大小时，程序自动选择安全的测试区域

### 查看帮助

```shell
./spi_w25qxx.elf -h
```

### 使用示例

```shell
# 默认参数运行全部测试
./spi_w25qxx.elf

# 指定 QSPI0、CS14、5MHz，运行所有测试
./spi_w25qxx.elf -i 1 -c 14 -b 5

# 仅跑性能测试，地址 0x100000，大小 64KB
./spi_w25qxx.elf -t perf -a 0x100000 -s 64

# 运行设备信息测试，指定 OSPI 控制器
./spi_w25qxx.elf -i 0 -t info

# 运行基础功能测试，使用 QSPI0，波特率 20MHz
./spi_w25qxx.elf -i 1 -t basic -b 20
```

### 查看结果

程序会按参数执行相应测试并打印结果摘要，包含：

1. 设备信息（型号、容量、地址模式）
1. 基础功能测试（写使能/写禁止）
1. 读写测试（擦除-写入-回读校验）
1. 边界测试
1. 性能测试

最终会输出 `ALL TESTS PASSED` 或失败项信息。

```{admonition} 提示
在使用 SPI 之前，需要先完成 FPIOA 引脚复用配置。写入前需确保目标区域已擦除（通常为 0xFF），并注意不同容量器件可能涉及 4 字节地址模式切换。
```
