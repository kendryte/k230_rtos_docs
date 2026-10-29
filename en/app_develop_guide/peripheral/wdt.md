# WDT Example

## Introduction

This example demonstrates the basic watchdog flow: setting timeout, starting, periodic feeding, and stopping or keeping running on exit.

Source location: `src/rtsmart/examples/peripheral/wdt/test_wdt.c`

## Example Behavior

- Set timeout duration (1~60 seconds)
- Start WDT and periodically call `wdt_feed()`
- On Ctrl+C exit:
  - By default, execute `wdt_stop()`
  - If `--no-stop` is passed, only feed the dog before exit without stopping

## Key Interfaces

- `wdt_set_timeout()` / `wdt_get_timeout()`
- `wdt_start()` / `wdt_stop()`
- `wdt_feed()`

## Build and Run

```shell
cd src/rtsmart/examples/peripheral/wdt
make
```

Run:

```shell
./test_wdt <timeout_sec> [--no-stop]
```

Example:

```shell
./test_wdt 5
./test_wdt 10 --no-stop
```

```{admonition} Tip
For WDT interface details, please refer to the [WDT API Documentation](../../api_reference/peripheral/wdt.md).
```
