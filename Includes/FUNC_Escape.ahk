Escape(String)
{ ; ������� �������������� String � RegExp
	static Index, Char, Escape
	Escape := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]
	for Index, Char in Escape
	{
		String := StrReplace(String, Char, "\" . Char)
	}
	return String
}
