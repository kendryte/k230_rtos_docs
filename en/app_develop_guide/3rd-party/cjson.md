# cJSON Example

## Introduction

This example demonstrates the use of cJSON on the K230 RT-Smart platform. cJSON is an ultra-lightweight, portable ANSI C JSON parser consisting of only two files, `cJSON.c` and `cJSON.h`, making it well suited for embedded environments.

## Feature Description

cJSON provides complete JSON parsing and generation capabilities:

- **JSON Parsing**: Supports parsing JSON data from strings or files
- **JSON Generation**: Supports building JSON objects and outputting them as formatted strings
- **Object Operations**: Supports adding, deleting, modifying, and querying various JSON types, including arrays, objects, strings, numbers, and booleans
- **Preallocated Printing**: Supports printing with preallocated buffers to reduce memory fragmentation
- **Memory Management**: Provides a hook mechanism that allows users to customize memory allocators

### Example Features

The example runs the complete official cJSON test suite, covering the following scenarios:

- Creation and parsing of JSON objects and arrays
- Handling of strings, numbers, booleans, and null
- Construction and traversal of nested structures
- Formatted and unformatted printing
- Printing with preallocated buffers
- Error handling and boundary condition tests
- Performance testing (optional)

## Code Location

- Library source: `src/rtsmart/libs/3rd-party/cjson/cJSON/`
- Sample source: `src/rtsmart/examples/3rd-party/cjson/cjson_basic/`

## Usage Instructions

### Compilation Method

#### Firmware Compilation

At the root directory of the `K230 RTOS SDK`, use `make menuconfig` to configure the compilation options:

1. Enter `RT-Smart 3rd-party Configuration` → enable `Enable Build cJSON`
2. Enter the sample configuration → enable `Enable Build cJSON Sample Programs`

Then compile the firmware.

#### Standalone Compilation

Enter the cJSON sample directory and use the Makefile for compilation:

```shell
cd src/rtsmart/examples/3rd-party/cjson/cjson_basic
make
```

After successful compilation, the executable file will be generated.

### Running Example

Copy the compiled executable to the development board, enter the directory where it is stored, and run:

```shell
./test_cjson
```

### Viewing Results

After the program runs, it will execute the complete cJSON test suite and output something similar to the following:

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

### Common API Examples

```c
#include "cJSON.h"

// Parse a JSON string
const char *json_str = "{\"name\":\"K230\",\"version\":1}";
cJSON *root = cJSON_Parse(json_str);
if (root == NULL) {
    const char *err = cJSON_GetErrorPtr();
    printf("Parse error at: %s\n", err);
}

// Read a field
cJSON *name = cJSON_GetObjectItem(root, "name");
if (cJSON_IsString(name)) {
    printf("name: %s\n", name->valuestring);
}
cJSON *ver = cJSON_GetObjectItem(root, "version");
if (cJSON_IsNumber(ver)) {
    printf("version: %d\n", ver->valueint);
}

// Build a JSON object
cJSON *new_obj = cJSON_CreateObject();
cJSON_AddStringToObject(new_obj, "device", "K230");
cJSON_AddNumberToObject(new_obj, "uptime", 3600);
char *output = cJSON_Print(new_obj);
printf("%s\n", output);

// Free
cJSON_Delete(root);
cJSON_Delete(new_obj);
free(output);
```

## Configuration Description

| Kconfig Option | Description |
| :-- | :-- |
| `RTSMART_3RD_PARTY_ENABLE_CJSON` | Compile the cJSON library (`libcjson.a`) |

## Dependencies

- cJSON has no external dependencies and can be used independently
- libpeer depends on cJSON: `RTSMART_3RD_PARTY_ENABLE_LIBPEER` automatically selects cJSON

```{admonition} Tip
cJSON provides only a single `.c` and `.h` file, and the source code can be directly copied into any C project. For detailed information about the cJSON API and best practices, please refer to [cJSON GitHub](https://github.com/DaveGamble/cJSON).
```
