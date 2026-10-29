# libwebsockets 示例

## 简介

本示例展示 libwebsockets 在 K230 RT-Smart 平台上的使用。libwebsockets 是一个轻量级、高性能的 C 语言 Web 通信库，支持 HTTP/1、WebSocket、MQTT 等多种协议，采用 MIT 许可证，广泛用于嵌入式与物联网场景。

## 功能说明

### libwebsockets 特性

K230 平台集成的 libwebsockets 具备以下能力：

- **WebSocket 客户端/服务端**：支持 RFC 6455 标准的 WebSocket 双向通信
- **TLS/SSL 加密**：基于 MbedTLS 实现安全的 WebSocket over TLS (`wss://`)
- **HTTP 基础支持**：支持 HTTP GET/POST 等基础请求
- **RAW Socket 角色**：支持基于 RAW 角色的自定义协议扩展
- **Generic Crypto**：内置通用加解密能力
- **轻量级**：构建为静态库 (`libwebsockets.a`)，不依赖系统动态库

### 示例类型

K230 RTOS SDK 提供三个 libwebsockets 示例：

#### 1. ws_server - WebSocket Echo 服务端

一个简单的 WebSocket Echo 服务端：

- 监听指定端口（默认 7681），接受 WebSocket 客户端连接
- 将收到的文本消息原样回显给客户端
- 支持命令行参数配置端口号

#### 2. ws_client - WebSocket 客户端

一个 WebSocket 客户端示例：

- 连接到 WebSocket 服务端并发送文本消息
- 接收服务端的回显或推送消息并打印
- 支持命令行参数配置服务器地址、端口、路径和消息内容
- 内置超时机制（默认 10 秒）

#### 3. ws_poll_test - 连接隔离测试

一个用于验证 RT-Smart / SAL / lwIP 网络栈 `connect()` + `poll(POLLOUT)` 行为的测试工具：

- **raw 模式**：纯非阻塞 connect 测试
- **lws 模拟模式**（`-l`）：应用与 lws 相同的 socket 选项（`FD_CLOEXEC` + `TCP_NODELAY`）
- **blocking 模式**（`-b`）：阻塞式 connect 基线测试
- 用于排查 WebSocket 客户端在 `LRS_WAITING_CONNECT` 状态卡住的问题

## 代码位置

- 库源码：`src/rtsmart/libs/3rd-party/libwebsockets/libwebsockets/`
- 移植文件：`src/rtsmart/libs/3rd-party/libwebsockets/port/riscv64.cmake`
- ws_server 示例：`src/rtsmart/examples/3rd-party/libwebsockets/ws_server/`
- ws_client 示例：`src/rtsmart/examples/3rd-party/libwebsockets/ws_client/`
- ws_poll_test 示例：`src/rtsmart/examples/3rd-party/libwebsockets/ws_poll_test/`
- 配套 Python 测试脚本：`src/rtsmart/examples/3rd-party/libwebsockets/host_ws_test.py`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项：

1. 进入 `RT-Smart 3rd-party Configuration` → 使能 `Enable Build libwebsockets`
2. 进入示例配置 → 使能 `Enable Build libwebsockets Sample Programs`

然后编译固件。

#### 独立编译

进入对应示例目录，使用 Makefile 进行编译。

WebSocket 服务端：

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets/ws_server
make
```

WebSocket 客户端：

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets/ws_client
make
```

### 运行示例

#### ws_server（Echo 服务端）

```shell
./ws_server.elf [port]
```

| 参数 | 说明 |
| :-- | :-- |
| `port` | 监听端口号（可选，默认 7681） |

示例：

```shell
# 使用默认端口
./ws_server.elf

# 指定端口
./ws_server.elf 9000
```

程序启动后等待客户端连接，收到消息后自动回显。

#### ws_client（客户端）

```shell
./ws_client.elf [host] [port]
```

| 参数 | 说明 |
| :-- | :-- |
| `host` | WebSocket 服务端地址（默认 `127.0.0.1`） |
| `port` | WebSocket 服务端端口（默认 `7681`） |

也可以通过命令行选项灵活配置：

```shell
./ws_client.elf -a <host> -p <port> -u <path> -m <message> -t <timeout>
```

| 选项 | 说明 | 默认值 |
| :-- | :-- | :-- |
| `-a` | 服务器地址 | `127.0.0.1` |
| `-p` | 服务器端口 | `7681` |
| `-u` | URL 路径 | `/` |
| `-m` | 发送的消息 | `Hello from RT-Smart WebSocket client!` |
| `-t` | 超时时间（秒） | `10` |

#### ws_poll_test（连接测试）

```shell
./ws_poll_test.elf <host> <port> [-l] [-b] [-t <ms>]
```

| 选项 | 说明 |
| :-- | :-- |
| `<host>` | 目标服务器地址 |
| `<port>` | 目标服务器端口 |
| `-l` | 启用 lws socket 选项模拟 |
| `-b` | 启用阻塞式 connect 模式 |
| `-t <ms>` | poll 超时时间，单位毫秒（默认 10000） |

### 使用 Python 脚本测试

源码目录下提供了 `host_ws_test.py` 脚本，可在 PC 端配合 K230 WebSocket 服务端进行快速测试：

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets
python host_ws_test.py
```

### 测试场景示例

#### 场景一：板端 Echo 测试

1. 在 K230 开发板上启动 WebSocket 服务端：

   ```shell
   ./ws_server.elf
   ```

2. 在开发板上另一个终端启动 WebSocket 客户端：

   ```shell
   ./ws_client.elf 127.0.0.1 7681
   ```

3. 客户端发送消息后接收服务端回显，输出类似：

   ```text
   libwebsockets WebSocket client
   Connecting to 127.0.0.1:7681...
   Connected. Sending: Hello from RT-Smart WebSocket client!
   RX: Hello from RT-Smart WebSocket client!
   Exiting main loop.
   ```

#### 场景二：PC 与板端通信

1. 在 K230 开发板上启动 WebSocket 服务端：

   ```shell
   ./ws_server.elf 7681
   ```

2. 在 PC 上使用 Python 脚本或 WebSocket 客户端工具连接到开发板 IP：

   ```python
   import websocket
   ws = websocket.create_connection("ws://192.168.1.100:7681/")
   ws.send("Hello K230!")
   print(ws.recv())  # 收到回显: Hello K230!
   ws.close()
   ```

## 配置说明

| Kconfig 选项 | 说明 |
| :-- | :-- |
| `RTSMART_3RD_PARTY_ENABLE_LIBWEBSOCKETS` | 编译 libwebsockets 库 (`libwebsockets.a`) |

`RTSMART_3RD_PARTY_ENABLE_LIBWEBSOCKETS` 会自动选中 MbedTLS（`RTSMART_3RD_PARTY_ENABLE_MBEDTLS`）。

## 依赖关系

- **MbedTLS**：libwebsockets 依赖 MbedTLS 提供 TLS/SSL 加密能力
- **网络协议栈**：需要 RT-Smart 的 SAL（Socket Abstraction Layer）和 lwIP 协议栈
- 编译需要 CMake 工具链

## 构建说明

libwebsockets 采用 CMake 构建方式，SDK 的 Makefile 将上游源码归档后应用补丁，然后通过 K230 RISC-V 工具链文件 (`port/riscv64.cmake`) 调用 CMake 交叉编译。

当前构建配置：

- 启用 WebSocket 服务端与客户端角色
- 启用 RAW Socket 角色（用于自定义协议）
- 启用 Generic Crypto
- 禁用 HTTP/2、HTTP/3、QUIC
- 禁用插件与 CGI 支持

```{admonition} 提示
libwebsockets 内部使用 `lws_service()` 事件循环驱动所有 I/O 操作，应用中需要在主循环中周期性调用该函数。有关 libwebsockets 的详细 API 与高级特性，请参考 [libwebsockets 官方文档](https://libwebsockets.org/)。
```

```{admonition} 提示
如果 WebSocket 客户端连接后卡在等待状态，可使用 `ws_poll_test` 工具运行 `-l` 模式来诊断是否是 socket 选项设置与 lwIP 协议栈的兼容性问题。
```
