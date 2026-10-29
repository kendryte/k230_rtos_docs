# How to Build Firmware

## Overview

The K230 RTOS SDK is a multi-repository integrated development suite managed by repo, including core components such as U-Boot, OpenSBI, RT-Smart, and MPP. This document provides two build methods:

- **Build using Docker** (recommended): No need to install any build dependencies; one command completes the build
- **Native build directly**: Manually set up the environment on Ubuntu 20.04

## Build Using Docker (Recommended)

Use the pre-configured [k230-builder](https://github.com/huangzhenming/k230-builder) image, which includes the download tool for the required toolchain, repo, genimage, and all build dependencies. The only prerequisite is to install Docker.

### Prerequisites

- **Install Docker**

  Please refer to the [Docker official documentation](https://docs.docker.com/engine/install/) to install Docker suitable for your operating system.

  - For **Windows** users, it is recommended to use WSL (Windows Subsystem for Linux) and install Docker in WSL, or use Docker Desktop with the WSL 2 backend enabled.
  - After installation, **be sure** to execute the following command to add the current user to the `docker` user group to avoid needing `sudo` for every `docker` command (otherwise subsequent builds may fail due to permission issues):

    ```bash
    sudo usermod -aG docker $USER
    newgrp docker   # or simply re-login to the terminal
    ```

- **Configure Gitee SSH Key** (required for code download)
  Register an account on [Gitee](https://gitee.com) and [add the SSH public key](https://gitee.com/profile/sshkeys).

- **Configure Git User Information**

  ```bash
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
  ```

### Install the k230 Command

```bash
curl -fsSL https://www.kendryte.com/misc/install.sh | bash
source ~/.bashrc
```

After installation, run `k230 pull` to pull the Docker image (the first time depends on the network, approximately 1GB+).

### Quick Start

```bash
# 1) Create a working directory
mkdir -p ~/rtos_k230 && cd ~/rtos_k230

# 2) Pull the docker image
k230 pull

# 3) Download the toolchain (only need to run this once for the first time)
k230 download-toolchains TC1 TC3

# 4) Download the code (repo is built into the container, and host SSH keys are automatically mounted)
k230 repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git

# Download from GitHub (international)
# k230 repo init -u https://github.com/canmv-k230/manifest --repo-url=https://github.com/canmv-k230/git-repo.git

k230 repo sync -j$(nproc)

# 5) Select the board configuration you need, here k230_rtos_01studio_defconfig as an example
k230 make list-def             # View all board configurations
k230 make k230_rtos_01studio_defconfig

# 6) Build
k230 make

# 7) View the output image
ls -lh output/k230_rtos_01studio_defconfig/images/
```

### Common Commands

```bash
k230 list-toolchains                  # View the list of available toolchains
k230 make                             # Build (incremental build)
k230 make list-def                    # View all board configurations
k230 make menuconfig                  # Interactive configuration
k230 bash                             # Enter the container terminal
k230 repo sync -j$(nproc)            # Update the code
k230 pull                             # Update the k230-builder image
```

### Git and SSH

`k230` automatically mounts the host's `~/.ssh` and `~/.gitconfig` into the container; `repo init` / `git clone` works directly without additional configuration.

---

## Direct Local Compilation

> Docker compilation is recommended. Only refer to the following manual setup process when Docker is unavailable.

### System Requirements

- **Operating System**: Ubuntu 20.04 LTS (x86_64)
- **Memory**: ≥ 2GB
- **Disk**: ≥ 10GB

### Configure APT Sources (Optional, Recommended for Domestic Users)

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources_bak.list
sudo sed -i "s/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo sed -i "s/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g" /etc/apt/sources.list
sudo apt update
```

### Install System Dependencies

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

### Configure Python Environment

```bash
pip3 config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip3 install -U pyyaml pycryptodome gmssl jsonschema jinja2
```

### Install the repo Tool

```bash
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
echo 'export PATH="$HOME/.bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Download Code and Compile

```bash
mkdir -p ~/rtos_k230 && cd ~/rtos_k230

# Download from Gitee (Domestic, requires SSH key)
repo init -u git@gitee.com:canmv-k230/manifest.git --repo-url=git@gitee.com:canmv-k230/git-repo.git

# Download from GitHub (International)
# repo init -u https://github.com/canmv-k230/manifest --repo-url=https://github.com/canmv-k230/git-repo.git

repo sync -j $(nproc)

# Download toolchain (first time only)
make dl_toolchain

# Select board configuration and compile
make k230_rtos_01studio_defconfig
time make
```

---

## Building RTOS Image from CanMV defconfig

Some boards only have `k230_canmv_*_defconfig` and do not have a corresponding `k230_rtos_*_defconfig`. You can build a pure RTOS image based on the CanMV defconfig:

```bash
make k230_canmv_xxx_defconfig
make menuconfig
```

In `menuconfig`:

1. Disable `CanMV Components Configuration`
2. Enable `RT-Smart UserSpace Examples Configuration > Enable xxxx examples` as needed
3. To build custom applications, enable the corresponding switch under `Applications Configuration`

After saving, compile:

```bash
make
```

To save as a new defconfig:

```bash
make savedefconfig
# Save the generated configuration to configs/ for team reuse
```

---

## Build Output

The generated firmware images are located in `output/<defconfig>/images/`, common files include:

- `*.img`: SD card burning or command-line burning
- `*.kdimg`: K230BurningTool USB burning or OTA upgrade

---

## Directory Structure

```text
rtos_k230/
├── boards/          # Board Support Package (BSP), power, pins, DDR, etc. configuration
├── configs/         # defconfig configuration entry
├── output/          # Build output (organized by defconfig directory)
├── src/
│   ├── applications # User-defined applications
│   ├── opensbi/     # OpenSBI (secondary boot)
│   ├── rtsmart/     # RT-Smart kernel, drivers, MPP, examples
│   ├── uboot/       # U-Boot
│   └── canmv/       # CanMV components
└── tools/           # Build scripts, kconfig, toolchain management
```

### Key Directories

| Directory | Description |
|------|------|
| `output/<defconfig>/images/` | Final flashable images |
| `configs/` | Default configuration templates (all options seen by `make list-def`) |
| `src/rtsmart/examples/` | Official example source code |
| `src/applications/` | User-defined application entry |
| `tools/` | Build infrastructure (`make menuconfig`, `make list-def`, etc.) |

---

## FAQ

### `k230` command not found

Run `source ~/.bashrc` or re-login to the terminal. Verify that `~/.local/bin` is in `$PATH`.

### `repo sync` fails

1. Check your network connection; users in China should use the Gitee repository
2. Retry: `k230 repo sync -j4 --fail-fast`
3. Verify that the Gitee SSH key is configured and the corresponding private key exists under `~/.ssh`

### Toolchain download fails

The toolchains are stored in the Docker Volume `k230_toolchains`. The initial download is large, and you can download in batches when the network is unstable:

```bash
k230 download-toolchains TC1     # Download TC1 first
k230 download-toolchains TC3     # Then download TC3
```

### Docker permission denied

```bash
sudo usermod -aG docker $USER
newgrp docker
```

## Next Steps

- [Flash Firmware to Development Board](./how_to_flash.md)
- [Run Sample Programs](./how_to_run_samples.md)
