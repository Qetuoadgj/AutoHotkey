class Layout
{ ; функции управления раскладками клавиатуры
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	static WM_INPUTLANGCHANGEREQUEST := 0x0050
	static INPUTLANGCHANGE_FORWARD := 0x0002
	static INPUTLANGCHANGE_BACKWARD := 0x0004
	
	static Layouts_List := Layout.Get_Layouts_List()
	
	Get_Layouts_List()
	{ ; функция создания базы данных для текущих раскладок
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
	{ ; функция получения наименования ( сокращённого "en" или полного "English") раскладки по её "HKL" 
		static LocID, LCType, Size
		LocID := HKL & 0xFFFF
		LCType := Full_Name ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0 ) * 2
		VarSetCapacity( localeSig, Size, 0 )
		DllCall( "GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size )
		Return, localeSig
	}
	
	Display_Name( ByRef HKL )
	{ ; функция получения названия ( "Английская" ) раскладки по её "HKL" 
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
	{ ; функция получения названия "KLID" раскладки по её "HKL" 
		static KLID, Prior_HKL
		VarSetCapacity( KLID, 8 * ( A_IsUnicode ? 2 : 1 ) )
		Prior_HKL := DllCall( "GetKeyboardLayout", "Ptr", DllCall( "GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr" ), "Ptr" )
		if ( not DllCall( "ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0 ) or not DllCall( "GetKeyboardLayoutName", "Ptr", &KLID ) or not DllCall( "ActivateKeyboardLayout", "Ptr", Prior_HKL, "UInt", 0 ) ) {
			Return, False
		}
		Return, StrGet(&KLID)
	}
	
	Get_HKL( ByRef Window := "A" )
	{ ; функция получения названия "HKL" текущей раскладки
		static HKL
		static Window_Class
		If ( Window_ID := WinExist( Window ) ) {
			WinGetClass, Window_Class
			If ( Window_Class = "ConsoleWindowClass" ) {
				WinGet, Console_PID, PID
				DllCall( "AttachConsole", Ptr, Console_PID )
				VarSetCapacity( Buff, 16 )
				DllCall( "GetConsoleKeyboardLayoutName", Str, Buff )
				DllCall( "FreeConsole" )
				HKL := SubStr( Buff, -3 )
				HKL := HKL ? "0x" . HKL : 0
			} else {
				HKL := DllCall( "GetKeyboardLayout", Ptr, DllCall( "GetWindowThreadProcessId", Ptr, Window_ID, UInt, 0, Ptr ), Ptr ) ; & 0xFFFF
			}
			Return, HKL
		}
	}
	
	Next( ByRef Window := "A" )
	{ ; функция смены раскладки ( вперед )
		If ( Window_ID := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST, % This.INPUTLANGCHANGE_FORWARD,,, ahk_id %Window_ID%
		}
	}
	
	Change( Byref HKL, ByRef Window := "A" )
	{ ; функция смены раскладки по "HKL"
		If ( Window_ID := WinExist( Window ) ) {
			PostMessage, % This.WM_INPUTLANGCHANGEREQUEST,, % HKL,, ahk_id %Window_ID%
		}
	}
	
	Get_Index( Byref HKL )
	{ ; функция получения порядкового номера раскладки по "HKL"
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( This.KLID( Layout.HKL ) = This.KLID( HKL ) ) {
				Return, Index
			}
		}
	}
	
	Get_Index_By_Name( Byref Full_Name )
	{ ; функция получения порядкового номера раскладки по полному имени ( "English" )
		static Index, Layout
		For Index, Layout in This.Layouts_List
		{
			If ( Layout.Full_Name = Full_Name ) {
				Return, Index
			}
		}
	}
}

