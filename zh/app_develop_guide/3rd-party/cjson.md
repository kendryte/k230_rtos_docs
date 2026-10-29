# cJSON 示例

## 简介

本示例展示 cJSON 在 K230 RT-Smart 平台上的使用。cJSON 是一个超轻量级、可移植的 ANSI C JSON 解析器，仅由 `cJSON.c` 和 `cJSON.h` 两个文件构成，非常适合嵌入式环境。

## 功能说明

cJSON 提供完整的 JSON 解析与生成能力：

- **JSON 解析**：支持从字符串或文件解析 JSON 数据
- **JSON 生成**：支持构建 JSON 对象并输出为格式化字符串
- **对象操作**：支持数组、对象、字符串、数值、布尔等多种 JSON 类型的增删改查
- **预分配打印**：支持预分配缓冲区打印，减少内存碎片
- **内存管理**：提供挂钩（hook）机制，允许用户自定义内存分配器

### 示例功能

示例运行 cJSON 官方自带的完整测试套件，覆盖以下场景：

- JSON 对象与数组的创建和解析
- 字符串、数值、布尔值、null 的处理
- 嵌套结构的构建与遍历
- 格式化与非格式化打印
- 预分配缓冲区的打印
- 错误处理与边界条件测试
- 性能测试（可选）

## 代码位置

- 库源码：`src/rtsmart/libs/3rd-party/cjson/cJSON/`
- 示例源码：`src/rtsmart/examples/3rd-party/cjson/cjson_basic/`

## 使用说明

### 编译方法

#### 固件编译

在 `K230 RTOS SDK` 根目录下使用 `make menuconfig` 配置编译选项：

1. 进入 `RT-Smart 3rd-party Configuration` → 使能 `Enable Build cJSON`
2. 进入示例配置 → 使能 `Enable Build cJSON Sample Programs`

然后编译固件。

#### 独立编译

进入 cJSON 示例目录，使用 Makefile 进行编译：

```shell
cd src/rtsmart/examples/3rd-party/cjson/cjson_basic
make
```

编译成功后会生成可执行文件。

### 运行示例

将编译好的可执行文件拷贝到开发板，进入存放目录后运行：

```shell
./test_cjson
```

### 查看结果

程序运行后会执行 cJSON 完整测试套件，输出类似如下：

```text
cJSON Test Suite
================

Testing cJSON_Version()
[PASS] version check

Testing print_preallocated
[PASS] preallocated print matches normal print

Testing object creation and manipulation
[PASS] object add
[PASS] object replace
[PASS] array size
[PASS] parse number

...

===== Test Summary =====
Passed: XX
Failed:  0
=======================
All tests passed!
```

### 常用 API 示例

```c
#include "cJSON.h"

// 解析 JSON 字符串
const char *json_str = "{\"name\":\"K230\",\"version\":1}";
cJSON *root = cJSON_Parse(json_str);
if (root == NULL) {
    const char *err = cJSON_GetErrorPtr();
    printf("Parse error at: %s\n", err);
}

// 读取字段
cJSON *name = cJSON_GetObjectItem(root, "name");
if (cJSON_IsString(name)) {
    printf("name: %s\n", name->valuestring);
}
cJSON *ver = cJSON_GetObjectItem(root, "version");
if (cJSON_IsNumber(ver)) {
    printf("version: %d\n", ver->valueint);
}

// 构建 JSON 对象
cJSON *new_obj = cJSON_CreateObject();
cJSON_AddStringToObject(new_obj, "device", "K230");
cJSON_AddNumberToObject(new_obj, "uptime", 3600);
char *output = cJSON_Print(new_obj);
printf("%s\n", output);

// 释放
cJSON_Delete(root);
cJSON_Delete(new_obj);
free(output);
```

## 配置说明

| Kconfig 选项 | 说明 |
| :-- | :-- |
| `RTSMART_3RD_PARTY_ENABLE_CJSON` | 编译 cJSON 库 (`libcjson.a`) |

## 依赖关系

- cJSON 无外部依赖，可独立使用
- libpeer 依赖 cJSON：`RTSMART_3RD_PARTY_ENABLE_LIBPEER` 会自动选中 cJSON

```{admonition} 提示
cJSON 只提供单个 `.c` 和 `.h` 文件，可以直接将源码拷贝到任何 C 工程中使用。有关 cJSON 的详细 API 与最佳实践，请参考 [cJSON GitHub](https://github.com/DaveGamble/cJSON)。
```
