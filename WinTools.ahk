#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#Persistent
#SingleInstance, Ignore

Run_As_Admin(Script_Args())

; Your code here...

gosub, InitGUI

Exit

InitGUI:
{
	global Btn_W := 200, Btn_H := 33 
	Gui, +AlwaysOnTop
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "ClearPrinterQueue", % "Clear Printer Queue"
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "ClearEventsLog", % "Clear Events Log"
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "FixDesktopIcons", % "Fix Desktop Icons Bug"
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinReBootSafeMin", % "Win Safe Mode (Minimal)"
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinReBootSafeNet", % "Win Safe Mode (Network)"
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinReBootNormal", % "Win Normal Mode"
	Gui, Show,, % "Win Tools"
	return
}

ClearPrinterQueue(CP := "CP866")
{
	static Command, BatFile
	BatFile := A_Temp . "\ClearPrinterQueue.bat"
	Command =
	( LTrim RTrim Join`r`n
		@echo off
		net stop spooler
		del "`%systemroot`%\System32\spool\PRINTERS\*" /Q /F /S
		net start spooler
		exit
	)
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
	return
}

ClearPrinterQueue:
{
	ClearPrinterQueue()
	MsgBox, 262144, % "Printer Queue", % "OK", 1
	return
}

ClearEventsLog(CP := "CP866")
{
	static Command, BatFile
	BatFile := A_Temp . "\ClearEventsLog.bat"
	Command =
	( LTrim RTrim Join`r`n
		@echo off
		for /F "tokens=1,2*" `%`%V in ('bcdedit') do set adminTest=`%`%V
		if (`%adminTest`%)==(Access) goto noAdmin
		for /F "tokens=*" `%`%G in ('wevtutil.exe el') do (call :do_clear "`%`%G")
		echo.
		echo Event Logs have been cleared!
		goto theEnd
		:do_clear
		echo clearing `%1
		wevtutil.exe cl `%1
		goto :eof
		:noAdmin
		echo You must run this script as an Administrator!
		echo.
		:theEnd
		exit
	)
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
	return
}

ClearEventsLog:
{
	ClearEventsLog()
	MsgBox, 262144, % "Events Log", % "OK", 1
	return
}

FixDesktopIcons(CP := "CP866")
{
	static Command, BatFile
	BatFile := A_Temp . "\FixDesktopIcons.bat"
	Command =
	( LTrim RTrim Join`r`n
		@echo off
		ie4uinit.exe -ClearIconCache
		taskkill /IM explorer.exe /F
		del "`%LocalAppData`%\IconCache.db" /A
		del "`%LocalAppData`%\Microsoft\Windows\Explorer\iconcache*" /A
		REM explorer
		exit
	)
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
	RunExplorer()
	return
}

FixDesktopIcons:
{
	FixDesktopIcons()
	MsgBox, 262144, % "Desktop Icons", % "OK", 1
	return
}

WinReBoot(Mode := "Normal", CP := "CP866")
{ ; функция перезагрузки Windows
	; Modes: SafeNet, SafeMin, Normal
	static Command, BatFile, Go, ModeName
	Go := 0, ModeName := ""
	if (Mode = "SafeMin") {
		BatFile := A_Temp . "\SafeModeMin.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off
			bcdedit /set safeboot minimal
			shutdown -r -f -t 0
			exit
		)
		Go := 1
		ModeName := "Safe Minimal"
	}
	else if (Mode = "SafeNet") {
		BatFile := A_Temp . "\SafeModeNet.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off
			bcdedit /set safeboot network
			shutdown -r -f -t 0
			exit
		)
		Go := 1
		ModeName := "Safe Network"
	}
	else if (Mode = "Normal") {
		BatFile := A_Temp . "\SafeModeOff.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off
			bcdedit /deletevalue safeboot
			shutdown -r -f -t 0
			exit
		)
		Go := 1
		ModeName := "Normal Mode"
	}
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	StringUpper, ModeName, ModeName
	; MsgBox, 33, Windows ReBoot - %ModeName%, Reboot Windows in [%ModeName%] mode?
	MsgBox, 262433, Windows ReBoot - %ModeName%, Reboot Windows in [%ModeName%] mode?
	IfMsgBox, OK
	{
		if (Go) {
			RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
		}
	}
	return
}

WinReBootSafeMin:
{
	WinReBoot("SafeMin")
	return
}

WinReBootSafeNet:
{
	WinReBoot("SafeNet")
	return
}

WinReBootNormal:
{
	WinReBoot("Normal")
	return
}


GuiClose:
{
	ExitApp
}

Script_Args()
{ ; функция получения аргументов коммандной строки в виде текста
	static ret
	ret := ""
	for n, param in A_Args
	{
		ret .= " " param
	}
	ret := Trim(ret)
	return ret
}

Run_As_Admin(Args := "")
{ ; функция запуска скрипта с правами администратора
	if (not A_IsAdmin) {
		try {
			Run, *RunAs "%A_ScriptFullPath%" %Args%
		}
		ExitApp
	}
}

Close_All_Instances(Process_WinTitle)
{ ; функция завершения всех копий процесса
	static Process_List, Process_Count, Process_ID, Process_PID
	;
	WinGet, Process_List, List, %Process_WinTitle%
	Sleep, 1
	Process_Count := 1
	Loop, %Process_List%
	{
		Process_ID := Process_List%Process_Count%
		; MsgBox, Process_ID: %Process_ID%
		WinGet, Process_PID, PID, % Process_WinTitle . " ahk_id " . Process_ID
		Sleep, 1
		Process, Close, %Process_PID%
		Sleep, 1
		Process_Count += 1
	}
}

RunExplorer(Delays := 250, Tries := 20)
{
	static TaskButtonHWND, TaskMgr_PID
	Close_All_Instances("ahk_class #32770 ahk_exe taskmgr.exe")
	Sleep, 250
	Run, % A_WinDir . "\System32\taskmgr.exe",,, TaskMgr_PID
	WinWait, ahk_pid %TaskMgr_PID%,, 5
	IfWinExist, ahk_pid %TaskMgr_PID%
	{
		WinActivate, ahk_pid %TaskMgr_PID%
		WinWaitActive, ahk_pid %TaskMgr_PID%,, 3
		IfWinActive, ahk_pid %TaskMgr_PID%
		{
			Sleep, %Delays%
			SendInput, {F10}{Enter 2}
			Loop, %Tries%
			{
				Sleep, %Delays%
				ControlGet, CommandLineHWND, Hwnd,, % "Edit1", ahk_pid %TaskMgr_PID%
				if (CommandLineHWND) {
					ControlSetText,, % "explorer", ahk_id %CommandLineHWND%
					Sleep, %Delays%
					Control, UnCheck,, % "Button2", ahk_pid %TaskMgr_PID%
					Sleep, %Delays%
					SendInput, {Enter}
					Sleep, %Delays%
					break
				}
			}
		}
		Sleep, 250
		Process, Close, %TaskMgr_PID%
	}
	return
}
