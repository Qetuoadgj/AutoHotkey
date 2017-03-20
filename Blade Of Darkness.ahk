#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Force ; [force|ignore|off]
#Persistent
Process,Priority,,High
DetectHiddenWindows,On

IfNotExist,Bin\Blade.exe
{
  SoundPlay, *16
  MsgBox,0,Error,Check application working dir.,5.0
  ExitApp
}

ForceSingleInstance()

If (not A_IsAdmin) {
  Try
  {
    Run,*RunAs "%A_ScriptFullPath%"
  } Catch {
    ; MsgBox,You cancelled when asked to elevate to admin!
  }
  ExitApp
}

PID := DllCall("GetCurrentProcessId")
; MsgBox,0,,Launched PID: %PID%,0.5

SetTitleMatchMode,3
SetTitleMatchMode,slow

IfWinNotExist,ahk_exe Blade.exe
{
  Run,Bin\Blade.exe,Bin
}

WinTitle = ahk_exe Blade.exe

WinWait,%WinTitle%
#IfWinExist,WinTitle
{
  While (!Controls) {
    WinGet,Controls,ControlList,%WinTitle%,,,
    Sleep,100
  }
  If (Controls) {
    ControlClick,Play Game,%WinTitle%,,LEFT,1,NA
  }
}

SetTimer,process_watcher,On

#IfWinActive,ahk_exe Blade.exe
{
  F6:: ;QuickSave
  {
    IfExist,Save\SaveGame6.py
    {
      Send,{Esc}{Enter 3}{Up}{Enter}{Esc} ;Overwrite existing Save
    } else {
      Send,{Esc}{Enter 3}{Esc} ;Create new Save
    }
    Return
  }

  F9:: ;QuickLoad
  {
    Send,{Esc}{Enter}{Down}{Enter 2}{Up}{Enter}
    Send,{O down}
    Sleep,100
    Send,{O up}
    Send,{NumpadSub}
    Return
  }

  SC014:: ;Camera
  {
    Send,{O down}
    Sleep,125
    Send,{O up}
    Send,{NumpadSub}
    Return
  }

  Return
}

process_watcher:
{
	Process,Exist,Blade.exe
    If (ErrorLevel = 0) {
      ExitApp
    }
  Return
}

OnExit,Exit

Exit:
{
  ; MsgBox,0,,Exit done!,0.5
  Process,Close,%PID%
}
