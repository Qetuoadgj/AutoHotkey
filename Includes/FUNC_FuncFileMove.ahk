FuncFileMove(Source, Dest, Flag := 0, Tries := 10, IntervalsMS := 200)
{
	; FileMove, Source, Dest [, Flag (1 = overwrite)]
	; FileMoveDir, Source, Dest [, Flag (2 = overwrite, R = rename)]
	local
	IsDir := FileExist(Source) == "D"
	if (IsDir) {
		FileMoveDir, %Source%, %Dest%, %Flag%
		; return ErrorLevel
	}
	else {
		; FileSetAttrib, -R, %Source%
		while (FileExist(Source) and A_Index < Tries) {
			FileMove, %Source%, %Dest%, %Flag%
			; EL := ErrorLevel
			Sleep, %IntervalsMS%
		}
		; return EL
	}
	; return -1
	return not FileExist(Source)
}
