#Requires AutoHotkey v2.0

#HotIf IsUSLayout() && !IsLayerActive()
sc029:: Send '{Esc}' ; "`" (US)
#HotIf