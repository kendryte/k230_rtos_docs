# Live555

## Introduction

Live555 is an open-source multimedia streaming library that supports RTP/RTCP protocols and is widely used in streaming media application development. The K230 RTOS SDK integrates the Live555 library, supporting streaming media transmission on the K230 platform.

## Feature Description

### Live555 Features

Live555 provides a complete streaming media framework:

- **RTP/RTCP Protocol**: Real-time Transport Protocol and Real-time Control Protocol
- **RTSP Protocol**: Real Time Streaming Protocol
- **SIP Protocol**: Session Initiation Protocol (partial support)
- **Multiple Codecs**: Supports H.264, H.265, AAC, and other codecs
- **Cross-platform**: Supports multiple operating systems

### Main Components

Live555 includes the following main components:

- **UsageEnvironment**: Usage environment, providing basic task scheduling and event handling
- **BasicUsageEnvironment**: Basic usage environment implementation
- **liveMedia**: Media processing library
- **groupsock**: Multicast and unicast network handling
- **BasicUsageEnvironment**: Basic environment implementation

## Application Scenarios

On the K230 platform, Live555 can be used for:

- **RTSP Server**: Implements a streaming media server, `/src/rtsmart/mpp/middleware/src/rtsp_server` is the RTSP server interface encapsulated using live555, and `/src/rtsmart/examples/mpp/sample_rtspserver` is the corresponding demo
- **RTSP Client**: Implements a streaming media client, `/src/rtsmart/mpp/middleware/src/rtsp_client` is the RTSP client interface encapsulated using live555, and `/src/rtsmart/examples/mpp/sample_rtspclient` is the corresponding demo

## Build Instructions

### Live555 Library Integration

The K230 RTOS SDK has pre-built Live555 libraries, located in the library directory of the SDK. Users can directly link and use these libraries.

### Linking the Live555 Library

Add Live555 library linking in Makefile or CMake:

```makefile
# Makefile example
LDFLAGS += -lBasicUsageEnvironment -lUsageEnvironment -lgroupsock -lliveMedia
```

```cmake
# CMake example
target_link_libraries(your_target
    BasicUsageEnvironment
    UsageEnvironment
    groupsock
    liveMedia
)
```

## Usage Instructions

### RTSP Server Basic Flow

#### 1. Create Usage Environment

```cpp
#include <BasicUsageEnvironment.hh>
#include <GroupsockHelper.hh>

TaskScheduler* scheduler = BasicTaskScheduler::createNew();
UsageEnvironment* env = BasicUsageEnvironment::createNew(*scheduler);
```

#### 2. Create Server Media Session

```cpp
#include <OnDemandServerMediaSubsession.hh>
#include <H264VideoFileServerMediaSubsession.hh>

RTSPServer* rtspServer = RTSPServer::createNew(*env, 8554);
if (rtspServer == NULL) {
    *env << "Failed to create RTSP server: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 3. Add Media Subsession

```cpp
char const* fileName = "test.264";
ServerMediaSession* sms = ServerMediaSession::createNew(*env, fileName, fileName, True);
sms->addSubsession(H264VideoFileServerMediaSubsession::createNew(*env, fileName, False));
rtspServer->addServerMediaSession(sms);
```

#### 4. Start Event Loop

```cpp
env->taskScheduler().doEventLoop();
```

### RTSP Client Basic Flow

#### 1. Create the Usage Environment

```cpp
TaskScheduler* scheduler = BasicTaskScheduler::createNew();
UsageEnvironment* env = BasicUsageEnvironment::createNew(*scheduler);
```

#### 2. Create the RTSP Client

```cpp
#include <RTSPClient.hh>

RTSPClient* rtspClient = RTSPClient::createNew(*env, "rtsp://example.com/video", 0, "k230_client");
if (rtspClient == NULL) {
    *env << "Failed to create RTSP client: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 3. Send DESCRIBE Command

```cpp
MediaSession* session = MediaSession::createNew(*env, rtspClient->describeURL());
if (session == NULL) {
    *env << "Failed to create session: " << env->getResultMsg() << "\n";
    exit(1);
}
```

#### 4. Set Up RTP Reception

```cpp
MediaSubsessionIterator* iter = session->setupSubsessionIterator();
MediaSubsession* subsession;
while ((subsession = iter->next()) != NULL) {
    if (!subsession->initiate()) {
        *env << "Failed to initiate subsession: " << subsession->codecName() << "\n";
    } else {
        // Set up RTP reception callback
        subsession->sink = createRTPSink(subsession);
        subsession->sink->startPlaying();
    }
}
```

#### 5. Start the Event Loop

```cpp
env->taskScheduler().doEventLoop();
```

```{admonition} Tip
The Live555 event loop is blocking and needs to run in a separate thread. For detailed API documentation of Live555, please refer to the [Live555 official documentation](http://www.live555.com/liveMedia/).
```

```{admonition} Tip
When using Live555 for streaming media transmission on the K230 platform, it can be used in conjunction with the K230's hardware codecs (VDEC/VENC) and the Media Processing Platform (MPP) to achieve high-performance streaming media applications.
```
