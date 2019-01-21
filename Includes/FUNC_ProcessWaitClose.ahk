ProcessWaitClose(WinTitle, Seconds := "", UseProcessKill := 0)
{
	local
	WinGet, ProcessList, List, %WinTitle% ;, WinText, ExcludeTitle, ExcludeText
	Loop, %ProcessList%
	{
		ProcessID := ProcessList%A_Index%
		WinGet, ProcessPID, PID, ahk_id %ProcessID% ;, WinText, ExcludeTitle, ExcludeText
		if (UseProcessKill) {
			Process, Close, ahk_pid %ProcessPID%
		}
		else {
			WinClose, ahk_pid %ProcessPID%
		}
		Process, WaitClose, %ProcessPID%, %Seconds%
	}
}

/*
#SingleInstance, Force
F11::
{
	Loop, 5
	{
		Run, notepad,, UseErrorLevel, NotepadPID
		WinWait, ahk_pid %NotepadPID%
		GroupAdd, WinGroup, ahk_pid %NotepadPID%
	}
	MsgBox, ahk_pid: %NotepadPID%
	ProcessWaitClose("ahk_group WinGroup", Seconds := "", UseProcessKill := 0)
	MsgBox, OK
	return
}
*/
