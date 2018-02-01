#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance Off  ; [force|ignore|off]
#Persistent
; Process,Priority,,High
; DetectHiddenWindows,On

ForceSingleInstance()

If (not A_IsAdmin) {
  Try
  {
    Run,*RunAs "%A_ScriptFullPath%"
  } Catch {
    ; MsgBox,You cancelled when asked to elevate to admin!
  }
  ExitApp
}

PID := DllCall("GetCurrentProcessId")
; MsgBox,0,,Launched PID: %PID%,0.5

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.0"
SCRIPT_WIN_TITLE = %SCRIPT_NAME% v%SCRIPT_VERSION%

CreateGUI:
{
  If (A_Language = "0419") {
    L_Source := "Источник"
    L_Target := "Ссылка"
    L_File := "Файл"
    L_Folder := "Папка"
    L_HardLink := "Жесткая связь"
    L_DirectoryJunction := "Соединение каталогов"
    L_Cancel := "Отмена"
    L_OK := "Готово"

    Gui,Add,Button,x05 y05 w70 h20 gButtonSource,%L_Source%
    Gui,Add,Button,x05 y30 w70 h20 gButtonTarget,%L_Target%
    Gui,Add,Edit,x75 y05 w390 h20 vSOURCE_PATH gGetControlValues,
    Gui,Add,Edit,x75 y30 w390 h20 vTARGET_PATH gGetControlValues,

    Gui,Add,Text,vSliderText1,%L_File%
    Gui,Add,Text,vSliderText2,%L_Folder%
    Gui,Add,Slider,x40 y55 w50 h20 Range1-2 NoTicks Buddy1SliderText1 Buddy2SliderText2 vLinkType gGetControlValues,1

    Gui,Add,CheckBox,x133 y55 w100 h20 vHardLink gGetControlValues,%L_HardLink%
    Gui,Add,CheckBox,x133 y55 w140 h20 vDirectoryJunction gGetControlValues Checked,%L_DirectoryJunction%
    GuiControl,Hide,DirectoryJunction

    Gui,Add,Button,x320 y55 w70 h20 gGuiClose,%L_Cancel%
    Gui,Add,Button,x395 y55 w70 h20 gButtonOK,%L_OK%

    Gui,Add,Edit,x5 y80 w460 h95 vCommandText,

    Gui,Show,xCenter yCenter w470 h180,%SCRIPT_WIN_TITLE%
  } else {
    L_Source := "Source"
    L_Target := "Target"
    L_File := "File"
    L_Folder := "Folder"
    L_HardLink := "Hard link"
    L_DirectoryJunction := "Directory Junction"
    L_Cancel := "Cancel"
    L_OK := "OK"

    Gui,Add,Button,x05 y05 w70 h20 gButtonSource,%L_Source%
    Gui,Add,Button,x05 y30 w70 h20 gButtonTarget,%L_Target%
    Gui,Add,Edit,x75 y05 w360 h20 vSOURCE_PATH gGetControlValues,
    Gui,Add,Edit,x75 y30 w360 h20 vTARGET_PATH gGetControlValues,

    Gui,Add,Text,vSliderText1,%L_File%
    Gui,Add,Text,vSliderText2,%L_Folder%
    Gui,Add,Slider,x25 y55 w50 h20 Range1-2 NoTicks Buddy1SliderText1 Buddy2SliderText2 vLinkType gGetControlValues,1

    Gui,Add,CheckBox,x115 y55 w65 h20 vHardLink gGetControlValues,%L_HardLink%
    Gui,Add,CheckBox,x115 y55 w105 h20 vDirectoryJunction gGetControlValues Checked,%L_DirectoryJunction%
    GuiControl,Hide,DirectoryJunction

    Gui,Add,Button,x290 y55 w70 h20 gGuiClose,%L_Cancel%
    Gui,Add,Button,x365 y55 w70 h20 gButtonOK,%L_OK%

    Gui,Add,Edit,x5 y80 w430 h95 vCommandText,

    Gui,Show,xCenter yCenter w440 h180,%SCRIPT_WIN_TITLE%
  }

  Return
}

ButtonSource:
{
  gosub GetControlValues

  If (LinkType = 1) {
    FileSelectFile,SourcePath,2,,Select file ;,*.*
  } else if (LinkType = 2) {
    FileSelectFolder,SourcePath,,Add 2,Select folder
  }
  If (SourcePath and SourcePath != "") {
    GuiControl,,SOURCE_PATH,%SourcePath%
  }

  gosub GetControlValues

  Return
}

ButtonTarget:
{
  gosub GetControlValues

  SplitPath,SOURCE_PATH,SourceName,,,,

  If (LinkType = 1) {
    FileSelectFile,TargetPath,2,%SourceName%,Select file ;,*.*
  } else if (LinkType = 2) {
    FileSelectFolder,TargetPath,,Add 2,Select folder
  }
  If (TargetPath and TargetPath != "") {
    GuiControl,,TARGET_PATH,%TargetPath%
  }

  gosub GetControlValues

  Return
}

GetControlValues:
{
  Gui,Submit,Nohide

  If (LinkType = 1) {
    Type := "File"
    KEYS := ""
    If (HardLink) {
      KEYS := KEYS . "/H "
    }
    GuiControl,Show,HardLink
    GuiControl,Hide,DirectoryJunction
  } else if (LinkType = 2) {
    Type := "Folder"
    KEYS := "/D "
    If (DirectoryJunction) {
      KEYS := KEYS . "/J "
    }
    GuiControl,Hide,HardLink
    GuiControl,Show,DirectoryJunction
  }

  COMMAND = MKLINK %KEYS%"%TARGET_PATH%" "%SOURCE_PATH%"

  GuiControl,,CommandText,%COMMAND%

  Gui,Submit,Nohide

  ; MsgBox,LinkType: %Type%`n`Keys: %KEYS%

  Return
}

ButtonOK:
{
  gosub GetControlValues

  If (SOURCE_PATH != "" and TARGET_PATH != "") {
    If (LinkType != "") {
      SplitPath,TARGET_PATH,,TARGET_DIR,,,

      RunWait,%comspec% /k %COMMAND% & pause & exit

      IfExist, %TARGET_DIR%
      {
        Run, %TARGET_DIR%
      }
    }
  }

  Return
}

GuiClose:
{
  ExitApp
  Return
}

OnExit,Exit

Exit:
{
  Gui,Destroy
  Process,Close,%PID%
}
