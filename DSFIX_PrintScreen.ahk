#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#Persistent
; #SingleInstance, Ignore

#SingleInstance, Off
Script_Name := Script.Name()
Script_Args := Script.Args()
Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])
Script.Run_As_Admin(Script_Args)
 
global VK_PAUSE := 19
global VK_PRINTSCREEN := 44

gosub, Init_HotKeys
gosub, Show_Tray_Tip

Exit

Init_HotKeys:
{
	#IfWinActive, DARK SOULS ahk_class DARK SOULS ahk_exe DATA.exe
	{
		$*SC029:: ; ` [vk192] 
		{ ; take Hudless Screenshot
			; SendKey(VK_Pause, 50), SendKey(VK_PrintScreen, 50), SendKey(VK_Pause, 50)
			TakeScreenshot(VK_PRINTSCREEN, VK_PAUSE, 1)
			Sleep, 50
			return
		}
		/*
		$*SC002:: ; 1 [vk49]
		{ ; cycle Items
			SendKey(82, 50) ; R [vk82]
			Sleep, 50
			return
		}
		$*SC003:: ; 2 [vk50]
		{ ; cycle Spells
			SendKey(9, 50) ; Tab [vk9]
			Sleep, 50
			return
		}
		*/
	}
	return
}

Show_Tray_Tip:
{
	TrayTip, %Script_Name%, % "OK!", 10
	Sleep, 1000
	TrayTip
	return
}

SendKey(ScanCode, PressTime := 50)
{
	DllCall("keybd_event", int, ScanCode, int, 0, int, 0, int, 0)	; Press
	Sleep, %PressTime%												; Hold
	DllCall("keybd_event", int, ScanCode, int, 0, int, 2, int, 0)	; Release
	return
}

TakeScreenshot(ScreenshotKey, HideHudKey, Hudless)
{
	if (Hudless && HideHudKey) {
		SendKey(HideHudKey, 50), SendKey(ScreenshotKey, 50), SendKey(HideHudKey, 50)
	}
	else {
		SendKey(ScreenshotKey, 50)
	}
}

#Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk
