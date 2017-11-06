#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

Script_Name := Script.Name()
Config_File := A_ScriptDir "\" "Updater" ".ini"

NumberOfParameters = %0%

If ( NumberOfParameters ) {
	Loop, %NumberOfParameters%
	{
		; IfEqual, A_Index, 1, Continue
		Parameter := %A_Index%
		If RegExMatch( Parameter, "-app_pid=(.*)", Match ) {
			Process_PID := Match1
			Process, Close, %Process_PID%
			WinWaitClose, ahk_pid %Process_PID%,,5
		}
	}
}

GoSub, SET_DEFAULTS
GoSub, READ_CONFIG_FILE
GoSub, START_UPDATE
GoSub, RUN_APP

Exit

SET_DEFAULTS:
{
	Defaults := {}
	; Info
	Defaults.info_download_from := "https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/Layout_Switcher_v2/"
	Defaults.info_run_x32 := "Layout_Switcher_x32.exe"
	Defaults.info_run_x64 := "Layout_Switcher_x64.exe"
	Return
}

READ_CONFIG_FILE:
{
	; Info
	IniRead, info_download_from, %Config_File%, Info, info_download_from, % Defaults.info_download_from
	Normalize( "info_download_from", Defaults.info_download_from )
	info_updater_ini := Defaults.info_download_from . "Updater.ini"
	
	IniRead, info_run_x32, %Config_File%, Info, info_run_x32, % Defaults.info_run_x32
	Normalize( "info_run_x32", Defaults.info_run_x32 )
	IniRead, info_run_x64, %Config_File%, Info, info_run_x64, % Defaults.info_run_x64
	Normalize( "info_run_x64", Defaults.info_run_x64 )

	Return
}

START_UPDATE:
{	
	If ( GetUrlStatus( info_updater_ini ) == 200 ) {
		UrlDownloadToFile, %info_updater_ini%, %Config_File%
	}
	;
	IniRead, info_download_from, %Config_File%, Info, info_download_from
	If ( info_download_from == "ERROR" ) {
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
		( LTrim RTrim Join`r`n
			[x86]
			; ICONS
			Icons\English.ico
			Icons\Russian.ico
			Icons\Ukrainian.ico
			;
			Icons\Menu\Home.ico
			Icons\Menu\Update.ico
			;
			Icons\Menu\Dictionaries.ico
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
			; TRANSLATIONS
			Translations\Russian.ini
			[x32]
			Layout_Switcher_x32.exe
			[x64]
			Layout_Switcher_x64.exe
		)
		;
		FileAppend, %default_text%, %Config_File%		
	}
	
	IniRead, x86_section, %Config_File%, x86
	IniRead, x32_section, %Config_File%, x32
	IniRead, x64_section, %Config_File%, x64
	
	DownloadFromList( info_download_from, x86_section )
	If ( A_Is64bitOS ) {
		DownloadFromList( info_download_from, x64_section )
	} Else {
		DownloadFromList( info_download_from, x32_section )
	}
	
	; MsgBox, Done!
	Return
}

RUN_APP:
{
	If ( A_Is64bitOS ) {
		IniRead, info_run_x64, %Config_File%, Info, info_run_x64, % Defaults.info_run_x64
		Normalize( "info_run_x64", Defaults.info_run_x64 )
		IniWrite( "info_run_x64", Config_File, "Info", info_run_x64 )
		If FileExist( info_run_x64 ) {
			Run, %info_run_x64%
		}
	} Else {
		IniRead, info_run_x32, %Config_File%, Info, info_run_x32, % Defaults.info_run_x32
		Normalize( "info_run_x32", Defaults.info_run_x32 )
		IniWrite( "info_run_x32", Config_File, "Info", info_run_x32 )
		If FileExist( info_run_x32 ) {
			Run, %info_run_x32%
		}
	}
	
	Return
}

Normalize( ByRef VarName, ByRef Value := 0 )
{
	%VarName% := %VarName% ? %VarName% : Value
}

GetUrlStatus( ByRef URL, ByRef Timeout = -1 )
{ ; проверка статуса URL
	ComObjError(0)
	static WinHttpReq := ComObjCreate("WinHttp.WinHttpRequest.5.1")

	WinHttpReq.Open("HEAD", URL, True)
	WinHttpReq.Send()
	WinHttpReq.WaitForResponse(Timeout) ; Return: Success = -1, Timeout = 0, No response = Empty String

	Return, WinHttpReq.Status()
}

DownloadFromList( ByRef DownloadFrom, ByRef List, ByRef DestDir := False )
{
	static Line, Location, Download
	DestDir := DestDir ? DestDir : A_ScriptDir
	Loop, Parse, List, `n, `r
	{
		Line := Trim( A_LoopField )
		Line := RegExReplace( Line, " `;.*", "" )
		If ( Line == "" ) { ; пропуск пустых строк
			Continue
		}
		File := StrReplace( Line, "/", "\" )
		Download := DownloadFrom . StrReplace( File, "\", "/" )
		If ( GetUrlStatus( Download ) == 200 ) {
			If RegExMatch( File, "(.*\\)", Dir ) {
				FileCreateDir, % DestDir "\" Dir
			}
			UrlDownloadToFile, %Download%, % DestDir "\" . StrReplace( File, "/", "\" )
		}
	}
}

class Script
{ ; функции управления скриптом
	
	Force_Single_Instance()
	{ ; функция автоматического завершения всех копий текущего скрипта (одновременно для .exe и .ahk)
		static Detect_Hidden_Windows_Tmp
		static File_Types, Index, File_Type
		static Script_Name, Script_Full_Path
		;
		Detect_Hidden_Windows_Tmp := A_DetectHiddenWindows
		#SingleInstance, Off
		DetectHiddenWindows, On
		File_Types := [ ".exe", ".ahk" ]
		For Index, File_Type in File_Types {
			Script_Name := RegExReplace( A_ScriptName, "^(.*)\.(.*)$", "$1" ) . File_Type
			Script_Full_Path := A_ScriptDir . "\" . Script_Name
			This.Close_Other_Instances( Script_Full_Path . "ahk_class AutoHotkey" )
		}
		DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
	}

	Close_Other_Instances( ByRef Script_Full_Path )
	{ ; функция завершения всех копий текущего скрипта (только для указанного файла)
		static Current_ID, Process_List, Process_Count, Process_ID, Process_PID
		;
		Script_Full_Path := Script_Full_Path ? Script_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
		WinGet, Process_List, List, % Script_Full_Path . " ahk_class AutoHotkey"
		Process_Count := 1
		Loop, %Process_List%
		{
			Process_ID := Process_List%Process_Count%
			If ( not Process_ID = Current_ID ) {
				WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
				Process, Close, %Process_PID%
			}
			Process_Count += 1
		}
	}

	Run_As_Admin( ByRef Params := "" )
	{ ; функция запуска скрипта с правами адиминистратора
		If ( not A_IsAdmin ) {
			Try {
				Run, *RunAs "%A_ScriptFullPath%" %Params%
			}
			ExitApp
		}
	}
	
	Name()
	{ ; функция получения имени текущего скрипта
		static Name
		;
		SplitPath, A_ScriptFullPath,,,, Name
		Return, Name
	}
}

IniWrite( ByRef Key, ByRef File, ByRef Section, ByRef Value )
{ ; замена стандартонго IniWrite (записывает только измененные параметры)
	static Test_Value
	;
	If ( not File ) {
		Return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead, Test_Value, %File%, %Section%, %Key%
	If ( not Test_Value = Value ) {
		IniWrite, %Value%, %File%, %Section%, %Key%
	}
}
