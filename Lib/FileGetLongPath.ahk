; ===================================================================================
; 											ФУНКЦИЯ ПОЛУЧЕНИЯ ПОЛНОГО ПУТИ К ФАЙЛУ
; ===================================================================================
FileGetLongPath(GivenPath)
{
  GivenPath := TrimPath(GivenPath)
	IfExist, %GivenPath%
	{
		Loop, %GivenPath%, 1
		{
			Return %A_LoopFileLongPath%
		}
	} Else {
			Return %GivenPath%
	}
}
