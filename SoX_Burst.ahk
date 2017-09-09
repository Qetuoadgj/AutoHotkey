#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

SetWorkingDir, % "D:\Downloads\Sounds\sox-14.4.2\converted"

SoX := "D:\Downloads\Sounds\sox-14.4.2\sox.exe"
Output_Dir := A_WorkingDir "\SoX_Output"

Command = ; null

inFilePath := "flyby_004.wav"
inFileExt := RegExReplace( inFilePath, ".*\.(.*)", "$1" )
inFileName := RegExReplace(  RegExReplace( inFilePath, ".*\\(.*)", "$1" ), "(.*)\..*", "$1" )

rpm = 400
shots = 5
step := 60/rpm
pitch := 200

pitch_min := -(pitch/2)
pitch_max := +(pitch/2)

outFilesArray := []
outFilesList := ""

cleanUpArray := []

count := 0

Loop, % shots - 1
{
	count := A_Index
	Random, pitchValue, % pitch_min, % pitch_max
	outFileName := Format( "{1:s}.{2:s}", inFileName " - " count, inFileExt )
	outFilePath := outFileName
	Command = "%SoX%" "%inFilePath%" "%outFilePath%"
	Command .= " pitch " pitchValue
	RunWait, %Command%
	If FileExist( outFilePath )
	{
		outFilesArray.Push( outFilePath )
		; outFilesList .= """" outFilePath """"
		; outFilesList .= " "
		cleanUpArray.Push( outFilePath )
	}
}

For outFileIndex, outFilePath1 in outFilesArray
{
	count := outFileIndex
	Random, stepError, 0.95, 1.05
	outFileName := Format( "{1:s}.{2:s}", inFileName " - cut_" count, inFileExt )
	outFilePath := outFileName
	Command = "%SoX%" "%outFilePath1%" "%outFilePath%"
	Command .= " trim 0 " (step * stepError)
	RunWait, %Command%
	If FileExist( outFilePath )
	{
		; outFilesArray.Push( outFilePath )
		outFilesList .= """" outFilePath """"
		outFilesList .= " "
		cleanUpArray.Push( outFilePath )
	}
}

outFileName := Format( "{1:s}.{2:s}", inFileName " - cut_" count+1, inFileExt )
outFilePath := outFileName
FileCopy, %inFilePath%, %outFilePath%, 1
If FileExist( outFilePath )
{
	outFilesArray.Push( outFilePath )
	outFilesList .= """" outFilePath """"
	outFilesList .= " "
	cleanUpArray.Push( outFilePath )
}

outFilesList := Trim( outFilesList )

outFileName := Format( "{1:s}.{2:s}", inFileName " - Burst " shots, inFileExt )
outFilePath := outFileName

Command = "%SoX%" %outFilesList% "%outFilePath%"
If ( StrLen( Command ) > 0 )
{
	MsgBox, %Command%
	RunWait, %Command%
}

Msg :=  ""
For cleanUpFileIndex, cleanUpFilePath in cleanUpArray
{
	FileDelete, %cleanUpFilePath%
	Msg .= cleanUpFilePath "`n"
}
MsgBox, %Msg%

ExitApp

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

