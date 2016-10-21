; https://github.com/Qetuoadgj/AutoHotkey

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode,Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]
Process,Priority,,High
DetectHiddenWindows,Off

NumberOfParameters = %0%

Delays := 100 ; --minimize-delays=Integer
MaxTimeToTry := 3000 ; --minimize-time=Integer

If (not NumberOfParameters) {
  ExePath = "notepad.exe" /W
} else {
  ExePath = %1%
  Loop,%NumberOfParameters%
  {
    IfEqual,A_Index,1,Continue
    Parameter := %A_Index%

    If RegExMatch(Parameter,"i)" . "--minimize-delays=(\d+)",DelaysMatch,1) {
      Delays := DelaysMatch1
      Continue
    }
    If RegExMatch(Parameter,"i)" . "--minimize-time=(\d+)",TimeMatch,1) {
      MaxTimeToTry := TimeMatch1
      Continue
    }

    Parameters = %Parameters% %Parameter%
  }
  ExePath = %ExePath% %Parameters%
}

Delays := (Delays < 10) ? 10 : Delays ; Normalize
Repetitions := floor(MaxTimeToTry / Delays)

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
  ExampleText = Example:`n"%A_ScriptFullPath%" %ExePath% --Minimize-Delays=%Delays% --Minimize-Time=%MaxTimeToTry%
  ControlSendRaw,,%ExampleText%,%WinTitle%
}

/*
MESSAGE =
( LTrim RTrim
  %ExePath%
  %WinPID%
  %WinID%
  %WinTitle%
  %Repetitions%
)

MsgBox,0,,%MESSAGE%,1.0
*/
