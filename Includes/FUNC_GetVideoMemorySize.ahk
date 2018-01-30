GetVideoMemorySize()
{ ; возвращает значение объема памяти видеоадаптера, байт
	static info_file, video_adapter_info, Match, Match1
	info_file := A_Temp "\Win32_videocontroller_info.txt"
	RunWait, %ComSpec% /k wmic PATH Win32_videocontroller GET adapterram>"%info_file%" & exit,, Hide
	if FileExist(info_file) {
		FileRead, video_adapter_info, % info_file
		Loop, Parse, % video_adapter_info, `n, `r
		{
			if RegExMatch(Trim(A_LoopField), "^(\d{4,})$", Match) {
				return (Match1+0)
			}
		}
		FileDelete, % info_file
	}
	return
}
