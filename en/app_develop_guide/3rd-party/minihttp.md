# MiniHTTP Example

## Introduction

This example demonstrates how to use the MiniHTTP library for HTTP/HTTPS network communication on the K230 platform. MiniHTTP is a lightweight HTTP client library that supports HTTP/HTTPS protocols, SSL/TLS encryption, file downloads, and other features.

## Feature Description

### MiniHTTP Features

This example showcases the main features of the MiniHTTP library:

- **HTTP/HTTPS Support**: Supports both HTTP and HTTPS protocols
- **SSL/TLS Encryption**: Supports SSL/TLS encrypted communication
- **Simple API**: Provides a simple file download API
- **Event-Driven**: Supports event-based asynchronous operations
- **Flexible Configuration**: Configurable buffer sizes, timeouts, and other parameters

### Example Types

This example includes two sub-examples:

#### 1. minihttp_basic - Basic Example

The simplest file download API usage example:

- **One-Click Download**: Uses a simple API to download content from a specified URL
- **Automatic Handling**: Automatically handles HTTP connections and data reception
- **Memory Management**: Automatically allocates and frees memory

#### 2. minihttp_advanced - Advanced Example

An event-based HTTP client example:

- **Event-Driven**: Handles HTTP responses through event callbacks
- **Connection Management**: Manages the lifecycle of HTTP connections
- **SSL Verification**: Validates the validity of SSL certificates
- **Data Reception**: Handles received HTTP data
- **Error Handling**: Handles network errors and timeouts

### Main API

#### Basic API

```cpp
// Simple file download
char* minihttp::Download(const char* url);
```

#### Advanced API

```cpp
// Initialize network
void minihttp::InitNetwork();
void minihttp::StopNetwork();

// Check SSL support
bool minihttp::HasSSL();

// HTTP Socket class
class HttpSocket {
public:
    virtual bool Download(const char* url);
    virtual void SetKeepAlive(int n);
    virtual void SetBufsizeIn(unsigned int size);

protected:
    virtual void _OnOpen();
    virtual void _OnClose();
    virtual void _OnRequestDone();
    virtual void _OnRecv(void* buf, unsigned int size);
};
```

## Code Location

Demo source location: `src/rtsmart/examples/3rd-party/minihttp`

## Usage Instructions

### Compilation Method

#### Firmware Compilation

In the `K230 RTOS SDK` root directory, use `make menuconfig` to configure the compilation options, select to compile the MiniHTTP example into the firmware, and then compile the firmware.

#### Standalone Compilation

Enter the MiniHTTP example directory and use CMake to compile:

```shell
cd src/rtsmart/examples/3rd-party/minihttp/minihttp_basic
mkdir build && cd build
cmake ..
make
```

The compilation method for the advanced example is the same.

### Run Example

#### Basic Example

Copy the compiled executable to the development board, enter the storage directory, and then run:

```shell
./test_minihttp
```

### View Results

#### Basic Example

The program downloads the content of the specified URL and outputs it to the console:

```text
<!DOCTYPE html>
<html>
<head>
    <title>百度一下，你就知道</title>
...
```

#### Advanced Example

Copy the compiled executable to the development board, navigate to the storage directory, and run:

```shell
./minihttp_adv <url>
```

**Parameter Description:**

| Parameter Name | Description |
|--------|------|
| url | URL to download (supports HTTP and HTTPS) |

**Usage Example:**

```shell
./minihttp_adv https://www.baidu.com
```

Output result:

```text
minihttp have ssl support: YES
Connecting to: https://www.baidu.com
[Event] _OnOpen()
SSL status flags (0 is good): 0x0

--- Data Received (1024 bytes) ---
<!DOCTYPE html>
<html>
...
-------------------------------

[Event] _OnRequestDone(): /
[Event] _OnClose()

Test finished.
```

### SSL Notes

When using HTTPS, pay attention to the following:

1. **System Time**: SSL certificate verification requires the correct system time
1. **Certificate Verification**: SSL certificates are verified by default; errors may be caused by certificate issues
1. **Error Code**: If the SSL error code is 0x1, the system time is usually incorrect

```{admonition} Tip
MiniHTTP library supports HTTP Keep-Alive functionality, which can be configured via `SetKeepAlive()` to set the Keep-Alive count to improve performance. For detailed MiniHTTP API information, please refer to the relevant API documentation.
```

```{admonition} Tip
When using HTTPS, please ensure the system has the correct time configured, otherwise SSL certificate verification will fail. You can use the `date` command to set the system time.
```
