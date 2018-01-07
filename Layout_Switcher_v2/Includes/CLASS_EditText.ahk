class c_Edit_Text
{ ; функции получения / обработки текста
	; static Ctrl_C := "^{vk43}" . "{Ctrl Up}"
	; static Ctrl_V := "^{vk56}" . "{Ctrl Up}"
	; static Select_Left := "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"
	; static Select_Right := "^+{Right}" . "{Ctrl Up}" . "{Shift Up}"
	; static Select_No_Starting_Space := "^+{Right}" . "{Ctrl Up}" . "{Shift Up}" ;. "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"
	; static Select_No_Space := "^+{Right 2}" . "{Ctrl Up}" . "{Shift Up}" . "^+{Left}" . "{Ctrl Up}" . "{Shift Up}"
	;
	static Title_Case_Symbols := "(\_|\-|\.|\[|\(|\{)"
	static Title_Case_Match := "(.)"
	static Upper_Case_Words := "(ID\b|PID\b|UI\b|HKL\b|KLID\b)"
	;
	static Next_Case_ID := "U"
	;
	static Dictionaries := {}
	static Dictionaries.English := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:`"`"||ZXCVBNM<>?"
	static Dictionaries.Russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\\ячсмитьбю. Ё!`"`"№;%:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ//ЯЧСМИТЬБЮ,"
	static Dictionaries.Ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ґячсмитьбю. Ё!`"`"№;%:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ҐЯЧСМИТЬБЮ,"
	;
	; static Dictionaries_Order := ["English", "Russian", "Ukrainian"]
	;
	Select()
	{ ; функция получения выделенного текста либо выделения текста влево до первого пробела
		static Selected_Text
		; -----------------------------------------------------------------------------------
		; Выделение текста / получение уже выделенного, назначение переменной "Selected_Text"
		; -----------------------------------------------------------------------------------
		Clipboard := "" ; Null
		SendInput % "{Ctrl Down}"
		; Sleep 1
		SendInput % "{vk43}"
		Sleep 1
		SendInput % "{Ctrl Up}"
		ClipWait 0.05
		Selected_Text := Clipboard
		if (StrLen(Selected_Text) = 0) {
			Loop 100 {
				Clipboard := "" ; Null
				SendInput % "{Ctrl Down}{Shift Down}"
				; Sleep 1
				SendInput % "{Left}"
				; Sleep 1
				SendInput % "{Shift Up}"
				Sleep 1
				SendInput % "{vk43}"
				Sleep 1
				SendInput % "{Ctrl Up}"
				ClipWait 0.5
				if (StrLen(Clipboard) = 0) { ; перестраховка на случай, если текст вообще невозможно скопировать в буфер
					return
				}
				if (StrLen(Clipboard) = StrLen(Selected_Text)) { ; достигнуто начало строки
					Break
				}
				if RegExMatch(Clipboard, "^\s+$") { ; строка состоит из пробелов
					SendInput % "{Right}"
					Break
				}
				if RegExMatch(Clipboard, "\s+$") { ; курсор стоял перед пробелом, его нужно "перескочить"
					Clipboard := "" ; Null
					SendInput % "{Left}"
					; Sleep 1
					SendInput % "{Ctrl Down}{Shift Down}"
					; Sleep 1
					SendInput % "{Right}"
					; Sleep 1
					SendInput % "{Shift Up}"
					Sleep 1
					SendInput % "{vk43}"
					Sleep 1
					SendInput % "{Ctrl Up}"
					ClipWait 0.5
					Break
				}
				if RegExMatch(Clipboard, "^[^\s]+\s+[^\s]+") { ; в выделение попал пробел или перенос на новую строку
					Clipboard := "" ; Null
					SendInput % "{Ctrl Down}{Shift Down}"
					; Sleep 1
					SendInput % "{Right 2}{Left}"
					; Sleep 1
					SendInput % "{Shift Up}"
					Sleep 1
					SendInput % "{vk43}"
					Sleep 1
					SendInput % "{Ctrl Up}"
					ClipWait 0.5
					Break
				}
				if RegExMatch(Clipboard, "\s") { ; в выделение попал пробел, который находится в самом начале области редактирования
					Clipboard := "" ; Null
					SendInput % "{Ctrl Down}{Shift Down}"
					; Sleep 1
					SendInput % "{Right}{Left}"
					; Sleep 1
					SendInput % "{Shift Up}"
					Sleep 1
					SendInput % "{vk43}"
					Sleep 1
					SendInput % "{Ctrl Up}"
					ClipWait 0.5
					Break
				}
				Selected_Text := Clipboard ; необходимо для сравнения текущего результата с предыдущим
			}
			Selected_Text := Clipboard ; конечное (гарантированное) присвоение содержимого буфера обмена
		}
		; -----------------------------------------------------------------------------------
		; ToolTip, '%Selected_Text%'
		return Selected_Text
	}
	
	Convert_Case(ByRef Selected_Text, ByRef Force_Case_ID := 0)
	{ ; функция смены регистра текста
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; Преобразование регистра текста, назначение переменной "Converted_Text"
		; -----------------------------------------------------------------------------------
		if (StrLen(Selected_Text) = 0) {
			return
		}
		This.Next_Case_ID := Force_Case_ID ? Force_Case_ID : This.Next_Case_ID
		if (This.Next_Case_ID = "U") {
			StringUpper Converted_Text, Selected_Text
			if (not Force_Case_ID and Converted_Text == Selected_Text) {
				This.Next_Case_ID := "T"
			}
		}
		if (This.Next_Case_ID = "T") {
			StringLower Converted_Text, Selected_Text, T
			Converted_Text := RegExReplace(Converted_Text, This.Title_Case_Symbols . This.Title_Case_Match, "$1$U2")
			Converted_Text := RegExReplace(Converted_Text, "i)" . This.Title_Case_Symbols . This.Upper_Case_Words, "$1$U2")
			if (not Force_Case_ID and Converted_Text == Selected_Text) {
				This.Next_Case_ID := "L"
			}
		}
		if (This.Next_Case_ID = "L") {
			StringLower Converted_Text, Selected_Text
			if (not Force_Case_ID and Converted_Text == Selected_Text) {
				This.Next_Case_ID := "U"
			}
		}
		if (not Force_Case_ID) {
			if (This.Next_Case_ID = "U") {
				This.Next_Case_ID := "T"
			} 
			else if (This.Next_Case_ID = "T") {
				This.Next_Case_ID := "L"
			} 
			else if (This.Next_Case_ID = "L") {
				This.Next_Case_ID := "U"
			}
		}
		; -----------------------------------------------------------------------------------
		return Converted_Text
	}
	
	Dictionary(ByRef Selected_Text)
	{ ; функция сравнения текста со словарями (определение словаря, соответствующего тексту)
		static Language
		static Dictionary
		static Same_Dictionary
		; -----------------------------------------------------------------------------------
		; Определение словаря, полностью соответствующего тексту
		; -----------------------------------------------------------------------------------
		if (StrLen(Selected_Text) = 0) {
			return
		}
		for Language, Dictionary in This.Dictionaries {
			; MsgBox, % Language " = " Dictionary
			Loop Parse, Selected_Text
			{
				Same_Dictionary := InStr(Dictionary, A_LoopField, 1) or RegExMatch(A_LoopField, "\s")
				if (not Same_Dictionary) {
					Break
				}
			} ; until not Same_Dictionary
			if (Same_Dictionary) {
				return Language
			}
		}
		; -----------------------------------------------------------------------------------
	}
	
	Replace_By_Dictionaries(ByRef Selected_Text, ByRef Current_Dictionary, ByRef Next_Dictionary)
	{ ; функция замены символов одного словаря соответствующими (по порядку) символами другого (смена раскладки текста)
		static Converted_Text
		; -----------------------------------------------------------------------------------
		; Замена символов словаря "Current_Dictionary" соответствующими символами "Next_Dictionary"
		; -----------------------------------------------------------------------------------
		if (StrLen(Selected_Text) = 0) {
			return
		}
		Converted_Text := "" ; Null
		Loop Parse, Selected_Text
		{
			if (Current_Dictionary_Match := InStr(This.Dictionaries[Current_Dictionary], A_LoopField, 1)) {
				Converted_Text .= SubStr(This.Dictionaries[Next_Dictionary], Current_Dictionary_Match, 1)
			}
			else {
				Converted_Text .= A_LoopField
			}
		}
		; -----------------------------------------------------------------------------------
		return Converted_Text
	}
	
	Paste(ByRef Converted_Text)
	{ ; функция отправки буфер текста обмена / вывода текста
		; -----------------------------------------------------------------------------------
		; Отправление "Converted_Text" в буфер обмена и отправка команды "Control + V"
		; -----------------------------------------------------------------------------------
		if (StrLen(Converted_Text) = 0) {
			return
		}
		Clipboard := "" ; Null
		Clipboard := Converted_Text
		ClipWait 1.0
		SendInput % "{Ctrl Down}"
		Sleep 1
		SendInput % "{vk56}" 
		Sleep 1
		SendInput % "{Ctrl Up}"
		; -----------------------------------------------------------------------------------
		return Clipboard
	}
	
	/*
	Get_Index_By_Name(ByRef Name)
	{ ; функция получения порядкового номера словаря по полному имени ("English")
		static Index, Dictionary
		;
		Index := 1
		for Dictionary in This.Dictionaries
		{
			if (Dictionary = Name) {
				return Index
			}
			Index += 1
		}
	}
	*/
}
