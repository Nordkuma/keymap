#Requires AutoHotkey v2.0

#HotIf IsUSLayout() && !IsLayerActive()
`:: Send '{Esc}'
#HotIf

#HotIf IsUSLayout() && IsLayerActive()
`:: SendText '``'
#HotIf