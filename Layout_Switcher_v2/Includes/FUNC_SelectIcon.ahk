SelectIcon(ByRef IconPath := "", ByRef Index := 0)
{ ; ������� ������ ������� ������ ����� ������ � ����� ������ �� ����
	IconPath := IconPath ? IconPath : A_WinDir . "\system32\shell32.dll"
	DllCall("shell32\PickIconDlg", "Uint", "null", "str", IconPath, "Uint", 260, "intP", Index)
	return IconPath . "," . Index
}
; #SelectedIcon := StrSplit(SelectIcon(), ",", "`s")
; #IconFile := #SelectedIcon[1], #IconIndex := #SelectedIcon[2]
; MsgBox % #IconFile . ", " . #IconIndex
