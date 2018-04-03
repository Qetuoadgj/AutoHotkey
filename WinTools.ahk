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

; Your code here...

global DevManView := A_Is64bitOS ? A_ScriptDir . "\DevManView\DevManView_x64.exe" : A_ScriptDir . "\DevManView\DevManView_x32.exe"
global GeForce610M := "NVIDIA GeForce 610M" ;"VideoMate TV Capture" ;"NVIDIA GeForce 610M"
global WinUpdateService := "wuauserv"

gosub, InitGUI
gosub, CheckGeForce610mStatus
gosub, CheckWinUpdatesStatus
; MsgBox, % GetServiceStatus(WinUpdateService)

Exit

Language_Name(HKL, Full_Name := false)
{ ; функция получения наименования (сокращенного "en" или полного "English") раскладки по ее "HKL"
	static LocID, LCType, Size
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	;
	LocID := HKL & 0xFFFF
	LCType := Full_Name ? LOCALE_SENGLANGUAGE : SISO639LANGNAME
	Size := DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0) * 2
	VarSetCapacity(localeSig, Size, 0)
	DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size)
	return localeSig
}

WriteTranslation(Key, File, Section, TransTable, DefaultSection := "en")
{ ; замена стандартного IniWrite (записывает только измененные параметры)
	static Value, Test_Value
	;
	Value := TransTable[Section] ? TransTable[Section][Key] : (TransTable[DefaultSection] ? TransTable[DefaultSection][Key] : "")
	; MsgBox, %Value%
	if (Value == "") {
		return
	}
	if (not File) {
		return
	}
	IniRead, Test_Value, %File%, %Section%, %Key%, %A_Space%
	; MsgBox, % StrLen(Test_Value)
	if (StrLen(Test_Value) = 0) {
		IniWrite, %Value%, %File%, %Section%, %Key%
	}
}

FindTranslation(Key, Section, TransTable, DefaultSection := "en")
{
	return TransTable[Section] ? TransTable[Section][Key] : (TransTable[DefaultSection] ? TransTable[DefaultSection][Key] : "")
}


CREATE_LOCALIZATION:
{
	Translation_Language := Language_Name("0x" . A_Language, false)
	Translation_File := A_ScriptDir . "\" . Script_Name .  ".ini"
	; MsgBox, % Translation_Language

	Translations := {}

	Translations.en := {}
	Translations.en.clear_printer_queue := "Clear Printer Queue"
	Translations.en.clear_events_log := "Clear Events Log"
	Translations.en.fix_desktop_icons_bug := "Fix Desktop Icons Bug"
	Translations.en.win_safe_mode_minimal := "Reboot Windows in Safe Mode (minimal)"
	Translations.en.win_safe_mode_network := "Reboot Windows in Safe Mode (network)"
	Translations.en.win_normal_mode := "Reboot Windows in Normal Mode"
	Translations.en.win_updates_disable := "Disable Windows Update Service"
	Translations.en.win_updates_enable := "Enable Windows Update Service"
	Translations.en.geforce610m_disable := "Disable" . GeForce610M ;"Disable Video Adapter GeForce 610M"
	Translations.en.geforce610m_enable := "Enable" . GeForce610M ;"Enable Video Adapter GeForce 610M"
	Translations.en.reboot := "Reboot"

	Translations.ru := {}
	Translations.ru.clear_printer_queue := "Очистить очередь печати"
	Translations.ru.clear_events_log := "Очистить журнал событий"
	Translations.ru.fix_desktop_icons_bug := "Исправить иконки рабочего стола"
	Translations.ru.win_safe_mode_minimal := "Безопасный режим Windows (минимальный)"
	Translations.ru.win_safe_mode_network := "Безопасный режим Windows (сетевой)"
	Translations.ru.win_normal_mode := "Обычный режим Windows"
	Translations.ru.win_updates_disable := "Отключить службу обновлений Windows"
	Translations.ru.win_updates_enable := "Включить службу обновлений Windows"
	Translations.ru.geforce610m_disable := "Отключить устроство: " . GeForce610M ;"Отключить видео адаптер GeForce 610M"
	Translations.ru.geforce610m_enable := "Включить устроство: " . GeForce610M ;"Включить видео адаптер GeForce 610M"
	Translations.ru.reboot := "Перезагрузка"

	if Script.InArgs("/L") {
		WriteTranslation("clear_printer_queue", Translation_File, "en", Translations, "en")
		WriteTranslation("clear_events_log", Translation_File, "en", Translations, "en")
		WriteTranslation("fix_desktop_icons_bug", Translation_File, "en", Translations, "en")
		WriteTranslation("win_safe_mode_minimal", Translation_File, "en", Translations, "en")
		WriteTranslation("win_safe_mode_network", Translation_File, "en", Translations, "en")
		WriteTranslation("win_normal_mode", Translation_File, "en", Translations, "en")
		WriteTranslation("win_updates_disable", Translation_File, "en", Translations, "en")
		WriteTranslation("win_updates_enable", Translation_File, "en", Translations, "en")
		WriteTranslation("geforce610m_disable", Translation_File, "en", Translations, "en")
		WriteTranslation("geforce610m_enable", Translation_File, "en", Translations, "en")
		WriteTranslation("reboot", Translation_File, "en", Translations, "en")

		WriteTranslation("clear_printer_queue", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("clear_events_log", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("fix_desktop_icons_bug", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("win_safe_mode_minimal", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("win_safe_mode_network", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("win_normal_mode", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("win_updates_disable", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("win_updates_enable", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("geforce610m_disable", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("geforce610m_enable", Translation_File, Translation_Language, Translations, "en")
		WriteTranslation("reboot", Translation_File, Translation_Language, Translations, "en")
	}
	
	; Translations
	IniRead, l_clear_printer_queue, %Translation_File%, %Translation_Language%, clear_printer_queue, % FindTranslation("clear_printer_queue", Translation_Language, Translations, "en") ;Translations.en.clear_printer_queue
	IniRead, l_clear_events_log, %Translation_File%, %Translation_Language%, clear_events_log, % FindTranslation("clear_events_log", Translation_Language, Translations, "en") ;Translations.en.clear_events_log
	IniRead, l_fix_desktop_icons_bug, %Translation_File%, %Translation_Language%, fix_desktop_icons_bug, % FindTranslation("fix_desktop_icons_bug", Translation_Language, Translations, "en") ;Translations.en.fix_desktop_icons_bug

	IniRead, l_win_safe_mode_minimal, %Translation_File%, %Translation_Language%, win_safe_mode_minimal, % FindTranslation("win_safe_mode_minimal", Translation_Language, Translations, "en") ;Translations.en.win_safe_mode_minimal
	IniRead, l_win_safe_mode_network, %Translation_File%, %Translation_Language%, win_safe_mode_network, % FindTranslation("win_safe_mode_network", Translation_Language, Translations, "en") ;Translations.en.win_safe_mode_network
	IniRead, l_win_normal_mode, %Translation_File%, %Translation_Language%, win_normal_mode, % FindTranslation("win_normal_mode", Translation_Language, Translations, "en") ;Translations.en.win_normal_mode

	IniRead, l_win_updates_disable, %Translation_File%, %Translation_Language%, win_updates_disable, % FindTranslation("win_updates_disable", Translation_Language, Translations, "en") ;Translations.en.win_updates_disable
	IniRead, l_win_updates_enable, %Translation_File%, %Translation_Language%, win_updates_enable, % FindTranslation("win_updates_enable", Translation_Language, Translations, "en") ;Translations.en.win_updates_enable

	IniRead, l_geforce610m_disable, %Translation_File%, %Translation_Language%, geforce610m_disable, % FindTranslation("geforce610m_disable", Translation_Language, Translations, "en") ;Translations.en.geforce610m_disable
	IniRead, l_geforce610m_enable, %Translation_File%, %Translation_Language%, geforce610m_enable, % FindTranslation("geforce610m_enable", Translation_Language, Translations, "en") ;Translations.en.geforce610m_enable

	IniRead, l_reboot, %Translation_File%, %Translation_Language%, reboot, % FindTranslation("reboot", Translation_Language, Translations, "en") ;Translations.en.reboot

	return
}

InitGUI:
{
	gosub, CREATE_LOCALIZATION

	global Btn_Margin_X := 10, Btn_Margin_Y := 10/1.5, Btn_X := Btn_Margin_X, Btn_Y := Btn_Margin_Y, Btn_W := 160, Btn_H := 33

	Gui, +AlwaysOnTop
	
	Gui, Font, s8 norm, Arial

	Gui, Font, norm
	Gui, Add, Button, % " x" Btn_Margin_X " y" Btn_Margin_Y " w" . Btn_W . " h" . Btn_H . " g" . "ClearPrinterQueue", %l_clear_printer_queue%
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "ClearEventsLog", %l_clear_events_log%
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "FixDesktopIcons", %l_fix_desktop_icons_bug%

	Gui, Font, bold
	Gui, Add, Button, % " x+" Btn_Margin_X " y" Btn_Margin_Y " w" Btn_W " h" Btn_H " g" "WinReBootSafeMin", %l_win_safe_mode_minimal%
	Gui, Font, norm
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinReBootSafeNet", %l_win_safe_mode_network%
	Gui, Font, bold
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinReBootNormal", %l_win_normal_mode%

	Gui, Font, norm
	Gui, Add, Button, % " x+" Btn_Margin_X " y" Btn_Margin_Y " w" Btn_W " h" Btn_H " g" "WinUpdatesDisable" " v" "WinUpdatesDisable", %l_win_updates_disable%
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "WinUpdatesEnable" " v" "WinUpdatesEnable", %l_win_updates_enable%

	Gui, Font, norm
	Gui, Add, Button, % " x+" Btn_Margin_X " y" Btn_Margin_Y " w" Btn_W " h" Btn_H " g" "GeForce610mDisable" " v" "GeForce610mDisable", %l_geforce610m_disable%
	Gui, Add, Button, % " w" Btn_W " h" Btn_H " g" "GeForce610mEnable" " v" "GeForce610mEnable", %l_geforce610m_enable%

	Gui, Show,, % Script_Name

	return
}

ClearPrinterQueue(CP := "CP866")
{
	static Command, BatFile
	BatFile := A_Temp . "\ClearPrinterQueue.bat"
	Command =
	( LTrim RTrim Join`r`n
		@echo off

		call :isAdmin
		if `%ErrorLevel`% == 0 `(
		echo.Running with admin rights.
		echo.
		`) else `(
		echo.Error: You must run this script as an Administrator!
		echo.
		pause
		goto :theEnd
		`)

		net stop spooler
		del "`%systemroot`%\System32\spool\PRINTERS\*" /Q /F /S
		net start spooler

		:theEnd
		exit

		:isAdmin
		fsutil dirty query `%systemdrive`% >nul
		exit /b
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

		call :isAdmin
		if `%ErrorLevel`% == 0 `(
		echo.Running with admin rights.
		echo.
		`) else `(
		echo.Error: You must run this script as an Administrator!
		echo.
		pause
		goto :theEnd
		`)

		for /F "tokens=*" `%`%G in ('wevtutil.exe el') do (call :do_clear "`%`%G")
		echo.
		echo.Event Logs have been cleared!
		goto :theEnd

		:do_clear
		echo.clearing `%1
		wevtutil.exe cl `%1
		exit /b

		:theEnd
		exit

		:isAdmin
		fsutil dirty query `%systemdrive`% >nul
		exit /b
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
	static CmdCommand, PSCommand, BatFile, PSFile
	BatFile := A_Temp . "\FixDesktopIcons.bat"
	/*
	$apppath = "powershell.exe"
	$taskname = "Launch $apppath"
	schtasks /create /SC ONCE /ST 23:59 /TN $taskname /TR $apppath
	schtasks /run /tn $taskname
	Start-Sleep -s 1
	schtasks /delete /tn $taskname /F
	*/
	CmdCommand =
	( LTrim RTrim Join`r`n
		@echo off

		call :isAdmin
		if `%ErrorLevel`% == 0 `(
		echo.Running with admin rights.
		echo.
		`) else `(
		echo.Error: You must run this script as an Administrator!
		echo.
		pause
		goto :theEnd
		`)

		tasklist | find /i "explorer.exe" || start "" "explorer.exe"
		ie4uinit.exe -ClearIconCache
		tasklist | find /i "explorer.exe" && taskkill /im explorer.exe /F || echo.process "explorer.exe" not running.
		del "`%LocalAppData`%\IconCache.db" /A
		del "`%LocalAppData`%\Microsoft\Windows\Explorer\iconcache*" /A
		set "apppath=explorer.exe"
		set "taskname=Launch `%apppath`%"
		schtasks /create /SC ONCE /ST 23:59 /TN "`%taskname`%" /TR "`%apppath`%" /F
		schtasks /run /tn "`%taskname`%"
		schtasks /delete /tn "`%taskname`%" /F

		:theEnd
		exit

		:isAdmin
		fsutil dirty query `%systemdrive`% >nul
		exit /b
	)
	FileDelete, %BatFile%
	FileAppend, %CmdCommand%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" ;,, Hide
	/*
	PSFile := A_Temp . "\RunNonElevatedExplorer.ps1"
	PSCommand =
	( LTrim RTrim Join`r`n
		$apppath = "explorer.exe"
		$taskname = "Launch $apppath"
		$action = New-ScheduledTaskAction -Execute $apppath
		$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date)
		Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskname -Settings "New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries" | Out-Null
		Start-ScheduledTask -TaskName $taskname
		Start-Sleep -s 1
		Unregister-ScheduledTask -TaskName $taskname -Confirm:$false
	)
	FileDelete, %PSFile%
	FileAppend, %PSCommand%, %PSFile%, %CP%
	RunWait, *RunAs PowerShell.exe "Set-ExecutionPolicy RemoteSigned"
	RunWait, *RunAs PowerShell.exe -NoExit -Command &{%PSFile%} ;'%param1%' '%param2%'
	RunWait, *RunAs PowerShell.exe "Set-ExecutionPolicy Restricted"
	*/
	; RunExplorer()
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
	global l_win_safe_mode_minimal, l_win_safe_mode_network, l_win_normal_mode, l_reboot
	static Command, BatFile, Go, ModeName
	Go := 0, ModeName := ""
	if (Mode = "SafeMin") {
		BatFile := A_Temp . "\SafeModeMin.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off

			call :isAdmin
			if `%ErrorLevel`% == 0 `(
			echo.Running with admin rights.
			echo.
			`) else `(
			echo.Error: You must run this script as an Administrator!
			echo.
			pause
			goto :theEnd
			`)

			bcdedit /set safeboot minimal
			shutdown -r -f -t 0

			:theEnd
			exit

			:isAdmin
			fsutil dirty query `%systemdrive`% >nul
			exit /b
		)
		Go := 1
		ModeName := l_win_safe_mode_minimal ;"Safe Minimal"
	}
	else if (Mode = "SafeNet") {
		BatFile := A_Temp . "\SafeModeNet.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off

			call :isAdmin
			if `%ErrorLevel`% == 0 `(
			echo.Running with admin rights.
			echo.
			`) else `(
			echo.Error: You must run this script as an Administrator!
			echo.
			pause
			goto :theEnd
			`)

			bcdedit /set safeboot network
			shutdown -r -f -t 0

			:theEnd
			exit

			:isAdmin
			fsutil dirty query `%systemdrive`% >nul
			exit /b
		)
		Go := 1
		ModeName := l_win_safe_mode_network ;"Safe Network"
	}
	else if (Mode = "Normal") {
		BatFile := A_Temp . "\SafeModeOff.bat"
		Command =
		( LTrim RTrim Join`r`n
			@echo off

			call :isAdmin
			if `%ErrorLevel`% == 0 `(
			echo.Running with admin rights.
			echo.
			`) else `(
			echo.Error: You must run this script as an Administrator!
			echo.
			pause
			goto :theEnd
			`)

			bcdedit /deletevalue safeboot
			shutdown -r -f -t 0

			:theEnd
			exit

			:isAdmin
			fsutil dirty query `%systemdrive`% >nul
			exit /b
		)
		Go := 1
		ModeName := l_win_normal_mode ;"Normal Mode"
	}
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	; StringUpper, ModeName, ModeName
	; MsgBox, 33, Windows ReBoot - %ModeName%, Reboot Windows in [%ModeName%] mode?
	MsgBox, 262433, %l_reboot%, %l_reboot%: %ModeName%.
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

WinUpdatesDisable:
{
	
	; RunWait, *RunAs %ComSpec% /k net stop "%WinUpdateService%" & exit ;,, Hide
	RunWait, *RunAs %ComSpec% /k sc config "%WinUpdateService%" start= disabled & sc stop "%WinUpdateService%" & exit ;,, Hide
	gosub, CheckWinUpdatesStatus
	MsgBox, 262144, % "Win Updates Disable", % "OK", 1
	return
}

WinUpdatesEnable:
{
	; RunWait, *RunAs %ComSpec% /k net start "%WinUpdateService%" & exit ;,, Hide
	RunWait, *RunAs %ComSpec% /k sc config "%WinUpdateService%" start= delayed-auto & sc start "%WinUpdateService%" & exit ;,, Hide
	gosub, CheckWinUpdatesStatus
	MsgBox, 262144, % "Win Updates Enable", % "OK", 1
	return
}

GeForce610mDisable:
{
	if FileExist(DevManView) {
		RunWait, *RunAs %DevManView% /disable "%GeForce610M%"
		gosub, CheckGeForce610mStatus
		MsgBox, 262144, % "%GeForce610M% Disable", % "OK", 1
	}
	return
}

GeForce610mEnable:
{
	if FileExist(DevManView) {
		RunWait, *RunAs %DevManView% /enable "%GeForce610M%"
		gosub, CheckGeForce610mStatus
		MsgBox, 262144, % "%GeForce610M% Enable", % "OK", 1
	}
	return
}

GuiClose:
{
	ExitApp
}

; /*
RunNotElevated(AppPath, CP := "CP866")
{
	static Command, BatFile
	BatFile := A_Temp . "\RunNotElevated.bat"
	Command =
	( LTrim RTrim Join`r`n
		@echo off

		if "`%~1" == "" goto :theEnd

		call :isAdmin
		if `%ErrorLevel`% == 0 `(
		echo.Running with admin rights.
		echo.
		`) else `(
		echo.Error: You must run this script as an Administrator!
		echo.
		pause
		goto :theEnd
		`)

		set "apppath=`%~1"
		set "taskname=Launch `%apppath`%"
		schtasks /create /SC ONCE /ST 23:59 /TN "`%taskname`%" /TR "`%apppath`%" /F
		schtasks /run /tn "`%taskname`%"
		schtasks /delete /tn "`%taskname`%" /F

		:theEnd
		exit

		:isAdmin
		fsutil dirty query `%systemdrive`% >nul
		exit /b
	)
	FileDelete, %BatFile%
	FileAppend, %Command%, %BatFile%, %CP%
	RunWait, *RunAs %ComSpec% /k call "%BatFile%" "%AppPath%";,, Hide
	; FileDelete, %BatFile%
	return
}
; */

/*
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
*/

GetDeviceStatus(DeviceName)
{
	global DevManView
	
	static DeviceStatus
	DeviceStatus := ""
	
	static DeviceFound, DeviceIndex, DeviceDisabled
	DeviceFound := ""
	DeviceIndex := ""
	DeviceDisabled := ""
	
	static XML_file
	XML_file := A_Temp . "\DevManView_Log.xml"
	
	FileDelete, %XML_file%
	RunWait, *RunAs %DevManView% /sxml "%XML_file%"
	if FileExist(XML_file) {
		FileRead, XML_data, %XML_file%
		XML := ComObjCreate("MSXML2.DOMDocument.6.0")
		XML.loadXML(XML_data)
		
		static IDS, ID, Node

		IDS := XML.SelectNodes("//devices_list/item/device_name")
		ID := [] ; use this to store each item's text data
		Loop, % IDS.length ; number of items that matched the selection
		{
			id[A_Index] := IDS.item(A_Index-1) ; access each item using the item() method
			Node := id[A_Index]
			if (Node.text = DeviceName) {
				DeviceFound := true
				DeviceIndex := A_Index
				break
			}
		}
		if (DeviceFound) {
			IDS := XML.SelectNodes("//devices_list/item/disabled")
			id := [] ; use this to store each item's text data
			Loop, % IDS.length ; number of items that matched the selection
			{
				if (A_Index == DeviceIndex) {
					id[A_Index] := IDS.item(A_Index-1) ; access each item using the item() method
					Node := id[A_Index]
					DeviceDisabled := Node.text
					break
				}
			}
		}
	}
	
	FileDelete, %XML_file%

	if (DeviceDisabled = "Yes") {
		return "Disabled"
	}
	if (DeviceDisabled = "No") {
		return "Enabled"
	}
	
	return "ERROR"
}

CheckGeForce610mStatus:
{
	GeForce610mStatus := GetDeviceStatus(GeForce610M)
	GuiControl, Enable, GeForce610mDisable
	GuiControl, Enable, GeForce610mEnable
	if (GeForce610mStatus = "ERROR") {
		GuiControl, Disable, GeForce610mDisable
		GuiControl, Disable, GeForce610mEnable
	} else if (GeForce610mStatus = "Enabled") {
		GuiControl, Disable, GeForce610mEnable
	} else if (GeForce610mStatus = "Disabled") {
		GuiControl, Disable, GeForce610mDisable
	}
	return
}

GetServiceStatus(ServiceName)
{
	static ServiceStatus
	ServiceStatus := ""
	
	static CmdStdOut
	; CmdStdOut := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c sc query """ . ServiceName . """ | find ""RUNNING""").StdOut.ReadAll()
	CmdStdOut := ComObjCreate("WScript.Shell").Exec("cmd.exe /q /c chcp 437 & sc query """ . ServiceName . """").StdOut.ReadAll()
	
	static Match, Match1
	if RegExMatch(CmdStdOut, " STATE[\t ]+:[\t ]+\d+[\t ]+(.*)", Match) {
		return Trim(Match1)
	}
	return "ERROR"
}

CheckWinUpdatesStatus:
{
	WinUpdatesStatus := GetServiceStatus(WinUpdateService)
	; MsgBox, %WinUpdatesStatus%
	GuiControl, Enable, WinUpdatesDisable
	GuiControl, Enable, WinUpdatesEnable
	if (WinUpdatesStatus = "ERROR") {
		GuiControl, Disable, WinUpdatesDisable
		GuiControl, Disable, WinUpdatesEnable
	} else if (WinUpdatesStatus = "RUNNING") {
		GuiControl, Disable, WinUpdatesEnable
	} else {
		GuiControl, Disable, WinUpdatesDisable
	}
	return
}


#Include CLASS_Script.ahk
