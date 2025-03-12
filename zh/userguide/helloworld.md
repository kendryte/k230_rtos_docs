# 如何增加一个helloworld应用

如何添加一个helloworld应用

## 例程

我们已经提供例程参考 `src/applications/helloworld` 中的代码以及 Makefile 和 Kconfig。

```bash
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee/src/applications/helloworld$ ls
Kconfig  Makefile  link.lds  main.c
```

可以拷贝我们提供的例程进行修改。

## 编译

### 单独编译

```bash
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee/src/applications/helloworld$ make
[CC] main.c
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee/src/applications/helloworld$ ls
Kconfig  Makefile  helloworld  link.lds  main.c
```

生成可执行文件helloworld，可以手动拷贝到板子上运行

### 整个img编译

1、修改 `src/applications/apps.mk`，添加对应目录到编译系统中。

```bash
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee/src/applications$ cat apps.mk
-include $(SDK_SRC_ROOT_DIR)/.config

subdirs-$(CONFIG_APP_ENABLE_HELLOWORLD) += helloworld
```

2、在menuconfig中配置打开APP编译功能

```bash
zhangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee$ make menuconfig
```

```text
Application Configuration > Enable Application HelloWorld
```

然后执行 `make` 或者 `make app` 即可编译 `src/applications` 目录下的应用。

```bash
hangchenli@DESKTOP-OSN5BJK:~/canmv_k230_gitee$ make
```

把编译完成的IMG烧写到开发板。
应用将被打包到镜像的 `/sdcard/app/xxx` 目录，用户可以设置其开机自启或者手动运行测试。
