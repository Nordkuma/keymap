# ime
A CLI tool to switch IME on Windows via AutoHotkey.

## How it works
`ime` sends a `PostMessage` to the `IMEControllerAHK` window exposed by the [autohotkey scripts](../autohotkey/README.md).
The scripts then call the IMM32 API to switch the IME state of the currently focused window.

## Requirements
* WSL2 with MinGW-w64
* [autohotkey scripts](../autohotkey/README.md) running on Windows

## Install
1. Install MinGW-w64 (first time only)
   ```shell
   # Debian/Ubuntu
   sudo apt install mingw-w64
   ```
1. Build and install
   ```shell
   make install
   ```
1. To uninstall
   ```shell
   make uninstall
   ```

## Usage
```shell
ime on   # enable IME
ime off  # disable IME
```
