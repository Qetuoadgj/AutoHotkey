; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/GetRecursiveFilesList.ahk| v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force ; [Force|Ignore|Off]

if (not %0%) {
  ExitApp
}
/*
FilesList := ""
PreviousDir := ""

Loop Files, %1%\*, FR
{
  ; FolderSize += A_LoopFileSize
  File := A_LoopFileLongPath
  FileDir := A_LoopFileDir
 
  if (not FileDir == PreviousDir) {
    if (A_Index != 1) {
      FilesList .= ";`r`n"
    }
    FilesList .=  "; " . A_LoopFileDir . "\`r`n"
  }
  FilesList .= "`t" . File . "`r`n"

  PreviousDir := FileDir

  ; MsgBox 0,, %File%, 0.1
}

; Run,notepad.exe,,,Notepad_WinPID
; WinWait,ahk_pid %Notepad_WinPID%
; ControlSetText,,%FilesList%,ahk_pid %Notepad_WinPID%
*/

FileList := ""
Loop Files, %1%\*, FR
{
  FileList .= A_LoopFileLongPath . "|" . A_LoopFileDir "`n"
}

Sort, FileList, \ ;R

PreviousDir := ""
Output := ""
Loop, parse, FileList, `n, `r
{
  if (A_LoopField == "") { ; Ignore the blank item at the end of the list.
    Output .= ";"
    continue
  }
  FileData := StrSplit(A_LoopField, "|")
  File := FileData[1]
  FileDir := FileData[2]
  if (not FileDir == PreviousDir) {
    if (A_Index != 1) {
      Output .= ";`r`n"
    }
    Output .=  "; " . FileDir . "\`r`n"
  }
  Output .= "`t" . File . "`r`n"
  PreviousDir := FileDir
}

Clipboard = ; Empty the clipboard.
Clipboard := Output
ClipWait ;2.0

; MsgBox 0,, Done!, 0.5
MsgBox 0,, %Clipboard%, 1.5
