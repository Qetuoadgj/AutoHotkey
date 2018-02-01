#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()
Script.Run_As_Admin()
/*
If not ( Win_Width or Win_Height ) {
	MsgBox, Не найдено окно:`n%Win_Title%
	ExitApp
}
*/

Win_Title := "ahk_class TARGETRECT ahk_exe bdcam.exe"

#IfWinExist, ahk_class TARGETRECT ahk_exe bdcam.exe
{
	^f::
	{
		ControlSend,,^f,%Win_Title%
		ToolTip(1111)
		Return
	}
}

ExitApp

GetStartDimensions:
{
	Win_Width = 683
	Win_Height = 475
	If not ( Win_Width or Win_Height ) {
		WinGetPos,,, Win_Width, Win_Height, %Win_Title%
	}
	Return
}

Get_Min( ByRef Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	SendMessage, 0x0401, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMIN
	Return, ErrorLevel
}

Get_Max( ByRef Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	SendMessage, 0x0402, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMAX
	Return, ErrorLevel
}
Get_Pos( ByRef Win_ID := False )
{
	Win_ID := Win_ID ? Win_ID : WinExist("A")
	static Min, Max, Pos
	SendMessage, 0x0401, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMIN
	Min := ErrorLevel
	SendMessage, 0x0402, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETRANGEMAX
	Max := ErrorLevel
	SendMessage, 0x0400, 0, 0, msctls_trackbar321, ahk_id %Win_ID% ; TBM_GETPOS
	Pos := ErrorLevel
	Pos := Pos > Max ? Pos - Min - Max : Pos
	Return, Pos
}

To_Percent( ByRef Cur, ByRef Max, ByRef Rnd := 0)
{
	Return, Round( Cur / Max * 100, Rnd )
}

To_Pos( ByRef Pct, ByRef Max, ByRef Rnd := 0 )
{
	Return, Round( Max * ( Pct / 100 ), Rnd )
}

ToolTip( ByRef text, ByRef time := 800 )
{ ; функция вывода высплывающей подсказки с последующим ( убирается по таймеру )
	Tooltip, %text%
	SetTimer, Clear_ToolTips, %time%
}

Clear_ToolTips:
{ ; рутина очистки подсказок и отключения связанных с ней таймеров
	ToolTip
	SetTimer, %A_ThisLabel%, Off
	Return
}

class Script
{ ; функции управления скриптом
	
	Force_Single_Instance()
	{ ; функция автоматического завершения всех копий текущего скрипта (одновременно для .exe и .ahk)
		static Detect_Hidden_Windows_Tmp
		static File_Types, Index, File_Type
		static Script_Name, Script_Full_Path
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
		static Process_ID
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
		SplitPath, A_ScriptFullPath,,,, Name
		Return, Name
	}
}
