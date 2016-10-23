; https://singularlabs.com/forums/topic/oldchromeremover-remove-obsolete-google-chrome-versions/
; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/OldChromeRemover-0.5.exe.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]
Process,Priority,,High
; DetectHiddenWindows,Off

; #Persistent ; to make it run indefinitely
; SetBatchLines,-1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

global NumberOfParameters
NumberOfParameters = %0%

ExePath := GetLaunchParameters("OldChromeRemover-0.5.exe")

If not FileExist(ExePath) {
    ; ExitApp

    ; If the image we want to work with does not exist on disk,then download it...
    DefaultExePath := A_WorkingDir . "\" . ExePath
    If !FileExist(DefaultExePath) {
      SplitPath,DefaultExePath,,DefaultExeDir
      IfNotExist,DefaultExeDir
      {
        FileCreateDir,% DefaultExeDir
      }
      DownloadURL := "http://singularlabs.com/download/10350/"
      UrlDownloadToFile,%DownloadURL%,%DefaultExePath%
      Run,"explorer" "%DefaultExeDir%"
      Sleep,1000
    }
}

If !A_IsAdmin
{
  SavedClipboard := Clipboardall
  Clipboard = ; Empty the clipboard.
  Clipboard := ExePath
  ClipWait,0.5

  Run *RunAs "%A_ScriptFullPath%" "%ExePath%"
  ExitApp
}

ExePath := GetLaunchParameters("OldChromeRemover-0.5.exe")

ExeFile := RegExReplace(ExePath,".*\\(.*)","$1")
WinSelector := "ahk_exe " . ExeFile

Y_Key = {SC015}

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

; ------------------ FUNCTIONS ------------------

GetLaunchParameters(DefaultParameters) {
  If (not NumberOfParameters) {
    Parameters := DefaultParameters
  } else {
  Loop,%NumberOfParameters%
    {
      Parameter := %A_Index%
      Parameters = %Parameters% %Parameter%
    }
  }
  Return %Parameters%
}
