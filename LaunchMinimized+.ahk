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
PrintMessage := false

If (not NumberOfParameters) {
  ExePath = "notepad.exe" /W
} else {
  ExePath = %1%
  Loop,%NumberOfParameters%
  {
    IfEqual,A_Index,1,Continue
    Parameter := %A_Index%

    If RegExMatch(Parameter,"i)" . "--Minimize-Delays=(\d+)",DelaysMatch,1) {
      Delays := DelaysMatch1
      Continue
    }
    If RegExMatch(Parameter,"i)" . "--Minimize-Time=(\d+)",TimeMatch,1) {
      MaxTimeToTry := TimeMatch1
      Continue
    }

    If RegExMatch(Parameter,"i)" . "--Minimize-Msg=(\d+)",MsgMatch,1) {
      PrintMessage := MsgMatch1
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
  PrintMessage := 2

  SavedClipboard := Clipboardall
  Clipboard = ; Empty the clipboard.

  HelpText =
  ( LTrim RTrim Join`r`n ; or perhaps just `n for your app)
    Example:
    %A_Space%%A_Space%"%A_ScriptFullPath%" %ExePath% --Minimize-Time=%MaxTimeToTry% --Minimize-Delays=%Delays% --Minimize-Msg=%PrintMessage%

    --Minimize-Time=%MaxTimeToTry% - max time given for minimization tries (%MaxTimeToTry% msec)
    %A_Space%%A_Space%min = 0,%A_Space%default = 3000 msec.

    --Minimize-Delays=%Delays% - delay between window minimization tries (%Delays% msec)
    %A_Space%%A_Space%min = 10 msec,%A_Space%default = 100 msec.

    --Minimize-Msg=%PrintMessage% - print debug messages on screen (%PrintMessage%)
    %A_Space%%A_Space%0 - off,%A_Space%1 - done,%A_Space%2 - all,%A_Space%default = 0.
  )

  Clipboard = %HelpText%
  ClipWait,0.5

  ; SetKeyDelay,1,1
  ; ControlSend,,% Clipboard,%WinTitle%
  WinActivateBottom,%WinTitle%
  ; ControlSendRaw,,% Clipboard,%WinTitle%
  ControlSend,,^v,%WinTitle%

  Clipboard = ; Empty the clipboard.
  Clipboard := SavedClipboard
  ClipWait,0.5
}

If (PrintMessage=1 or PrintMessage=2) {
  MsgBox,0,,Done!,0.5
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
