; ===================================================================================
; 				ФУНКЦИЯ ПРЕОБРАЗОВАНИЯ СТРОКОВЫХ ПАРАМЕТРОВ, СОДЕРЖАЩИХ СПЕЦ. ЗНАКИ
; ===================================================================================
ConvertToString(String)
{
	; Escaped := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]

	String := StrReplace(String, "\", "\\")
	String := StrReplace(String, ".", "\.")
	String := StrReplace(String, "*", "\*")
	String := StrReplace(String, "?", "\?")
	String := StrReplace(String, "+", "\+")
	String := StrReplace(String, "[", "\[")
	String := StrReplace(String, "]", "\]")
	String := StrReplace(String, "{", "\{")
	String := StrReplace(String, "}", "\}")
	String := StrReplace(String, "|", "\|")
	String := StrReplace(String, "(", "\(")
	String := StrReplace(String, ")", "\)")
	String := StrReplace(String, "^", "\^")
	String := StrReplace(String, "$", "\$")

	Return String
}
