IniRead(Filename, Section := "", Key := "", Default := "")
{ ; замена стандартного IniRead (имеет возможность читать параметры, для которых не существует [Section])
	static OutputVar := ""
	;
	IniRead, OutputVar, %Filename%, %Section%, %Key%, %Default%
	;
	if (Key and not Section and (OutputVar == Default or OutputVar == "ERROR")) {
		static FileContents := "", Line_ := "", Line_1 := "", Line_2 := ""
		;
		FileRead, FileContents, %Filename%
		Loop Parse, FileContents, `n, `r
		{
			StringSplit, Line_, A_LoopField, =
			if (Line_1) {
				Line_1 := Trim(Line_1, """" . " ")
			}
			if (Line_2) {
				Line_2 := Trim(Line_2, """" . " ")
			}
			; MsgBox % Line_1 . "=" . Line_2
			if (Line_1 = Key) {
				OutputVar := Line_2
				return OutputVar
			}
		}
	}
	return OutputVar
}
