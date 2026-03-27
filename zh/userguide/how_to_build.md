# 如何编译固件

## 概述

K230 RTOS SDK 是基于 repo 管理的多仓库集成开发套件，包含 U-Boot、OpenSBI、RT-Smart、MPP 等核心组件。本文档提供完整的开发环境搭建、代码下载与编译流程说明。

## 开发环境要求

> 推荐使用虚拟机或者 Docker, 并随时备份修改，防止资料丢失。

### 系统要求

- **操作系统**：Ubuntu 20.04 LTS (x86_64)  
  *其他 Linux 发行版未经充分测试，可能存在兼容性问题。*

### 硬件要求

- 内存：建议 ≥ 2GB
- 磁盘空间：建议预留 ≥ 10GB

## 开发环境搭建

### 配置 APT 源（可选，推荐国内用户）

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources_bak.list
sudo sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo apt update
```

### 安装系统依赖

```bash
# 添加 i386 架构支持
sudo dpkg --add-architecture i386
sudo apt update

# 安装编译工具链及依赖库
sudo apt install -y --no-install-recommends \
    sudo vim wget curl git git-lfs openssh-client net-tools sed tzdata expect \
    make cmake binutils build-essential gcc g++ bash patch perl tar cpio unzip \
    file bc bison flex autoconf automake python3 python3-pip python3-dev \
    lib32z1 libncurses5-dev fakeroot pigz tree doxygen gawk pkg-config \
    libssl-dev libc6-dev-i386 libncurses5:i386 libconfuse-dev python-is-python3 scons libyaml-dev mtools

# 清理缓存
sudo apt clean
```

### 配置 Python 环境

```bash
# 配置 PIP 国内镜像源（推荐）
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 安装 Python 依赖库
pip3 install -U pyyaml pycryptodome gmssl jsonschema jinja2
```

### 安装 repo 工具

```bash
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## 代码获取与编译

## 10 分钟首次成功路径（推荐）

如果你是第一次接触 K230 RTOS SDK，建议先按下面这条最短路径完成一次成功编译：

```bash
# 1) 下载代码, gitee需要注册账号并配置私钥。
mkdir -p ~/rtos_k230 && cd ~/rtos_k230
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git
repo sync -j $(nproc)

# 2) 下载工具链（首次一次）
make dl_toolchain

# 3) 选择板级配置（示例：01Studio）
make k230_rtos_01studio_defconfig

# 4) 编译
time make log

# 5) 查看输出镜像
ls -lh output/k230_rtos_01studio_defconfig/images/
```

如果你的板子不是 01Studio，请先执行 `make list-def`，再选择对应的 `k230_rtos_*_defconfig`。

### 初始化git配置

```bash
#根据申请的git账号配置你的用户名和密码
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

### 下载 SDK 源码

```bash
# 创建工作目录
mkdir -p ~/rtos_k230 && cd ~/rtos_k230

# 从 Gitee 下载代码（推荐国内用户，需配置 SSH 密钥）
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git

# 从 GitHub 下载代码（国际用户）
# repo init -u https://github.com/canmv-k230/manifest --repo-url=https://github.com/canmv-k230/git-repo.git

# 同步代码仓库
repo sync -j $(nproc)
```

### 初始化工具链

```bash
# 首次编译需下载工具链（仅需执行一次）
make dl_toolchain
```

### 选择目标硬件配置

```bash
# 查看所有支持的硬件配置
make list-def

# 示例：01Studio 开发板
make k230_rtos_01studio_defconfig

# 示例：立创开发板
make k230_rtos_lckfb_defconfig
```

### 仅有 CanMV defconfig 时，如何构建 RTOS 镜像

部分板卡可能只有 `k230_canmv_*_defconfig`，没有对应的 `k230_rtos_*_defconfig`。这种情况下，也可以基于 CanMV defconfig 构建 RTOS 镜像：

```bash
# 1) 先选择一个可用的 canmv defconfig
make k230_canmv_xxx_defconfig

# 2) 进入 menuconfig 调整功能开关
make menuconfig
```

在 `menuconfig` 中建议至少调整以下项：

1. 关闭 CanMV 组件：

```text
CanMV Components Configuration
```

把该选项关闭（对应 `CONFIG_SDK_ENABLE_CANMV` 不使能）。

1. 按需编译示例：

```text
RT-Smart UserSpace Examples Configuration > Enable xxxx examples
```

1. 如果需要编译自定义应用，开启应用开关：

```text
Applications Configuration > (选择你的应用开关)
```

例如内置示例：`Enable Application HelloWorld`。

保存配置后执行编译：

```bash
time make log
```

如果你希望把当前调整固化成新的 defconfig，可执行：

```bash
make savedefconfig
```

然后将生成的配置保存到 `configs/` 下，便于团队复用。

### 执行编译

```bash
# 开始完整编译（耗时较长，建议使用 `time` 记录时间）
time make log
```

**编译输出**  
生成的固件镜像位于：  
`./output/<defconfig>/images/`

常见文件包括：

- `*.img`：用于 SD 卡烧录或部分命令行烧录场景
- `*.kdimg`：用于 K230BurningTool USB 烧录，或者 OTA 升级使用

## 目录结构说明

```text
rtos_k230/
├── boards/          # 板级支持包（BSP），包含板卡电源、引脚、启动介质、DDR 等配置
├── configs/         # defconfig 配置集合（入口配置）
├── output/          # 编译输出目录（按 defconfig 分目录）
├── src/
│   ├── applications # 用户应用（自定义 app，打包到 /sdcard/app）
│   ├── opensbi/     # OpenSBI（二级引导）
│   ├── rtsmart/     # RT-Smart 内核、驱动、MPP、示例等
│   ├── uboot/       # U-Boot（启动加载、分区/镜像装载）
│   └── canmv/       # CanMV 组件（开启 CONFIG_SDK_ENABLE_CANMV 时参与构建）
└── tools/           # 构建脚本、kconfig、工具链管理脚本
```

### 关键目录详解

#### boards/

- 作用：存放板级差异配置（BSP），例如内存规格、启动介质、外设复用、镜像布局关联配置。
- 典型场景：新增板卡、调整板级硬件参数（如某些 GPIO/电源/DDR 相关设置）。

#### configs/

- 作用：存放 `*_defconfig`，是整个工程的配置入口。
- 使用方式：执行 `make <board>_defconfig` 后，配置会展开到根目录 `.config`，后续 `make menuconfig` 在此基础上增改。
- 建议：团队内固定使用一份已验证的 defconfig，避免口口相传导致配置漂移。

#### output/

- 作用：每次构建的产物输出目录。
- 结构：`output/<defconfig>/...`
- 常见子目录：
  - `output/<defconfig>/images/`：最终可烧录镜像（常见 `*.img`、`*.kdimg`）
  - `output/<defconfig>/rtsmart/`：RT-Smart 相关中间产物
  - `output/<defconfig>/uboot/`、`opensbi/`、`applications/`：各模块独立构建产物

#### src/rtsmart/

- 作用：RTOS 主体目录，是大多数运行时能力和示例的核心来源。
- 顶层关键子目录：
  - `rtsmart/`：RT-Smart 主体（内核、系统组件、工具）
  - `mpp/`：多媒体处理平台（视频/音频/图像相关内核与用户态能力）
  - `examples/`：官方示例工程（外设、MPP、AI、集成样例）
  - `libs/`：公共库与 HAL（如 `rtsmart_hal`、3rd-party、nncase、opencv 等）

- 常见开发场景与修改入口：
  - 调整 RT-Smart 系统行为：优先查看 `src/rtsmart/rtsmart/`
  - 调整媒体链路或驱动相关接口：优先查看 `src/rtsmart/mpp/`
  - 验证硬件或功能：优先从 `src/rtsmart/examples/` 选择对应样例
  - 增加底层驱动封装或公共能力：优先查看 `src/rtsmart/libs/`

- 与镜像内容关系：
  - `src/rtsmart/examples/` 编译后会安装到镜像中的示例目录（通常为 `/sdcard/app/examples/`）
  - `src/rtsmart/mpp/` 与 `src/rtsmart/libs/` 的改动会影响相应运行库和示例行为

#### src/applications/

- 作用：用户自定义应用入口（相对于示例，更适合项目化交付）。
- 常见流程：新增应用目录 -> 在 `apps.mk`/Kconfig 中注册 -> `menuconfig` 使能 -> `make` 编译打包。

#### src/canmv/

- 作用：CanMV 相关组件与资源。
- 说明：当关闭 `CONFIG_SDK_ENABLE_CANMV` 时，该目录不会参与构建，适合纯 RTOS 镜像场景。

#### tools/

- 作用：构建系统基础设施，如工具链下载、Kconfig 解析、辅助脚本等。
- 常见命令入口：`make dl_toolchain`、`make menuconfig`、`make list-def`。

### 新手常用定位

- 找可烧录镜像：`output/<defconfig>/images/`
- 找当前可改配置：根目录 `.config`（由 defconfig + menuconfig 生成）
- 找默认配置模板：`configs/`
- 找示例源码：`src/rtsmart/examples/`
- 找自定义应用源码：`src/applications/`

## 常见问题

### 代码同步失败

- **现象**：`repo sync` 报错或卡顿  
- **解决方案**：  
  1. 检查网络连接，国内用户优先使用 Gitee 仓库。  
  1. 重试命令：`repo sync -j4 --fail-fast`。

### 编译工具链缺失

- **现象**：`make` 报错提示工具链未找到  
- **解决方案**：  
  确保已执行 `make dl_toolchain`，并检查 `~/.kendryte/k230_toolchains` 目录下是否包含工具链文件。

### 依赖冲突

- **现象**：编译过程中提示库版本不兼容  
- **解决方案**：  
  1. 使用 `apt list --installed` 检查依赖版本。  
  1. 通过 `sudo apt install <package>=<version>` 安装指定版本。

### 打包镜像失败

- **现象**：最后打包提示分区太小
- **解决方案**：减少使能的 example ，或者修改对应板子的镜像配置文件，增大对应分区的文件大小

## 下一步

- [烧录固件至开发板](./how_to_flash.md)  
- [运行示例程序](./how_to_run_samples.md)

通过本指南，您已完成 K230 RTOS SDK 的开发环境搭建与固件编译。如有其他问题，请参考官方文档或提交 Issue 至代码仓库。
