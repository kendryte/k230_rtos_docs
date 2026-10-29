# libwebsockets Example

## Introduction

This example demonstrates the use of libwebsockets on the K230 RT-Smart platform. libwebsockets is a lightweight, high-performance C-language Web communication library that supports multiple protocols such as HTTP/1, WebSocket, and MQTT. It is licensed under the MIT License and is widely used in embedded and Internet of Things scenarios.

## Feature Description

### libwebsockets Features

The libwebsockets integrated into the K230 platform provides the following capabilities:

- **WebSocket Client/Server**: Supports bidirectional WebSocket communication compliant with the RFC 6455 standard
- **TLS/SSL Encryption**: Provides secure WebSocket over TLS (`wss://`) based on MbedTLS
- **Basic HTTP Support**: Supports basic requests such as HTTP GET/POST
- **RAW Socket Role**: Supports custom protocol extensions based on the RAW role
- **Generic Crypto**: Provides built-in general-purpose encryption and decryption capabilities
- **Lightweight**: Built as a static library (`libwebsockets.a`) with no dependency on system dynamic libraries

### Example Types

The K230 RTOS SDK provides three libwebsockets examples:

#### 1. ws_server - WebSocket Echo Server

A simple WebSocket Echo server:

- Listens on a specified port (7681 by default) and accepts WebSocket client connections
- Echoes received text messages back to the client verbatim
- Supports configuring the port number through command-line arguments

#### 2. ws_client - WebSocket Client

A WebSocket client example:

- Connects to a WebSocket server and sends text messages
- Receives echoed or pushed messages from the server and prints them
- Supports configuring the server address, port, path, and message content through command-line arguments
- Includes a built-in timeout mechanism (10 seconds by default)

#### 3. ws_poll_test - Connection Isolation Test

A testing tool used to verify the behavior of `connect()` + `poll(POLLOUT)` in the RT-Smart / SAL / lwIP network stack:

- **raw mode**: Pure non-blocking connect test
- **lws simulation mode** (`-l`): Applies the same socket options as lws (`FD_CLOEXEC` + `TCP_NODELAY`)
- **blocking mode** (`-b`): Blocking connect baseline test
- Used to troubleshoot issues where the WebSocket client becomes stuck in the `LRS_WAITING_CONNECT` state

## Code Location

- Library source code: `src/rtsmart/libs/3rd-party/libwebsockets/libwebsockets/`
- Porting file: `src/rtsmart/libs/3rd-party/libwebsockets/port/riscv64.cmake`
- ws_server example: `src/rtsmart/examples/3rd-party/libwebsockets/ws_server/`
- ws_client example: `src/rtsmart/examples/3rd-party/libwebsockets/ws_client/`
- ws_poll_test example: `src/rtsmart/examples/3rd-party/libwebsockets/ws_poll_test/`
- Companion Python test script: `src/rtsmart/examples/3rd-party/libwebsockets/host_ws_test.py`

## Usage Instructions

### Compilation Methods

#### Firmware Compilation

Use `make menuconfig` at the `K230 RTOS SDK` root directory to configure the build options:

1. Go to `RT-Smart 3rd-party Configuration` → enable `Enable Build libwebsockets`
2. Go to the example configuration → enable `Enable Build libwebsockets Sample Programs`

Then compile the firmware.

#### Standalone Compilation

Enter the corresponding example directory and use the Makefile to compile.

WebSocket server:

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets/ws_server
make
```

WebSocket client:

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets/ws_client
make
```

### Run Examples

#### ws_server (Echo Server)

```shell
./ws_server.elf [port]
```

| Parameter | Description |
| :-- | :-- |
| `port` | Listening port number (optional, default: 7681) |

Example:

```shell
# Use the default port
./ws_server.elf

# Specify a port
./ws_server.elf 9000
```

After the program starts, it waits for a client to connect and automatically echoes messages upon receipt.

#### ws_client (Client)

```shell
./ws_client.elf [host] [port]
```

| Parameter | Description |
| :-- | :-- |
| `host` | WebSocket server address (default: `127.0.0.1`) |
| `port` | WebSocket server port (default: `7681`) |

You can also configure it flexibly through command-line options:

```shell
./ws_client.elf -a <host> -p <port> -u <path> -m <message> -t <timeout>
```

| Option | Description | Default Value |
| :-- | :-- | :-- |
| `-a` | Server address | `127.0.0.1` |
| `-p` | Server port | `7681` |
| `-u` | URL path | `/` |
| `-m` | Message to send | `Hello from RT-Smart WebSocket client!` |
| `-t` | Timeout (seconds) | `10` |

#### ws_poll_test (Connection Test)

```shell
./ws_poll_test.elf <host> <port> [-l] [-b] [-t <ms>]
```

| Option | Description |
| :-- | :-- |
| `<host>` | Target server address |
| `<port>` | Target server port |
| `-l` | Enable lws socket option simulation |
| `-b` | Enable blocking connect mode |
| `-t <ms>` | poll timeout in milliseconds (default: 10000) |

### Using a Python Script for Testing

The source code directory provides the `host_ws_test.py` script, which can be used on a PC with the K230 WebSocket server for quick testing:

```shell
cd src/rtsmart/examples/3rd-party/libwebsockets
python host_ws_test.py
```

### Example Test Scenarios

#### Scenario 1: Board-Side Echo Test

1. Start the WebSocket server on the K230 development board:

   ```shell
   ./ws_server.elf
   ```

2. Start the WebSocket client in another terminal on the development board:

   ```shell
   ./ws_client.elf 127.0.0.1 7681
   ```

3. After the client sends a message, it receives the echo from the server, and the output is similar to:

   ```text
   libwebsockets WebSocket client
   Connecting to 127.0.0.1:7681...
   Connected. Sending: Hello from RT-Smart WebSocket client!
   RX: Hello from RT-Smart WebSocket client!
   Exiting main loop.
   ```

#### Scenario 2: Communication Between the PC and the Board

1. Start the WebSocket server on the K230 development board:

   ```shell
   ./ws_server.elf 7681
   ```

2. On the PC, use the Python script or a WebSocket client tool to connect to the development board IP:

   ```python
   import websocket
   ws = websocket.create_connection("ws://192.168.1.100:7681/")
   ws.send("Hello K230!")
   print(ws.recv())  # Receive echo: Hello K230!
   ws.close()
   ```

## Configuration Instructions

| Kconfig Option | Description |
| :-- | :-- |
| `RTSMART_3RD_PARTY_ENABLE_LIBWEBSOCKETS` | Build the libwebsockets library (`libwebsockets.a`) |

`RTSMART_3RD_PARTY_ENABLE_LIBWEBSOCKETS` automatically selects MbedTLS (`RTSMART_3RD_PARTY_ENABLE_MBEDTLS`).

## Dependencies

- **MbedTLS**: libwebsockets depends on MbedTLS to provide TLS/SSL encryption capabilities
- **Network protocol stack**: RT-Smart's SAL (Socket Abstraction Layer) and the lwIP protocol stack are required
- Building requires the CMake toolchain

## Build Instructions

libwebsockets uses CMake for building. The SDK's Makefile archives the upstream source code and applies patches, then invokes CMake for cross-compilation through the K230 RISC-V toolchain file (`port/riscv64.cmake`).

Current build configuration:

- Enable the WebSocket server and client roles
- Enable the RAW Socket role (for custom protocols)
- Enable Generic Crypto
- Disable HTTP/2, HTTP/3, and QUIC
- Disable plugin and CGI support

```{admonition} Tip
libwebsockets internally uses the `lws_service()` event loop to drive all I/O operations, and applications need to call this function periodically in the main loop. For detailed libwebsockets APIs and advanced features, see the [official libwebsockets documentation](https://libwebsockets.org/).
```

```{admonition} Tip
If the WebSocket client remains stuck in a waiting state after connecting, you can run the `ws_poll_test` tool in `-l` mode to diagnose whether the socket option settings are compatible with the lwIP protocol stack.
```
