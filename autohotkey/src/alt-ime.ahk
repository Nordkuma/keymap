#Requires AutoHotkey v2.0

; Mask Alt keyup event
A_MenuMaskKey := 'vkE8'

; Create a hidden window for external IME control
global g_imcGui := Gui()
g_imcGui.Title := 'IMEControllerAHK'
g_imcGui.Show('Hide')
IMECTL_MSG := 0x8000 + 0x1  ; WM_APP + 0x1
DllCall("user32\ChangeWindowMessageFilterEx", "Ptr", g_imcGui.Hwnd, "UInt", IMECTL_MSG, "UInt", 1, "Ptr", 0)
OnMessage(IMECTL_MSG, IMECtlMessage)

; Set IME state
SetIME(on) {
    hwnd := WinExist('A')

    if !hwnd
        return

    ptr := A_PtrSize
    size := 24 + (ptr * 6)  ; 4 + 4 + (ptr * 6) + 16
    gti := Buffer(size, 0)

    NumPut('UInt', size, gti, 0)

    if DllCall('GetGUIThreadInfo', 'UInt', 0, 'Ptr', gti.Ptr) {
        hwndFocus := NumGet(gti, 8 + ptr, 'Ptr')
        if (hwndFocus)
            hwnd := hwndFocus
    }

    ime := DllCall('imm32\ImmGetDefaultIMEWnd', 'Ptr', hwnd, 'Ptr')

    if (ime)
        DllCall('SendMessage', 'Ptr', ime, 'UInt', 0x0283, 'Ptr', 0x0006, 'Ptr', on ? 1 : 0)
}

; Set IME state from command
IMECtlMessage(wParam, lParam, msg, hwnd) {
    switch wParam {
        case 0:
            SetIME(0)
        case 1:
            SetIME(1)
    }
}

; Alt keydown events
*LAlt:: {
    Send '{Blind}{LAlt down}{vkE8}'
}
*RAlt:: {
    Send '{Blind}{RAlt down}{vkE8}'
}

; Alt keyup events
*LAlt Up:: {
    Send '{Blind}{LAlt up}'
    if A_PriorHotkey == '*LAlt' && (A_PriorKey == 'LAlt' || A_PriorKey == '')
        SetIME(0)
}
*RAlt Up:: {
    Send '{Blind}{RAlt up}'
    if A_PriorHotkey == '*RAlt' && (A_PriorKey == 'RAlt' || A_PriorKey == '')
        SetIME(1)
}
