; https://github.com/Qetuoadgj/AutoHotkey

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,Force ;[force|ignore|off]
Process,Priority,,High
DetectHiddenWindows,Off

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.6"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

If (not %0%) {
  APP_PATH := "notepad.exe"
} else {
  APP_PATH = %1%
}
Run,%APP_PATH%,,Min,WIN_PID

; WIN_TITLE = ahk_pid %WIN_PID%
EXE := RegExReplace(APP_PATH,".*\\(.*)","$1")
WIN_TITLE = ahk_exe %EXE%

WinWait,%WIN_TITLE%,,2
If (ErrorLevel) {
  MsgBox,0,%SCRIPT_WIN_TITLE% Error,Could not find target: %WIN_TITLE%,1.5 
} else {
  WinGet WIN_ID,ID,%WIN_TITLE%
  WIN_TITLE = ahk_id %WIN_ID%
  
  WinGet MMX,MinMax,%WIN_TITLE%
  DetectHiddenWindows,On
  If (MMX = -1) {
    ; WinRestore
    WIN_STATUS := "Minimized"
    Sleep,100
    WinMinimize
  } else {
    ; WinMinimize
    WIN_STATUS := "Maximized"
    WinSet,Transparent,On,%WIN_TITLE%
    WinMinimize
    Sleep,100
    WinMinimize
    WinSet,Transparent,Off,%WIN_TITLE%
  }

  /*
  MESSAGE =
  ( LTrim RTrim
    %APP_PATH%
    %WIN_TITLE%
    %WIN_PID%
    %WIN_STATUS%
  )

  MsgBox,0,,%MESSAGE%,1.0
  */
}
