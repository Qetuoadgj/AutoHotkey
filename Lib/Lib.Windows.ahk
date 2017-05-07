class Windows
{ ; ��������� ���������� � Windows
	static Tray_ID := Windows.Get_Tray_ID() ; ID ���������� ���� Windows
	static Desktop_ID := Windows.Get_Desktop_ID() ; ID �������� ����� Windows
	
	Get_Tray_ID()
	{ ; ������� ��������� ID ���������� ���� Windows
		static ID
		ID := WinExist( "ahk_class Shell_TrayWnd" )
		Return, ID
	}
	
	Get_Desktop_ID()
	{ ; ������� ��������� ID �������� ����� Windows
		static ID
		ID := WinExist( "ahk_class Progman ahk_exe Explorer.EXE" ) ;
		If ( not ID ) {
			ID := WinExist( "ahk_class WorkerW ahk_exe Explorer.EXE" )
		}
		Return, ID
	}
}

