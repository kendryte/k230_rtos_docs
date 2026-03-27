# Ogg Demo

## 简介

本示例演示 K230 上基于 Opus 的实时音频回环处理流程，并在中间插入 Ogg 封装与解封装步骤。程序会从 AI 采集音频，交给 AENC 编码为 Opus 数据，再在内存中完成 Ogg mux/demux，最后送入 ADEC 解码并通过 AO 播放。

- Ogg 封装：将 AENC 输出的 Opus 帧打包为 Ogg page
- Ogg 解封装：从 Ogg page 中提取出 Opus 帧
- 实时回环：AI -> AENC -> Ogg mux -> Ogg demux -> ADEC -> AO
- 退出方式：程序持续运行，按 Ctrl+C 触发信号处理并清理资源

## 使用说明

### 代码位置

示例目录：`/src/rtsmart/examples/mpp/sample_ogg`

当前示例入口文件为 `main.cpp`，构建后生成可执行文件 `sample_ogg.elf`。

### 关键参数

| 参数名 | 描述 | 参数值 |
| :-- | :-- | :-- |
| `SAMPLE_RATE` | 音频采样率 | 16000 Hz |
| `AUDIO_PERSEC_DIV_NUM` | 每秒音频帧数 | 25 |
| `MAX_AUDIO_STREAM_SIZE` | Ogg/Opus 中转缓冲区大小 | 1000 字节 |
| 编码格式 | AENC/ADEC 使用的载荷类型 | Opus |
| 编码声道数 | 编解码通道数 | 1 |
| 采样精度 | I2S 位宽 | 16 bit |
| AI/AO 设备号 | 程序默认使用 | 0 |
| AI/AO/AENC/ADEC 通道号 | 程序默认使用 | 0 |

### 运行程序

程序启动后会初始化 VB、AI、AO、AENC、ADEC、Ogg muxer 与 demuxer，然后进入循环处理实时音频。按 Ctrl+C 退出。

```shell
./sample_ogg.elf
```

示例启动时会打印类似信息：

```text
Starting Ogg audio sample program. Press Ctrl+C to exit.
vb_set_config succeeded
Ogg stream muxer initialized successfully.
```

### 代码流程说明

1. 初始化 VB 资源
   - `audio_sample_vb_init()` 调用 `kd_mpi_vb_set_config()` 和 `kd_mpi_vb_init()` 初始化 VB 系统。
   - `audio_data_vb_create_pool()` 创建私有 VB 池，用于保存 ADEC 输入使用的中转音频流。
   - 通过 `kd_mpi_vb_get_block()`、`kd_mpi_vb_handle_to_phyaddr()`、`kd_mpi_sys_mmap()` 建立物理地址到用户空间的映射。

1. 初始化 Ogg 组件
   - `init_ogg_muxer()` 配置 `kd_ogg_muxer_params`，设置采样率 16 kHz、单声道、流式输出。
   - `init_ogg_demuxer()` 创建 Ogg demuxer，用于将 page 还原为 Opus 帧。

1. 配置音频输入、输出与编解码器
   - `audio_sample_ogg()` 中将 AI 与 AO 都配置为内置 codec 的 I2S 模式。
   - AI/AO 都设置为 16 bit、16 kHz、`AUDIO_PERSEC_DIV_NUM=25`。
   - 创建 AENC/ADEC 通道，载荷类型为 `K_PT_OPUS`。

1. 建立 MPP 绑定关系
   - `kd_mpi_sys_bind()` 将 AI 通道绑定到 AENC。
   - `kd_mpi_sys_bind()` 将 ADEC 通道绑定到 AO。

1. 在内存中执行 Ogg 封装与解封装
   - 主循环通过 `kd_mpi_aenc_get_stream()` 获取 Opus 编码流。
   - `do_opus_stream()` 先调用 `kd_ogg_write_frame_ex()` 将 Opus 帧封装为 Ogg page。
   - 随后调用 `kd_ogg_demuxer_feed_page_ex()` 从 page 中解出 Opus 帧。
   - 解出的 Opus 数据被拷贝到预先申请的 `g_audio_stream` 缓冲区，再通过 `kd_mpi_adec_send_stream()` 送入解码器。
   - 处理完成后调用 `kd_mpi_aenc_release_stream()` 释放编码流。

1. 信号退出与资源清理
   - `main()` 注册 `SIGINT` 和 `SIGTERM`，收到信号后将 `g_running` 置为 `false`。
   - 循环退出后，程序解除 AI/AENC 和 ADEC/AO 绑定，关闭 AI、AO、AENC、ADEC。
   - `cleanup_resources()` 销毁 Ogg muxer、demuxer，释放 VB block、销毁 VB pool，并调用 `kd_mpi_vb_exit()`。

### 注意事项

- 该示例不读写 `.ogg` 文件，Ogg 封装与解封装全部在内存中完成。
- 示例固定使用设备号 0 和通道号 0，移植到其他音频链路时需要同步调整代码。
- 如果音频设备初始化失败，程序会直接打印错误并执行清理流程。

```{admonition} 提示
有关 Ogg 处理与音频编解码相关接口，请结合 `sample_ogg/main.cpp` 以及对应的音频 API 文档一起阅读。
```
