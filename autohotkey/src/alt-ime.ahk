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

; Press Alt
AltDown(alt) {
    Send '{Blind}{' alt ' down}{vkE8}'
}

; Release Alt and set IME state on tap
AltUp(key, alt, ime) {
    Send '{Blind}{' alt ' up}'
    if A_PriorHotkey = '*' key && (A_PriorKey = GetKeyName(key) || A_PriorKey == '')
        SetIME(ime)
}

; Alt keydown events
*LAlt:: AltDown('LAlt')
*RAlt:: AltDown('RAlt')

; Alt keyup events
*LAlt Up:: AltUp('LAlt', 'LAlt', 0)
*RAlt Up:: AltUp('RAlt', 'RAlt', 1)

; Suppress katakana mode while suspended
#SuspendExempt
#HotIf A_IsSuspended
+vk16:: Send '{vk16}' ; Shift + VK_IME_ON
#HotIf
#SuspendExempt False
