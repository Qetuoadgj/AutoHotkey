SelectIcon(IconPath := "", Index := 0)
{ ; функция вызова диалога выбора файла иконки и самой иконки из него
	static Call
	IconPath := IconPath ? IconPath : A_WinDir . "\system32\shell32.dll"
	Call := DllCall("shell32\PickIconDlg", "Uint", "null", "str", IconPath, "Uint", 260, "intP", Index)
	if (Call) {
		return IconPath . "," . Index+1
	}
}
; #SelectedIcon := StrSplit(SelectIcon(), ",", "`s")
; #IconFile := #SelectedIcon[1], #IconIndex := #SelectedIcon[2]
; MsgBox % #IconFile . ", " . #IconIndex
