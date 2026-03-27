# MiniHTTP 示例

## 简介

本示例演示了如何在K230平台上使用MiniHTTP库进行HTTP/HTTPS网络通信。MiniHTTP是一个轻量级的HTTP客户端库，支持HTTP/HTTPS协议、SSL/TLS加密、文件下载等功能。

## 功能说明

### MiniHTTP特性

本示例展示了MiniHTTP库的主要功能：

- **HTTP/HTTPS支持**：支持HTTP和HTTPS协议
- **SSL/TLS加密**：支持SSL/TLS加密通信
- **简单API**：提供简单的文件下载API
- **事件驱动**：支持基于事件的异步操作
- **灵活配置**：可配置缓冲区大小、超时等参数

### 示例类型

本示例包含两个子示例：

#### 1. minihttp_basic - 基础示例

最简单的文件下载API使用示例：

- **一键下载**：使用简单的API下载指定URL的内容
- **自动处理**：自动处理HTTP连接、数据接收等
- **内存管理**：自动分配和释放内存

#### 2. minihttp_advanced - 高级示例

基于事件的HTTP客户端示例：

- **事件驱动**：通过事件回调处理HTTP响应
- **连接管理**：管理HTTP连接的生命周期
- **SSL验证**：验证SSL证书有效性
- **数据接收**：处理接收到的HTTP数据
- **错误处理**：处理网络错误和超时

### 主要API

#### 基础API

```cpp
// 简单的文件下载
char* minihttp::Download(const char* url);
```

#### 高级API

```cpp
// 初始化网络
void minihttp::InitNetwork();
void minihttp::StopNetwork();

// 检查SSL支持
bool minihttp::HasSSL();

// HTTP Socket类
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

## 代码位置

Demo 源码位置：`src/rtsmart/examples/3rd-party/minihttp`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项，选择将MiniHTTP示例编译进固件，然后编译固件。

#### 独立编译

进入MiniHTTP示例目录，使用CMake进行编译：

```shell
cd src/rtsmart/examples/3rd-party/minihttp/minihttp_basic
mkdir build && cd build
cmake ..
make
```

高级示例的编译方式相同。

### 运行示例

#### 基础示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
./test_minihttp
```

### 查看结果

#### 基础示例

程序会下载指定URL的内容并输出到控制台：

```text
<!DOCTYPE html>
<html>
<head>
    <title>百度一下，你就知道</title>
...
```

#### 高级示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
./minihttp_adv <url>
```

**参数说明：**

| 参数名 | 说明 |
|--------|------|
| url | 要下载的URL（支持HTTP和HTTPS） |

**使用示例：**

```shell
./minihttp_adv https://www.baidu.com
```

输出结果：

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

### SSL注意事项

使用HTTPS时需要注意以下事项：

1. **系统时间**：SSL证书验证需要正确的系统时间
1. **证书验证**：默认会验证SSL证书，如遇错误可能是证书问题
1. **错误码**：如果SSL错误码为0x1，通常是系统时间不正确

```{admonition} 提示
MiniHTTP库支持HTTP Keep-Alive功能，可以通过 `SetKeepAlive()` 设置Keep-Alive次数以提高性能。有关 MiniHTTP 的详细API，请参考相关的API文档。
```

```{admonition} 提示
使用HTTPS时，请确保系统已配置正确的时间，否则SSL证书验证会失败。可以使用 `date` 命令设置系统时间。
```
