# 如何运行示例程序

本文详细说明如何在 K230 RTOS SDK 中启用、编译、运行示例程序，并配置开机自启动。

## 启用示例程序

### 进入配置菜单

在 SDK 根目录（`~/rtos_k230`）执行以下命令，进入交互式配置界面：

```bash
make menuconfig
```

### 启用编译示例

当前 SDK 已重构示例配置，统一入口为：

```text
RT-Smart UserSpace Examples Configuration
```

建议按以下顺序配置：

1. 先开启总开关：

   ```text
   RT-Smart UserSpace Examples Configuration
   ```

   > 需要关掉 `CanMV Components Configuration`

1. 再按类别开启子开关（按需选择）：

   ```text
   Enable 3rd-party examples
   Enable build peripheral examples
   Enable MPP examples
   Enable build ai examples
   Enable build integrated examples
   ```

1. 若开启了某个类别（例如 `Enable MPP examples`），继续进入该子菜单勾选具体 sample（如 `sample_venc`、`sample_vdec` 等）。

**说明**：

- 旧路径 `RT-Smart Configuration > Enable build Rtsmart examples` 和 `MPP Configuration > Enable build MPP samples` 已不再作为示例主入口。
- 示例总开关依赖 `!SDK_ENABLE_CANMV`；若你使用 CanMV 方案，需先按构建指南切到 RTOS 路径后该菜单才会出现。

## 编译示例程序

### 整体编译（推荐）

在根目录执行 `make` 命令，一键编译所有启用的示例并打包到镜像中：

```bash
make
```

### 单独编译（调试场景）

若需单独编译某个示例，可进入对应目录执行编译：

```bash
cd src/rtsmart/examples/integrated_poc  # 示例路径
make clean && make                      # 清理并重新编译
```

![make smart_ipc](https://www.kendryte.com/api/post/attachment?id=533)

**注意事项**：  

- 单独编译生成的 ELF 文件需手动拷贝到开发板（见步骤 3.2）。
- 确保编译前已在 `RT-Smart UserSpace Examples Configuration` 中启用对应类别和具体 sample。

## 运行示例程序

### 通过镜像自动部署

若使用 `make` 整体编译，RT-Smart 示例会默认打包到镜像的 `/sdcard/app/examples/` 目录。通过串口登录开发板后，可直接执行：

```bash
cd /sdcard/app/examples

# 运行示例（示例）
./integrated_poc/smart_ipc.elf
```

### 手动部署单独编译的示例

1. 将生成的 ELF 文件（如 `integrated_poc.elf`）通过读卡器或者 mtp 拷贝到开发板：
1. 通过串口终端运行：

   ```bash
   /sdcard/app/examples/integrated_poc.elf
   ```

![run smart ipc](https://www.kendryte.com/api/post/attachment?id=534)

**串口连接提示**：

- 使用 `PuTTY` 或 `Minicom` 连接开发板串口（波特率为 `115200`）。
- 串口设备名在 Linux 下通常为 `/dev/ttyUSB0`，Windows 下为 `COMx`。

## 配置开机自启动示例

### 设置启动命令

1. 在 `make menuconfig` 中导航至：

   ```text
   RT-Smart Configuration > Rtsmart auto execute command string
   ```

1. 普通文件系统自启动时，关闭 `Fast Boot Configuration`，并填写示例程序的板端绝对路径和参数。

1. Fast Boot 自启动时，在 `Fast Boot Configuration > Fast boot file path` 中填写主机侧 ELF 路径，并把自动运行命令设置为 `@preload`，参数跟在其后。`@preload` 是内部触发标记，不是 `/bin/preload` 文件，也不能作为普通 `msh` 命令运行。

完整配置、Secure Boot 限制和故障排查见[如何使用 Fast Boot 与配置 RT-Smart 自动运行](./how_to_use_fast_boot.md)。

### 验证自启动

重启开发板后，示例程序会自动运行。可通过日志或外设现象确认是否生效。

## 常见问题

1. **示例未出现在 `/sdcard/app/examples` 目录**  
   - 检查 `RT-Smart UserSpace Examples Configuration` 是否已开启总开关。
   - 检查对应类别（如 MPP/AI/Integrated）和具体 sample 是否已勾选。
   - 重新执行 `make` 并确保编译无报错。

1. **串口无输出**  
   - 确认串口线连接正常；使用外置 USB 转串口模块时，先核对 [串口电平与转接模块安全](../app_develop_guide/peripheral/uart.md)。
   - 检查波特率与终端配置是否匹配。

通过上述步骤，您可以快速掌握 K230 RTOS SDK 示例程序的完整操作流程。
