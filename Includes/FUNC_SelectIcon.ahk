SelectIcon(ByRef IconPath := "", ByRef Index := 0)
{ ; функция вызова диалога выбора файла иконки и самой иконки из него
	IconPath := IconPath ? IconPath : A_WinDir . "\system32\shell32.dll"
	DllCall("shell32\PickIconDlg", "Uint", "null", "str", IconPath, "Uint", 260, "intP", Index)
	return IconPath . "," . Index
}
; MsgBox % SelectIcon()
