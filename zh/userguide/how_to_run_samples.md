# 如何运行示例程序

本文详细说明如何在 K230 RTOS SDK 中启用、编译、运行示例程序，并配置开机自启动。

## 启用示例程序

### 进入配置菜单

在 SDK 根目录（`~/rtos_k230`）执行以下命令，进入交互式配置界面：

```bash
make menuconfig
```

### 启用 RT-Smart 示例

导航至以下路径并启用示例编译选项：

```text
RT-Smart Configuration > Enable build Rtsmart examples
```

![rtsmart exmaples](https://developer.canaan-creative.com/api/post/attachment?id=531)

### 启用 MPP 示例

继续导航至 MPP 示例配置项并启用：

```text
MPP Configuration > Enable build MPP samples
```

![mpp examples](https://developer.canaan-creative.com/api/post/attachment?id=530)

**说明**：  
启用后，示例代码会被包含在后续编译流程中。若需禁用某个示例，可返回此处取消勾选。

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

![make smart_ipc](https://developer.canaan-creative.com/api/post/attachment?id=533)

**注意事项**：  

- 单独编译生成的 ELF 文件需手动拷贝到开发板（见步骤 3.2）。
- 确保编译前已通过 `menuconfig` 启用对应示例。

## 运行示例程序

### 通过镜像自动部署

若使用 `make` 整体编译，示例程序会默认打包到镜像的 `/sdcard/app/` 目录。通过串口登录开发板后，可直接执行：

```bash
cd /sdcard/app
./sample_elf_name      # 替换为实际示例文件名
```

### 手动部署单独编译的示例

1. 将生成的 ELF 文件（如 `integrated_poc.elf`）通过读卡器或者 mtp 拷贝到开发板：
1. 通过串口终端运行：

   ```bash
   /sdcard/app/integrated_poc.elf
   ```

![run smart ipc](https://developer.canaan-creative.com/api/post/attachment?id=534)

**串口连接提示**：

- 使用 `PuTTY` 或 `Minicom` 连接开发板串口（波特率为 `115200`）。
- 串口设备名在 Linux 下通常为 `/dev/ttyUSB0`，Windows 下为 `COMx`。

## 配置开机自启动示例

### 设置启动命令

1. 在 `make menuconfig` 中导航至：

   ```text
   RT-Smart Configuration > Startup command
   ```

1. 输入示例程序的绝对路径（如 `/sdcard/app/sample_elf_name`）。

### 验证自启动

重启开发板后，示例程序会自动运行。可通过日志或外设现象确认是否生效。

## 常见问题

1. **示例未出现在 `/sdcard/app` 目录**  
   - 检查 `menuconfig` 中是否启用对应示例。
   - 重新执行 `make` 并确保编译无报错。

1. **串口无输出**  
   - 确认串口线连接正常。
   - 检查波特率与终端配置是否匹配。

通过上述步骤，您可以快速掌握 K230 RTOS SDK 示例程序的完整操作流程。
