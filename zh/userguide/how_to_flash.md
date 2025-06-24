# 如何烧录固件

K230 支持四种启动介质：EMMC、SD卡、SPI Nor Flash 和 SPI Nand Flash。用户可通过以下两种方式烧录固件：

- **USB烧录**：直接通过USB连接设备烧录
- **SD卡烧录**：使用PC工具将镜像写入SD卡后启动

串口和USB连接方式：[K230 开发板](https://www.kendryte.com/zh/products)，选择相应的开发板跳转开发板资料链接

## 通过USB烧录

### 进入烧录模式的三种方法

1. **默认启动介质无有效固件**  
   - 例如：未烧录过固件的EMMC，或移除SD卡后上电。
1. **强制切换启动模式**  
   - 按住板载的 **Boot按键** 再上电，使芯片无法找到可启动介质。
1. **终端命令触发**  
   - 在RtSmart终端执行命令：

     ```bash
     reboot_to_upgrade
     ```

   - 设备将自动重启并进入烧录模式。

> **注意事项**  
> 若执行 `reboot_to_upgrade` 后未进入烧录模式，需使用最新烧录工具烧录以下补丁文件：
> [K230 Patch/K230D Patch](https://kendryte-download.canaan-creative.com/developer/tools/chip_patch/)

### 使用K230BurningTool（图形界面工具）

- **工具下载**：[K230BurningTool](https://www.kendryte.com/en/resource?selected=0-2-2)  
- **特点**：支持多设备同时烧录，操作直观。
- **步骤**：
  1. 连接设备并进入烧录模式。
  1. 选择固件文件（如`.kdimg` 格式，或者 `*.img`，`*.bin`）。
  1. 点击 **开始烧录**，完成后需手动点击 **确认** 以继续。

![K230BurningTool界面](https://www.kendryte.com/api/post/attachment?id=536)

### 使用K230-Flash（命令行工具）

- **工具安装**：  

  ```bash
  pip install k230-flash
  ```

- **特点**：基于Kburn和Python开发，适合自动化操作。
- **使用示例**：  

  ```bash
  k230_flash.exe -m EMMC 0 xxx.img
  ```

![K230-Flash界面](https://www.kendryte.com/api/post/attachment?id=537)

## 通过SD卡烧录

### 使用Rufus或balenaEtcher

- **适用场景**：将镜像文件烧录至SD卡后启动设备。
- **支持格式**：原始镜像文件（若为 `.gz` 格式需先解压）。
- **工具推荐**：
  - [Rufus](https://rufus.ie/en/)  
  - [balenaEtcher](https://etcher.balena.io/)  
- **步骤**：
  可参考[01Studio烧录固件](https://www.kendryte.com/k230_canmv/zh/main/zh/userguide/how_to_burn_firmware.html)  

> **重要提示**  
> `.kdimg` 格式文件**仅支持K230BurningTool烧录**，不可通过SD卡工具写入。

![Rufus操作示例](https://www.kendryte.com/api/post/attachment?id=538)

## 总结

| 烧录方式       | 适用场景                  | 推荐工具                     |
|----------------|--------------------------|-----------------------------|
| **USB烧录**    | 直接连接设备快速更新固件  | K230BurningTool、K230-Flash |
| **SD卡烧录**   | 无USB接口或批量烧录      | Rufus、balenaEtcher         |
