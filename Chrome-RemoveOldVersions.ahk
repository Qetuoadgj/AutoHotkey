; Source: http://www.gameplayinside.com/optimize/cleaning-old-google-chrome-versions-to-save-disk-space/
; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/Chrome-RemoveOldVersions.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force ; [Force|Ignore|Off]

UseSingleInstance()

If (not A_IsAdmin) {
  Try
  {
    Run,*RunAs "%A_AhkPath%" "%A_ScriptFullPath%"
  } Catch {
    ; MsgBox,You cancelled when asked to elevate to admin!
  }
  ExitApp
}

RegRead,ChromeAppPaths,HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe,Path
; MsgBox,%ChromeAppPaths%
; Run,"explorer" "%OutputVar%"

FoldersToRemoveArray := []
FoldersToKeepArray := []

FoldersToRemoveString := ""
FoldersToKeepString := ""

SavedSpace := 0

APP_VERSION_MAX := 0

MAJOR_MAX := 0
MINOR_MAX := 0
BUILD_MAX := 0
PATCH_MAX := 0

Loop,Files,%ChromeAppPaths%\*,D
{
  FolderName := A_LoopFileName
  If RegExMatch(FolderName,"i)" . "(\d+)\.(\d+)\.(\d+)\.(\d+)",FolderMatch,1) {
    MAJOR := FolderMatch1
    MINOR := FolderMatch2
    BUILD := FolderMatch3
    PATCH := FolderMatch4

    MatchFolder := A_LoopFileLongPath
    MatchVersion := MAJOR . "." . MINOR . "." . BUILD . "." . PATCH

    If (MAJOR > MAJOR_MAX) {
      MAJOR_MAX := MAJOR
      MINOR_MAX := MINOR
      BUILD_MAX := BUILD
      PATCH_MAX := PATCH

    } Else If (MAJOR = MAJOR_MAX) {
      If (MINOR > MINOR_MAX) {
        MAJOR_MAX := MAJOR
        MINOR_MAX := MINOR
        BUILD_MAX := BUILD
        PATCH_MAX := PATCH

      } Else If (MINOR = MINOR_MAX) {
        If (BUILD > BUILD_MAX) {
          MAJOR_MAX := MAJOR
          MINOR_MAX := MINOR
          BUILD_MAX := BUILD
          PATCH_MAX := PATCH

        } Else If (BUILD = BUILD_MAX) {
          If (PATCH > PATCH_MAX) {
            MAJOR_MAX := MAJOR
            MINOR_MAX := MINOR
            BUILD_MAX := BUILD
            PATCH_MAX := PATCH
          }
        }
      }
    }

    APP_VERSION_MAX := MAJOR_MAX . "." . MINOR_MAX . "." . BUILD_MAX . "." . PATCH_MAX

    ; MsgBox,0,,%MatchFolder%`nVersion: %MatchVersion%,1.0
  }
}

Loop,Files,%ChromeAppPaths%\*,D
{
  FolderName := A_LoopFileName
  If RegExMatch(FolderName,"i)" . "(\d+)\.(\d+)\.(\d+)\.(\d+)",AppFolderMatch,1) {
    APP_MAJOR := AppFolderMatch1
    APP_MINOR := AppFolderMatch2
    APP_BUILD := AppFolderMatch3
    APP_PATCH := AppFolderMatch4

    MatchFolder := A_LoopFileLongPath
    MatchVersion := APP_MAJOR . "." . APP_MINOR . "." . APP_BUILD . "." . APP_PATCH
    If (MatchVersion == APP_VERSION_MAX) {
      FoldersToKeepArray.Push(MatchFolder)
    } Else {
      FoldersToRemoveArray.Push(MatchFolder)
      FolderSize := GetFileFolderSize(MatchFolder)
      SavedSpace += FolderSize
      ; MsgBox,%FolderSize%
    }
  }
}

For Index,Element in FoldersToKeepArray
{
  If (A_Index = 1) {
    FoldersToKeepString := Element
  } Else {
    FoldersToKeepString := FoldersToKeepString . "`r`n" . Element
  }
}

For Index,Element in FoldersToRemoveArray
{
  If (A_Index = 1) {
    FoldersToRemoveString := Element
  } Else {
    FoldersToRemoveString := FoldersToRemoveString . "`r`n" . Element
  }
}

SavedSpaceString := SavedSpace

If (SavedSpaceString > 1024**3) {
  SavedSpaceString := Round(SavedSpaceString / 1024**3,2) . " GB"
} Else If (SavedSpaceString > 1024**2) {
  SavedSpaceString := Round(SavedSpaceString / 1024**2,2) . " MB"
} Else If (SavedSpaceString > 1024) {
  SavedSpaceString := Round(SavedSpaceString / 1024,2) . " KB"
} Else {
  SavedSpaceString := Round(SavedSpaceString,0)  . " Bytes"
}

MsgText =
( LTrim RTrim Join`r`n
  Max Version: %APP_VERSION_MAX%

  Keep:
  %FoldersToKeepString%

  Remove:
  %FoldersToRemoveString%

  Saved Space:
  %SavedSpaceString%
)
MsgBox,1,,%MsgText%
IfMsgBox,Ok
{
  For Index,Element in FoldersToRemoveArray
  {
    Folder := Element
    FileRecycle,%Folder%
  }
  MsgBox,1,,Done!,2.0
} Else {
  ; MsgBox You pressed No.
}

ExitApp

GetFileFolderSize(fPath="") {
  If InStr( FileExist( fPath ),"D" ) {
    Loop,Files,%fPath%\*,RFD
    {
      FolderSize += %A_LoopFileSize%
    }
		Size := FolderSize ? FolderSize : 0
    Return,Size
  } Else If ( FileExist( fPath ) <> "" ) {
    FileGetSize,FileSize,%fPath%
		Size := FileSize ? FileSize : 0
    Return,Size
  } Else {
    Return -1
  }
}

; ===================================================================================
;		ФУНКЦИЯ АВТОМАТИЧЕСКОГО ЗАВЕРШЕНИЯ ВСЕХ КОПИЙ ТЕКУЩЕГО ПРОЦЕССА (КРОМЕ АКТИВНОЙ)
; ===================================================================================
UseSingleInstance()
{
	DetectHiddenWindows,On
	#SingleInstance Off

	WinGet,CurrentID,ID,%A_ScriptFullPath% ahk_class AutoHotkey
	WinGet,ProcessList,List,%A_ScriptFullPath% ahk_class AutoHotkey
	ProcessCount := 1
	Loop,%ProcessList% {
		ProcessID := ProcessList%ProcessCount%
		If (ProcessID != CurrentID) {
			WinGet,ProcessPID,PID,%A_ScriptFullPath% ahk_id %ProcessID%
			Process,Close,%ProcessPID%
		}
		ProcessCount += 1
	}
	Return
}
