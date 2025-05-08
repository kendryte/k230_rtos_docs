# 如何编译固件

## 概述

K230 RTOS SDK 是基于 repo 管理的多仓库集成开发套件，包含 U-Boot、OpenSBI、RT-Smart、MPP 等核心组件。本文档提供完整的开发环境搭建、代码下载与编译流程说明。

## 开发环境要求

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
repo init -u git@gitee.com:canmv-k230/manifest.git -m rtsmart.xml \
  --repo-url=git@gitee.com:canmv-k230/git-repo.git

# 从 GitHub 下载代码（国际用户）
# repo init -u https://github.com/canmv-k230/manifest -m rtsmart.xml \
#   --repo-url=https://github.com/canmv-k230/git-repo.git

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

# 示例：选择 K230 默认配置
make xxx_defconfig
```

### 执行编译

```bash
# 开始完整编译（耗时较长，建议使用 `time` 记录时间）
time make log
```

**编译输出**  
生成的固件镜像位于：  
`./output/xxx_defconfig/****_v****.img`

## 目录结构说明

```text
rtos_k230/
├── boards/          # 硬件板级支持文件
├── configs/         # 编译配置文件（如 xxxx_defconfig）
├── output/          # 编译输出目录（镜像、临时文件）
├── src/
│   ├── applications # 用户应用程序
│   ├── opensbi/     # OpenSBI 引导程序
│   ├── rtsmart/     # RT-Smart 实时操作系统
│   └── uboot/       # U-Boot 引导加载程序
└── tools/           # 编译工具链与脚本
```

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

### 修改了 MPP 目录下的文件，没有重新编译

- **现象**：修改了 `src/rtsmart/mpp` 目录下的源码，或者 sample，执行 `make` 生成新镜像但是没有更新
- **解决方案**：执行一次 `make rtsmart-clean` 然后再执行 `make` ，这个设计是因为 MPP 编译较慢，但是改动的较少，因此仅主动编译一次。

## 下一步

- [烧录固件至开发板](./how_to_flash.md)  
- [运行示例程序](./how_to_run_samples.md)

通过本指南，您已完成 K230 RTOS SDK 的开发环境搭建与固件编译。如有其他问题，请参考官方文档或提交 Issue 至代码仓库。
