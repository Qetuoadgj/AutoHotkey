SearchImage(ByRef OutputVarX, ByRef OutputVarY, ImagePath, SearchAreaX := "", SearchAreaY := "", SearchAreaWidth := "", SearchAreaHeight := "", Options := "", OffsetX := 0, OffsetY := 0) {
	ImageSearch, OutputVarX, OutputVarY, %SearchAreaX%, %SearchAreaY%, %SearchAreaWidth%, %SearchAreaHeight%, %Options% %ImagePath%
	if (ErrorLevel = 0) {
		OutputVarX += OffsetX
		OutputVarY += OffsetY
		; MsgBox, 0, %A_Space%, PosX: %PosX%`nPosY: %PosY%, 1
		return true
	}
	/*
	else {
		; MsgBox, 262160, % "ОШИБКА", % "Не удалось обнаружить " . ImagePath . " на экране.", 1
	}
	*/
	return
}

