#Include *i CLASS_Windows.ahk

class Window
{
	Is_Full_Screen(ByRef Win_Title := "A")
	{ ; функция проверки полноэкранного режима
		static Win_ID
		static Win_Style
		static Win_W
		static Win_H
		;		
		Win_ID := WinExist(Win_Title)
		if (not Win_ID) {
			return False
		}
		if (Win_ID = Windows.Desktop_ID) {
			return False
		}
		WinGet Win_Style, Style, ahk_id %Win_ID%
		if (Win_Style & 0x20800000) { ; 0x800000 is WS_BORDER, 0x20000000 is WS_MINIMIZE, no border and not minimized
			return False
		}
		WinGetPos ,,, Win_W, Win_H, %Win_Title%
		if (Win_H < A_ScreenHeight or Win_W < A_ScreenWidth) {
			return False
		}
		return True
	}
}
