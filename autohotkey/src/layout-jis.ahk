#Requires AutoHotkey v2.0

#HotIf IsJISLayout()
sc029:: Send '{Esc}' ; "Hankaku / Zenkaku" (JIS)
#HotIf