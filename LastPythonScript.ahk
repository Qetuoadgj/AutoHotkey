#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, force
#Persistent  ; to make it run indefinitely
; SetBatchLines, -1  ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.1.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

SC052:: ;Numpad0
{
  IfWinExist, ahk_class Notepad++
  {
    WinActivate
    WinWaitActive

    SendEvent, {F10}
    Sleep, 30
    SendEvent, {Right 9}
    Sleep, 30
    SendEvent, {Down 14}
    Sleep, 30
    SendEvent, {Right}
    Sleep, 30
    SendEvent, {Down 3}
    Sleep, 100
    SendEvent, {Enter}

    WinWait, Ввод данных:,,1
    IfWinExist, Ввод данных:
    {
      WinActivate, Ввод данных:
      WinWaitActive, Ввод данных:
      SendEvent, {Enter}
      WinWaitClose
    }

    MouseClick, left
    Sleep, 100
    SendEvent, ^{Pgdn}
  }
  Return
}
Exit
