﻿#Include *i FUNC_hexToDecimal.ahk

class Layout
{ ; функции управления раскладками клавиатуры
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	static WM_INPUTLANGCHANGEREQUEST := 0x0050
	static INPUTLANGCHANGE_FORWARD := 0x0002
	static INPUTLANGCHANGE_BACKWARD := 0x0004
	;
	static Layouts_List := Layout.Get_Layouts_List()
	;
	static Switch_Layout_Combo := "{Alt Down}{Shift Down}{Alt Up}{Shift Up}"
	;
	Get_Layouts_List()
	{ ; функция создания базы данных для текущих раскладок
		static Layouts_List, Layouts_List_Size
		static Layout_HKL, Layout_Name, Layout_Full_Name, Layout_Display_Name
		;
		VarSetCapacity(List, A_PtrSize * 5)
		Layouts_List_Size := DllCall("GetKeyboardLayoutList", Int, 5, Str, List)
		Layouts_List := []
		Loop % Layouts_List_Size
		{
			Layout_HKL := NumGet(List, A_PtrSize * (A_Index - 1)) ; & 0xFFFF
			Layout_Name := This.Language_Name(Layout_HKL, false)
			Layout_Full_Name := This.Language_Name(Layout_HKL, true)
			Layout_Display_Name := This.Display_Name(Layout_HKL)
			Layouts_List[A_Index] := {}
			Layouts_List[A_Index].HKL := Layout_HKL
			Layouts_List[A_Index].Name := Layout_Name
			Layouts_List[A_Index].Full_Name := Layout_Full_Name
			Layouts_List[A_Index].Display_Name := Layout_Display_Name
		}
		return Layouts_List
	}
	
	Language_Name(ByRef HKL, ByRef Full_Name := false)
	{ ; функция получения наименования (сокращённого "en" или полного "English") раскладки по её "HKL" 
		static LocID, LCType, Size
		;
		LocID := HKL & 0xFFFF
		LCType := Full_Name ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0) * 2
		VarSetCapacity(localeSig, Size, 0)
		DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size)
		return localeSig
	}
	
	Display_Name(ByRef HKL)
	{ ; функция получения названия ("Английская") раскладки по её "HKL" 
		static KLID, Display_Name, outBufSize
		;
		KLID := This.Get_KLID(HKL)
		RegRead Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Display Name"
		if (not Display_Name) {
			return False
		}
		DllCall("Shlwapi.dll\SHLoadIndirectString", "Ptr", &Display_Name, "Ptr", &Display_Name, "UInt", outBufSize := 50, "UInt", 0)
		if (not Display_Name) {
			RegRead Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Text"
		}
		return Display_Name
	}
	
	Get_HKL(ByRef Window := "A")
	{ ; функция получения названия "HKL" текущей раскладки
		static Window_ID, Window_Class, Console_PID, HKL
		;
		Window_ID := WinExist(Window)
		WinGetClass Window_Class
		if (Window_Class == "ConsoleWindowClass") {
			WinGet Console_PID, PID
			DllCall("AttachConsole", Ptr, Console_PID)
			VarSetCapacity(Buff, 16)
			DllCall("GetConsoleKeyboardLayoutName", Str, Buff)
			DllCall("FreeConsole")
			HKL := SubStr(Buff, -3)
			HKL := HKL ? hexToDecimal(HKL . HKL) : 0 ; HKL := HKL ? "0x" . HKL : 0
		}
		else {
			HKL := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, Window_ID, UInt, 0, Ptr), Ptr) ; & 0xFFFF
		}
		return HKL
	}
	
	Get_KLID(ByRef HKL)
	{ ; функция получения названия "KLID" раскладки по её "HKL" 
		static Prior_HKL, KLID
		;
		Prior_HKL := DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr"), "Ptr")
		VarSetCapacity(KLID, 8 * (A_IsUnicode ? 2 : 1))
		if !DllCall("ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0) || !DllCall("GetKeyboardLayoutName", "Ptr", &KLID) || !DllCall("ActivateKeyboardLayout", "Ptr", Prior_HKL, "UInt", 0) {
			return False
		}
		return StrGet(&KLID)
	}
	
	Next(ByRef Window := "A", ByRef BySend := false)
	{ ; функция смены раскладки (вперед)
		if BySend { ; с помощью команды Send
			SendInput % This.Switch_Layout_Combo
		}
		else { ; с помощью команды PostMessage
			static Window_ID
			;
			if (Window_ID := WinExist(Window)) {
				PostMessage % This.WM_INPUTLANGCHANGEREQUEST, % This.INPUTLANGCHANGE_FORWARD,,, ahk_id %Window_ID%
			}
		}
		Sleep 1
	}
	
	Change(ByRef HKL, ByRef Window := "A", ByRef BySend := false)
	{ ; функция смены раскладки по "HKL"
		static Window_ID
		;
		if (Window_ID := WinExist(Window)) {
			if BySend { ; с помощью команды Send
				static This_Layout_KLID
				static Next_Layout_KLID
				;
				Loop % This.Layouts_List.MaxIndex()
				{
					This_Layout_KLID := This.Get_KLID(This.Get_HKL("ahk_id " Window_ID))
					Next_Layout_KLID := This.Get_KLID(HKL)
					Sleep 1
					if (This_Layout_KLID == Next_Layout_KLID) {
						Break
					}
					SendInput % This.Switch_Layout_Combo
					Sleep 1
				}
			}
			else { ; с помощью команды PostMessage
				PostMessage % This.WM_INPUTLANGCHANGEREQUEST,, % HKL,, ahk_id %Window_ID%
			}
		}
		Sleep 1
	}

	Get_Index(ByRef HKL)
	{ ; функция получения порядкового номера раскладки по "HKL"
		static Index, Layout
		;
		for Index, Layout in This.Layouts_List {
			if (This.Get_KLID(Layout.HKL) = This.Get_KLID(HKL)) {
				return Index
			}
		}
	}
	
	Get_Index_By_Name(ByRef Full_Name)
	{ ; функция получения порядкового номера раскладки по полному имени ("English")
		static Index, Layout
		;
		for Index, Layout in This.Layouts_List {
			if (Layout.Full_Name = Full_Name) {
				return Index
			}
		}
	}
}

