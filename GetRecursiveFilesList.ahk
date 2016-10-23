; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/GetRecursiveFilesList.ahk| v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]

If (not %0%) {
  ExitApp
}

FilesList := ""
PreviousDir := ""

Loop,Files,%1%\*,FR
{
  ; FolderSize += A_LoopFileSize
  File := A_LoopFileLongPath
  FileDir := A_LoopFileDir

  If (A_Index = 1) {
    FilesList := File
  } Else {
    If (not FileDir == PreviousDir) {
      File := ";`r`n" . File
    }
    FilesList := FilesList . "`r`n" . File
  }
  PreviousDir := FileDir

  ; MsgBox,0,,%File%,0.1
}

; Run,notepad.exe,,,Notepad_WinPID
; WinWait,ahk_pid %Notepad_WinPID%
; ControlSetText,,%FilesList%,ahk_pid %Notepad_WinPID%

Clipboard = ; Empty the clipboard.
Clipboard := FilesList
ClipWait ;,2.0

; MsgBox,0,,Done!,0.5
MsgBox,0,,%FilesList%,1.5

