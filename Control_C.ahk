; https://github.com/Qetuoadgj/AutoHotkey

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, force
#Persistent ; to make it run indefinitely
; SetBatchLines, -1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.4"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

CreateLogo:
{
  logoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".png"
  logoURL := "https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Chrome_Logo.svg/64px-Chrome_Logo.svg.png"
  logoSize := 64
  logoAlpha := 0.95

  GdipCreateLogo(logoFile, logoURL, logoSize, logoAlpha)
}

CreateGUI:
{
  Gui, %SCRIPT_NAME%_: +AlwaysOnTop
  Gui, %SCRIPT_NAME%_: Add, Button, x5 y5 w90 h40 gResetArray, Reset Array
  Gui, %SCRIPT_NAME%_: Add, Text, x105 y7 w55 h20, New Lines
  Gui, %SCRIPT_NAME%_: Add, ComboBox, x160 y5 w45 h300 vNewLines, 0|1||2|3|4|5|6|7|8|9|10
  Gui, %SCRIPT_NAME%_: Add, Text, x105 y30 w55 h20, Use Enter
  Gui, %SCRIPT_NAME%_: Add, ComboBox, x160 y27 w45 h300 vUseEnter, Yes||No|
  Gui, %SCRIPT_NAME%_: Add, Text, x215 y7 w80 h20, Close Window
  Gui, %SCRIPT_NAME%_: Add, ComboBox, x290 y5 w45 h300 vCloseWindow, Yes|No||
  Gui, %SCRIPT_NAME%_: Add, Text, x215 y30 w80 h20, Insert Counter
  Gui, %SCRIPT_NAME%_: Add, ComboBox, x290 y27 w45 h300 vInsertCounter, Yes|No||
  Gui, %SCRIPT_NAME%_: Submit, Hide
}

DefineGlobals:
{
  itemsArray := Object() ; Таблица проверки дубликатов
  timeToWait = 0.5 ;0.1 ; 10 msec

  arrayLengthBefore := 0
  arrayLengthAfter := 0

  ; insertCounter := 1
  ; counter := 0

  ; addNewLines := 0
  ; closeAddedWindow := 1
  
  SaveClipboard := "Yes"
  CUR_CLIPBOARD := false
}

DOCUMENT_PATH := "D:\Google Диск\HTML\2.0.4.html"
; EDITOR_PATH := A_ProgramFiles . "\Notepad++\notepad++.exe"

If (DOCUMENT_PATH) {
  ; RunWait, "%EDITOR_PATH%" "%DOCUMENT_PATH%"
  DOCUMENT := DOCUMENT_PATH . " - Notepad++"
} else {
  WinGetTitle, DOCUMENT, ahk_class Notepad++
}

IfWinExist, %DOCUMENT%
{
  MsgBox, 0, %SCRIPT_WIN_TITLE%, %DOCUMENT%, 0.5
  WinWaitClose, %DOCUMENT%
  SoundPlay,*64
  ExitApp
} else {
  SoundPlay,*16
  MsgBox, 0, Error, Open document:`n%DOCUMENT%, 1.5
  ExitApp
}

SC052:: ;Numpad0
{
  IfWinExist, ahk_exe chrome.exe
  {
    WinGetTitle, BrowserWinTitle
  }

  If (BrowserWinTitle) {
    WinGetActiveTitle, ActiveWinTitle

    If (Clipboard) {
      If (SaveClipboard == "Yes") {
        CUR_CLIPBOARD := Clipboard
        Sleep, 100
      }
    }

    WinActivate, %BrowserWinTitle%
    WinWaitActive, %BrowserWinTitle%
    IfWinActive, %BrowserWinTitle%
    {
      arrayLengthBefore := itemsArray.Length()

      Clipboard =   ; Empty the clipboard.
      SendEvent, ^c
      ClipWait, %timeToWait%

      If (Clipboard) {
        If (not inArray(itemsArray, Clipboard)) {
          IfWinExist, %DOCUMENT% ;ahk_class Notepad++
          {
            WinActivate
            WinWaitActive

            WinGetActiveTitle, EditorTitle
            EditorTitle := RegExReplace(EditorTitle, ".*\\(.*)", "$1")
            EditorTitle := RegExReplace(EditorTitle, "(.*) - Notepad\+\+", "$1")
            EditorTitle := RegExReplace(EditorTitle, "^[?] ", "")
            EditorTitle := RegExReplace(EditorTitle, "^[*]", "")

            If (EditorTitle == A_ScriptName) {
              MsgBox, 0, Error, Select another document!, 1.5
            } else {
              clipBody := Clipboard
              clipText := clipBody

              If (InsertCounter == "Yes") {
                counter := itemsArray.Length() + 1
                clipText := "<!-- " . counter . " -->" . "`n" . clipText
              }

              addLines := NewLines + 1
              If (UseEnter == "No") {
                Loop, %addLines% {
                  clipText := clipText . "`n"
                }
              }

              Clipboard =   ; Empty the clipboard.
              Clipboard = %clipText%
              ClipWait, 2

              SendEvent, {End}^v ;{Enter %newLines%} ; SendEvent, {End}^v{Enter 2}
              If (UseEnter == "Yes") {
                SendEvent, {Enter %newLines%}
              }
              If (RegExMatch(EditorTitle, ".*[.].*", match, 1)) {
                Send, ^s
              }
              itemsArray.Insert(clipBody) ;itemsArray.Insert(Clipboard)
            }
          }
        } else {
          MsgBox, 0, Error, Already in array!, 0.5
        }
      }

      If (CUR_CLIPBOARD) {
        Clipboard =   ; Empty the clipboard.
        Clipboard = %CUR_CLIPBOARD%
        ClipWait, %timeToWait%
      }

      arrayLengthAfter := itemsArray.Length()

      WinActivate, %ActiveWinTitle%
      If (CloseWindow == "Yes" && arrayLengthAfter > arrayLengthBefore) {
        SendEvent, ^{F4}
      }
    }
  }
  Return
}

SC04F:: ;Numpad1
{
  ; itemsArray := Object() ; Сброс таблицы проверки дубликатов

  ControlGet, bool, Visible, , , %SCRIPT_NAME% From
  If (bool) {
    Gui, %SCRIPT_NAME%_: Submit, Hide
  } Else {
    Gui, %SCRIPT_NAME%_: Show, xCenter yCenter h50 w340, %SCRIPT_NAME% From
  }

  Return
}

; ------------------ GUI BUTTONS ------------------
ResetArray:
{
  itemsArray := Object() ; Сброс таблицы проверки дубликатов
  Gui, Submit, Hide
  MsgBox, 0, %SCRIPT_WIN_TITLE%, Done!, 0.5
  Return
}

; ------------------ FUNCTIONS ------------------
inArray(haystack, needle) {
  if(!isObject(haystack)) {
    return false
  }
  if(haystack.Length()==0) {
    return false
  }
  for k,v in haystack {
    if(v==needle){
      return true
    }
  }
  return false
}