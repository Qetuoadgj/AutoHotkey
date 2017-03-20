#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,force
#Persistent  ; to make it run indefinitely
; SetBatchLines,-1  ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.1.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

MsgBox,0,%SCRIPT_WIN_TITLE%,Ready!,0.5

Delay := 100

SC052:: ;Numpad0
{
  IfWinExist,ahk_class Notepad++
  {
    WinActivate
    WinWaitActive
    
    SendEvent,{F10}
    Sleep,% Delay
    SendEvent,{Right 10}
    Sleep,% Delay
    SendEvent,{Down 13}
    Sleep,% Delay
    SendEvent,{Right}
    Sleep,% Delay
    SendEvent,{Down 3}
    Sleep,% Delay
    SendEvent,{Enter}
    
    WinWait,Ввод данных:,,1
    IfWinExist,Ввод данных:
    {
      WinActivate,Ввод данных:
      WinWaitActive,Ввод данных:
      SendEvent,{Enter}
      WinWaitClose
    }
    
    Sleep,% Delay
    
    MouseClick,left
    Sleep,% Delay
    SendEvent,^{Pgdn}
  }
  Return
}
Exit
