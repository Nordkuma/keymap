#Requires AutoHotkey v2.0

SetCapsLockState 'AlwaysOff'

IsLayerActive() {
    global g_layout
    return (g_layout = 'US' && GetKeyState('CapsLock', 'P'))
    || (g_layout = 'JIS' && GetKeyState('F24', 'P'))
}

IsUSLayout() {
    global g_layout
    return g_layout = 'US'
}

IsJISLayout() {
    global g_layout
    return g_layout = 'JIS'
}

IsUSLayerActive() {
    global g_layout
    return g_layout = 'US' && GetKeyState('CapsLock', 'P')
}

IsJISLayerActive() {
    global g_layout
    return g_layout = 'JIS' && GetKeyState('F24', 'P')
}

; CapsLock keydown event
CapsLock:: return

#HotIf IsJISLayout()
; F24 keydown event
F24:: return
#HotIf

#HotIf IsUSLayerActive()
; Backquote keydown event of CapsLock layer
`:: SendText '``'
#HotIf

#HotIf IsUSLayout()
; Backquote keydown event
`:: Send '{Escape}'
#HotIf

; CapsLock layer
#HotIf IsLayerActive()
; 5th row
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
BackSpace:: Send '{Delete}'
; 4th row
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
; 3rd row
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
; 2nd row
z:: Send '^z'
x:: Send '^x'
c:: Send '^c'
v:: Send '^v'
b:: Send '^b'
n:: Send '^n'
m:: Send '{PgDn}'
,:: Send '{PgUp}'
/:: Send '^/'
; 1st row
Space:: Send '{Escape}'
#HotIf