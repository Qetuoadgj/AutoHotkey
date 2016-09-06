; ===================================================================================
; 											ФУНКЦИЯ ВЫБОРА ЭЛЕМЕНТА ПО УМОЛЧАНИЮ для DropDownList
; ===================================================================================
DropDownDefault(DropDownList, List, Default)
{
	String := Default
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

	List := RegExReplace(List, String "[|]?", Default "||", ,1)
	GuiControl,, %DropDownList%, %List%
}
