# 触摸屏示例

## 简介

本示例基于 RT-Smart 触摸 HAL 演示触摸设备读点流程，包含两种模式：

- 使用已存在触摸设备进行读点测试
- 通过配置参数动态创建设备后进行读点测试

示例源码：`src/rtsmart/examples/peripheral/touch/test_touch.c`

## 示例能力

- 读取并打印触摸点事件（`DOWN`/`MOVE`/`UP`）
- 支持多点触控数据读取（示例缓冲区上限 5 点）
- 打印设备能力信息（最大触点数、坐标范围等）
- 打印当前触摸配置与默认旋转信息
- 支持 Ctrl+C 安全退出，并自动释放资源

## 关键接口（对应实际代码）

- `drv_touch_inst_create()`：创建触摸实例
- `drv_touch_read()`：读取触摸点数据
- `drv_touch_get_info()`：查询设备信息
- `drv_touch_get_config()`：读取设备配置
- `drv_touch_get_default_rotate()`：读取默认旋转
- `drv_touch_inst_destroy()`：销毁实例
- `canmv_misc_create_touch_device()`：动态注册触摸设备
- `canmv_misc_delete_touch_device()`：删除动态注册设备

## 编译与运行

### 编译

在 SDK 根目录启用对应示例后编译，或独立编译：

```shell
cd src/rtsmart/examples/peripheral/touch
make
```

### 运行模式 1：测试已有设备

```shell
./test_touch -d 0
```

### 运行模式 2：动态创建设备后测试

```shell
./test_touch -c --index 1 --range-x 480 --range-y 800 --int-pin 23 --int-value 1 --reset-pin 22 --reset-value 0 --i2c-bus 3 --i2c-speed 400000
```

说明：示例退出时会自动尝试注销通过 `-c` 创建的触摸设备。

## 常用参数

| 参数 | 说明 |
| --- | --- |
| `-d, --device` | 使用已有触摸设备 ID（默认 `0`） |
| `-c, --create` | 按后续参数动态创建触摸设备 |
| `--index` | 新设备索引 |
| `--range-x`, `--range-y` | 坐标范围 |
| `--int-pin`, `--int-value` | 中断引脚与有效电平 |
| `--reset-pin`, `--reset-value` | 复位引脚与有效电平 |
| `--i2c-bus`, `--i2c-speed` | I2C 总线号与速率 |

## 输出解读

示例会打印：

- 设备基础信息：类型、厂商、最大触点数、坐标范围
- 当前配置：I2C、引脚、显示范围等
- 触点明细：`event`、`track_id`、`x/y`、`width`、`timestamp`

当无事件时，示例会周期性输出 `.`，表示循环正常但当前无触摸数据。

```{admonition} 提示
触摸输入通常依赖 I2C + GPIO（中断/复位）。建议先确认引脚复用与电平配置，再进行触摸读点测试。完整接口和调用顺序请参考 [Touch API 文档](../../api_reference/peripheral/touch.md)。
```
