#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

Ctrl_C := "^{vk43}"
Ctrl_V := "^{vk56}"
Select_Left := "^+{Left}"
Select_Right := "^+{Right}"

Title_Case_Symbols := "(\_|\-|\.)"
Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b)"

Next_Case_ID := 0

NumPad0::
{
	Critical
	/*
	; -----------------------------------------------------------------------------------
	; Сохранение содержимого буфера обмена, назначение переменной "Clipboard_All_Tmp"
	; -----------------------------------------------------------------------------------
	Clipboard_All_Tmp = ; null
	Clipboard_All_Tmp := ClipboardAll
	*/
	; -----------------------------------------------------------------------------------
	; Выделение текста / получение уже выделенного, назначение переменной "Selected_Text"
	; -----------------------------------------------------------------------------------
	Clipboard = ; null
	SendInput, % Ctrl_C
	ClipWait, 0.05
	Selected_Text = ; null
	; Selection_Steps_Count := 0
	If ( not Selected_Text := Clipboard ) {
		Loop, 100
		{
			Clipboard = ; null
			SendInput, % Select_Left . Ctrl_C
			ClipWait, 0.5
			; Selection_Steps_Count += 1
			If RegExMatch( Clipboard, "\s" ) {
				Clipboard = ; null
				SendInput, % Select_Right . Ctrl_C
				ClipWait, 0.5
				; Selection_Steps_Count -= 1
				Break
			}
			Selected_Text := Clipboard
		} Until StrLen( Clipboard ) <> StrLen( Selected_Text )
	}
	; -----------------------------------------------------------------------------------
	; Преобразование регистра текста, назначение переменной "Converted_Text"
	; -----------------------------------------------------------------------------------
	If ( Next_Case_ID = 0 ) {
		StringUpper, Converted_Text, Selected_Text
		If ( Converted_Text == Selected_Text ) {
			Next_Case_ID := Next_Case_ID < 2 ? Next_Case_ID + 1 : 0
		}
	}
	If ( Next_Case_ID = 1 ) {
		StringLower, Converted_Text, Selected_Text, T
		Converted_Text := RegExReplace( Converted_Text, Title_Case_Symbols . "([a-z])", "$1$U2" )
		Converted_Text := RegExReplace( Converted_Text, "i)" . Title_Case_Symbols . Upper_Case_Words, "$1$U2" )
		If ( Converted_Text == Selected_Text ) {
			Next_Case_ID := Next_Case_ID < 2 ? Next_Case_ID + 1 : 0
		}
	}
	If ( Next_Case_ID = 2 ) {
		StringLower, Converted_Text, Selected_Text
		If ( Converted_Text == Selected_Text ) {
			Next_Case_ID := Next_Case_ID < 2 ? Next_Case_ID + 1 : 0
		}
	}
	Next_Case_ID := Next_Case_ID < 2 ? Next_Case_ID + 1 : 0
	; -----------------------------------------------------------------------------------
	; Отправление "Converted_Text" в буфер обменя и отправка команды "Control + C"
	; -----------------------------------------------------------------------------------
	Clipboard = ; null
	Clipboard := Converted_Text
	ClipWait, 1.0
	SendInput, % CTRL_V
	/*
	; -----------------------------------------------------------------------------------
	; Восстановление содержимого буфера обмена, очистка переменной "Clipboard_All_Tmp"
	; -----------------------------------------------------------------------------------
	Clipboard = ; null
	Clipboard := Clipboard_All_Tmp
	ClipWait, 1.0
	Clipboard_All_Tmp = ; null
	*/
	/*
	; -----------------------------------------------------------------------------------
	; Выделение вставленного текста
	; -----------------------------------------------------------------------------------
	If ( Selection_Steps_Count > 0 ) {
		SendInput, % StrReplace( Select_Left, "}", " " . Selection_Steps_Count . "}" )
	}
	; -----------------------------------------------------------------------------------
	*/
	
	; MsgBox,% "selected_text bool: " . (selected_text ? "True" : "False")
	Return
}

Exit

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

	Close_Other_Instances( Script_Full_Path )
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

	Run_As_Admin()
	{ ; функция запуска скрипта с правами адиминистратора
		If ( not A_IsAdmin ) {
			Try {
				Run, *RunAs "%A_ScriptFullPath%"
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
