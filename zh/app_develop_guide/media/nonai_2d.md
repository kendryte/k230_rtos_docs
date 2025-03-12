# Nonai_2D Demo

## 简介

Nonai_2D Demo 具备图像叠加功能，可对输入文件执行相应操作。该功能在图像编辑、合成等场景中具有潜在应用价值，能够满足多幅图像合并展示或处理的需求。

## 功能说明

Nonai_2D 通过读取 YUV (I420 格式) 文件，进行图像叠加运算。

## 代码位置

Demo 源码位置：`canmv_k230/src/rtsmart/mpp/userapps/sample/sample_nonai_2d`。

假设您已经正确编译该 Demo。启动开发板后，进入 `/sdcard/elf/userapps` 目录，`sample_nonai_2d.elf` 为测试 Demo。

## 使用说明

输入参数如下：

| 参数名 | 描述 | 默认值 |
|--------|------|--------|
| -i     | 输入文件名 | -      |
| -w     | 图像宽度   | -      |
| -h     | 图像高度   | -      |
| -o     | 输出文件名 | -      |

## 示例

```shell
./sample_nonai_2d.elf -i ./foreman_128x64_3frames.yuv -w 128 -h 64 -o ./out_2d.yuv
```

## 查看结果

输出文件可以导出到本地，并使用 YUV 播放软件查看。

```{admonition} 提示
有关 nonai_2d 模块的具体接口，请参考[API文档](../../api_reference/nonai_2d.md)
```
