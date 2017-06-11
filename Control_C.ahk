; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/Control_C.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, Force
; #Persistent ; to make it run indefinitely
; SetBatchLines, -1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

; Process, Priority,, High
; DetectHiddenWindows, Off

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.1.6"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

; MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

CreateLogo:
{
	logoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".png"
	logoURL := "https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Images/AddURL.png"
	; "https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Chrome_Logo.svg/64px-Chrome_Logo.svg.png"
	logoSize := 64
	logoAlpha := 0.95

	GdipCreateLogo(logoFile, logoURL, logoSize, logoAlpha)
}

SetTrayIcon:
{
	IcoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".ico"
	If FileExist(IcoFile)
	{
		Menu, Tray, Icon, %IcoFile%
	}
}

CreateGUI:
{
	MainGUI := SCRIPT_NAME . "_"
	Gui, %MainGUI%:+AlwaysOnTop
	Gui, %MainGUI%:Add, Button, x5 y5 w90 h40 gResetArray, Reset Array
	Gui, %MainGUI%:Add, Text, x105 y7 w55 h20, New Lines
	Gui, %MainGUI%:Add, ComboBox, x160 y5 w45 h300 vNewLines, 0|1||2|3|4|5|6|7|8|9|10
	Gui, %MainGUI%:Add, Text, x105 y30 w55 h20, Use Enter
	Gui, %MainGUI%:Add, ComboBox, x160 y27 w45 h300 vUseEnter, Yes||No|
	Gui, %MainGUI%:Add, Text, x215 y7 w80 h20, Close Window
	Gui, %MainGUI%:Add, ComboBox, x290 y5 w45 h300 vCloseWindow, Yes|No||
	Gui, %MainGUI%:Add, Text, x215 y30 w80 h20, Insert Counter
	Gui, %MainGUI%:Add, ComboBox, x290 y27 w45 h300 vInsertCounter, Yes|No||
	Gui, %MainGUI%:Submit, Hide
}

DefineGlobals:
{
	ItemsArray := [] ; Object() ; Таблица проверки дубликатов

	; ClipWaitTime := 0.5 ; sec
	; ClipTimeout := Round(ClipWaitTime > 1 ? ClipWaitTime*1000 : 5000)
	; If (ClipTimeout)
	; {
		; #ClipboardTimeout, %ClipTimeout%
	; }

	SaveClipboard := True

	Pattern := "<div class="".*?"" .*?><\/div>"
	MsgTime := 10
}

SetDocumentWindow:
{
	DOCUMENT_PATH := %0% ? %0% : "D:\Google Диск\HTML\html\2.0.4.html"
	; DOCUMENT_FILE := RegExReplace(DOCUMENT_PATH, ".*\\(.*)", "$1")
	DOCUMENT_NPP_TITLE := DOCUMENT_PATH . " - Notepad++"

	If (WinExist("*" . DOCUMENT_NPP_TITLE) || WinExist(DOCUMENT_NPP_TITLE))
	{
		WinGet, Npp_WinID, ID
	}

	EDITOR_PATH := A_ProgramFiles . "\Notepad++\notepad++.exe"

	If (FileExist(EDITOR_PATH) && FileExist(DOCUMENT_PATH))
	{
		If (not Npp_WinID) {
			Run, "%EDITOR_PATH%" "%DOCUMENT_PATH%" -multiInst -nosession,,, Npp_WinPID
			WinWait, ahk_pid %Npp_WinPID%
			WinGet, Npp_WinID, ID
		}

		WinActivate, ahk_id %Npp_WinID%

		; Center Win
		; --------------------------------------
		WinGetPos,,, Width, Height, ahk_id %Npp_WinID%
		WinMove, ahk_id %Npp_WinID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
		; --------------------------------------
	}

	IfWinExist, ahk_id %Npp_WinID%
	{
		WinActivate, ahk_id %Npp_WinID%
		WinWaitActive, ahk_id %Npp_WinID%
		WinMaximize, ahk_id %Npp_WinID%
		WinRestore, ahk_id %Npp_WinID%
		MsgBox, 0, %SCRIPT_WIN_TITLE%, Path: %DOCUMENT_PATH%`nID: %Npp_WinID%`nPID: %Npp_WinPID%, 1.5
		WinWaitClose, ahk_id %Npp_WinID%
		SoundPlay, *64
		ExitApp
	} else {
		SoundPlay, *16
		MsgBox, 0, Error, Open document:`n%DOCUMENT_PATH%, 1.5
		ExitApp
	}
}

MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

SC052:: ; Numpad0
{
	WinGet, LastActive_WinID, ID, A
	WinGet, Chrome_WinID, ID, ahk_exe chrome.exe

	ArrayLengthBefore := ItemsArray.Length()

	IfWinExist, ahk_id %Chrome_WinID%
	{
		If (SaveClipboard)
		{
			CUR_CLIPBOARD := Clipboard
			Clipboard := ; Null
		}

		If not WinActive("ahk_id " . Chrome_WinID)
		{
			WinActivate, ahk_id %Chrome_WinID%
			WinWaitActive, ahk_id %Chrome_WinID%
		}

		Clipboard = ; Null
		SendInput, ^{SC02E} ; Send Ctrl+C
		ClipWait, 0.5 ; Wait for the clipboard to contain text.
		
		If InArray(ItemsArray, Clipboard)
		{
			MsgBox, 0, Error, Already in array!, 0.5
			Return
		}

		If (( StrLen( Clipboard ) = 0 ) or (Clipboard = CUR_CLIPBOARD))
		{
			MsgBox, 0, Error, There is nothing to paste!, 0.5
			Return
		}

		If (Pattern and ( StrLen( Clipboard ) > 0 ) and not RegExMatch(Clipboard, Pattern,, 1))
		{
			MsgBox, 0, Error, Text not match pattern!, 0.5
			Return
		}

		IfWinExist, ahk_id %Npp_WinID%
		{
			WinRestore, ahk_id %Npp_WinID%
			WinActivate, ahk_id %Npp_WinID%
			WinWaitActive, ahk_id %Npp_WinID%

			WinGetActiveTitle, Npp_EditorTitle
			Npp_EditorTitle := RegExReplace(Npp_EditorTitle, "^[?] ", "")
			Npp_EditorTitle := RegExReplace(Npp_EditorTitle, "^[*]", "")

			If (Npp_EditorTitle == A_ScriptName or Npp_EditorTitle != DOCUMENT_NPP_TITLE)
			{
				MsgBox, 0, Error, Select another document!, 1.5
				Return
			}

			ClipBody := Clipboard
			ClipText := Clipboard

			If (InsertCounter == "Yes")
			{
				Counter := ItemsArray.Length() + 1
				ClipText := "<!-- " . Counter . " -->" . "`r`n" . ClipText
			}

			AddLines := NewLines + 1
			If (UseEnter == "No")
			{
				Loop, %AddLines%
				{
					ClipText := ClipText . "`r`n"
				}
			}

			Clipboard = ; Null
			Clipboard := ClipText
			ClipWait, 0.5 ; Wait for the clipboard to contain text.

			If (( StrLen( Clipboard ) = 0 ) or (Clipboard == CUR_CLIPBOARD))
			{
				MsgBox, 0, Error, Plaease`, %A_Space%RETRY!, 0.5
				Return
			}

			If (MsgTime > 0) 
			{
				MsgBox, 0,, %Clipboard%, % Round(MsgTime/1000, 3)
			}

			WinActivate, ahk_id %Npp_WinID%
			WinWaitActive, ahk_id %Npp_WinID%

			SendInput, {F2}
			Sleep, 100
			SendInput, {Up}
			Sleep, 100
			SendInput, {End}
			Sleep, 100
			; SendInput, ^v
			SendInput, ^{SC02F} ; Send Ctrl+V

			Sleep, 500

			If (UseEnter == "Yes")
			{
				SendInput, {Enter %NewLines%}
			}

			If RegExMatch(Npp_EditorTitle, ".*[.].*",, 1)
			{
				SendInput, ^{SC01F} ; Send Ctrl+S
			}

			ItemsArray.Insert(ClipBody)
			ArrayLengthAfter := ItemsArray.Length()
		}

		If (CloseWindow == "Yes" && ArrayLengthAfter > ArrayLengthBefore)
		{
			WinActivate, ahk_id %Chrome_WinID%
			WinWaitActive, ahk_id %Chrome_WinID%
			SendInput, ^{F4} ; Send Control+F4
		}

		If (CUR_CLIPBOARD and (Clipboard != CUR_CLIPBOARD))
		{
			Clipboard = ; Null
			Clipboard := CUR_CLIPBOARD
			ClipWait, 0.5 ; Wait for the clipboard to contain text.
		}

		If (not SaveClipboard)
		{
		 Clipboard = ; Null
		}

		WinActivate, ahk_id %LastActive_WinID%
	}

	; Clear all temporary variables
	; --------------------------------------
	; VarSetCapacity(CUR_CLIPBOARD, 0)
	; VarSetCapacity(Npp_EditorTitle, 0)
	; VarSetCapacity(ClipBody, 0)
	; VarSetCapacity(ClipText, 0)
	; VarSetCapacity(Counter, 0)
	; VarSetCapacity(AddLines, 0)
	; VarSetCapacity(ArrayLengthAfter, 0)
	; Sleep, 500
	; --------------------------------------

	Return
}

SC04F:: ; Numpad1
{
	ControlGet, Bool, Visible,,, %SCRIPT_WIN_TITLE%
	If (Bool)
	{
		Gui, %MainGUI%:Submit, Hide
	} 
	Else
	{
		Gui, %MainGUI%:Show, xCenter yCenter h50 w340, %SCRIPT_WIN_TITLE%
	}
	Return
}

; ------------ GUI BUTTONS ------------
ResetArray:
{
	ItemsArray := [] ; Сброс таблицы проверки дубликатов
	Gui, Submit, Hide
	MsgBox, 0, %SCRIPT_WIN_TITLE%, Done!, 0.5
	Return
}

; ------------- FUNCTIONS -------------
InArray(haystack, needle) {
	If not isObject(haystack)
	{
		Return, False
	}
	If (haystack.Length() == 0)
	{
		Return, False
	}
	For k, v in haystack
	{
		If (v == needle)
		{
			Return, True
		}
	}
	Return, False
}
