; #Include *i CLASS_Windows.ahk

class Window
{
	Is_Full_Screen(Win_Title := "A", Exclude_Win_ID_Array := 0)
	{ ; функция проверки полноэкранного режима
		local
		; global Windows
		Win_ID := WinExist(Win_Title)
		if (not Win_ID) {
			return false
		}
		for i, Exclude_Win_ID in Exclude_Win_ID_Array {
			if (Win_ID = Exclude_Win_ID) {
				; MsgBox, % Exclude_Win_ID_Array "`n" "Win_ID = " Win_ID "`n" "Exclude_Win_ID = " . Exclude_Win_ID
				return false
			}
		}
		WinGet Win_Style, Style, ahk_id %Win_ID%
		if (Win_Style & 0x20800000) { ; 0x800000 is WS_BORDER, 0x20000000 is WS_MINIMIZE, no border and not minimized
			return false
		}
		WinGetPos ,,, Win_W, Win_H, %Win_Title%
		if (Win_H < A_ScreenHeight or Win_W < A_ScreenWidth) {
			return false
		}
		return true
	}
}

/*
GroupAdd, G_Windows_Desktop, ahk_class WorkerW ahk_exe Explorer.EXE ; Win 10
GroupAdd, G_Windows_Desktop, Program Manager ahk_class Progman ahk_exe explorer.exe ; Win 7

UPDATE_EXCLUDE_FULLSCREEN_WIN_ARRAY:
{
	G_Exclude_Win_ID_Array := []
	WinGet, G_Exclude_Win_ID_List, List, ahk_group G_Windows_Desktop
	Loop, %G_Exclude_Win_ID_List%
	{
		Exclude_Win_ID := G_Exclude_Win_ID_List%A_Index%
		G_Exclude_Win_ID_Array.push(Exclude_Win_ID)
		; MsgBox, %Exclude_Win_ID%
	}
	return
}

gosub, UPDATE_EXCLUDE_FULLSCREEN_WIN_ARRAY
G_IsFullscreen := Window.Is_Full_Screen("A", G_Exclude_Win_ID_Array)
*/
