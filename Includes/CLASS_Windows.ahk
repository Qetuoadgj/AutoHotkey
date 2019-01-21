class Windows
{ ; получение информации о Windows
	static Tray_ID := Windows.Get_Tray_ID() ; ID системного трея Windows
	static Desktop_ID := Windows.Get_Desktop_ID() ; ID рабочего стола Windows
	;
	Get_Tray_ID()
	{ ; функция получения ID системного трея Windows
		local
		ID := WinExist("ahk_class Shell_TrayWnd")
		return ID
	}
	Get_Desktop_ID()
	{ ; функция получения ID рабочего стола Windows
		local
		ID := WinExist("ahk_class WorkerW ahk_exe Explorer.EXE") ; Win 10
		ID := ID ? ID : WinExist("ahk_class Progman ahk_exe Explorer.EXE") ; Win 7
		return ID
	}
}
