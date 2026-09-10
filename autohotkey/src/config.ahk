#Requires AutoHotkey v2.0

global g_configPath := A_ScriptDir '\config.toml'
global g_layout := 'US'
global g_excludedIDs := []
global g_registerMode := false
global g_registerGui := 0

_Config_Init()

_Config_Init() {
    _RegisterRawInput()
    OnMessage(0x00FF, _OnRawInput)
    OnMessage(0x0219, _OnDeviceUpdate)
    A_TrayMenu.Add()
    A_TrayMenu.Add('Layout: US', _SetLayoutUS)
    A_TrayMenu.Add('Layout: JIS', _SetLayoutJIS)
    A_TrayMenu.Add('Register Excluded Keyboard...', _StartRegister)
    A_TrayMenu.Add('Show Connected Devices', (*) => ShowDevices())
    _LoadConfig()
    UpdateScriptState()
}

; -- Config (TOML) --

_LoadConfig() {
    global g_configPath, g_excludedIDs, g_layout
    g_excludedIDs := _ReadTomlStringArray(g_configPath, '', 'excluded')
    layout := StrUpper(_ReadTomlString(g_configPath, 'layout'))
    if layout = 'US' || layout = 'JIS'
        g_layout := layout
    else if layout != '' {
        g_layout := 'US'
        TrayTip 'Invalid layout "' layout '" in config.toml', 'Falling back to "US"', 16
    }
    _UpdateLayoutMenu()
}

_SaveConfig() {
    global g_configPath, g_excludedIDs, g_layout
    content := '# Keyboard configuration`n'
        . '# Add excluded keyboard IDs via tray menu > "Register Excluded Keyboard..."`n`n'
        . 'layout = "' g_layout '"  # "US" or "JIS"`n`n'
        . 'excluded = [`n'
    for id in g_excludedIDs
        content .= '    "' id '",`n'
    content .= ']`n'
    f := FileOpen(g_configPath, 'w', 'UTF-8')
    f.Write(content)
    f.Close()
}

_ReadTomlString(filePath, key) {
    if !FileExist(filePath)
        return ''
    loop read filePath {
        line := Trim(A_LoopReadLine)
        if line = '' || SubStr(line, 1, 1) = '#'
            continue
        if SubStr(line, 1, 1) = '['
            break
        if RegExMatch(line, '^' key '\s*=\s*"([^"]*)"', &m)
            return m[1]
    }
    return ''
}

_ReadTomlStringArray(filePath, section, key) {
    if !FileExist(filePath)
        return []
    ids := []
    inSection := (section = '')
    inArray := false
    loop read filePath {
        line := Trim(A_LoopReadLine)
        if line = '' || SubStr(line, 1, 1) = '#' || SubStr(line, 1, 1) = ';'
            continue
        if RegExMatch(line, '^\[(\w+)\]$', &m) {
            if section = ''
                break
            inSection := (m[1] = section)
            inArray := false
            continue
        }
        if !inSection
            continue
        if !inArray {
            if RegExMatch(line, '^' key '\s*=\s*\[(.*)', &m) {
                inArray := true
                rest := m[1]
                if InStr(rest, ']') {
                    _ExtractQuotedStrings(SubStr(rest, 1, InStr(rest, ']') - 1), ids)
                    inArray := false
                } else {
                    _ExtractQuotedStrings(rest, ids)
                }
            }
        } else {
            if InStr(line, ']') {
                _ExtractQuotedStrings(SubStr(line, 1, InStr(line, ']') - 1), ids)
                inArray := false
            } else {
                _ExtractQuotedStrings(line, ids)
            }
        }
    }
    return ids
}

_ExtractQuotedStrings(str, arr) {
    pos := 1
    while RegExMatch(str, '"([^"]*)"', &m, pos) {
        arr.Push(m[1])
        pos := m.Pos + m.Len
    }
}

; -- Raw Input --

_RegisterRawInput() {
    ridSize := 8 + A_PtrSize
    rid := Buffer(ridSize)
    NumPut('UShort', 0x01, rid, 0)  ; HID_USAGE_PAGE_GENERIC
    NumPut('UShort', 0x06, rid, 2)  ; HID_USAGE_KEYBOARD
    NumPut('UInt', 0x100, rid, 4)   ; RIDEV_INPUTSINK
    NumPut('Ptr', A_ScriptHwnd, rid, 8)
    DllCall('RegisterRawInputDevices', 'Ptr', rid.Ptr, 'UInt', 1, 'UInt', ridSize)
}

_GetKeyboardPath(hDevice) {
    DllCall('GetRawInputDeviceInfo', 'Ptr', hDevice, 'UInt', 0x20000007,
        'Ptr', 0, 'UInt*', &len := 0)
    if len = 0
        return ''
    buf := Buffer(len * 2)
    DllCall('GetRawInputDeviceInfo', 'Ptr', hDevice, 'UInt', 0x20000007,
        'Ptr', buf.Ptr, 'UInt*', &len)
    return StrGet(buf, 'UTF-16')
}

; -- Show devices --

ShowDevices() {
    global g_excludedIDs, g_configPath

    list := '[config]`n' g_configPath '`n`n'
    list .= '[excluded]`n'
    if g_excludedIDs.Length > 0 {
        for id in g_excludedIDs
            list .= id '`n'
    } else {
        list .= '(none)`n'
    }
    list .= '`n[devices]`n'
    for device in ComObjGet('winmgmts:').ExecQuery('Select * from Win32_PnPEntity')
        list .= device.PNPDeviceID '`n'

    g := Gui(, 'Devices')
    g.SetFont('s10', 'Consolas')
    g.MarginX := 15
    g.Add('Edit', 'w1000 h500 VScroll HScroll ReadOnly', list)
    g.Show()
}

; -- Hotkey state --

HasExcludedKeyboard() {
    global g_excludedIDs
    if g_excludedIDs.Length = 0
        return false
    for device in ComObjGet('winmgmts:').ExecQuery('Select * from Win32_PnPEntity')
        for id in g_excludedIDs
            if InStr(device.PNPDeviceID, id)
                return true
    return false
}

UpdateScriptState() {
    static lastState := True
    currentState := !HasExcludedKeyboard()
    if (currentState == lastState)
        return
    lastState := currentState
    if currentState {
        Suspend 0
        TrayTip 'Resumed keymap.ahk', 'Excluded keyboard disconnected', 16
    } else {
        Suspend 1
        TrayTip 'Suspended keymap.ahk', 'Excluded keyboard connected', 16
    }
}

_OnDeviceUpdate(Wparam, Lparam, Msg, Hwnd) {
    _LoadConfig()
    UpdateScriptState()
}

; -- Register excluded keyboard --

_OnRawInput(wParam, lParam, msg, hwnd) {
    global g_registerMode
    if !g_registerMode
        return
    headerSize := 8 + A_PtrSize * 2
    DllCall('GetRawInputData', 'Ptr', lParam, 'UInt', 0x10000003,
        'Ptr', 0, 'UInt*', &size := 0, 'UInt', headerSize)
    if size = 0
        return
    buf := Buffer(size)
    DllCall('GetRawInputData', 'Ptr', lParam, 'UInt', 0x10000003,
        'Ptr', buf.Ptr, 'UInt*', &size, 'UInt', headerSize)
    type := NumGet(buf, 0, 'UInt')
    if type != 1
        return
    flags := NumGet(buf, headerSize + 2, 'UShort')
    if !!(flags & 1)  ; RI_KEY_BREAK
        return
    hDevice := NumGet(buf, 8, 'Ptr')
    _HandleRegister(hDevice)
}

_StartRegister(*) {
    global g_registerMode, g_registerGui
    g_registerGui := Gui(, 'Register Excluded Keyboard')
    g_registerGui.Add('Text', 'w300 h40', 'Press any key on the keyboard to exclude...')
    g_registerGui.OnEvent('Close', _CancelRegister)
    g_registerGui.Show()
    g_registerMode := true
}

_CancelRegister(*) {
    global g_registerMode
    g_registerMode := false
}

_HandleRegister(hDevice) {
    global g_registerMode, g_registerGui, g_excludedIDs
    g_registerMode := false
    if IsObject(g_registerGui)
        g_registerGui.Destroy()

    path := _GetKeyboardPath(hDevice)

    ; Extract 4-digit VID and PID from the Raw Input path
    if !RegExMatch(path, 'i)VID[_&][0-9A-F]*([0-9A-F]{4}).*?PID[_&]([0-9A-F]{4})', &m) {
        MsgBox 'Could not extract keyboard ID:`n' path, 'Register Excluded Keyboard', 'Icon!'
        return
    }
    vid := m[1], pid := m[2]

    ; Find matching PNPDeviceIDs via WMI and extract the ID fragment to register
    candidates := []
    for device in ComObjGet('winmgmts:').ExecQuery('Select * from Win32_PnPEntity') {
        pnpID := device.PNPDeviceID
        if !RegExMatch(pnpID, 'i)VID[_&][0-9A-F]*' vid) || !RegExMatch(pnpID, 'i)PID[_&]' pid)
            continue
        if RegExMatch(pnpID, 'i)VID&[0-9A-F]{4,8}_PID&[0-9A-F]{4}_REV&[0-9A-F]{4}_[0-9A-F]{12}&COL01', &fm)
            extracted := fm[0]
        else if RegExMatch(pnpID, 'i)VID&[0-9A-F]{4,8}_PID&[0-9A-F]{4}&COL01', &fm)
            extracted := fm[0]
        else if RegExMatch(pnpID, 'i)VID_[0-9A-F]{4}&PID_[0-9A-F]{4}', &fm)
            extracted := fm[0]
        else
            continue
        isDup := false
        for id in candidates
            if id = extracted {
                isDup := true
                break
            }
        if !isDup
            candidates.Push(extracted)
    }

    if candidates.Length = 0 {
        MsgBox 'No matching keyboard found.`n`nPath: ' path, 'Register Excluded Keyboard', 'Icon!'
        return
    }

    detectedID := _SelectCandidate(candidates)
    if detectedID = ''
        return

    for id in g_excludedIDs
        if id = detectedID
            return  ; already registered

    g_excludedIDs.Push(detectedID)
    _SaveConfig()
    UpdateScriptState()
    MsgBox 'Saved. Excluded keyboard updated.', 'Register Excluded Keyboard'
}

_SelectCandidate(candidates) {
    if candidates.Length = 1 {
        if MsgBox('ID: ' candidates[1] '`n`nAdd to excluded?', 'Register Excluded Keyboard', 'YesNo') = 'Yes'
            return candidates[1]
        return ''
    }
    selected := ''
    g := Gui('+OwnDialogs', 'Register Excluded Keyboard')
    g.Add('Text', 'w700', 'Multiple IDs found. Select the one to register:')
    g.SetFont('s9', 'Consolas')
    lb := g.Add('ListBox', 'w700 r' Min(candidates.Length, 8) ' Choose1', candidates)
    g.SetFont()
    g.Add('Button', 'Default w80', 'OK').OnEvent('Click', (*) => (selected := lb.Text, g.Destroy()))
    g.Add('Button', 'w80', 'Cancel').OnEvent('Click', (*) => g.Destroy())
    g.Show()
    WinWaitClose('ahk_id ' g.Hwnd)
    return selected
}

; -- Layout --

_SetLayoutUS(*) {
    global g_layout
    g_layout := 'US'
    _SaveConfig()
    _UpdateLayoutMenu()
}

_SetLayoutJIS(*) {
    global g_layout
    g_layout := 'JIS'
    _SaveConfig()
    _UpdateLayoutMenu()
}

_UpdateLayoutMenu() {
    global g_layout
    if g_layout = 'US' {
        A_TrayMenu.Check('Layout: US')
        A_TrayMenu.Uncheck('Layout: JIS')
    } else {
        A_TrayMenu.Uncheck('Layout: US')
        A_TrayMenu.Check('Layout: JIS')
    }
}
