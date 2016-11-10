; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/Control_C.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force
#Persistent ; to make it run indefinitely
; SetBatchLines,-1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

Process,Priority,,High
DetectHiddenWindows,Off

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.8"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

MsgBox,0,%SCRIPT_WIN_TITLE%,Ready!,0.5

CreateLogo:
{
  logoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".png"
  logoURL := "https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Images/AddURL.png" ;"https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Chrome_Logo.svg/64px-Chrome_Logo.svg.png"
  logoSize := 64
  logoAlpha := 0.95

  GdipCreateLogo(logoFile,logoURL,logoSize,logoAlpha)
}

SetTrayIcon:
{
  icoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".ico"
  If FileExist(icoFile) {
   Menu,Tray,Icon,%icoFile%
  }
}

CreateGUI:
{
  MainGUI := SCRIPT_NAME . "_"
  Gui,%MainGUI%: +AlwaysOnTop
  Gui,%MainGUI%: Add,Button,x5 y5 w90 h40 gResetArray,Reset Array
  Gui,%MainGUI%: Add,Text,x105 y7 w55 h20,New Lines
  Gui,%MainGUI%: Add,ComboBox,x160 y5 w45 h300 vNewLines,0|1||2|3|4|5|6|7|8|9|10
  Gui,%MainGUI%: Add,Text,x105 y30 w55 h20,Use Enter
  Gui,%MainGUI%: Add,ComboBox,x160 y27 w45 h300 vUseEnter,Yes||No|
  Gui,%MainGUI%: Add,Text,x215 y7 w80 h20,Close Window
  Gui,%MainGUI%: Add,ComboBox,x290 y5 w45 h300 vCloseWindow,Yes|No||
  Gui,%MainGUI%: Add,Text,x215 y30 w80 h20,Insert Counter
  Gui,%MainGUI%: Add,ComboBox,x290 y27 w45 h300 vInsertCounter,Yes|No||
  Gui,%MainGUI%: Submit,Hide
}

DefineGlobals:
{
  ItemsArray := [] ;Object() ; Таблица проверки дубликатов
  ClipWaitTime = 0.5 ;0.1 ; 10 msec

  ArrayLengthBefore := 0
  ArrayLengthAfter := 0

  ; InsertCounter := 1
  ; Counter := 0

  ; AddNewLines := 0
  ; CloseAddedWindow := 1

  SaveClipboard := "Yes"
  CUR_CLIPBOARD := false
}

SetDocumentWindow:
{
  DOCUMENT_PATH := "D:\Google Диск\HTML\2.0.4.html"
  ; DOCUMENT_FILE := RegExReplace(DOCUMENT_PATH,".*\\(.*)","$1")
  DOCUMENT_NPP_TITLE := DOCUMENT_PATH . " - Notepad++"

  EDITOR_PATH := A_ProgramFiles . "\Notepad++\notepad++.exe"

  If (FileExist(EDITOR_PATH) && FileExist(DOCUMENT_PATH)) {
    If (not WinExist(DOCUMENT_NPP_TITLE)) {
      Run,"%EDITOR_PATH%" "%DOCUMENT_PATH%" -multiInst -nosession,,,Npp_WinPID
      WinWait,ahk_pid %Npp_WinPID%
      WinGet,Npp_WinID,ID
    } else {
      WinGet,Npp_WinID,ID,%DOCUMENT_NPP_TITLE%
    }
    WinActivate,ahk_id %Npp_WinID%
    ; Center Win
    ; ----------------------------------------
    WinGetPos,,,Width,Height,ahk_id %Npp_WinID%
    WinMove,ahk_id %Npp_WinID%,,(A_ScreenWidth/2)-(Width/2),(A_ScreenHeight/2)-(Height/2)
    ; ----------------------------------------
  }

  IfWinExist,%DOCUMENT_NPP_TITLE%
  {
    MsgBox,0,%SCRIPT_WIN_TITLE%,Path: %DOCUMENT_PATH%`nID: %Npp_WinID%`nPID: %Npp_WinPID%,1.5
    WinWaitClose,ahk_id %Npp_WinID%
    SoundPlay,*64
    ExitApp
  } else {
    SoundPlay,*16
    MsgBox,0,Error,Open document:`n%DOCUMENT_PATH%,1.5
    ExitApp
  }
}

SC052:: ;Numpad0
{
  WinGet,LastActive_WinID,ID,A

  IfWinExist,ahk_exe chrome.exe
  {
    WinGet,Chrome_WinID,ID,ahk_exe chrome.exe

    If (Clipboard) {
      If (SaveClipboard == "Yes") {
        CUR_CLIPBOARD := Clipboardall
        Clipboard = ; Empty the clipboard.
        Sleep,100
      }
    }

    WinActivate,ahk_id %Chrome_WinID%
    WinWaitActive,ahk_id %Chrome_WinID%
    IfWinActive,ahk_id %Chrome_WinID%
    {
      ArrayLengthBefore := ItemsArray.Length()

      ; SendEvent,^c
      ; ClipWait,%ClipWaitTime%
      
      Loop,3
      {
        Clipboard = ; Empty the clipboard.
        Sleep,100
        SendEvent,^c
        ClipWait,%ClipWaitTime%
      }

      If (Clipboard) {
        If (not InArray(ItemsArray,Clipboard) and not (Clipboard == CUR_CLIPBOARD)) {
          IfWinExist,ahk_id %Npp_WinID%
          {
            WinActivate,ahk_id %Npp_WinID%
            WinWaitActive,ahk_id %Npp_WinID%

            WinGetActiveTitle,Npp_EditorTitle
            ; Npp_EditorTitle := RegExReplace(Npp_EditorTitle,".*\\(.*)","$1")
            ; Npp_EditorTitle := RegExReplace(Npp_EditorTitle,"(.*) - Notepad\+\+","$1")
            Npp_EditorTitle := RegExReplace(Npp_EditorTitle,"^[?] ","")
            Npp_EditorTitle := RegExReplace(Npp_EditorTitle,"^[*]","")

            If (Npp_EditorTitle == A_ScriptName or Npp_EditorTitle != DOCUMENT_NPP_TITLE) {
              MsgBox,0,Error,Select another document!,1.5
              ; MsgBox,0,Error,A_ScriptName: %A_ScriptName%`nNpp_EditorTitle: %Npp_EditorTitle%`nDOCUMENT_NPP_TITLE: %DOCUMENT_NPP_TITLE%,3
            } else {
              ClipBody := Clipboard
              ClipText := ClipBody

              If (InsertCounter == "Yes") {
                Counter := ItemsArray.Length() + 1
                ClipText := "<!-- " . Counter . " -->" . "`r`n" . ClipText
              }

              AddLines := NewLines + 1
              If (UseEnter == "No") {
                Loop,%AddLines% {
                  ClipText := ClipText . "`r`n"
                }
              }

              Clipboard = ; Empty the clipboard.
              Clipboard = %ClipText%
              ClipWait,3

              SendEvent,{End}^v
              If (UseEnter == "Yes") {
                SendEvent,{Enter %NewLines%}
              }
              If (RegExMatch(Npp_EditorTitle,".*[.].*",match,1)) {
                Send,^s
              }
              ItemsArray.Insert(ClipBody)
            }
          }
        } else {
          MsgBox,0,Error,Already in array!,0.5
        }
      }

      If (CUR_CLIPBOARD and not (Clipboard == CUR_CLIPBOARD)) {
        Clipboard = ; Empty the clipboard.
        Clipboard = %CUR_CLIPBOARD%
        ClipWait,%ClipWaitTime%
      }

      ArrayLengthAfter := ItemsArray.Length()

      WinActivate,ahk_id %LastActive_WinID%
      If (CloseWindow == "Yes" && ArrayLengthAfter > ArrayLengthBefore) {
        WinActivate,ahk_id %Chrome_WinID%
        WinWaitActive,ahk_id %Chrome_WinID%
        SendEvent,^{F4}
      }
    }
  }
  Return
}

SC04F:: ;Numpad1
{
  ; ItemsArray := [] ;Object() ; Сброс таблицы проверки дубликатов

  ControlGet,Bool,Visible,,,%SCRIPT_WIN_TITLE%
  If (Bool) {
    Gui,%MainGUI%: Submit,Hide
  } Else {
    Gui,%MainGUI%: Show,xCenter yCenter h50 w340,%SCRIPT_WIN_TITLE%
  }

  Return
}

; ------------------ GUI BUTTONS ------------------
ResetArray:
{
  ItemsArray := [] ;Object() ; Сброс таблицы проверки дубликатов
  Gui,Submit,Hide
  MsgBox,0,%SCRIPT_WIN_TITLE%,Done!,0.5
  Return
}

; ------------------ FUNCTIONS ------------------
InArray(haystack,needle) {
  If(not isObject(haystack)) {
    Return,False
  }
  If(haystack.Length() == 0) {
    Return,False
  }
  For k,v in haystack {
    If(v == needle){
      Return,True
    }
  }
  Return,False
}
