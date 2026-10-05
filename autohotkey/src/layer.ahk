#Requires AutoHotkey v2.0

SetCapsLockState 'AlwaysOff'

IsLayerActive(key) {
    return GetKeyState(key, 'P')
}

AdjustBrightness(step) {
    try {
        wmi := ComObjGet('winmgmts:\\.\root\WMI')
        for monitor in wmi.ExecQuery('SELECT CurrentBrightness FROM WmiMonitorBrightness WHERE Active=TRUE') {
            level := Max(0, Min(100, monitor.CurrentBrightness + step))
            for method in wmi.ExecQuery('SELECT * FROM WmiMonitorBrightnessMethods WHERE Active=TRUE')
                method.WmiSetBrightness(1, level)
            return
        }
    }
}

*CapsLock:: return
*AppsKey:: return

#HotIf !IsLayerActive('CapsLock')
`:: Send '{Esc}'
#HotIf

#HotIf IsLayerActive('CapsLock')
; Number row
1:: Send '{F1}'
2:: Send '{F2}'
3:: Send '{F3}'
4:: Send '{F4}'
5:: Send '{F5}'
6:: Send '{F6}'
7:: Send '{F7}'
8:: Send '{F8}'
9:: Send '{F9}'
0:: Send '{F10}'
-:: Send '{F11}'
=:: Send '{F12}'
BS:: Send '{Del}'
; Top row (QWERTY)
q:: Send '^q'
w:: Send '^w'
e:: Send '^e'
r:: Send '^r'
t:: Send '^t'
y:: Send '{Home}'
u:: Send '^{End}'
i:: Send '^{Home}'
o:: Send '{End}'
p:: Send '^p'
[:: Send '^['
]:: Send '^]'
; Home row (ASDF)
a:: Send '^a'
s:: Send '^s'
d:: Send '^d'
f:: Send '^f'
g:: Send '^g'
h:: Send '{Left}'
j:: Send '{Down}'
k:: Send '{Up}'
l:: Send '{Right}'
Enter:: Send '^{Enter}'
; Bottom row (ZXCV)
z:: Send '^z'
x:: Send '^x'
c:: Send '^c'
v:: Send '^v'
b:: Send '^b'
n:: Send '^n'
m:: Send '{PgDn}'
,:: Send '{PgUp}'
/:: Send '^/'
; Space row
Space:: Send '{Esc}'
#HotIf

#HotIf IsLayerActive('AppsKey')
; Top row (QWERTY)
p:: Send '{Media_Prev}'
[:: Send '{Media_Play_Pause}'
]:: Send '{Media_Next}'
; Home row (ASDF)
`;:: AdjustBrightness(-10)
':: AdjustBrightness(10)
; Bottom row (ZXCV)
,:: Send '{Volume_Mute}'
.:: Send '{Volume_Down}'
/:: Send '{Volume_Up}'
#HotIf
