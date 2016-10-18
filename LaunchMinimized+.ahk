; https://github.com/Qetuoadgj/AutoHotkey

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,Force ;[force|ignore|off]
Process,Priority,,High
DetectHiddenWindows,Off

If (not %0%) {
  APP_PATH := "notepad.exe"
} else {
  APP_PATH = %1%
}

APP_EXE := RegExReplace(APP_PATH,".*\\(.*)","$1")

Run,%APP_PATH%,,Min,WIN_PID

WinWait,ahk_exe %APP_EXE%
WinGet,WIN_ID,ID
WIN_TITLE = ahk_id %WIN_ID%

SetWinDelay,-1

WinMinimize,%WIN_TITLE%
Sleep,30
WinMinimize,%WIN_TITLE%

/*
MESSAGE =
( LTrim RTrim
  %APP_PATH%
  %APP_EXE%
  %WIN_PID%
  %MMX%
)

MsgBox,0,,%MESSAGE%,1.0
*/
