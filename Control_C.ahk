; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/Control_C.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

; #SingleInstance, Force
; #Persistent ; to make it run indefinitely
; SetBatchLines, -1 ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

; Process, Priority,, High
; DetectHiddenWindows, Off

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.1.6"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION

; MsgBox, 0, %SCRIPT_WIN_TITLE%, Ready!, 0.5

Ctrl_C := "^{vk43}" . "{Ctrl Up}"
Ctrl_V := "^{vk56}" . "{Ctrl Up}"

; ERROR_COUNT := 0

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
	; DOCUMENT_PATH := %0% ? %0% : "D:\Google Диск\HTML\tmp\html\Dawson_Miller_2.html"
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
		If ( Window.State( "ahk_id " Npp_WinID ) != 0 ) {
			WinRestore, ahk_id %Npp_WinID%
		}
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
	WinGet, Chrome_WinID, ID, ahk_exe chrome.exe ahk_class Chrome_WidgetWin_1
	
	ArrayLengthBefore := ItemsArray.Length()
	
	IfWinExist, ahk_id %Chrome_WinID%
	{
		If (SaveClipboard)
		{
			CUR_CLIPBOARD = ; Null
			CUR_CLIPBOARD := Clipboard
		}
		
		If not WinActive("ahk_id " Chrome_WinID)
		{
			WinActivate, ahk_id %Chrome_WinID%
			WinWaitActive, ahk_id %Chrome_WinID%
		}
		
		Clipboard = ; Null
		SendInput, % Ctrl_C
		ClipWait, 0.05
		
		Selected_Text = ; Null
		Selected_Text := Clipboard
		If ( not Selected_Text or StrLen( Selected_Text ) = 0 ) {
			Loop, 2
			{
				Clipboard = ; Null
				SendInput, % Ctrl_C
				ClipWait, 0.5
			}
			Selected_Text := Clipboard
		}
		
		If InArray(ItemsArray, Selected_Text)
		{
			MsgBox, 0, Error, Already in array!, 0.5
			Return
		}
		
		If (( StrLen( Selected_Text ) = 0 )) ; or (Selected_Text = CUR_CLIPBOARD)
		{
			MsgBox, 0, Error, There is nothing to paste!, 0.5
			Return
		}
		
		If (Pattern and ( StrLen( Selected_Text ) > 0 ) and not RegExMatch(Selected_Text, Pattern,, 1))
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
			
			ClipBody := Selected_Text
			ClipText := Selected_Text
			
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
			ClipWait, 1.0
			
			; If (ERROR_COUNT > 0)
			; {
				; CUR_CLIPBOARD = ; Null
				; ERROR_COUNT := 0
			; }
			
			If ( StrLen( Clipboard ) = 0 ) ;or (Clipboard == CUR_CLIPBOARD))
			{
				MsgBox, 0, Error, Plaease`, %A_Space%RETRY!, 0.5
				; ERROR_COUNT ++
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
			SendInput, % Ctrl_V ; Send Ctrl+V
			
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
		
		If (CUR_CLIPBOARD) ;(CUR_CLIPBOARD and (Clipboard != CUR_CLIPBOARD))
		{
			Clipboard = ; Null
			Clipboard := CUR_CLIPBOARD
			ClipWait, 1.0
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
;-------------------------------
ToolTip( ByRef text, ByRef time := 800 )
{ ; функция вывода высплывающей подсказки с последующим ( убирается по таймеру )
	Tooltip, %text%
	SetTimer, Clear_ToolTips, %time%
}

Clear_ToolTips:
{ ; рутина очистки подсказок и отключения связанных с ней таймеров
	ToolTip
	SetTimer, %A_ThisLabel%, Off
	Return
}

class Script
{ ; функции управления скриптом
	
	Force_Single_Instance()
	{ ; функция автоматического завершения всех копий текущего скрипта (одновременно для .exe и .ahk)
		static Detect_Hidden_Windows_Tmp
		static File_Types, Index, File_Type
		static Script_Name, Script_Full_Path
		Detect_Hidden_Windows_Tmp := A_DetectHiddenWindows
		#SingleInstance, Off
		DetectHiddenWindows, On
		File_Types := [ ".exe", ".ahk" ]
		For Index, File_Type in File_Types {
			Script_Name := RegExReplace( A_ScriptName, "^(.*)\.(.*)$", "$1" ) . File_Type
			Script_Full_Path := A_ScriptDir . "\" . Script_Name
			This.Close_Other_Instances( Script_Full_Path . "ahk_class AutoHotkey" )
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}

	Close_Other_Instances( ByRef Script_Full_Path )
	{ ; функция завершения всех копий текущего скрипта (только для указанного файла)
		static Process_ID
		Script_Full_Path := Script_Full_Path ? Script_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % Script_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		Loop, %Process_List%
		{
			Process_ID := Process_List%Process_Count%
			If ( not Process_ID = Current_ID ) {
				WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
				Process, Close, %Process_PID%
			}
			Process_Count += 1
		}
	}

	Run_As_Admin( ByRef Params := "" )
	{ ; функция запуска скрипта с правами адиминистратора
		If ( not A_IsAdmin ) {
			Try {
				Run, *RunAs "%A_ScriptFullPath%" %Params%
			}
			ExitApp
		}
	}
	
	Name()
	{ ; функция получения имени текущего скрипта
		SplitPath, A_ScriptFullPath,,,, Name
		Return, Name
	}
}

class Window
{
	Is_Full_Screen( ByRef Win_Title := "A" )
	{ ; функция проверки полноэкранного режима
		static Win_ID
		Win_ID := WinExist( Win_Title )
		If ( not Win_ID ) {
			Return, False
		}
		If ( Win_ID = Windows.Desktop_ID ) {
			Return, False
		}
		WinGet, Win_Style, Style, ahk_id %Win_ID%
		If ( Win_Style & 0x20800000 ) { ; 0x800000 is WS_BORDER, 0x20000000 is WS_MINIMIZE, no border and not minimized
			Return, False
		}
		WinGetPos,,, Win_W, Win_H, %Win_Title%
		If ( Win_H < A_ScreenHeight or Win_W < A_ScreenWidth ) {
			Return, False
		}
		Return, True
	}
	
	State( ByRef Win_Title := "A" )
	{ ; функция определения состояния окна ( сернуто / развернуто ... )
		; -1: The window is minimized (WinRestore can unminimize it). 
		; 1: The window is maximized (WinRestore can unmaximize it).
		; 0: The window is neither minimized nor maximized.
		static Win_ID
		static WinState
		Win_ID := WinExist( Win_Title )
		If ( not Win_ID ) {
			Return, ERROR
		}
		WinGet, WinState, MinMax, ahk_id %Win_ID%
		Return, WinState
	}
}
