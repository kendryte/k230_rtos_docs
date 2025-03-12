# HelloWorld

在 K230 RTOS SDK 中，用户如果需要添加自己的应用，可以参考 `src/applications/helloworld` 中的代码以及 Makefile 和 Kconfig。

同时需要修改 `src/applications/apps.mk`，添加对应目录到编译系统中。

然后执行 `make` 或者 `make app` 即可编译 `src/applications` 目录下的应用。

应用将被打包到镜像的 `/sdcard/app/xxx` 目录，用户可以设置其开机自启或者手动运行测试。
