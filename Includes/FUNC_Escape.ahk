Escape(String)
{ ; функция преобразования String в RegExp
	static Index, Char, Escape
	Escape := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]
	for Index, Char in Escape
	{
		String := StrReplace(String, Char, "\" . Char)
	}
	return String
}
; Escape("1_505_TEST (2018.01.06) - 00.7z") = "1_505_TEST \(2018\.01\.06\) - 00\.7z"
