# Cipher Demo

## 简介

本章节对应 `sample_cipher` 目录下的安全能力示例，主要覆盖 AES、Hash、硬件 Hash 以及 PUF 相关能力。

## 代码位置

- `src/rtsmart/examples/mpp/sample_cipher/sample_aes`
- `src/rtsmart/examples/mpp/sample_cipher/sample_hash`
- `src/rtsmart/examples/mpp/sample_cipher/sample_hwhash`
- `src/rtsmart/examples/mpp/sample_cipher/sample_pufs`

## 编译方法

在 `make menuconfig` 中使能：

- `RT-Smart UserSpace Examples Configuration`
- `Enable MPP examples`
- `Enable Build sample_cipher`

然后执行固件编译。

## 运行示例

编译后会生成多个可执行文件（按子目录名命名）：

```shell
cd /sdcard/app/examples/mpp
./sample_aes.elf
./sample_hash.elf
./sample_hwhash.elf
./sample_pufs.elf
```

## 说明

- `sample_aes` 主要验证 `/dev/aes` 相关流程。
- `sample_hash` 演示软件 hash 流程。
- `sample_hwhash` 演示硬件 hash 流程。
- `sample_pufs` 演示 PUF 加解密/签名相关流程。
