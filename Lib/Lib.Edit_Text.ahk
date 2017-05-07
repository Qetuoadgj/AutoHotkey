class Edit_Text
{ ; ������� ��������� / ��������� ������
	static Ctrl_C := "^{vk43}" . "{Ctrl Up}"
	static Ctrl_V := "^{vk56}" . "{Ctrl Up}"
	static Select_Left := "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"
	static Select_Right := "^+{Right}" . "{Ctrl Up}" . "{Shift Up}"
	static Select_No_Starting_Space := "^+{Right}" . "{Ctrl Up}" . "{Shift Up}" . "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"
	static Select_No_Space := "^+{Right 2}" . "{Ctrl Up}" . "{Shift Up}" . "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"

	static Title_Case_Symbols := "(\_|\-|\.|\[|\(|\{)"
	static Title_Case_Match := "(.)"
	static Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b|KLID\b)"
	
	static Next_Case_ID := "U"
	
	static Dictionaries := {}
	static Dictionaries.English := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""||ZXCVBNM<>?"
	static Dictionaries.Russian := "�1234567890-=�����������������������\\���������. �!""�;%:?*()_+�����������������������//���������,"
	static Dictionaries.Ukrainian := "�1234567890-=����������������������\����������. �!""�;%:?*()_+����������կԲ�������ƪ/����������,"
	
	; static Dictionaries_Order := ["English", "Russian", "Ukrainian"]
	
	Select()
	{ ; ������� ��������� ����������� ������ ���� ��������� ������ ����� �� ������� �������
		static Selected_Text
		; -----------------------------------------------------------------------------------
		; ��������� ������ / ��������� ��� �����������, ���������� ���������� "Selected_Text"
		; -----------------------------------------------------------------------------------
		Clipboard = ; Null
		SendInput, % This.Ctrl_C
		ClipWait, 0.05
		Selected_Text = ; Null
		If ( not Selected_Text := Clipboard ) {
			Loop, 100
			{
				Clipboard = ; Null
				SendInput, % This.Select_Left . This.Ctrl_C
				ClipWait, 0.5
				If ( StrLen( Clipboard ) = 0 )
				{ ; ������������� �� ������, ���� ����� ������ ���������� ����������� � �����
					Return
				}
				If ( StrLen( Clipboard ) = StrLen( Selected_Text ) )
				{ ; ���������� ������ ������
					Break
				}
				If RegExMatch( Clipboard, "[\r\n]" )
				{ ; � ��������� ����� ������� �� ����� ������
					Clipboard = ; Null
					SendInput, % This.Select_No_Space . This.Ctrl_C
					ClipWait, 0.5
					Break
				}
				If RegExMatch( Clipboard, "^\s.+" )
				{ ; ������ ���������� � �������
					Clipboard = ; Null
					SendInput, % This.Select_No_Starting_Space . This.Ctrl_C
					ClipWait, 0.5
					Break
				}
				If RegExMatch( Clipboard, "\s" )
				{ ; � ��������� ����� ������
					Clipboard = ; Null
					SendInput, % This.Select_No_Space . This.Ctrl_C ; This.Select_Right . This.Ctrl_C
					ClipWait, 0.5
					Break
				}
				Selected_Text := Clipboard
			}
		}
		; -----------------------------------------------------------------------------------
		Return, Selected_Text
	}
	
	Convert_Case( ByRef Selected_Text, ByRef Force_Case_ID := 0 )
	{ ; ������� ����� �������� ������
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; �������������� �������� ������, ���������� ���������� "Converted_Text"
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
	{ ; ������� �������� ������ �� ��������� ( ����������� �������, ���������������� ������ )
		static Language
		static Dictionary
		static Same_Dictionary
		; -----------------------------------------------------------------------------------
		; ����������� �������, ��������� ���������������� ������
		; -----------------------------------------------------------------------------------
		If ( not Selected_Text ) {
			Return
		}
		For Language, Dictionary in This.Dictionaries {
			; MsgBox, % Language " = " Dictionary
			Loop, Parse, Selected_Text
			{
				Same_Dictionary := InStr( Dictionary, A_LoopField, 1 ) or RegExMatch( A_LoopField, "\s" )
				If ( not Same_Dictionary ) {
					Break
				}
			} ; Until not Same_Dictionary
			If ( Same_Dictionary ) {
				Return, Language
			}
		}
		; -----------------------------------------------------------------------------------
	}
	
	Replace_By_Dictionaries( ByRef Selected_Text, ByRef Current_Dictionary, ByRef Next_Dictionary )
	{ ; ������� ������ �������� ������ ������� ���������������� ( �� ������� ) ��������� ������� ( ����� ��������� ������ )
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; ������ �������� ������� "Current_Dictionary" ���������������� ��������� "Next_Dictionary"
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
	{ ; ������� �������� ����� ������ ������ / ������ ������
		; -----------------------------------------------------------------------------------
		; ����������� "Converted_Text" � ����� ������ � �������� ������� "Control + V"
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
	
	/*
	Get_Index_By_Name( Byref Name )
	{ ; ������� ��������� ����������� ������ ������� �� ������� ����� ( "English" )
		static Index, Dictionary
		Index := 1
		For Dictionary in This.Dictionaries
		{
			If ( Dictionary = Name ) {
				Return, Index
			}
			Index += 1
		}
	}
	*/
}

