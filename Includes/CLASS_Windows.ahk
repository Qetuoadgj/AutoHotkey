class c_Windows
{ ; получение информации о Windows
	static Tray_ID := c_Windows.Get_Tray_ID() ; ID системного трея Windows
	static Desktop_ID := c_Windows.Get_Desktop_ID() ; ID рабочего стола Windows
	;
	Get_Tray_ID()
	{ ; функция получения ID системного трея Windows
		static ID
		;
		ID := WinExist("ahk_class Shell_TrayWnd")
		return ID
	}
	
	Get_Desktop_ID()
	{ ; функция получения ID рабочего стола Windows
		static ID
		;
		ID := WinExist("ahk_class Progman ahk_exe Explorer.EXE") ;
		if (not ID) {
			ID := WinExist("ahk_class WorkerW ahk_exe Explorer.EXE")
		}
		return ID
	}
}
