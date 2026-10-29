# How to Run and Add a HelloWorld Application

This document is divided into two parts:

- First, run the HelloWorld already provided by the SDK (fastest way to verify the environment)
- Then add/modify your own HelloWorld application

## Run the Built-in HelloWorld (Recommended First)

The SDK already provides the example directory: `src/applications/helloworld`

```bash
cd <sdk_root>
ls src/applications/helloworld
```

If the directory contains `Kconfig`, `Makefile`, and `main.c`, the example is ready.

### 1. Enable the HelloWorld Build Switch

```bash
make menuconfig
```

Enable in the menu:

```text
Application Configuration > Enable Application HelloWorld
```

### 2. Compile and Flash

```bash
make
```

After flashing is complete, the application will be packaged into the `/sdcard/app/` directory on the board.

### 3. Run on the Board

```bash
/sdcard/app/helloworld
```

## Add/Modify HelloWorld

You can modify directly based on the existing `src/applications/helloworld`, or copy it as a new application directory.

## Compile

### Compile Individually

```bash
cd <sdk_root>/src/applications/helloworld
make
ls
```

An executable file `helloworld` is generated, which can be manually copied to the board for execution.

### Compile the Entire img

1. Modify `src/applications/apps.mk` and add the corresponding directory to the build system.

```bash
cat src/applications/apps.mk
-include $(SDK_SRC_ROOT_DIR)/.config

subdirs-$(CONFIG_APP_ENABLE_HELLOWORLD) += helloworld
```

1. Enable the APP compilation feature in menuconfig

```bash
make menuconfig
```

```text
Application Configuration > Enable Application HelloWorld
```

Then execute `make` or `make app` to compile the applications under the `src/applications` directory.

```bash
make
```

Flash the compiled IMG to the development board.
The application will be packaged into the `/sdcard/app/` directory of the image, and users can set it to start automatically on boot or run it manually for testing.
