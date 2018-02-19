TrimPath(GivenPath)
{ ; функция удаления лишних символов из путей
	GivenPath := StrReplace(GivenPath, """", "") ; Удаление кавычек из пути
	GivenPath := RegExReplace(GivenPath, "[\\+]$", "", ,1) ; Удаление замыкающего слэша из пути
	GivenPath := RegExReplace(GivenPath, "^[\\+]", "", ,1) ; Удаление предшествующего слэша из пути
	Return %GivenPath%
}

FileGetLongPath(GivenPath)
{ ; функция получения полного пути к файлу
	GivenPath := TrimPath(GivenPath)
	IfExist, %GivenPath%
	{
		Loop, %GivenPath%, 1
		{
			return %A_LoopFileLongPath%
		}
	}
	else {
		return %GivenPath%
	}
}
