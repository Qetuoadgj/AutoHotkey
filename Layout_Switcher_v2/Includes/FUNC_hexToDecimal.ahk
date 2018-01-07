hexToDecimal(ByRef str)
{
	static _0 := 0
	static _1 := 1
	static _2 := 2
	static _3 := 3
	static _4 := 4
	static _5 := 5
	static _6 := 6
	static _7 := 7
	static _8 := 8
	static _9 := 9
	static _a := 10
	static _b := 11
	static _c := 12
	static _d := 13
	static _e := 14
	static _f := 15
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
