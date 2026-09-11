# autohotkey
AutoHotkey scripts that remap keys.

## Requirements
* Windows 10/11
* [AutoHotkey v2](https://www.autohotkey.com/)

## Install
Run from WSL:
```shell
./install.sh   # copies scripts to %USERPROFILE%\AutoHotkey
```
Or on Windows:
```bat
install.bat
```

`config.toml` is copied only if it does not already exist, to preserve your settings.

## Usage
Run `launcher.ahk` to start all scripts.
Running as administrator is recommended to ensure hotkeys work in elevated windows.

Right-click the tray icon to access the following options:

| Menu item                     | Description                                            |
| ----------------------------- | ------------------------------------------------------ |
| Layout: US / Layout: JIS      | Switch the active keyboard layout                      |
| Register Excluded Keyboard... | Press any key on a keyboard to register it as excluded |
| Show Connected Devices        | List all connected devices                             |

## Configuration
Settings are stored in `config.toml` in `%USERPROFILE%\AutoHotkey`:

```toml
layout = "US"  # "US" or "JIS"
excluded = [
    # "VID_XXXX&PID_XXXX",
]
```

| Key        | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| `layout`   | Keyboard layout. Affects layout-specific hotkeys.              |
| `excluded` | Device IDs of keyboards that suspend remapping when connected. |

## Features

### Esc key
The key to the left of `1` sends `Esc`.

| Layout | Key                 | Action                             |
| ------ | ------------------- | ---------------------------------- |
| US     | `` ` ``             | `Esc` (outside the CapsLock layer) |
| JIS    | `Hankaku / Zenkaku` | `Esc` (always)                     |

### CapsLock layer
Hold CapsLock to activate a layer of shortcuts.

| Key                                 | Action                    |
| ----------------------------------- | ------------------------- |
| `` ` `` (US)                        | `` ` ``                   |
| `1`–`0`, `-`, `=` (US) / `^` (JIS) | `F1`–`F12`               |
| `Backspace`                         | `Del`                     |
| `H` / `J` / `K` / `L`               | `←` / `↓` / `↑` / `→` |
| `Y` / `O`                           | `Home` / `End`            |
| `U` / `I`                           | `Ctrl+End` / `Ctrl+Home`  |
| `M` / `,`                           | `PgDn` / `PgUp`           |
| `Space`                             | `Esc`                     |
| Most other keys                     | `Ctrl` + key              |

### Alt IME control
Tapping Alt switches the IME state.

| Key        | Action  |
| ---------- | ------- |
| `LAlt` tap | IME off |
| `RAlt` tap | IME on  |

The script also accepts IME commands from the [`ime`](../ime/README.md) CLI tool via a hidden window.

### Device exclusion
When any keyboard in `excluded` is connected, all hotkey remapping is suspended automatically.
This is useful for keyboards with firmware-level remapping (e.g. QMK/VIA).

Use **Register Excluded Keyboard...** in the tray menu to detect and register a keyboard interactively.

## JIS layout
On JIS keyboards, CapsLock may not work correctly as a layer key.
As a workaround, remap CapsLock to F24 at the OS level using the registry files in [reg/](reg/):

* `reg/set-scancode-map.reg`: Remaps CapsLock to F24
* `reg/remove-scancode-map.reg`: Reverts the remapping

Apply the `.reg` file and reboot, then set `layout = "JIS"` in `config.toml`.

> **Note:** Modifying the registry is done at your own risk. Back up the registry before applying.
