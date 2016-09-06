#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance, force

SCRIPT_NAME :=  RegExReplace(A_ScriptName, "\.ahk$", "", ,1)
SCRIPT_VERSION := "1.0.0"
SCRIPT_WIN_TITLE = %SCRIPT_NAME% v%SCRIPT_VERSION%

If %0% {
  MsgBox, 0, , Writing installer for:`n%PATCH_PATH%, 0.5

  TARGET_DIR := "D:\Games\Blade of Darkness"
  BACKUP_DIR := TARGET_DIR "\PatchBackups"

  PATCH_PATH := %0%
  PATCH_PATH := FileGetLongPath(PATCH_PATH)
  PATCH_DIR := RegExReplace(PATCH_PATH, ".*\\(.*)$", "$1", ,1)

  INSTALL_FILE := PATCH_PATH "\Install.bat"
  INSTALL_FILE_ENCODING = cp866

  IfExist, %INSTALL_FILE%
  {
    FileDelete, %INSTALL_FILE%
  }

  filesList := Object()
  dirsList := Object()
  Loop, Files, %PATCH_PATH%\*, FRD
  {
    fileName := A_LoopFileName
    fileDir := A_LoopFileDir
    fileDir := StrReplace(fileDir, PATCH_PATH, "")
    fileDir := RegExReplace(fileDir, "^\\", "")
    filePath = %fileDir%\%fileName%
    filePath := RegExReplace(filePath, "^\\", "")

    if ( not inArray(dirsList, fileDir) ) {
      dirsList.Push(fileDir)
    }

    filesList.Push(filePath)
  }


  removeDirsList := Object()
  installerSection := Object()
  uninstallerSection := Object()

  count = 0
  For index, filePath in filesList
  {
    patchFile := filePath
    targetFile := TARGET_DIR "\" patchFile
    targetFileDir := RegExReplace(targetFile, "(.*)\\.*$", "$1", ,1)
    backupDir := BACKUP_DIR "\" PATCH_DIR
    backupFile := BACKUP_DIR "\" PATCH_DIR "\" patchFile
    backupFileDir := RegExReplace(backupFile, "(.*)\\.*$", "$1", ,1)

    If ( count < 1 ) {
      text =
      ( LTrim RTrim
        @echo off`n
        if exist "%BACKUP_DIR%\%PATCH_DIR%.bat" ( goto :UNINSTALLER )`n
        :INSTALLER
        if not exist "%BACKUP_DIR%" ( md "%BACKUP_DIR%" )`n`n
      )
      installerSection.Push(text)

      text =
      ( LTrim RTrim
        `n:UNINSTALLER`n
      )
      uninstallerSection.Push(text)

      count = count + 1
    }

    If ( not FileExist(targetFileDir) and not inArray(removeDirsList, targetFileDir) ) {
      removeDirsList.Insert(1, targetFileDir)
    }

    if ( not inArray(dirsList, patchFile) ) {
      If ( FileExist(targetFile) ) {
        text =
        ( LTrim RTrim
          attrib -h "%targetFile%"
          if not exist "%backupFileDir%" ( md "%backupFileDir%" )
          move "%targetFile%" "%backupFileDir%"
          attrib -h "%patchFile%"
          xcopy "`%cd`%\%patchFile%" "%targetFile%"*`n`n
        )
        installerSection.Push(text)

        text =
        ( LTrim RTrim
          move /y "%backupFile%" "%targetFileDir%\"`n`n
        )
        uninstallerSection.Push(text)
      } else {
        text =
        ( LTrim RTrim
          attrib -h "%patchFile%"
          xcopy "`%cd`%\%patchFile%" "%targetFile%"*`n`n
        )
        installerSection.Push(text)

        text =
        ( LTrim RTrim
          attrib -h "%targetFile%"
          erase /q "%targetFile%"`n`n
        )
        uninstallerSection.Push(text)
      }
    }
  }

  For index, lineString in removeDirsList
  {
    text = rmdir "%lineString%" /q`n
    uninstallerSection.Push(text)
  }

  text =
  ( LTrim RTrim
    xcopy "`%~dpnx0" "%BACKUP_DIR%\%PATCH_DIR%.bat"*`n
    echo.
    echo.Installation of: "%PATCH_DIR%" completed.
    echo.`n
    goto :END`n
  )
  installerSection.Push(text)

  text =
  ( LTrim RTrim
    erase /q "%BACKUP_DIR%\%PATCH_DIR%.bat"`n
    rmdir "%backupDir%" /s /q`n
    echo.
    echo.Uninstallation of: "%PATCH_DIR%" completed.
    echo.`n
    :END
    pause`n
  )
  uninstallerSection.Push(text)

  For index, lineString in installerSection
  {
    FileAppend, %lineString%, %INSTALL_FILE%, %INSTALL_FILE_ENCODING%
  }
  For index, lineString in uninstallerSection
  {
    FileAppend, %lineString%, %INSTALL_FILE%, %INSTALL_FILE_ENCODING%
  }

  IfExist, %INSTALL_FILE%
  {
    MsgBox, 36, ,Копирование файлов завершено.`n`nОткрыть папку назначения?`n`n%PATCH_PATH%, 15
    IfMsgBox, No
        Exit
    IfMsgBox, Yes
    {
      Run, %PATCH_PATH%
    }
  } else {
     MsgBox, Not found:`n%INSTALL_FILE%
  }

} else {
  MsgBox, 0, Error, ERROR:`nYou must drag and drop patch directory on this file:`n%A_ScriptName%, 5.0
}

exit

inArray(array, value) {
  if ( not isObject(array) ) {
    return false
  } else if ( array.Length() == 0 ) {
    return false
  } else {
    for k, v in array {
      if ( v == value ) {
        return true
      }
    }
  }
  return false
}
