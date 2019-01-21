; --------------------------------------------------------------------------------------------
#Include *i FUNC_GetUrlStatus.ahk
; --------------------------------------------------------------------------------------------
DownloadByList(RootURL, List, DestDir := False)
{ ; функция загрузки фалов из списка
	local
	DestDir := DestDir ? DestDir : A_ScriptDir
	Loop, Parse, List, `n, `r
	{
		Line := Trim(A_LoopField)
		Line := RegExReplace(Line, " `;.*", "")
		if (Line == "") { ; пропуск пустых строк
			Continue
		}
		File := StrReplace(Line, "/", "\")
		Download := RootURL . StrReplace(File, "\", "/")
		if (GetUrlStatus(Download) == 200) {
			if RegExMatch(File, "(.*\\)", Dir) {
				FileCreateDir, % DestDir . "\" . Dir
			}
			UrlDownloadToFile, %Download%, % DestDir "\" . StrReplace(File, "/", "\")
		}
	}
}
; --------------------------------------------------------------------------------------------