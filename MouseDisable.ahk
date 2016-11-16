; #NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; ; #Warn  ; Enable warnings to assist with detecting common errors.
; SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#m:: ;win + m hotkey
if (x != 1)
{
  BlockInput, MouseMove
  x := 1
  Hotkey, LButton, DoNothing
  Hotkey, RButton, DoNothing
  Hotkey, XButton1, DoNothing
  Hotkey, XButton2, DoNothing
    return
}
if (x = 1)
  reload

DoNothing:
return
