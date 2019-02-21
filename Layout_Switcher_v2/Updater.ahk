#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, StdOut ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

; Определение классов (для исключения их прямой перезаписи)
; new Script			:= c_Script
;

Maximize_Performance:
{
	#MaxThreads
	SetBatchLines, -1
}

; Script.Force_Single_Instance()
Script.Force_Single_Instance(false, 1, 1)

Script_Name := Script.Name()
Config_File := A_ScriptDir "\" "Updater" ".ini"

NumberOfParameters = %0%

if (NumberOfParameters) {
	Loop, %NumberOfParameters%
	{
		; IfEqual, A_Index, 1, Continue
		Parameter := %A_Index%
		if RegExMatch(Parameter, "-app_pid=(.*)", Match) {
			Process_PID := Match1
			; Process, Close, %Process_PID%
			Script.Close_Process(Process_PID, 5, 1) ; Script.Close_Process(Process_PID)
			; WinWaitClose, ahk_pid %Process_PID%,,5
		}
	}
}

gosub, SET_DEFAULTS
gosub, READ_CONFIG_FILE
gosub, START_UPDATE
gosub, RUN_APP

Exit

SET_DEFAULTS:
{
	Defaults := {}
	; Info
	Defaults.info_download_from := "https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Layout_Switcher_v2/"
	Defaults.info_run_x32 := "Layout_Switcher_x32.exe"
	Defaults.info_run_x64 := "Layout_Switcher_x64.exe"
	return
}

READ_CONFIG_FILE:
{
	; Info
	IniRead, info_download_from, %Config_File%, Info, info_download_from, % Defaults.info_download_from
	Normalize("info_download_from", Defaults.info_download_from)
	info_updater_ini := Defaults.info_download_from . "Updater.ini"

	IniRead, info_run_x32, %Config_File%, Info, info_run_x32, % Defaults.info_run_x32
	Normalize("info_run_x32", Defaults.info_run_x32)
	IniRead, info_run_x64, %Config_File%, Info, info_run_x64, % Defaults.info_run_x64
	Normalize("info_run_x64", Defaults.info_run_x64)

	return
}

START_UPDATE:
{
	if (GetUrlStatus(info_updater_ini) == 200) {
		UrlDownloadToFile, %info_updater_ini%, %Config_File%
	}
	;
	IniRead, info_download_from, %Config_File%, Info, info_download_from
	if (info_download_from == "ERROR") {
		info_download_from := Defaults.info_download_from
		info_run_x32 := Defaults.info_run_x32
		info_run_x64 := Defaults.info_run_x64
		;
		FileDelete, % Config_File
		;
		IniWrite, % info_download_from, %Config_File%, Info, info_download_from
		IniWrite, % info_run_x32, %Config_File%, Info, info_run_x32
		IniWrite, % info_run_x64, %Config_File%, Info, info_run_x64
		;
		default_text =
		(LTrim RTrim Join`r`n
		[Info]
		info_download_from=https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Layout_Switcher_v2/
		info_run_x32=Layout_Switcher_x32.exe
		info_run_x64=Layout_Switcher_x64.exe
		
		[x86]
		; ICONS
		Icons\English.ico
		Icons\Russian.ico
		Icons\Ukrainian.ico
		;
		Icons\Menu\Home.ico
		Icons\Menu\Update.ico
		;
		Icons\Menu\Code.ico
		Icons\Menu\Dictionaries.ico
		Icons\Menu\Folder.ico
		Icons\Menu\Restart.ico
		Icons\Menu\Settings.ico
		Icons\Menu\Shutdown.ico
		; IMAGES
		Images\English.png
		Images\Russian.png
		Images\Ukrainian.png
		; SOUNDS
		Sounds\switch_keyboard_layout.wav
		Sounds\switch_text_case.wav
		Sounds\switch_text_layout.wav
		Sounds\toggle_cursor.wav
		; TRANSLATIONS
		Translations\Russian.ini
		; MAGNIFIER
		Modules\Magnifier\Magnifier.ini
		
		[x32]
		; MAIN
		Layout_Switcher_x32.exe
		; MAGNIFIER
		Modules\Magnifier\Magnifier_x32.exe
		
		[x64]
		; MAIN
		Layout_Switcher_x64.exe
		; MAGNIFIER
		Modules\Magnifier\Magnifier_x64.exe
		
		)
		;
		FileAppend, %default_text%, %Config_File%
	}

	IniRead, x86_section, %Config_File%, x86
	IniRead, x32_section, %Config_File%, x32
	IniRead, x64_section, %Config_File%, x64

	DownloadByList(info_download_from, x86_section)
	if (A_Is64bitOS) {
		DownloadByList(info_download_from, x64_section)
	}
	else {
		DownloadByList(info_download_from, x32_section)
	}

	; MsgBox, Done!
	return
}

RUN_APP:
{
	if (A_Is64bitOS) {
		IniRead, info_run_x64, %Config_File%, Info, info_run_x64, % Defaults.info_run_x64
		Normalize("info_run_x64", Defaults.info_run_x64)
		IniWrite("info_run_x64", Config_File, "Info", info_run_x64)
		if FileExist(info_run_x64) {
			Run, %info_run_x64%
		}
	}
	else {
		IniRead, info_run_x32, %Config_File%, Info, info_run_x32, % Defaults.info_run_x32
		Normalize("info_run_x32", Defaults.info_run_x32)
		IniWrite("info_run_x32", Config_File, "Info", info_run_x32)
		if FileExist(info_run_x32) {
			Run, %info_run_x32%
		}
	}

	return
}
/*
Normalize(VarName, Value := 0)
{
	%VarName% := %VarName% ? %VarName% : Value
}
*/
/*
GetUrlStatus(URL, Timeout = -1)
{ ; проверка статуса URL
	ComObjError(0)
	static WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")

	WinHttpReq.Open("HEAD", URL, True)
	WinHttpReq.Send()
	WinHttpReq.WaitForResponse(Timeout) ; return: Success = -1, Timeout = 0, No response = Empty String

	return WinHttpReq.Status()
}

DownloadByList(RootURL, List, DestDir := False)
{ ; функция загрузки фалов из списка
	static Line, Location, Download
	DestDir := DestDir ? DestDir : A_ScriptDir
	Loop, Parse, List, `n, `r
	{
		Line := Trim(A_LoopField)
		Line := RegExReplace(Line, " `;.*", "")
		if (Line == "") { ; пропуск пустых строк
			Continue
		}
		File := StrReplace(Line, "/", "\")
		Download := RootURL . StrReplace(File, "\", "/")
		if (GetUrlStatus(Download) == 200) {
			if RegExMatch(File, "(.*\\)", Dir) {
				FileCreateDir, % DestDir . "\" . Dir
			}
			UrlDownloadToFile, %Download%, % DestDir "\" . StrReplace(File, "/", "\")
		}
	}
}
*/

#Include ..\Includes\FUNC_Normalize.ahk

#Include ..\Includes\CLASS_Script.ahk
#Include ..\Includes\FUNC_IniWrite.ahk

#Include ..\Includes\FUNC_GetUrlStatus.ahk
#Include ..\Includes\FUNC_DownloadByList.ahk
