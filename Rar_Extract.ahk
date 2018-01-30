#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

WinRAR = "C:\Program Files\WinRAR\WinRAR.exe"
Set_CD = cd /d "%A_WorkingDir%"
Output_Dir := A_WorkingDir . "\" . "Extracted" . "\"

if FileExist("Extracted\") {
	FileRemoveDir, Extracted, 1
	}
	
	File_List := []
	Loop, Read, % "List_File.txt"
	{
		Loop, Parse, A_LoopReadLine, `n, `r
		{
			Read_Line := Trim(A_LoopReadLine)
			if RegExMatch( Read_Line, "^;" ) {
				continue
			}
			File_List.Push( Read_Line )
		}
	}
	
	Archive_List := []
	Loop, Files, % "*.pak", RF
	{
		Archive_List.Push( A_LoopFileFullPath )
	}
	
	for File_Index, File in File_List {
		for Archive_Index, Archive in Archive_List {
			Parsed := File_Index/File_List.MaxIndex() + (Archive_Index/Archive_List.MaxIndex() - 1)/100
			Pct := Round( Parsed * 100, 2 ) . "%"
			Tip := "File:   " File " (" File_Index " of " File_List.MaxIndex() ")" . "`n" . "In:     " Archive " (" Archive_Index " of " Archive_List.MaxIndex() ")" . "`n" . "Total: " Pct
			Extract_CMD = %WinRAR% x -INUL -o+ "%Archive%" "%File%" "%Output_Dir%"
			RunWait, %Extract_CMD%
			ToolTip( Tip )
		}
	}
	
	MsgBox, F I N I S H E D
	
	IfExist, %Output_Dir%
	{
		Run, %Output_Dir%
	}
	
	ExitApp
	
	ToolTip( text, time := 800 )
	{ ; функция вывода высплывающей подсказки с последующим ( убирается по таймеру )
		ToolTip, %text%
		SetTimer, Clear_ToolTips, %time%
	}
	
	Clear_ToolTips:
	{ ; рутина очистки подсказок и отключения связанных с ней таймеров
		ToolTip
		SetTimer, %A_ThisLabel%, Off
		return
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
			for Index, File_Type in File_Types {
				Script_Name := RegExReplace( A_ScriptName, "^(.*)\.(.*)$", "$1" ) . File_Type
				Script_Full_Path := A_ScriptDir . "\" . Script_Name
				This.Close_Other_Instances( Script_Full_Path . "ahk_class AutoHotkey" )
			}
			DetectHiddenWindows, % Detect_Hidden_Windows_Tmp
		}
		
		Close_Other_Instances( Script_Full_Path )
		{ ; функция завершения всех копий текущего скрипта (только для указанного файла)
			static Process_ID
			Script_Full_Path := Script_Full_Path ? Script_Full_Path : A_ScriptFullPath . " ahk_class AutoHotkey"
			WinGet, Current_ID, ID, % A_ScriptFullPath . " ahk_class AutoHotkey"
			WinGet, Process_List, List, % Script_Full_Path . " ahk_class AutoHotkey"
			Process_Count := 1
			Loop, %Process_List%
			{
				Process_ID := Process_List%Process_Count%
				if ( not Process_ID = Current_ID ) {
					WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
					Process, Close, %Process_PID%
				}
				Process_Count += 1
			}
		}
		
		Run_As_Admin( Params := "" )
		{ ; функция запуска скрипта с правами адиминистратора
			if ( not A_IsAdmin ) {
				try {
					Run, *RunAs "%A_ScriptFullPath%" %Params%
				}
				ExitApp
			}
		}
		
		Name()
		{ ; функция получения имени текущего скрипта
			SplitPath, A_ScriptFullPath,,,, Name
			return, Name
		}
	}	