# Live555

## 简介

Live555是一个开源的多媒体流媒体库，支持RTP/RTCP协议，广泛用于流媒体应用开发。K230 RTOS SDK集成了Live555库，支持在K230平台上进行流媒体传输。

## 功能说明

### Live555特性

Live555提供了完整的流媒体框架：

- **RTP/RTCP协议**：实时传输协议和实时控制协议
- **RTSP协议**：实时流协议
- **SIP协议**：会话初始化协议（部分支持）
- **多种编解码器**：支持H.264、H.265、AAC等编解码器
- **跨平台**：支持多种操作系统

### 主要组件

Live555包含以下主要组件：

- **UsageEnvironment**：使用环境，提供基础的任务调度和事件处理
- **BasicUsageEnvironment**：基本使用环境实现
- **liveMedia**：媒体处理库
- **groupsock**：组播和单播网络处理
- **BasicUsageEnvironment**：基础环境实现

## 应用场景

在K230平台上，Live555可以用于：

- **RTSP服务器**：实现流媒体服务器，`/src/rtsmart/mpp/middleware/src/rtsp_server` 为使用live555封装的rtsp 服务器接口，`/src/rtsmart/examples/mpp/sample_rtspserver`为对应demo
- **RTSP客户端**：实现流媒体客户端，`/src/rtsmart/mpp/middleware/src/rtsp_client` 为使用live555封装的rtsp 客户端接口,`/src/rtsmart/examples/mpp/sample_rtspclient`为对应demo

## 编译说明

### Live555库集成

K230 RTOS SDK已经预编译了Live555库，位于SDK的库目录下。用户可以直接链接使用这些库。

### 链接Live555库

在Makefile或CMake中添加Live555库链接：

```makefile
# Makefile示例
LDFLAGS += -lBasicUsageEnvironment -lUsageEnvironment -lgroupsock -lliveMedia
```

```cmake
# CMake示例
target_link_libraries(your_target
    BasicUsageEnvironment
    UsageEnvironment
    groupsock
    liveMedia
)
```

## 使用说明

### RTSP服务器基本流程

#### 1. 创建使用环境

```cpp
#include <BasicUsageEnvironment.hh>
#include <GroupsockHelper.hh>

TaskScheduler* scheduler = BasicTaskScheduler::createNew();
UsageEnvironment* env = BasicUsageEnvironment::createNew(*scheduler);
```

#### 2. 创建Server Media Session

```cpp
#include <OnDemandServerMediaSubsession.hh>
#include <H264VideoFileServerMediaSubsession.hh>

RTSPServer* rtspServer = RTSPServer::createNew(*env, 8554);
if (rtspServer == NULL) {
    *env << "Failed to create RTSP server: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 3. 添加媒体子会话

```cpp
char const* fileName = "test.264";
ServerMediaSession* sms = ServerMediaSession::createNew(*env, fileName, fileName, True);
sms->addSubsession(H264VideoFileServerMediaSubsession::createNew(*env, fileName, False));
rtspServer->addServerMediaSession(sms);
```

#### 4. 启动事件循环

```cpp
env->taskScheduler().doEventLoop();
```

### RTSP客户端基本流程

#### 1. 创建使用环境

```cpp
TaskScheduler* scheduler = BasicTaskScheduler::createNew();
UsageEnvironment* env = BasicUsageEnvironment::createNew(*scheduler);
```

#### 2. 创建RTSP客户端

```cpp
#include <RTSPClient.hh>

RTSPClient* rtspClient = RTSPClient::createNew(*env, "rtsp://example.com/video", 0, "k230_client");
if (rtspClient == NULL) {
    *env << "Failed to create RTSP client: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 3. 发送DESCRIBE命令

```cpp
MediaSession* session = MediaSession::createNew(*env, rtspClient->describeURL());
if (session == NULL) {
    *env << "Failed to create session: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 4. 设置RTP接收

```cpp
MediaSubsessionIterator* iter = session->setupSubsessionIterator();
MediaSubsession* subsession;
while ((subsession = iter->next()) != NULL) {
    if (!subsession->initiate()) {
        *env << "Failed to initiate subsession: " << subsession->codecName() << "\n";
    } else {
        // 设置RTP接收回调
        subsession->sink = createRTPSink(subsession);
        subsession->sink->startPlaying();
    }
}
```

#### 5. 启动事件循环

```cpp
env->taskScheduler().doEventLoop();
```

```{admonition} 提示
Live555的事件循环是阻塞的，需要在一个单独的线程中运行。有关 Live555 的详细API，请参考 [Live555官方文档](http://www.live555.com/liveMedia/)。
```

```{admonition} 提示
在K230平台上使用Live555进行流媒体传输时，可以与K230的硬件编解码器（VDEC/VENC）和媒体管道（MPP）配合使用，以实现高性能的流媒体应用。
```
