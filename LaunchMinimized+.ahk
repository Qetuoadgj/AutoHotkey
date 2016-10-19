; https://github.com/Qetuoadgj/AutoHotkey

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode,Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]
Process,Priority,,High
DetectHiddenWindows,Off

NumberOfParameters = %0%
Repetitions = 3
Delays = 50

If (not NumberOfParameters) {
  ExePath = "notepad.exe" /W
} else {
  Loop,%NumberOfParameters%
  {
    Parameter := %A_Index%
    ExePath = %ExePath% %Parameter%
  }
}

Run,%ExePath%,,Min,WinPID

WinWait,ahk_pid %WinPID%
WinGet,WinID,ID
WinTitle = ahk_id %WinID%

SetWinDelay,-1

WinMinimize,%WinTitle%
Loop,%Repetitions%
{
  Sleep,%Delays%
  WinMinimize,%WinTitle%
}

If (not NumberOfParameters) {
  text = Example:`n"%A_ScriptFullPath%" %ExePath%
  ControlSendRaw,,%text%,%WinTitle%
}

/*
MESSAGE =
( LTrim RTrim
  %ExePath%
  %WinPID%
  %WinID%
  %WinTitle%
)

MsgBox,0,,%MESSAGE%,1.0
*/
