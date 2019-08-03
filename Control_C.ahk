; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/Raw/master/Control_C.ahk | v1.0.0

#NoEnv ; Recommended For performance and compatibility with future AutoHotkey releases.
; #Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

; Script.Force_Single_Instance()

#SingleInstance, Force
; #Persistent ; to make it run indefinitely
; SetBatchLines, -1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

; Process, Priority,, High
; DetectHiddenWindows, Off

SCRIPT_NAME := RegExReplace(A_ScriptName, "(\.(ahk|exe))+$", "") ;GetScriptName()
SCRIPT_VERSION := "1.1.7"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

OnExit, OnAppClose

; MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

Ctrl_C := "^{vk43}" . "{Ctrl Up}"
Ctrl_V := "^{vk56}" . "{Ctrl Up}"
/*
CreateLogo:
{
	logoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".png"
	logoURL := "https://Raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Images/AddURL.png"
	; "https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Chrome_Logo.svg/64px-Chrome_Logo.svg.png"
	logoSize := 64
	logoAlpha := 0.95

	GdipCreateLogo(logoFile, logoURL, logoSize, logoAlpha)
}
*/
SetTrayIcon:
{
	IcoFile := A_ScriptDir . "\Images\" . SCRIPT_NAME . ".ico"
	If FileExist(IcoFile) {
		Menu, Tray, Icon, %IcoFile%
	}
}

CreateGUI:
{
	MainGUI := SCRIPT_NAME . "_"
	Gui, %MainGUI%: +AlwaysOnTop
	Gui, %MainGUI%: Add, Button, x5 y5 w90 h40 gResetArray, Reset Array
	Gui, %MainGUI%: Add, Text, x105 y7 w55 h20, New Lines
	Gui, %MainGUI%: Add, ComboBox, x160 y5 w45 h300 vNewLines, -2|-1|0||1|2|3|4|5|6|7|8|9|10
	Gui, %MainGUI%: Add, Text, x105 y30 w55 h20, Use Enter
	Gui, %MainGUI%: Add, ComboBox, x160 y27 w45 h300 vUseEnter, Yes||No|
	Gui, %MainGUI%: Add, Text, x215 y7 w80 h20, Close Window
	Gui, %MainGUI%: Add, ComboBox, x290 y5 w45 h300 vCloseWindow, Yes|No||
	Gui, %MainGUI%: Add, Text, x215 y30 w80 h20, Insert Counter
	Gui, %MainGUI%: Add, ComboBox, x290 y27 w45 h300 vInsertCounter, Yes|No||
	Gui, %MainGUI%: Submit, Hide
}

DefineGlobals:
{
	ItemsArray := [] ; Object() ; Таблица проверки дубликатов

	RestoreClipboard := true

	Pattern := "<div Class="".*?"" .*?><\/div>"
	MsgTime := 10
}

SetDocumentWindow:
{
	DOCUMENT_PATH := A_Args[1] ? A_Args[1] : "D:\Google Диск\HTML\html\2.0.4.html"
	KeyWait, Shift, D T0.005
	if (not ErrorLevel) {
		FileSelectFile, NEW_DOCUMENT_PATH,, %A_WorkingDir% ; открываем окно для выбора файла
		DOCUMENT_PATH := NEW_DOCUMENT_PATH ? NEW_DOCUMENT_PATH : DOCUMENT_PATH
	}
	; DOCUMENT_PATH := %0% ? %0% : "D:\Google Диск\HTML\tmp\html\Dawson_Miller_2.html"
	; DOCUMENT_FILE := RegExReplace(DOCUMENT_PATH, ".*\\(.*)", "$1")
	DOCUMENT_NPP_TITLE := DOCUMENT_PATH . " - Notepad++"

	If (WinExist("*" . DOCUMENT_NPP_TITLE) || WinExist(DOCUMENT_NPP_TITLE)) {
		WinGet, Npp_WinID, ID
	}
	/*
	for n, param in A_Args  ; For each parameter:
	{
		MsgBox Parameter number %n% is %param%.
	}
	*/
	If ArrayGetIndex(A_Args, "new_win=1") {
		Npp_WinID := 0
	}

	EDITOR_PATH := ""
	EDITOR_PATH_ARRAY := []
	EDITOR_PATH_ARRAY.Push(A_ProgramFiles . "\Notepad++\notepad++.exe")
	EDITOR_PATH_ARRAY.Push(A_ProgramFiles . " (86)\Notepad++\notepad++.exe")
	EDITOR_PATH_ARRAY.Push("D:\Program Files\Notepad++\notepad++.exe")
	Path := ""
	for Index, Path in EDITOR_PATH_ARRAY {
		if FileExist(Path) {
			EDITOR_PATH := Path
			break
		}
	}
	if (EDITOR_PATH = "") {
		SoundPlay, *16
		MsgBox, 0, Error, Can't find notepad++.exe, 1.5
		ExitApp
	}
	
	If (FileExist(EDITOR_PATH) && FileExist(DOCUMENT_PATH)) {
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

	if WinExist("ahk_id " . Npp_WinID) {
		WinActivate, ahk_id %Npp_WinID%
		WinWaitActive, ahk_id %Npp_WinID%
		WinMaximize, ahk_id %Npp_WinID%
		; If (Window.State("ahk_id " Npp_WinID) != 0) {
		WinRestore, ahk_id %Npp_WinID%
		; }
		MsgBox, 0, %SCRIPT_WIN_TITLE%, Path: %DOCUMENT_PATH%`nID: %Npp_WinID%`nPID: %Npp_WinPID%, 1.5
		WinWaitClose, ahk_id %Npp_WinID%
		SoundPlay, *64
		ExitApp
	} 
	else {
		SoundPlay, *16
		MsgBox, 0, Error, Open document:`n%DOCUMENT_PATH%, 1.5
		ExitApp
	}
}

MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

SC052:: ; Numpad0
{
	Critical, On
	
	WinGet, LastActive_WinID, ID, A
	Sleep, 50
	WinGet, Chrome_WinID, ID, ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1
	Sleep, 50

	ArrayLengthBefore := ItemsArray.Length()

	If WinExist("ahk_id " . Chrome_WinID) {
		If (RestoreClipboard) {
			gosub, CLIPBOARD_SAVE
		}

		If (not WinActive("ahk_id " Chrome_WinID)) {
			WinActivate, ahk_id %Chrome_WinID%
			WinWaitActive, ahk_id %Chrome_WinID%
		}
		
		; gosub, BrowserPageActivate

		Clipboard := "" ; Null
		ControlSend, Chrome_RenderWidgetHostHWND1,  % Ctrl_C, ahk_id %Chrome_WinID%

		Selected_Text := Copy()
		If (StrLen(Selected_Text) = 0) {
			Loop, 3
			{
				; gosub, BrowserPageActivate
				Clipboard := "" ; Null
				WinActivate, ahk_id %Chrome_WinID%
				WinWaitActive, ahk_id %Chrome_WinID%,,5
				ControlSend, Chrome_RenderWidgetHostHWND1, % Ctrl_C, ahk_id %Chrome_WinID%
				SendInput, % Ctrl_C
				ClipWait, 0.5
				Selected_Text := Clipboard
				if StrLen(Selected_Text) > 0 {
					break
				}
			}
		}
		
		; gosub, RestoreMusePos

		If ArrayGetIndex(ItemsArray, Selected_Text) {
			MsgBox, 0, Error, Already in Array!, 0.5
			Return
		}

		If ((StrLen(Selected_Text) = 0) or Selected_Text == CUR_CLIPBOARD) {
			MsgBox, 0, Error, There is nothing to paste!, 0.5
			Return
		}

		If (Pattern and not RegExMatch(Selected_Text, Pattern,, 1) && StrLen(Selected_Text) < 200) {
			MsgBox, 0, Error, Text not match pattern!, 0.5
			Return
		}

		if WinExist("ahk_id " . Npp_WinID) {
			WinRestore, ahk_id %Npp_WinID%
			WinActivate, ahk_id %Npp_WinID%
			WinWaitActive, ahk_id %Npp_WinID%

			WinGetActiveTitle, Npp_EditorTitle
			Npp_EditorTitle := RegExReplace(Npp_EditorTitle, "^[?] ", "")
			Npp_EditorTitle := RegExReplace(Npp_EditorTitle, "^[*]", "")

			If (Npp_EditorTitle == A_ScriptName or Npp_EditorTitle != DOCUMENT_NPP_TITLE) {
				MsgBox, 0, Error, Select another document!, 1.5
				Return
			}

			ClipBody := Selected_Text
			ClipText := Selected_Text

			If (InsertCounter == "Yes") {
				Counter := ItemsArray.Length() + 1
				ClipText := "<!-- " . Counter . " -->" . "`r`n" . ClipText
			}

			EmptyLines := ""
			AddLines := Abs(NewLines) + 1

			If (UseEnter == "No") {
				Loop, %AddLines%
				{
					EmptyLines .= "`r`n"
				}
				ClipText := NewLines > -1 ? ClipText . EmptyLines : EmptyLines . ClipText
			}

			If ((StrLen(ClipText) = 0) or (not RegExMatch(ClipText, Pattern,, 1) && StrLen(Selected_Text) < 200)) {
				MsgBox, 0, Error, Plaease`, %A_Space%Retry!, 0.5
				Return
			}

			If (MsgTime > 0) {
				MsgBox, 0,, %ClipText%, % Round(MsgTime/1000, 3)
			}

			WinActivate, ahk_id %Npp_WinID%
			WinWaitActive, ahk_id %Npp_WinID%

			SendInput, {F2}
			Sleep, 10
			SendInput, {Up}
			Sleep, 10
			SendInput, {End}
			Sleep, 10

			If (UseEnter == "Yes" and NewLines < 0) {
				SendInput, {Enter %AddLines%}
				Sleep, 10
			}

			Paste(ClipText)

			Sleep, 500

			If (UseEnter == "Yes" and NewLines > -1) {
				SendInput, {Enter %AddLines%}
				Sleep, 10
			}

			CanMinimize := 0
			If RegExMatch(Npp_EditorTitle, ".*[.].*",, 1) {
				; SendInput, ^{SC01F} ; Send Ctrl+S
				; ControlSend, % "SysTabControl32", ^{SC01F}, ahk_id %Npp_WinID% ; Send Ctrl+S
				SendInput, {Ctrl Down}{SC01F}{Ctrl Up} ; Send Ctrl+S
				CanMinimize := 0 ; not ErrorLevel
			}

			ItemsArray.Insert(ClipBody)
			ArrayLengthAfter := ItemsArray.Length()

			if (CanMinimize) {
				WinMinimize, ahk_id %Npp_WinID%
			}
		}

		If (CloseWindow == "Yes" && ArrayLengthAfter > ArrayLengthBefore) {
			WinActivate, ahk_id %Chrome_WinID%
			WinWaitActive, ahk_id %Chrome_WinID%
			SendInput, ^{F4} ; Send Control+F4
		}

		If (RestoreClipboard) {
			Sleep, 50
			gosub, CLIPBOARD_RESTORE
		}

		WinActivate, ahk_id %LastActive_WinID%
	}
	Critical, Off
	Return
}

BrowserPageActivate:
{
	WinActivate, ahk_id %Chrome_WinID%
	WinWaitActive, ahk_id %Chrome_WinID%
	Sleep, 50
	;
	CoordMode, Mouse, Screen
	MouseGetPos, MousePosX, MousePosY	
	CoordMode, Mouse, Client
	ControlGetPos, conX, conY,,, Chrome_RenderWidgetHostHWND1, ahk_id %Chrome_WinID%
	ClickPosX := conX + 2
	ClickPosY := conY + 2
	MouseMove, %ClickPosX%, %ClickPosY%
	Click, Right, %ClickPosX%, %ClickPosY%
	Sleep, 50
	Send, {Esc}
	; Sleep, 5
	;
	Return
}

RestoreMusePos:
{
	CoordMode, Mouse, Screen
	MouseMove, %MousePosX%, %MousePosY%
	return
}

SC04F:: ; Numpad1
{
	ControlGet, Bool, Visible,,, %SCRIPT_WIN_TITLE%
	If (Bool) {
		Gui, %MainGUI%:Submit, Hide
	}
	Else {
		Gui, %MainGUI%:Show, xCenter yCenter h50 w340, %SCRIPT_WIN_TITLE%
	}
	Return
}

NumpadEnter::
{
	Send {Volume_Mute}
	return
}

OnAppClose:
{
	SoundSet, 0, MASTER, MUTE, 1 ; 0 = Un-Mute ; +1|-1 = Mute
	ExitApp
	return
}

; ------------ Gui Buttons ------------
ResetArray:
{
	ItemsArray := [] ; Сброс таблицы проверки дубликатов
	Gui, Submit, Hide
	MsgBox, 0, %SCRIPT_WIN_TITLE%, Done!, 0.5
	Return
}

ArrayGetIndex(Array, Value) {
	static k, v
	if (not isObject(Array)) {
		return
	}
	if (Array.Length() == 0) {
		return
	}
	for k, v in Array {
		if (v = Value) {
			return k
		}
	}
}

; #Include %A_ScriptDir%\Includes\FUNC_In_Array.ahk
; #Include %A_ScriptDir%\Includes\FUNC_ToolTip.ahk
; #Include %A_ScriptDir%\Includes\CLASS_Script.ahk
; #Include %A_ScriptDir%\Includes\CLASS_Windows.ahk
; #Include %A_ScriptDir%\Includes\CLASS_Window.ahk

Copy()
{ ; функция сохранения выделенного в редакторе текста в буфер обмена. Также возвращает скопированный текст.
	local
	Clipboard := ""											; очищаем буфер обмена
	SendInput, ^c											; нажимаем Ctrl+C
	ClipWait, 0.05, 0										; ждем пока данные передадутся в буфер обмена
	Selected_Text := Clipboard								; сохраняем текстовые данные из буфера обмена в переменную Selected_Text
	;
	; ToolTip, Selected_Text:`n"%Selected_Text%"
	return Selected_Text
}

Paste(Text)
{ ; функция вставки текста в редактор с использованием буфера обмена. Также возвращает скопированный в буфер текст.
	; -----------------------------------------------------------------------------------
	; Отправление "Text" в буфер обмена и отправка команды "Control + V"
	; -----------------------------------------------------------------------------------
	if (StrLen(Text) = 0) {
		return
	}
	Clipboard := "" ; Null
	Clipboard := Text
	ClipWait, 1.0
	SendInput, % "{Blind}{Ctrl Down}"
	Sleep, 1
	SendInput, % "{vk56}"
	Sleep, 1
	SendInput, % "{Blind}{Ctrl Up}"
	; -----------------------------------------------------------------------------------
	return Clipboard
}

Clipboard_Save:
{ ; рутина сохранения текущего буфера обмена в переменную Clipboard_Image
	Clipboard_Image := ""									; очищаем переменную Clipboard_Image
	Clipboard_Image := ClipboardAll							; сохраняем двоичные данные из буфера обмена в переменную Clipboard_Image
	return
}

Clipboard_Restore:
{ ; рутина восстановления буфера обмена из переменной Clipboard_Image. (Требует предварительного запуска рутины Clipboard_Save)
	Clipboard := ""											; очищаем буфер обмена
	Clipboard := Clipboard_Image							; помещаем в буфер обмена двоичные данные из переменной Clipboard_Image
	ClipWait, 1.0, 0										; ждем пока данные передадутся в буфер обмена
	VarSetCapacity(Clipboard_Image, 0)						; удаляем переменную Clipboard_Image из памяти
	return
}
