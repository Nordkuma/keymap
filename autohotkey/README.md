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
Run `keymap.ahk` to start the script.
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

### Alt IME control
Tapping Alt switches the IME state.

| Key        | Action  |
| ---------- | ------- |
| `LAlt` tap | IME off |
| `RAlt` tap | IME on  |

On JIS keyboards, `Muhenkan` acts as `LAlt` and `Henkan` / `Kana` act as `RAlt` (see [JIS layout](#jis-layout)).

The script also accepts IME commands from the [`ime`](../ime/README.md) CLI tool via a hidden window.

### CapsLock layer
Hold CapsLock to activate a layer of shortcuts.

| Key                   | Action                    |
| --------------------- | ------------------------- |
| `` ` ``               | `` ` ``                   |
| `1`–`0`, `-`, `=`    | `F1`–`F12`               |
| `Backspace`           | `Del`                     |
| `H` / `J` / `K` / `L` | `←` / `↓` / `↑` / `→` |
| `Y` / `O`             | `Home` / `End`            |
| `U` / `I`             | `Ctrl+End` / `Ctrl+Home`  |
| `M` / `,`             | `PgDn` / `PgUp`           |
| `Space`               | `Esc`                     |
| Most other keys       | `Ctrl` + key              |

`` ` `` sends `Esc` outside the CapsLock layer.

### AppsKey layer
Hold `AppsKey` to control media, brightness and volume. `AppsKey` itself is disabled.

| Key       | Action                |
| --------- | --------------------- |
| `P` / `]` | Previous / next track |
| `[`       | Play / pause          |
| `;` / `'` | Brightness down / up  |
| `,`       | Mute                  |
| `.` / `/` | Volume down / up      |

### Device exclusion
When any keyboard in `excluded` is connected, all hotkey remapping is suspended automatically.
This is useful for keyboards with firmware-level remapping (e.g. QMK/VIA).

Use **Register Excluded Keyboard...** in the tray menu to detect and register a keyboard interactively.

> While suspended, the following keys are still handled:
> * `Shift` + `VK_IME_ON` is sent as plain `VK_IME_ON` so that the IME does not switch to katakana input mode.
> * Tapping `LAlt` / `RAlt` does not activate the window menu bar.

### Search selected text
Press `Win` + `Shift` + `Q` to look up the selected text.

| Selected text | Action                 |
| ------------- | ---------------------- |
| URL           | Open the URL           |
| Other text    | Search with DuckDuckGo |

The Edge window is activated afterwards. This keeps working while remapping is suspended by device exclusion.

## JIS layout
JIS keyboards are used as US keyboards.
Set the Windows hardware keyboard layout to **English keyboard (101/102 keys)** (Settings > Time & language > Language & region > Japanese > Options > Keyboard layout), reboot, then set `layout = "JIS"` in `config.toml`.

### Key remapping
With the English layout, every key types the character printed on a US keyboard at the same position, including shortcuts with modifiers.
The JIS-specific keys are remapped as follows:

| Key               | Action      |
| ----------------- | ----------- |
| `¥`               | `Backspace` |
| `\`               | `RShift`    |
| `Muhenkan`        | `LAlt`      |
| `Henkan` / `Kana` | `RAlt`      |
