# Build Firmware

## Overview

K230 RTOS SDK is an SDK package managed by repo, including necessary uboot, opensbi, rtsmart, mpp and other repositories.

## Setting Up the Development Environment

| Host Environment           | Description                                |
| -------------------------- | ------------------------------------------ |
| Ubuntu 20.04.4 LTS (x86_64) | The K230 RTOS Only compilation environment is suitable for Ubuntu 20.04 and above. |

Currently, the K230 RTOS Only SDK has only been verified to compile under Linux environment, other Linux versions have not been tested, so compatibility on other systems cannot be guaranteed.

### Local Build Environment

- Update APT sources (optional)

```shell
sudo bash -c 'cp /etc/apt/sources.list /etc/apt/sources_bak.list && \
  sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list && \
  sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list'
```

- Install necessary dependencies

```shell
# Add support for i386 architecture
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

- Update PIP sources (optional)

```shell
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
pip3 config set global.extra-index-url "https://mirrors.aliyun.com/pypi/simple https://mirrors.cloud.tencent.com/pypi/simple"
```

- Install Python dependencies

```shell
pip3 install -U pyyaml pycryptodome gmssl jsonschema jinja2
```

- Install the repo tool

```shell
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="${HOME}/.bin:${PATH}"' >> ~/.bashrc
source ~/.bashrc
```

## Compilation Process

### Source Code Download

The source code of K230-RTOS-Only is hosted on Github and Gitee. Users can download the source code using the repo tool.

```shell
# It is recommended to create a new directory in the user root directory and then download the code
mkdir -p ~/canmv_k230 && cd ~/canmv_k230

# Download the SDK from GitHub, using the https protocol
repo init -u https://github.com/canmv-k230/manifest -b master --repo-url=https://github.com/canmv-k230/git-repo.git

# Or download the SDK from gitee, using the ssh protocol. Gitee needs to log in to the account and upload the ssh public key.
repo init -u git@gitee.com:canmv-k230/manifest.git -b master --repo-url=git@gitee.com:canmv-k230/git-repo.git

# Synchronize code
repo sync
```

### Code Preparation

When compiling for the first time, you need to download the toolchain. The following command only needs to be executed once.

```shell
# Download the toolchain when running for the first time
make dl_toolchain
```

### Compilation

Select the corresponding board configuration file according to actual needs, and then start compiling.

```shell
# List available configuration options
make list_def 
# Select the corresponding board configuration file
make xxxx_defconfig 
# Start compilation
time make log
```

After compilation, the image files will be generated in the `~/canmv_k230/output/xxxx/xxx.img` directory.

If you don't want to compile `CanMV`, you need to modify the configuration to disable only that module.

```shell
make menuconfig

# Disable the CanMV module
```

![disable canmv](https://developer.canaan-creative.com/api/post/attachment?id=440)

## Code Directory Description

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

Directory structure description:

1. `boards`: Board-related files
1. `configs`: List of configuration files
1. `include`: Automatically generated header files
1. `output`: Compiled files, including images and temporary files
1. `src/applications`: User applications
1. `src/opensbi`: OpenSBI-related files
1. `src/rtsmart`: RT-Smart and MPP-related files
1. `src/uboot`: U-Boot-related files
1. `scripts`: Compilation system-related scripts
