# K230 ADB User Guide

## ADB Function Description

K230 supports the Android Debug Bridge (ADB) function, providing device debugging and file transfer capabilities. Through ADB, developers can interact with the K230 device on the PC side, including executing shell commands, transferring files, etc. The ADB function is particularly suitable for:

- Remote debugging and log viewing
- Application deployment and testing
- File upload and download

## ADB Configuration Description

### Board-side Function Configuration

```bash
make rtsmart-menuconfig

# Find the corresponding configuration item
Components Configuration > Enable CherryUSB > Enable CherryUSB Device
   -> USB Device Function

# Select to enable the function
Select CDC + ADB or ADB
```

![ENABL ADB](https://www.kendryte.com/api/post/attachment?id=770)

Differences between several configurations:

- CDC: CanMV IDE connection function
- CDC+MTP: CanMV IDE connection function + CanMV disk function
- CDC+ADB: CanMV IDE connection function + ADB function
- ADB: ADB function
- UVC: UVC Device function (not compatible with IDE and ADB functions)

### Host Environment Configuration

#### Windows Environment

1. Download Android SDK Platform Tools:
   - Visit the Android Developer official website
   - Download the platform-tools archive for the corresponding platform

1. Extract and configure environment variables:

```shell
   # Add the platform-tools directory to the system PATH environment variable
   C:\path\to\platform-tools
```

1. Verify the installation:

```text
   adb version
```

#### Linux Environment

```bash
# Ubuntu/Debian system
sudo apt update
sudo apt install android-tools-adb

# Or download platform-tools
wget https://dl.google.com/android/repository/platform-tools-latest-linux.zip
unzip platform-tools-latest-linux.zip
export PATH=$PATH:$(pwd)/platform-tools
```

## ADB Command Description

### Device Connection Verification

After connecting the device, execute the following command on the PC to verify the connection:

```text
# View connected device list
adb devices

# Expected output:
# List of devices attached
# 001000000    device
```

### ADB Shell

#### Enter interactive shell

```text
adb shell
```

#### Execute a single command in shell

##### Basic syntax

```text
adb shell <command>
```

##### Usage examples

```text
# View memory usage
adb shell free
```

### ADB File Transfer

#### adb push - Upload file to device

##### Basic Syntax

```text
adb push <local_file_path> <remote_file_path>
```

##### Usage Examples

```text
# Upload a single file
adb push C:\Users\user\test.txt /tmp/test.txt

# Upload a file and rename it
adb push ./local_config.json /tmp/config.json

# Upload to a specific directory
adb push ./app.bin /tmp
```

#### adb pull - Download file to PC

##### Basic Syntax

```text
adb pull <remote_file_path> [local_file_path]
```

##### Usage Examples

```text
# Download a single file
adb pull /tmp/syslog ./logs/

# Download and rename
adb pull /tmp/debug.log ./debug_backup.log

# Download to current directory
adb pull /home/user/config.json ./
```

## Notes

1. The file transfer function only supports a single file and does not support transferring directories.
1. If you suddenly find that adb is disconnected during use, it may be that the USB cable has been moved. You need to shake and firmly plug in the USB cable.
