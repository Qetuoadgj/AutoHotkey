FuncFileDelete(Path, Method := 1, DeleteDirsWithSubdirs := 0, Tries := 10, IntervalsMS := 200)
{
	local
	IsDir := FileExist(Path) == "D"
	if (Method == 2) {
		if (IsDir) {
			FileRemoveDir, %Path%, %DeleteDirsWithSubdirs%
			; return ErrorLevel
		}
		else {
			FileSetAttrib, -R, %Path%
			while (FileExist(Path) and A_Index < Tries) {
				FileDelete, %Path%
				; EL := ErrorLevel
				Sleep, %IntervalsMS%
			}
			; return EL
		}
	}
	else if (Method == 1) {
		FileRecycle, %Path%
		; return ErrorLevel
	}
	; return -1
	return not FileExist(Path)
}
