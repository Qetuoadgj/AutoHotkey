hexToDecimal(str)
{
	local
	_0 := 0, _1 := 1, _2 := 2, _3 := 3
	, _4 := 4, _5 := 5, _6 := 6, _7 := 7
	, _8 := 8, _9 := 9, _a := 10, _b := 11
	, _c := 12, _d := 13, _e := 14, _f := 15
	;
	str := LTrim(str, "0x `t`n`r")
	len := StrLen(str)
	ret := 0
	Loop Parse, str
	{
		ret += _%A_LoopField% * (16 ** (len - A_Index))	
	}
	return ret
}
