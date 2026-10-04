#Requires AutoHotkey v2.0

; JIS keyboard with the Windows keyboard layout set to English (101/102)
#HotIf IsJISLayout()
#InputLevel 1 ; Allow triggering other hotkeys
sc07D::Backspace ; "¥"
sc073::RShift ; "\"
AppsKey::RWin
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