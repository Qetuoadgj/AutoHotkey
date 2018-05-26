WinWait(WinTitle, TimeOut := 0)
{ ; Альтернатива стандартной функции ожидания окна. Позволяет задать сразу несколько WinTitle ([WinTitle1, WinTitle2, ...], TimeOut)
	static WinID
	static TimerStart, TimerEnd
	;
	WinID := false
	TimerStart := A_TickCount, TimerEnd := TimerStart + TimeOut
	;
	While ((A_TickCount < TimerEnd) && (not WinID))
	{
		if isObject(WinTitle) {
			Loop, % WinTitle.MaxIndex()
			{
				WinID := WinID ? WinID : WinExist(WinTitle[A_Index])
			}
		}
		else {
			WinID :=  WinExist(WinTitle)
		}
	}
	;
	return WinID
}
