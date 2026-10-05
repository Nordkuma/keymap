#Requires AutoHotkey v2.0

; Get selected text
GetSelected() {
    backup := ClipboardAll()

    A_Clipboard := ''

    Send '^c'

    if !ClipWait(2, 0) {
        A_Clipboard := backup
        return ''
    }

    text := A_Clipboard
    A_Clipboard := backup

    return text
}

; Check if text is a URL with schemes
IsURLWithSchemes(text) {
    return !!RegExMatch(text, 'i)^(?:https?|ftp)://\S+$')
}

; Encode text to URL-encoded format
URLEncode(text) {
    encoded := ''
    for ch in StrSplit(text) {
        code := Ord(ch)
        if (code >= 0x30 && code <= 0x39) || (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)  ; 0-9A-Za-z
        || (ch = '-') || (ch = '_') || (ch = '.') || (ch = '~') {
            encoded .= ch
        } else {
            len := StrPut(ch, 'UTF-8')
            buf := Buffer(len)
            DllCall('WideCharToMultiByte', 'UInt', 65001, 'UInt', 0, 'Str', ch, 'Int', -1, 'Ptr', buf, 'Int', len,
                'Ptr', 0, 'Ptr', 0)
            loop len {
                b := NumGet(buf, A_Index - 1, 'UChar')
                if (b = 0)
                    break
                encoded .= Format('%{1:02X}', b)
            }
        }
    }
    return encoded
}

; Open URL or search with DuckDuckGo, then activate the Edge window
SearchSelected() {
    text := Trim(GetSelected())

    if (text == '')
        return

    if (IsURLWithSchemes(text)) {
        Run text
    } else {
        Run Format('https://duckduckgo.com/?q={1}&ia=web', URLEncode(text))
    }

    Sleep 500
    WinActivate 'ahk_exe msedge.exe'
}

#SuspendExempt
#+q:: SearchSelected()
#SuspendExempt False
