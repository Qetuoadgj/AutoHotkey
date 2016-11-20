; ===================================================================================
;		ФУНКЦИЯ АВТОМАТИЧЕСКОГО ЗАВЕРШЕНИЯ ВСЕХ КОПИЙ ТЕКУЩЕГО ПРОЦЕССА (КРОМЕ АКТИВНОЙ)
; ===================================================================================
ForceSingleInstance() { 
	DetectHiddenWindows,On
	#SingleInstance,Off
	
	WinGet, CurrentID, ID, %A_ScriptFullPath% ahk_class AutoHotkey
	WinGet, ProcessList, List, %A_ScriptFullPath% ahk_class AutoHotkey
	ProcessCount := 1
	Loop, %ProcessList% {
		ProcessID := ProcessList%ProcessCount%
		If (ProcessID != CurrentID) {
			WinGet, ProcessPID, PID, %A_ScriptFullPath% ahk_id %ProcessID%
			Process,Close,%ProcessPID%
		}
		ProcessCount += 1
	}	 
	Return
}
