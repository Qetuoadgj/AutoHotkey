MenuIcon(MenuName := "Tray", ItemName := "", IcoFile := "", IconNumber := "", IconWidth := 0)
{ ; функция добавления иконок в меню приложения (с проверкой наличия файла иконки)
	if FileExist(IcoFile) {
		Menu %MenuName%, Icon, %ItemName%, %IcoFile%, %IconNumber%, %IconWidth%
	}
}