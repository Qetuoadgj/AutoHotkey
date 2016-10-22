﻿#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]
Process,Priority,,High
; DetectHiddenWindows,Off

; #Persistent ; to make it run indefinitely
; SetBatchLines,-1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

If !A_IsAdmin
{
  Run *RunAs "%A_ScriptFullPath%"
  ExitApp
}

Y_Key = {SC015}

ExePath := "OldChromeRemover-0.5.exe"
ExeFile := RegExReplace(ExePath,".*\\(.*)","$1")
WinSelector := "ahk_exe " . ExeFile

If FileExist(ExePath) {
  If (not WinExist(WinSelector)) {
    Run,*RunAs %ExePath%,,,WinPID
    WinSelector := "ahk_pid " . WinPID
  }

  WinWait,%WinSelector%
  WinActivate,%WinSelector%
  WinWaitActive,%WinSelector%,,2
  ControlSend,,% Y_Key,%WinSelector%
}

ExitApp
