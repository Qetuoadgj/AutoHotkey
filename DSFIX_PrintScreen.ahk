#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

Script_Name := Script.Name()
Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])
Script.Run_As_Admin(%0%)

#Persistent
; #SingleInstance, Ignore
 
VK_Pause := 19
VK_PrintScreen := 44

#IfWinActive, DARK SOULS ahk_class DARK SOULS ahk_exe DATA.exe
{
	SC029:: ; ~
	{
		SendKey(VK_Pause, 50), SendKey(VK_PrintScreen, 50), SendKey(VK_Pause, 50)
		Sleep, 50
		return
	}
}

SendKey(ScanCode, PressTime := 50)
{
	DllCall("keybd_event", int, ScanCode, int, 0, int, 0, int, 0)	; Press
	Sleep, %PressTime%												; Hold
	DllCall("keybd_event", int, ScanCode, int, 0, int, 2, int, 0)	; Release
	return
}

#Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk

Exit
