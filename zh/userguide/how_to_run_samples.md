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
   RT-Smart Configuration > Startup command
   ```

1. `Startup command` 是运行时命令字符串，建议输入示例程序的绝对路径（如 `/sdcard/app/examples/integrated_poc/smart_ipc.elf`）。

1. 若配置的是 `Fast Boot Configuration > Fast boot file path`，则可使用绝对路径，或使用 `tools/mkenv.mk` 导出的 `${SDK_*}` 变量（如 `${SDK_BUILD_IMAGES_DIR}`）。**同时也需要将自启命令修改掉，替换掉 elf 路径修改为 `/bin/preload`。**

### 验证自启动

重启开发板后，示例程序会自动运行。可通过日志或外设现象确认是否生效。

## 常见问题

1. **示例未出现在 `/sdcard/app/examples` 目录**  
   - 检查 `RT-Smart UserSpace Examples Configuration` 是否已开启总开关。
   - 检查对应类别（如 MPP/AI/Integrated）和具体 sample 是否已勾选。
   - 重新执行 `make` 并确保编译无报错。

1. **串口无输出**  
   - 确认串口线连接正常。
   - 检查波特率与终端配置是否匹配。

通过上述步骤，您可以快速掌握 K230 RTOS SDK 示例程序的完整操作流程。
