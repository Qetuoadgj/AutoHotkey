; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/MouseDisable.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force

#m:: ;Win + M hotkey
if (x != 1)
{
  BlockInput,MouseMove
  x := 1
  Hotkey,LButton,DoNothing
  Hotkey,RButton,DoNothing
  Hotkey,XButton1,DoNothing
  Hotkey,XButton2,DoNothing
  Return
}
if (x = 1)
  Reload

DoNothing:
  Return
