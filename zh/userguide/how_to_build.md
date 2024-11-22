# 2. 编译镜像

## 1. 概述

K230 RTOS SDK 是使用 repo 进行管理的一个 SDK 包，包括必要的 uboot，opensbi，rtsmart，mpp 等仓库。

## 2. 开发环境搭建

| 主机环境          | 描述                                |
| ----------------- | ----------------------------------- |
| Ubuntu 20.04.4 LTS (x86_64) | K230 CanMV 的编译环境适用于 Ubuntu 20.04 及以上版本。 |

目前，K230 RTOS Only SDK 仅在 Linux 环境下验证编译，其他 Linux 版本未经过测试，因此无法保证在其他系统上的兼容性。

### 2.1 本地构建环境

- 更新 APT 源（可选）

```shell
sudo bash -c 'cp /etc/apt/sources.list /etc/apt/sources_bak.list && \
  sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
  sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list'
```

- 安装必要的依赖软件

```shell
# 添加 i386 架构支持
sudo bash -c 'dpkg --add-architecture i386 && \
  apt-get clean all && \
  apt-get update && \
  apt-get install -y --fix-broken --fix-missing --no-install-recommends \
    sudo vim wget curl git git-lfs openssh-client net-tools sed tzdata expect mtd-utils inetutils-ping locales \
    sed make cmake binutils build-essential diffutils gcc g++ bash patch gzip bzip2 perl tar cpio unzip rsync \
    file bc findutils dosfstools mtools bison flex autoconf automake python3 python3-pip python3-dev python-is-python3 \
    lib32z1 scons libncurses5-dev kmod fakeroot pigz tree doxygen gawk pkg-config libyaml-dev libconfuse2 libconfuse-dev \
    libssl-dev libc6-dev-i386 libncurses5:i386'
```

- 更新 PIP 源（可选）

```shell
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
pip3 config set global.extra-index-url "https://mirrors.aliyun.com/pypi/simple https://mirrors.cloud.tencent.com/pypi/simple"
```

- 安装 Python 依赖

```shell
pip3 install -U pyyaml pycryptodome gmssl
```

- 安装 repo 工具

```shell
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

## 3. 编译流程

### 3.1 源码下载

K230 RTOS SDK 的源码托管在 Github 和 Gitee 上，用户可以通过 repo 工具下载源码。

```shell
# 推荐在用户根目录新建一个目录，再进行代码下载
mkdir -p ~/canmv_k230 && cd ~/canmv_k230

# 从github下载sdk，使用https协议
repo init -u https://github.com/canmv-k230/manifest -b master --repo-url=https://github.com/canmv-k230/git-repo.git

# 或者从gitee下载sdk，使用ssh协议，gitee需要登陆账号，并上传ssh公钥，大陆用户推荐使用gitee
repo init -u git@gitee.com:canmv-k230/manifest.git -b master --repo-url=git@gitee.com:canmv-k230/git-repo.git

# 同步代码
repo sync
```

### 3.2 代码准备

第一次编译时，需要下载工具链。以下命令仅需执行一次。

```shell
# 第一次执行时下载工具链
make dl_toolchain
```

### 3.3 编译

根据实际需求选择对应的板子配置文件，然后开始编译。

```shell
# 列出可用的配置选项
make list_def
# 选择对应的板子配置文件
make xxxx_defconfig
# 开始编译
time make log
```

编译完成后，镜像文件将生成在 `~/canmv_k230/output/xxxx/xxx.img` 目录下。

```shell
# 如果编译因为找不到而canmv报错，可以在menuconfig中去掉 CanMV 模块使能

make menuconfig
```

![disable canmv](https://developer.canaan-creative.com/api/post/attachment?id=440)

## 4. 代码目录说明

```sh
canmv_k230
.
├── boards
├── configs
├── include
├── output
├── src
│   ├── applications
│   ├── opensbi
│   ├── rtsmart
│   └── uboot
└── tools
```

目录结构说明：

1. `boards`：板子相关文件
1. `configs`：配置文件列表
1. `include`：自动生成的头文件
1. `output`：编译生成的文件，包括镜像和临时文件
1. `src/applications`：用户应用程序
1. `src/opensbi`：OpenSBI 相关文件
1. `src/rtsmart`：RT-Smart 和 MPP 相关文件
1. `src/uboot`：U-Boot 相关文件
1. `scripts`：编译系统相关脚本
