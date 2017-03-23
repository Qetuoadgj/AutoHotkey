;~ F1::Lyt.Set(0x4090409)	; set english layout by id
;~ F2::Lyt.Set("Switch")	; switch input language. Lyt.Set() do the same.
;~ F3::Lyt.Set("Forward")	; move forward in layout list cycle
;~ F4::Lyt.Set(2)			; set second layout in list
;~ F7::Lyt.Set("-en")		; set first non-english layout in list
;~ F8::Lyt.Set("en", "global")
;~ F9::Lyt.Set("forward", WinExist("AutoHotkey Help ahk_class HH Parent"))
;~ F10::Lyt.Set("en", "AutoHotkey Help ahk_class HH Parent")
;~ F11::MsgBox % Lyt.GetDisplayName("AutoHotkey Help ahk_class HH Parent")
;~ F12::MsgBox % "HKL: " Format("{:#010x}", Lyt.GetInputHKL()) "`n№: " Lyt.GetNum() "`nDisplayName: " Lyt.GetDisplayName() "`nLanguage: " Lyt.GetLng() " - " Lyt.GetLng(,, true) "`n`n"Lyt.GetList()[2].DisplayName " " Lyt.GetList()[2].LngName " " Lyt.GetList()[2].LngFullName
;~ Esc::ExitApp

Class Lyt {
	; ===================================================================================================================
	; Источник: http://forum.script-coding.com/viewtopic.php?id=12452
	; ===================================================================================================================
	Static SISO639LANGNAME				:= 0x0059 ; ISO abbreviated language name, eg "en"
	Static LOCALE_SENGLANGUAGE			:= 0x1001 ; Full language name, eg "English"
	Static WM_INPUTLANGCHANGEREQUEST	:= 0x0050
	Static INPUTLANGCHANGE_FORWARD		:= 0x0002
	Static INPUTLANGCHANGE_BACKWARD		:= 0x0004
	; ===================================================================================================================
	; PUBLIC METHOD Set()
	; Parameters:     arg (optional)   - (switch / forward / backward / 2-letter language name(en) / language number in current active layout list / language id e.g. HKL (0x04090409)). Default: switch
	;                 win (optional)   - (ahk format WinTitle / hWnd). Default: Active Window
	; Return value:   empty or description string in case of errors
	; ===================================================================================================================
	Set(arg := "switch", win := 0) {
		hWnd := win ? ( win + 0 ? WinExist("ahk_id" win) : win = "global" ? win : WinExist(win) ) : WinExist("A")
		If (hWnd = 0) {
			Return "Window not found"
		}
		if (arg = "forward") {
			Return This.Change(, This.INPUTLANGCHANGE_FORWARD, hWnd)
		} else if (arg = "backward") {
			Return This.Change(, This.INPUTLANGCHANGE_BACKWARD, hWnd)
		} else if (arg = "switch") {
			Return This.Change((This.GetNum(hWnd) != 1)  ?  This.GetList()[1].h  :  This.GetList()[2].h,, hWnd)
		} else if (arg ~= "[A-z]{2}") {
			invert := ((SubStr(arg, 1, 1) = "-") && (arg := SubStr(arg, 2, 2))) ? true : false
			For index, layout in This.GetList() {
				if (InStr(layout.LngName, arg) ^ invert) {
					Return This.Change(layout.h,, hWnd)
				}
			}
			Return "Language not found in current layout list"
		} else if (arg <= This.GetList().MaxIndex()) {
			Return This.Change(This.GetList()[arg].h,, hWnd)
		} else if (arg > 1024) {
			Return This.Change(arg,, hWnd)
		} else {
			Return "Not valid input"
		}
	}
	
	Change(HKL := 0, INPUTLANGCHANGE := 0, hWnd := 0) {
		Return (hWnd = "global") ? This.ChangeGlobal(HKL, INPUTLANGCHANGE) : This.ChangeLocal(HKL, INPUTLANGCHANGE, hWnd)
	}
	
	ChangeGlobal(HKL, INPUTLANGCHANGE) {
		If (INPUTLANGCHANGE != 0) {
			Return "Unpredictable behavior. Use other methods for global."
		}
		tmp := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGet, List, List
		DetectHiddenWindows, % tmp
		Loop % List {
			This.ChangeLocal(HKL, INPUTLANGCHANGE, List%A_Index%)
		}
	}
	
	ChangeLocal(HKL, INPUTLANGCHANGE, hWnd) {
		PostMessage, This.WM_INPUTLANGCHANGEREQUEST, % HKL ? "" : INPUTLANGCHANGE, % HKL ? HKL : "",, % (hWndOwn := DllCall("GetWindow", Ptr, hWnd, UInt, GW_OWNER := 4, Ptr)) ? "ahk_id" hWndOwn : "ahk_id" hWnd
	}

	GetNum(win := 0, HKL := 0) {
		HKL ? : HKL := This.GetInputHKL(win)
		For index, layout in This.GetList() {
			if (layout.h = HKL) {
				Return index
			}
		}
	}
	
	GetList(Layouts := 0) {
		If IsObject(Layouts) {
			Return Layouts
		} else {
			VarSetCapacity(List, A_PtrSize*5)
			Size := DllCall("GetKeyboardLayoutList", Int, 5, Str, List)
			Layouts := []
			Loop % Size {
				Layouts[A_Index] := {}
				Layouts[A_Index].h := NumGet(List, A_PtrSize*(A_Index - 1)) ;& 0xFFFF
				Layouts[A_Index].LngName := This.GetLng(, Layouts[A_Index].h)
				Layouts[A_Index].LngFullName := This.GetLng(, Layouts[A_Index].h, true)
				Layouts[A_Index].DisplayName := This.GetDisplayName(, Layouts[A_Index].h)
			}
			Return Layouts
		}
	}
	
	GetLng(win := 0, HKL := 0, FullName := false) {
		HKL ? : HKL := This.GetInputHKL(win)
		LocID := HKL & 0xFFFF
		LCType := FullName ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := (DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0) * 2)
		VarSetCapacity(localeSig, Size, 0)
		DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size)
		Return localeSig
	}
	
	GetDisplayName(win := 0, HKL := 0) {
		HKL ? : HKL := This.GetInputHKL(win)
		KLID := This.HKLtoKLID(HKL)
		RegRead, displayName, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, Layout Display Name
		if (!displayName) {
			Return false
		}
		DllCall("Shlwapi.dll\SHLoadIndirectString", "Ptr", &displayName, "Ptr", &displayName, "UInt", outBufSize:=50, "UInt", 0)
		if (!displayName) {
			RegRead, displayName, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, Layout Text
		}
		Return displayName
	}
	
	HKLtoKLID(HKL) {
		VarSetCapacity(KLID, 8 * (A_IsUnicode ? 2 : 1))
		priorHKL := DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr"), "Ptr")
		if (!DllCall("ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0) || !DllCall("GetKeyboardLayoutName", "Ptr", &KLID) || !DllCall("ActivateKeyboardLayout", "Ptr", priorHKL, "UInt", 0)) {
			return false
		}
		return StrGet(&KLID)
	}
		
	GetInputHKL(win := 0) { ; if handle incorrect, system default HKL return
		hWnd := win ? win + 0 ? WinExist("ahk_id" win) : WinExist(win) : WinExist("A")
		If (hWnd = 0) {
			Return "Window not found"
		}
		WinGetClass, Class
		if (Class == "ConsoleWindowClass") {
			WinGet, consolePID, PID
			DllCall("AttachConsole", Ptr, consolePID)
			VarSetCapacity(buff, 16)
			DllCall("GetConsoleKeyboardLayoutName", Str, buff)
			DllCall("FreeConsole")
			HKL := "0x" . SubStr(buff, -3)
		} else {
			HKL := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, hWnd, UInt, 0, Ptr), Ptr) ;& 0xFFFF
		}
		return HKL
	}
}

