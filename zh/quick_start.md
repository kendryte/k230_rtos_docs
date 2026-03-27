# 快速入门指南

## 你将完成什么

本页目标是帮助你在最短时间内完成一次“可验证成功”的流程：

1. 下载 SDK 源码
1. 选择板级配置并编译镜像
1. 烧录到开发板
1. 登录串口并运行第一个示例

如果你希望看完整说明，请转到用户指南：

- [如何编译固件](./userguide/how_to_build.md)
- [如何烧录固件](./userguide/how_to_flash.md)
- [如何运行示例程序](./userguide/how_to_run_samples.md)

## 前置条件

- 主机系统：Ubuntu 20.04 x86_64（推荐）
- 已连接开发板、串口线、USB 线（或 SD 卡读卡器）
- 有可用网络（用于 `repo sync` 和工具链下载）

## 15 分钟上手路径

### 1. 下载源码

```bash
mkdir -p ~/rtos_k230 && cd ~/rtos_k230
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git
repo sync -j $(nproc)
```

### 2. 下载工具链（首次一次）

```bash
make dl_toolchain
```

### 3. 选择板级配置

```bash
# 查看可用配置
make list-def

# 示例：01Studio
make k230_rtos_01studio_defconfig
```

如果你的板卡只有 `k230_canmv_*_defconfig`，也可以先选它，再用 `menuconfig` 关闭 CanMV 并开启 RTOS 侧能力（见 [如何编译固件](./userguide/how_to_build.md) 中“仅有 CanMV defconfig 时，如何构建 RTOS 镜像”一节）。

### 4. 编译镜像

```bash
time make log
```

编译结果通常在：

```text
output/<defconfig>/images/
```

常见文件：

- `*.kdimg`：推荐用于 K230BurningTool（USB）
- `*.img`：常用于 SD 卡写盘或命令行烧录

### 5. 烧录并启动

推荐先用 K230BurningTool 烧录 `*.kdimg`，步骤见 [如何烧录固件](./userguide/how_to_flash.md)。

启动后用串口工具连接开发板（常见 115200 波特率），进入 RT-Smart shell。

### 6. 运行第一个示例

```bash
cd /sdcard/app/examples
find . -name "*.elf" | head
./integrated_poc/smart_ipc.elf
```

如果示例路径不同，请以 `find` 输出结果为准。

## 常见入口

- 新增/修改应用：[`userguide/helloworld.md`](./userguide/helloworld.md)
- 查看支持的 Sensor 与使能方式：[`userguide/sensor_list.md`](./userguide/sensor_list.md)
- 应用开发指南：[`app_develop_guide/index.md`](./app_develop_guide/index.md)
- API 手册：[`api_reference/index.md`](./api_reference/index.md)

## 下一步建议

1. 先跑通一个现成示例，确认工具链、烧录、串口链路都正常
1. 再启用/裁剪自己需要的示例和应用开关
1. 最后固化为团队统一 defconfig，避免配置漂移
