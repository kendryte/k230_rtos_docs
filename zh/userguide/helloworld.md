# 如何运行和新增 HelloWorld 应用

本文档分两部分：

- 先运行 SDK 已提供的 HelloWorld（最快验证环境）
- 再新增/修改自己的 HelloWorld 应用

## 运行内置 HelloWorld（推荐先做）

SDK 已提供示例目录：`src/applications/helloworld`

```bash
cd <sdk_root>
ls src/applications/helloworld
```

如果目录存在 `Kconfig`、`Makefile`、`main.c`，说明示例已就绪。

### 1. 打开 HelloWorld 编译开关

```bash
make menuconfig
```

在菜单中启用：

```text
Application Configuration > Enable Application HelloWorld
```

### 2. 编译并烧录

```bash
make
```

烧录完成后，应用会被打包到板端的 `/sdcard/app/` 目录。

### 3. 板端运行

```bash
/sdcard/app/helloworld
```

## 新增/修改 HelloWorld

可以基于现有 `src/applications/helloworld` 直接修改，也可以拷贝一份作为新应用目录。

## 编译

### 单独编译

```bash
cd <sdk_root>/src/applications/helloworld
make
ls
```

生成可执行文件 `helloworld`，可手动拷贝到板子上运行。

### 整个img编译

1. 修改 `src/applications/apps.mk`，添加对应目录到编译系统中。

```bash
cat src/applications/apps.mk
-include $(SDK_SRC_ROOT_DIR)/.config

subdirs-$(CONFIG_APP_ENABLE_HELLOWORLD) += helloworld
```

1. 在 menuconfig 中打开 APP 编译功能

```bash
make menuconfig
```

```text
Application Configuration > Enable Application HelloWorld
```

然后执行 `make` 或者 `make app` 即可编译 `src/applications` 目录下的应用。

```bash
make
```

把编译完成的IMG烧写到开发板。
应用将被打包到镜像的 `/sdcard/app/` 目录，用户可以设置其开机自启或者手动运行测试。
