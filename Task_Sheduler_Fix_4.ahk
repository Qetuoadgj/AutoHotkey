#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Run_As_Admin( %0% )
Script.Force_Single_Instance()

Sheduler.Repair_Tasks()
Sheduler_Task_Files_List := Sheduler.Get_Task_Files_List( "tasks.csv" )
Sheduler.Clean_Up_Files_According_To_List( Sheduler_Task_Files_List )

MsgBox, Done!

class Sheduler
{	
	static Tasks_Dir := A_WinDir . "\System32\Tasks"
	static Tasks_Dir_Lenght := StrLen( Sheduler.Tasks_Dir . "\" )
	
	Get_Task_Files_List( ByRef Output_Csv_Name := "tasks.csv" )
	{
		static Task_Files_List, Output_Csv, Pattern, Match, File
		Task_Files_List := []
		Output_Csv := A_WorkingDir . "\" . Output_Csv_Name
		If FileExist( Output_Csv ) {
			FileDelete, %Output_Csv%
		}
		RunWait, %ComSpec% /k schtasks.exe /query /v /fo CSV > "%Output_Csv%" & exit ;& pause & exit
		Loop, Read, %Output_Csv%
		{
			Loop, Parse, A_LoopReadLine, `n, `r
			{
				Pattern = ".*?","\\(.*?)",.*
				If RegExMatch( A_LoopReadLine, Pattern, Match ) {
					File := This.Tasks_Dir "\" Match1
					Task_Files_List.Push( File )
					; ToolTip, % File
					; Sleep, 125
				}
			}
		}
		Return, Task_Files_List
	}
	
	Clean_Up_Files_According_To_List( ByRef Task_Files_List )
	{
		static Backup_File
		If FileExist( A_WorkingDir . "\Removed\" ) {
			FileRemoveDir, % A_WorkingDir . "\Removed\", 1
		}
		Loop, Files, % This.Tasks_Dir "\*", RF
		{
			If ( not InArray( Task_Files_List, A_LoopFileFullPath ) ) {
				Backup_File := A_WorkingDir . "\Removed\" . SubStr( A_LoopFileFullPath, This.Tasks_Dir_Lenght )
				FileCopy( A_LoopFileFullPath, Backup_File, 1 )
				If FileExist( Backup_File ) {
					FileRecycle, %A_LoopFileFullPath%
				}
				ToolTip, % SubStr( A_LoopFileFullPath, This.Tasks_Dir_Lenght )
				Sleep, 125
			}
		}
	}
	
	Repair_Tasks()
	{
		static Task_File, Task_File_Name, Task_File_Dir, Task_File_Extension, Task_File_NameNoExt, Task_File_Drive
		static Output_XML
		static Task_Full_Name
		Loop, Files, % This.Tasks_Dir "\*", RF
		{
			Task_File := A_LoopFileLongPath
			SplitPath, Task_File, Task_File_Name, Task_File_Dir, Task_File_Extension, Task_File_NameNoExt, Task_File_Drive
			
			Output_XML := Task_File_Dir "\" Task_File_NameNoExt ".xml"
			
			If FileExist( Output_XML ) {
				FileDelete, %Output_XML%
			}
			
			Task_Full_Name := False
			
			Loop, Read, %Task_File%
			{
				Loop, Parse, A_LoopReadLine, `n, `r
				{
					Line := A_LoopReadLine
					Line := StrReplace( A_LoopReadLine, "<UseUnifiedSchedulingEngine>true</UseUnifiedSchedulingEngine>", "<UseUnifiedSchedulingEngine>false</UseUnifiedSchedulingEngine>" )
					FileAppend, %Line%`n, %Output_XML%
					Task_Full_Name := SubStr( A_LoopFileFullPath, This.Tasks_Dir_Lenght )
					If RegExMatch( A_LoopReadLine, ".*<URI>(.*?)<\/URI>", Match) {
						Task_Full_Name := RegExReplace( Match1, "^\\", "" )
					}
				}
			}
			
			If ( Task_Full_Name and FileExist( Output_XML ) ) {
				This.Delete_Task( Task_Full_Name )
				This.Create_Task_From_XML( Task_Full_Name, Output_XML )
				; MsgBox, % Task_Full_Name
			}
			
			If FileExist( Output_XML ) {
				FileDelete, %Output_XML%
			}
		}
	}
	
	Create_Task_From_XML( ByRef Task_Name, ByRef Task_XML )
	{
		static Command
		Command = schtasks.exe /Create /XML "%Task_XML%" /tn "%Task_Name%"
		; RunWait, %ComSpec% /k %Command% & pause & exit
		RunWait, *RunAs %Command%
	}

	Delete_Task( ByRef Task_Name )
	{
		static Command
		Command = "%A_WinDir%\System32\schtasks.exe" /delete /TN "%Task_Name%" /F
		RunWait, *RunAs %Command%
	}
}

Exit



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

InArray(haystack,needle) {
  If(not isObject(haystack)) {
    Return,False
  }
  If(haystack.Length() == 0) {
    Return,False
  }
  For k,v in haystack {
    If(v == needle){
      Return,True
    }
  }
  Return,False
}

; ===================================================================================
; 		 ФУНКЦИЯ КОПИРОВАНИЯ ФАЙЛОВ С АВТОМАТИЧЕСКИМ СОЗДАНИЕМ НЕОБХОДИМЫХ ПАПОК
; ===================================================================================
FileCopy(SourcePattern, DestPattern, Flag = 0)
{
	IfNotExist,% SourcePattern
		return -1
	SplitPath, DestPattern, , OutDir
	IfNotExist, OutDir
	{
		FileCreateDir,% OutDir
		if ErrorLevel
			return -2
	}
	FileCopy,% SourcePattern,% DestPattern,% Flag
	return ErrorLevel
}
