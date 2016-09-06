; ===================================================================================
; 										ФУНКЦИЯ ПРОВЕРКИ РАСШИРЕНИЯ ФАЙЛУ
; ===================================================================================
FileCheckExtension(File, Extension)
{
	If % File = "" or RegExMatch(File, "^(\s+)")
	{
		Return ""
	} Else If RegExMatch(File, "^.+\..+$") {
		Return File
	} else {
		File := RegExReplace(File, "^(.*)?(\..*)$", "$1", ,1)
		File :=  File "." Extension
		Return File
	}
}
