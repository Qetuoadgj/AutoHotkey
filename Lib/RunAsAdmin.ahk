RunAsAdmin(ScriptPath:=False) { ; ������� ������� ������ � ������� ���������������.
	If (not A_IsAdmin) {
		ScriptPath:=ScriptPath?ScriptPath:A_ScriptFullPath
		Try
		{
			Run,*RunAs "%ScriptPath%"
		} Catch {
			; MsgBox,You cancelled when asked to elevate to admin!
		}
		ExitApp
	}
}
