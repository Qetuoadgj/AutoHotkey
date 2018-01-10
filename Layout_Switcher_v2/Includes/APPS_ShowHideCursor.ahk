ScrollLock::
if (flag := !flag) {
   MouseGetPos, , , hwnd
   Gui Cursor:+Owner%hwnd%
   ; BlockInput MouseMove
   DllCall("ShowCursor", Int,0)
} else {
   ; BlockInput MouseMoveOff
   DllCall("ShowCursor", Int,1)
}
Return
