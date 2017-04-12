#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

Ctrl_C := "^{vk43}"
Ctrl_V := "^{vk56}"
Select_Left := "^+{Left}"
Select_Right := "^+{Right}"

NumPad0::
{
	Selected_Text := Edit_Text.Select()
	Converted_Text := Edit_Text.Convert_Case( Selected_Text, false )
	Edit_Text.Paste( Converted_Text )
	Sleep, 50
	Return
}

NumPad1::
{
	; -----------------------------------------------------------------------------------
	; Выделение текста / получение уже выделенного, назначение переменной "Selected_Text"
	; -----------------------------------------------------------------------------------
	Selected_Text := Edit_Text.Select()
	; -----------------------------------------------------------------------------------
	; Определение словаря, полностью соответствующего тексту
	; -----------------------------------------------------------------------------------
	Selected_Text_Dictionary := Edit_Text.Dictionary( Selected_Text )
	Converted_Text := Edit_Text.Replace_By_Dictionaries( Selected_Text, Selected_Text_Dictionary, "Russian" )
	; MsgBox, % Selected_Text_Dictionary ":`n" Edit_Text.Dictionaries[Selected_Text_Dictionary]
	; ToolTip, % Selected_Text "`n" Converted_Text
	Edit_Text.Paste( Converted_Text )
	; -----------------------------------------------------------------------------------
	Sleep, 50
	Return
}

NumPad2::
{
	/*
	Layout_HKL := Layout.Get_HKL( "A" )
	Layout_KLID := Layout.KLID( Layout_HKL )
	
	Layouts_List_Size := Layout.Layouts_List.MaxIndex()
	Layout_Index := Layout.Get_Index( Layout_HKL )
	Next_Layout_Index := Layout_Index + 1 > Layouts_List_Size ? 1 : Layout_Index + 1
	Next_Layout_HKL := Layout.Layouts_List[Next_Layout_Index].HKL
	Next_Layout_Full_Name := ДфнщгеюДфнщгеі_ДшіехТуче_Дфнщге_ШтвучїюАгдд_Тфьу
	Layout.Change( Next_Layout_HKL )
		
	; Layout.Next( "A" )
	
	ToolTip, % "HKL: " Layout_HKL "`n" "KLID: " Layout_KLID "`n" "Index: " Layout_Index "`n" "Next HKL: " Next_Layout_HKL
	*/
	
	Selected_Text := Edit_Text.Select()
	Selected_Text_Dictionary := Edit_Text.Dictionary( Selected_Text )
	If ( not Selected_Text_Dictionary ) {
		Text_Layout_Index := Layout.Get_Index( Layout.Get_HKL( "A" ) )
		Selected_Text_Dictionary := Layout.Layouts_List[Text_Layout_Index].Full_Name
	} Else {
		Text_Layout_Index := Layout.Get_Index_By_Name( Selected_Text_Dictionary )
	}
	If ( Text_Layout_Index ) {
		Next_Layout_Index := Text_Layout_Index + 1 > Layout.Layouts_List.MaxIndex() ? 1 : Text_Layout_Index + 1
		Next_Layout_Full_Name := Layout.Layouts_List[Next_Layout_Index].Full_Name
		Converted_Text := Edit_Text.Replace_By_Dictionaries( Selected_Text, Selected_Text_Dictionary, Next_Layout_Full_Name )
		Edit_Text.Paste( Converted_Text )
		Next_Layout_HKL := Layout.Layouts_List[Next_Layout_Index].HKL
		Layout.Change( Next_Layout_HKL )
		
		Next_Layout_Display_Name := Layout.Layouts_List[Next_Layout_Index].Display_Name
		ToolTip( Next_Layout_Full_Name " - " Next_Layout_Display_Name )
	}
	Sleep, 50
	Return
}

Exit

class Layout
{
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	static WM_INPUTLANGCHANGEREQUEST := 0x0050
	static INPUTLANGCHANGE_FORWARD := 0x0002
	static INPUTLANGCHANGE_BACKWARD := 0x0004
	static WM_INPUTLANGCHANGE := 0x51
	
	static Layouts_List := Layout.Get_Layouts_List()
	
	Get_Layouts_List()
	{
		static Layouts_List, Layouts_List_Size
		static Layout_HKL, Layout_Name, Layout_Full_Name, Layout_Display_Name
		VarSetCapacity( List, A_PtrSize * 5 )
		Layouts_List_Size := DllCall( "GetKeyboardLayoutList", Int, 5, Str, List )
		Layouts_List := []
		Loop, % Layouts_List_Size
		{
			Layout_HKL := NumGet( List, A_PtrSize * ( A_Index - 1 ) ) ; & 0xFFFF
			Layout_Name := This.Language_Name( Layout_HKL, false )
			Layout_Full_Name := This.Language_Name( Layout_HKL, true )
			Layout_Display_Name := This.Display_Name( Layout_HKL )
			Layouts_List[A_Index] := {}
			Layouts_List[A_Index].HKL := Layout_HKL
			Layouts_List[A_Index].Name := Layout_Name
			Layouts_List[A_Index].Full_Name := Layout_Full_Name
			Layouts_List[A_Index].Display_Name := Layout_Display_Name
		}
		Return, Layouts_List
	}
	
	Language_Name( ByRef HKL, ByRef Full_Name := false )
	{
		static LocID, LCType, Size
		LocID := HKL & 0xFFFF
		LCType := Full_Name ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0 ) * 2
		VarSetCapacity( localeSig, Size, 0 )
		DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size )
		Return, localeSig
	}
	
	Display_Name( ByRef HKL )
	{
		static KLID
		KLID := This.KLID( HKL )
		RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Display Name"
		if (not Display_Name) {
			Return, False
		}
		DllCall( "Shlwapi.dll\SHLoadIndirectString", "Ptr", &Display_Name, "Ptr", &Display_Name, "UInt", outBufSize := 50, "UInt", 0 )
		if (not Display_Name) {
			RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Text"
		}
		Return, Display_Name
	}
	
	KLID( Byref HKL )
	{
		static KLID, Prior_HKL
		VarSetCapacity( KLID, 8 * ( A_IsUnicode ? 2 : 1 ) )
		Prior_HKL := DllCall( "GetKeyboardLayout", "Ptr", DllCall( "GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr" ), "Ptr" )
		if ( not DllCall( "ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0 ) or not DllCall( "GetKeyboardLayoutName", "Ptr", &KLID ) or not DllCall( "ActivateKeyboardLayout", "Ptr", Prior_HKL, "UInt", 0 ) ) {
			Return, False
		}
		Return, StrGet(&KLID)
	}
	
	Get_HKL( ByRef Window := "A" )
	{
		static HKL
		If ( hWnd := WinExist( Window ) ) {
			WinGetClass, Window_Class
			If ( Window_Class = "ConsoleWindowClass" ) {
				WinGet, Console_PID, PID
				DllCall( "AttachConsole", Ptr, Console_PID )
				VarSetCapacity( buff, 16 )
				DllCall( "GetConsoleKeyboardLayoutName", Str, buff )
				DllCall( "FreeConsole" )
				HKL := SubStr( buff, -3 )
				HKL := HKL ? "0x" . HKL : 0
			} else {
				HKL := DllCall( "GetKeyboardLayout", Ptr, DllCall( "GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr ), Ptr ) ; & 0xFFFF
			}
			If ( not HKL )
			{ ; рабочий стол Windows
				If ( hWnd := WinExist( "ahk_class Progman ahk_exe Explorer.EXE" ) ) {
					HKL := DllCall( "GetKeyboardLayout", Ptr, DllCall( "GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr ), Ptr ) ; & 0xFFFF
				}
			}
			Return, HKL
		}
	}
	
	Next( ByRef Window := "A" )
	{
		If ( hWnd := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST, % This.INPUTLANGCHANGE_FORWARD,,, ahk_id %hWnd%
		}
	}
	
	Change( Byref HKL, ByRef Window := "A" )
	{
		If ( hWnd := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST,, % HKL,, ahk_id %hWnd%
		}
	}
	
	Get_Index( Byref HKL )
	{
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( This.KLID( Layout.HKL ) = This.KLID( HKL ) ) {
				Return, Index
			}
		}
	}
	
	Get_Index_By_Name( Byref Full_Name )
	{
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( Layout.Full_Name = Full_Name ) {
				Return, Index
			}
		}
	}
}

class Edit_Text
{ ; функции получения / обработки текста
	static Ctrl_C := "^{vk43}"
	static Ctrl_V := "^{vk56}"
	static Select_Left := "^+{Left}"
	static Select_Right := "^+{Right}"

	static Title_Case_Symbols := "(\_|\-|\.)"
	static Title_Case_Match := "(.)"
	static Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b|KLID\b)"
	
	static Next_Case_ID := "U"
	
	static Dictionaries := {}
	static Dictionaries.Russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\\ячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ//ЯЧСМИТЬБЮ,"
	static Dictionaries.English := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""||ZXCVBNM<>?"
	static Dictionaries.Ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ґячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ҐЯЧСМИТЬБЮ,"
	
	Select()
	{ ; функция получения выделенного текста либо выделения текста влево до первого пробела
		static Selected_Text
		; -----------------------------------------------------------------------------------
		; Выделение текста / получение уже выделенного, назначение переменной "Selected_Text"
		; -----------------------------------------------------------------------------------
		Clipboard = ; Null
		SendInput, % This.Ctrl_C
		ClipWait, 0.05
		Selected_Text = ; Null
		; Selection_Steps_Count := 0
		If ( not Selected_Text := Clipboard ) {
			Loop, 100
			{
				Clipboard = ; Null
				SendInput, % This.Select_Left . This.Ctrl_C
				ClipWait, 0.5
				; Selection_Steps_Count += 1
				If RegExMatch( Clipboard, "\s" ) {
					Clipboard = ; Null
					SendInput, % This.Select_Right . This.Ctrl_C
					ClipWait, 0.5
					; Selection_Steps_Count -= 1
					Break
				}
				Selected_Text := Clipboard
			} Until StrLen( Clipboard ) <> StrLen( Selected_Text )
		}
		; -----------------------------------------------------------------------------------
		Return, Selected_Text
	}
	
	Convert_Case( ByRef Selected_Text, ByRef Force_Case_ID := 0 )
	{ ; функция смены регистра текста
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; Преобразование регистра текста, назначение переменной "Converted_Text"
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		This.Next_Case_ID := Force_Case_ID ? Force_Case_ID : This.Next_Case_ID
		If ( This.Next_Case_ID = "U" ) {
			StringUpper, Converted_Text, Selected_Text
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "T"
			}
		}
		If ( This.Next_Case_ID = "T" ) {
			StringLower, Converted_Text, Selected_Text, T
			Converted_Text := RegExReplace( Converted_Text, This.Title_Case_Symbols . This.Title_Case_Match, "$1$U2" )
			Converted_Text := RegExReplace( Converted_Text, "i)" . This.Title_Case_Symbols . This.Upper_Case_Words, "$1$U2" )
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "L"
			}
		}
		If ( This.Next_Case_ID = "L" ) {
			StringLower, Converted_Text, Selected_Text
			If ( not Force_Case_ID and Converted_Text == Selected_Text ) {
				This.Next_Case_ID := "U"
			}
		}
		If ( not Force_Case_ID ) {
			If ( This.Next_Case_ID = "U" ) {
				This.Next_Case_ID := "T"
			} Else If ( This.Next_Case_ID = "T" ) {
				This.Next_Case_ID := "L"
			} Else If ( This.Next_Case_ID = "L" ) {
				This.Next_Case_ID := "U"
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Converted_Text
	}
	
	Dictionary( ByRef Selected_Text )
	{ ; функция сравения текста со словарями ( определение словаря, соответствующего тексту )
		static Language
		static Dictionary
		static Same_Dictionary
		; -----------------------------------------------------------------------------------
		; Определение словаря, полностью соответствующего тексту
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		For Language, Dictionary in This.Dictionaries {
			; MsgBox, % Language " = " Dictionary
			Loop, Parse, Selected_Text
			{
				Same_Dictionary := InStr( Dictionary, A_LoopField, 1 ) or RegExMatch( A_LoopField, "\s" )
			} Until not Same_Dictionary
			If ( Same_Dictionary ) {
				Return, Language
			}
		}
		; -----------------------------------------------------------------------------------
	}
	
	Replace_By_Dictionaries( ByRef Selected_Text, ByRef Current_Dictionary, ByRef Next_Dictionary )
	{ ; функция замены символов одного словаря соответствующими ( по порядку ) символами другого ( смена раскладки текста )
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; Замена символов словаря "Current_Dictionary" соответствующими символами "Next_Dictionary"
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		Converted_Text = ; Null
		Loop, Parse, Selected_Text
		{
			If ( Current_Dictionary_Match := InStr( This.Dictionaries[Current_Dictionary], A_LoopField, 1 ) ) {
				Converted_Text .= SubStr( This.Dictionaries[Next_Dictionary], Current_Dictionary_Match, 1 )
			} Else {
				Converted_Text .= A_LoopField
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Converted_Text
	}
	
	Paste( ByRef Converted_Text )
	{ ; функция отправки буфер текста обмена / вывода текста
		; -----------------------------------------------------------------------------------
		; Отправление "Converted_Text" в буфер обменя и отправка команды "Control + V"
		; -----------------------------------------------------------------------------------
		If ( not Converted_Text ) {
			Return
		}
		Clipboard = ; Null
		Clipboard := Converted_Text
		ClipWait, 1.0
		SendInput, % This.Ctrl_V
		; -----------------------------------------------------------------------------------
		Return, Clipboard
	}
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

IniWrite( ByRef Key, ByRef File, ByRef Section, ByRef Value )
{ ; замена стандартонго IniWrite (записывает только измененные параметры)
	if (not File) {
		Return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead, Test_Value, %File%, %Section%, %Key%
	If (not Test_Value = Value) {
		IniWrite, %Value%, %File%, %Section%, %Key%
	}
}

ToolTip( ByRef text, ByRef time := 800 )
{
	Tooltip, %text%
	SetTimer, Clear_ToolTips, %time%
}

Clear_ToolTips:
{
	ToolTip
	SetTimer, %A_ThisLabel%, Delete
	Return
}

