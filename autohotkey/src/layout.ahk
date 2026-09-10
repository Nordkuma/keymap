#Requires AutoHotkey v2.0

SetCapsLockState 'AlwaysOff'

IsUSLayout() {
    global g_layout
    return g_layout = 'US'
}

IsJISLayout() {
    global g_layout
    return g_layout = 'JIS'
}

IsLayerActive() {
    return GetKeyState('CapsLock', 'P') || GetKeyState('F24', 'P')
}

; Swallow the layer key itself
CapsLock:: return
F24:: return