# 如何编译固件

## 概述

K230 RTOS SDK 是基于 repo 管理的多仓库集成开发套件，包含 U-Boot、OpenSBI、RT-Smart、MPP 等核心组件。本文档提供两种构建方式：

- **使用 Docker 编译**（推荐）：无需安装任何编译依赖，一条命令即可完成编译
- **直接本机编译**：在 Ubuntu 20.04 上手动搭建环境

## 使用 Docker 编译（推荐）

使用预配置的 [k230-builder](https://github.com/huangzhenming/k230-builder) 镜像，内置所需工具链的下载工具、repo、genimage 及所有编译依赖。前提条件仅需安装 Docker。

### 前提条件

- **安装 Docker**

  请参考 [Docker 官方文档](https://docs.docker.com/engine/install/) 安装适合您操作系统的 Docker。

  - 对于 **Windows** 用户，建议使用 WSL（Windows Subsystem for Linux），并在 WSL 中安装 Docker，或使用 Docker Desktop 并启用 WSL 2 后端。
  - 安装完成后，**务必**执行以下命令将当前用户添加到 `docker` 用户组，以避免每次执行 `docker` 命令都需使用 `sudo`（否则后续编译可能因权限问题出错）：

    ```bash
    sudo usermod -aG docker $USER
    newgrp docker   # 或直接重新登录终端
    ```

- **配置 Gitee SSH 密钥**（代码下载需要）
  在 [Gitee](https://gitee.com) 注册账号并[添加 SSH 公钥](https://gitee.com/profile/sshkeys)。

- **配置 Git 用户信息**

  ```bash
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
  ```

### 安装 k230 命令

```bash
curl -fsSL https://www.kendryte.com/misc/install.sh | bash
source ~/.bashrc
```

安装后执行 `k230 pull` 拉取 Docker 镜像（首次耗时取决于网络，约 1GB+）。

### 快速开始

```bash
# 1) 创建工作目录
mkdir -p ~/rtos_k230 && cd ~/rtos_k230

# 2) 拉取 docker 镜像
k230 pull

# 3) 下载工具链（仅需首次执行一次）
k230 download-toolchains TC1 TC3

# 4) 下载代码（容器内置 repo，自动挂载宿主 SSH 密钥）
k230 repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git

# 从 GitHub 下载（国际）
# k230 repo init -u https://github.com/canmv-k230/manifest --repo-url=https://github.com/canmv-k230/git-repo.git

k230 repo sync -j$(nproc)

# 5) 选择您所需要的板级配置, 此处以 k230_rtos_01studio_defconfig 举例
k230 make list-def             # 查看所有板级配置
k230 make k230_rtos_01studio_defconfig

# 6) 编译
k230 make

# 7) 查看输出镜像
ls -lh output/k230_rtos_01studio_defconfig/images/
```

### 常用命令

```bash
k230 list-toolchains                  # 查看可用工具链列表
k230 make                             # 编译（增量构建）
k230 make list-def                    # 查看所有板级配置
k230 make menuconfig                  # 交互式配置
k230 bash                             # 进入容器终端
k230 repo sync -j$(nproc)            # 更新代码
k230 pull                             # 更新 k230-builder 镜像
```

### Git 与 SSH

`k230` 自动挂载宿主 `~/.ssh` 和 `~/.gitconfig` 到容器，`repo init` / `git clone` 直接可用，无需额外配置。

---

## 直接本机编译

> 推荐使用 Docker 编译。仅在无法使用 Docker 时，参考以下手动搭建流程。

### 系统要求

- **操作系统**：Ubuntu 20.04 LTS (x86_64)
- **内存**：≥ 2GB
- **磁盘**：≥ 10GB

### 配置 APT 源（可选，推荐国内用户）

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources_bak.list
sudo sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo apt update
```

### 安装系统依赖

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y --no-install-recommends \
    sudo vim wget curl git git-lfs openssh-client net-tools sed tzdata expect \
    make cmake binutils build-essential gcc g++ bash patch perl tar cpio unzip \
    file bc bison flex autoconf automake python3 python3-pip python3-dev \
    lib32z1 libncurses5-dev fakeroot pigz tree doxygen gawk pkg-config \
    libssl-dev libc6-dev-i386 libncurses5:i386 libconfuse-dev python-is-python3 scons libyaml-dev mtools
sudo apt clean
```

### 配置 Python 环境

```bash
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
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

### 下载代码与编译

```bash
mkdir -p ~/rtos_k230 && cd ~/rtos_k230

# 从 Gitee 下载（国内，需 SSH 密钥）
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git

# 从 GitHub 下载（国际）
# repo init -u https://github.com/canmv-k230/manifest --repo-url=https://github.com/canmv-k230/git-repo.git

repo sync -j $(nproc)

# 下载工具链（首次一次）
make dl_toolchain

# 选择板级配置并编译
make k230_rtos_01studio_defconfig
time make
```

---

## CanMV defconfig 构建 RTOS 镜像

部分板卡只有 `k230_canmv_*_defconfig`，没有对应的 `k230_rtos_*_defconfig`，可基于 CanMV defconfig 构建纯 RTOS 镜像：

```bash
make k230_canmv_xxx_defconfig
make menuconfig
```

在 `menuconfig` 中：

1. 关闭 `CanMV Components Configuration`
2. 按需开启 `RT-Smart UserSpace Examples Configuration > Enable xxxx examples`
3. 如需编译自定义应用，在 `Applications Configuration` 中开启对应开关

保存后编译：

```bash
make
```

如需固化为新的 defconfig：

```bash
make savedefconfig
# 将生成的配置保存到 configs/，便于团队复用
```

---

## 编译输出

生成的固件镜像位于 `output/<defconfig>/images/`，常见文件：

- `*.img`：SD 卡烧录或命令行烧录
- `*.kdimg`：K230BurningTool USB 烧录或 OTA 升级

---

## 目录结构

```text
rtos_k230/
├── boards/          # 板级支持包（BSP），电源、引脚、DDR 等配置
├── configs/         # defconfig 配置入口
├── output/          # 编译输出（按 defconfig 分目录）
├── src/
│   ├── applications # 用户自定义应用
│   ├── opensbi/     # OpenSBI（二级引导）
│   ├── rtsmart/     # RT-Smart 内核、驱动、MPP、示例
│   ├── uboot/       # U-Boot
│   └── canmv/       # CanMV 组件
└── tools/           # 构建脚本、kconfig、工具链管理
```

### 关键目录

| 目录 | 说明 |
|------|------|
| `output/<defconfig>/images/` | 最终可烧录镜像 |
| `configs/` | 默认配置模板（`make list-def` 看到的所有选项） |
| `src/rtsmart/examples/` | 官方示例源码 |
| `src/applications/` | 用户自定义应用入口 |
| `tools/` | 构建基础设施（`make menuconfig`、`make list-def` 等） |

---

## 常见问题

### `k230` 命令未找到

执行 `source ~/.bashrc` 或重新登录终端。确认 `~/.local/bin` 在 `$PATH` 中。

### `repo sync` 失败

1. 检查网络连接，国内用户使用 Gitee 仓库
2. 重试：`k230 repo sync -j4 --fail-fast`
3. 确认 Gitee SSH 密钥已配置，`~/.ssh` 下存在对应私钥

### 工具链下载失败

工具链存储在 Docker Volume `k230_toolchains` 中，首次下载量较大，网络不稳定时可分批下载：

```bash
k230 download-toolchains TC1     # 先下 TC1
k230 download-toolchains TC3     # 再下 TC3
```

### Docker 无权限

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 下一步

- [烧录固件至开发板](./how_to_flash.md)
- [运行示例程序](./how_to_run_samples.md)
