#Requires AutoHotkey v2.0

IsUSLayout() {
    global g_layout
    return g_layout = 'US'
}

IsJISLayout() {
    global g_layout
    return g_layout = 'JIS'
}

#HotIf IsJISLayout()
#InputLevel 1
sc07D::BS ; "¥"
sc073::RShift ; "\"
#InputLevel 0
; "Muhenkan"
*sc07B:: AltDown('LAlt')
*sc07B Up:: AltUp('sc07B', 'LAlt', 0)
; "Henkan"
*sc079:: AltDown('RAlt')
*sc079 Up:: AltUp('sc079', 'RAlt', 1)
; "Kana"
*sc070:: AltDown('RAlt')
*sc070 Up:: AltUp('sc070', 'RAlt', 1)
#HotIf

#HotIf IsJISLayout() && IsLayerActive('CapsLock')
sc07D:: Send '{Del}' ; "¥"
#HotIf
