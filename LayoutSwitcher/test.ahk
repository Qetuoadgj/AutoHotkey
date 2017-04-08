#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

Ctrl_C := "^{vk43}"
Ctrl_V := "^{vk56}"
Select_Left := "^+{Left}"
Select_Right := "^+{Right}"

Next_Case_ID := 0

NumPad0::
{
	Critical
	/*
	; -----------------------------------------------------------------------------------
	; ���������� ����������� ������ ������, ���������� ���������� "Clipboard_All_Tmp"
	; -----------------------------------------------------------------------------------
	Clipboard_All_Tmp = ; null
	Clipboard_All_Tmp := ClipboardAll
	*/
	
	Selected_Text := Edit_Text.Select()
	Converted_Text_Data := Edit_Text.Convert_Case( Selected_Text, Next_Case_ID )
	Next_Case_ID := Converted_Text_Data["case"]
	Converted_Text := Converted_Text_Data["text"]
	Edit_Text.Paste( Converted_Text )


	/*
	; -----------------------------------------------------------------------------------
	; �������������� ����������� ������ ������, ������� ���������� "Clipboard_All_Tmp"
	; -----------------------------------------------------------------------------------
	Clipboard = ; null
	Clipboard := Clipboard_All_Tmp
	ClipWait, 1.0
	Clipboard_All_Tmp = ; null
	*/
	/*
	; -----------------------------------------------------------------------------------
	; ��������� ������������ ������
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

class Edit_Text
{
	static Ctrl_C := "^{vk43}"
	static Ctrl_V := "^{vk56}"
	static Select_Left := "^+{Left}"
	static Select_Right := "^+{Right}"

	static Title_Case_Symbols := "(\_|\-|\.)"
	static Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b)"
	
	Select()
	{
		static Selected_Text
		; -----------------------------------------------------------------------------------
		; ��������� ������ / ��������� ��� �����������, ���������� ���������� "Selected_Text"
		; -----------------------------------------------------------------------------------
		Clipboard = ; null
		SendInput, % This.Ctrl_C
		ClipWait, 0.05
		Selected_Text = ; null
		; Selection_Steps_Count := 0
		If ( not Selected_Text := Clipboard ) {
			Loop, 100
			{
				Clipboard = ; null
				SendInput, % This.Select_Left . This.Ctrl_C
				ClipWait, 0.5
				; Selection_Steps_Count += 1
				If RegExMatch( Clipboard, "\s" ) {
					Clipboard = ; null
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
	
	Convert_Case( Selected_Text, Next_Case_ID := 0 )
	{
		If ( not Selected_Text ) {
			Return
		}
		static Converted_Text
		static Output_Data
		; -----------------------------------------------------------------------------------
		; �������������� �������� ������, ���������� ���������� "Converted_Text"
		; -----------------------------------------------------------------------------------
		If ( Next_Case_ID = 0 ) {
			StringUpper, Converted_Text, Selected_Text
			If ( Converted_Text == Selected_Text ) {
				Next_Case_ID := Next_Case_ID < 2 ? Next_Case_ID + 1 : 0
			}
		}
		If ( Next_Case_ID = 1 ) {
			StringLower, Converted_Text, Selected_Text, T
			Converted_Text := RegExReplace( Converted_Text, This.Title_Case_Symbols . "([a-z])", "$1$U2" )
			Converted_Text := RegExReplace( Converted_Text, "i)" . This.Title_Case_Symbols . This.Upper_Case_Words, "$1$U2" )
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
		Output_Data := {} 
		Output_Data["text"] := Converted_Text
		Output_Data["case"] := Next_Case_ID
		Return, Output_Data
	}
	
	Paste( Converted_Text )
	{
		If ( not Converted_Text ) {
			Return
		}
		; -----------------------------------------------------------------------------------
		; ����������� "Converted_Text" � ����� ������ � �������� ������� "Control + V"
		; -----------------------------------------------------------------------------------
		Clipboard = ; null
		Clipboard := Converted_Text
		ClipWait, 1.0
		SendInput, % This.Ctrl_V
		; -----------------------------------------------------------------------------------
		Return, Clipboard
	}
}

class Script
{ ; ������� ���������� ��������
	
	Force_Single_Instance()
	{ ; ������� ��������������� ���������� ���� ����� �������� ������� (������������ ��� .exe � .ahk)
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
	{ ; ������� ���������� ���� ����� �������� ������� (������ ��� ���������� �����)
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
	{ ; ������� ������� ������� � ������� ���������������
		If ( not A_IsAdmin ) {
			Try {
				Run, *RunAs "%A_ScriptFullPath%"
			}
			ExitApp
		}
	}
	
	Name()
	{ ; ������� ��������� ����� �������� �������
		SplitPath, A_ScriptFullPath,,,, Name
		Return, Name
	}
	
}
