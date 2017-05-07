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
}

