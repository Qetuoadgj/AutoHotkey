ToolTip(text, time := 800)
{ ; функция вывода всплывающей подсказки с последующим (убирается по таймеру)
	ToolTip %text%
	SetTimer Clear_ToolTips, %time%
}

Clear_ToolTips:
{ ; рутина очистки подсказок и отключения связанных с ней таймеров
	ToolTip
	SetTimer %A_ThisLabel%, Off
	return
}
