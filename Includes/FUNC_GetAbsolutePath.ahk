GetAbsolutePath(Path, RootPath := "")
{ ; получение полного пути из относительного
	RootPath := RootPath ? RootPath : A_WorkingDir
	StringReplace, Path, Path, % "..\", % "..\", UseErrorLevel
	Loop, % ErrorLevel
	{
		RootPath := RegExReplace(RootPath, "^(.*)\\.*$", "$1",, 1)
	}
	Path := RegExReplace(Path, "(\.\.\\)+", RootPath . "\")
	return Path
}

ParseList(List, RootPath := "")
{ ; обработка относительных путей в списке
	static Line, Ret
	Ret := ""
	Loop, Parse, List, `n, `r
	{
		Line := ExpandEnvironmentVariables(A_LoopField)
		if RegExMatch(Line, "\.\.\\") { ; обработка относительных путей типа "..\..\Путь"
			Line := GetAbsolutePath(Line, A_WorkingDir)
		}
		if (not RegExMatch(Line, "^\w+:\\")) {
			Line := A_WorkingDir . "\" . Line
		}
		Ret .= Line . "`n"
		; MsgBox, 4, , File number %A_Index% is %Line%.`n`nContinue?
		; IfMsgBox, No, break
	}
	if (RootPath) {
		Ret := StrReplace(Ret, RootPath . "\", "")
	}
	Sort, Ret, U ; удаление дубликатов из списка
	return Ret
}
