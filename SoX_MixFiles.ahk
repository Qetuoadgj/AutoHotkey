#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn,All ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

Script.Force_Single_Instance()

; Цикл для всех параметров / файлов открытых в этом приложении
FullPath = ; Null
Loop,%0%
{
	GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	Loop,%GivenPath%,1
	{
		FullPath := A_LoopFileLongPath
	}
}
; Определение полного пути файла-источника
SourceFile := FullPath ? FullPath : "D:\Games\Far Cry\Mods\1_505_TEST\Weapon_Sounds__Bullet_Cracks_Full\Sounds\SoX_Mix.sox_mix" ;FullPath

; Определение путей файла-источника
SplitPath,SourceFile,SourceFileShort,SourceFileDir,SourceFileExtension,SourceFileName,SourceFileDrive

; Назначение рабочего каталога программы
SetWorkingDir,%SourceFileDir%

; Определение значений переменных по умолчанию
SoX := "D:\Downloads\Sounds\sox-14.4.2\sox.exe"
Output_Format := "wav"
Output_Volume := 1.00
L1_Channels := 2
L2_Channels := 2
L1_Factor := "[ 2.00, 2.00 ]"
L2_Factor := "[ 1.00, 1.00 ]"
Output_Channels := 2
Output_Dir := A_WorkingDir "\SoX_Output"
Mix_Table := Output_Dir "\Mix_Table.txt"
Mix_Log := Output_Dir "\Mix_Log.txt"

; Получение переменных из файла-источника
IniRead,SoX,%SourceFile%,Options,SoX,%SoX%
SoX := RegExReplace(SoX,"[ \t]+;.*$","")

IniRead,Output_Format,%SourceFile%,Options,Output_Format,%Output_Format%
Output_Format := RegExReplace(Output_Format,"[ \t]+;.*$","")

IniRead,Output_Volume,%SourceFile%,Options,Output_Volume,%Output_Volume%
Output_Volume := RegExReplace(Output_Volume,"[ \t]+;.*$","")

IniRead,L1_Channels,%SourceFile%,Options,L1_Channels,%L1_Channels%
L1_Channels := RegExReplace(L1_Channels,"[ \t]+;.*$","")

IniRead,L2_Channels,%SourceFile%,Options,L2_Channels,%L2_Channels%
L2_Channels := RegExReplace(L2_Channels,"[ \t]+;.*$","")

IniRead,L1_Factor,%SourceFile%,Options,L1_Factor,%L1_Factor%
L1_Factor := RegExReplace(L1_Factor,"[ \t]+;.*$","")

IniRead,L2_Factor,%SourceFile%,Options,L2_Factor,%L1_Factor%
L2_Factor := RegExReplace(L2_Factor,"[ \t]+;.*$","")

IniRead,Output_Channels,%SourceFile%,Options,Output_Channels,%Output_Channels%
Output_Channels := RegExReplace(Output_Channels,"[ \t]+;.*$","")

IniRead,Output_Dir,%SourceFile%,Options,Output_Dir,%Output_Dir%
Output_Dir := RegExReplace(Output_Dir,"[ \t]+;.*$","")

IniRead,Mix_Table,%SourceFile%,Options,Mix_Table,%Mix_Table%
Mix_Table := RegExReplace(Mix_Table,"[ \t]+;.*$","")

IniRead,Mix_Log,%SourceFile%,Options,Mix_Log,%Mix_Log%
Mix_Log := RegExReplace(Mix_Log,"[ \t]+;.*$","")

IniRead,L1,%SourceFile%,L1
IniRead,L2,%SourceFile%,L2

L1_Factor := StrSplit(L1_Factor, ",", "[]`s")
L2_Factor := StrSplit(L2_Factor, ",", "[]`s")
; ----------------------------------------------------------------------------------------------

; SetWorkingDir, A_WorkingDir ;% "D:\Downloads\Sounds\sox-14.4.2\converted"

; SoX := "D:\Downloads\Sounds\sox-14.4.2\sox.exe"
; Output_Dir := Output_Dir ;A_WorkingDir "\SoX_Output"
; Mix_Table := Output_Dir "\Mix_Table.txt"
; Mix_Log := Output_Dir "\Mix_Log.txt"

/*
File_List1 := []
Loop, Files, % "D:\Downloads\Sounds\Bullet_Cracks\223\Stereo\Bullet_Crack_*.wav", F ; RF
{
	File_List1.Push( A_LoopFileLongPath )
}

File_List2 := []
Loop, Files, % "D:\Downloads\Sounds\Bullet_Cracks\308\Stereo\Bullet_Crack_*.wav", F ; RF
{
	File_List2.Push( A_LoopFileLongPath )
}
*/

File_List1 := []
Loop, Parse, L1, `n, `r ; Recommended approach in most cases.
{
	Line := Trim( RegExReplace( A_LoopField, "[ \t]+;.*$", "" ) )
	If StrLen( Line > 0 ) {
		File_List1.Push( Line )
	}
}
Line = ; Null

File_List2 := []
Loop, Parse, L2, `n, `r ; Recommended approach in most cases.
{
	Line := Trim( RegExReplace( A_LoopField, "[ \t]+;.*$", "" ) )
	If StrLen( Line > 0 ) {
		File_List2.Push( Line )
	}
}
Line = ; Null

If ( File_List1.MaxIndex() < 1 or File_List2.MaxIndex() < 1 ) {
	ExitApp
}

/*
If FileExist( Output_Dir "\" ) {
	FileRemoveDir, %Output_Dir%, 1
}
*/
Command = ; null
Output_Data = ; null

FormatTime,Time_Stamp,, yyyy-MM-dd HH:mm:ss ; 2005-10-30 10:45
Comment := "REM "
Separator := Comment . "----------------------------------------------------------------------------------------------------"

; Output_Format := OutputFormat ;"mp3"

/*
Volume := 2.0 ;1.0

Factor1 := [ 1.00, 1.00 ] ;[ 0.70, 1.00 ]
Factor2 := [ 0.25, 0.25 ] ;[ 0.20, 0.40 ]
*/

Volume := Output_Volume ;1.0 ;1.0

Factor1 := L1_Factor ;[ 2.00, 2.00 ] ;[ 0.70, 1.00 ]
Factor2 := L2_Factor ;[ 1.00, 1.00 ] ;[ 0.20, 0.40 ]

Str_Factor1 := "[ " Factor1[1] ", " Factor1[2] " ]"
Str_Factor2 := "[ " Factor2[1] ", " Factor2[2] " ]"

Channels1 := L1_Channels ;2 ;1
Channels2 := L2_Channels ;1
Channels3 := Output_Channels ;1

Header = 
( LTrim RTrim Join`r`n
	%Separator%
	%Comment% %Time_Stamp%
	%Separator%
	
	%Comment% SoX params:
	%Comment% `tVolume: %Volume%
	%Comment% `tFactor1: %Str_Factor1%
	%Comment% `tFactor2: %Str_Factor2%
	%Comment% `tChannels1: %Channels1%
	%Comment% `tChannels2: %Channels2%
	%Comment% `tChannels3: %Channels3%
	
	cls
	@echo off		
	cd /d "`%~dp0"

	set "SOX=%SoX%"
	
	set OUTPUT_FORMAT=%Output_Format%
	set "OUTPUT_DIR=%Output_Dir%"
	
	set INPUT_1_CHANNELS=%Channels1%
	set INPUT_2_CHANNELS=%Channels2%
	set OUTPUT_CHANNELS=%Channels3%
	
	rd "`%OUTPUT_DIR`%" /q /s
	md "`%OUTPUT_DIR`%"
)

Output_Data .= Header "`r`n"
Output_Data .= "`r`n"

If ( not FileExist( SoX ) )
{
	MsgBox,ОШИБКА:`nОтсутствует файл: %SoX%
	ExitApp
}

If FileExist( Output_Dir "\" )
{
	FileRemoveDir, %Output_Dir%, 1
}

For File2_Index, File2_Path in File_List2 {
	Random, File1_Index, 1, % File_List1.MaxIndex()
	File1_Path := File_List1[File1_Index]
	Random, volume1, % 1.00 * Factor1[1], % 1.00 * Factor1[2]
	Random, volume2, % 1.00 * Factor2[1], % 1.00 * Factor2[2]
	volume1 := volume1 * Volume
	volume2 := volume2 * Volume
	; If (File1_Path != File2_Path) {
		If not FileExist( Output_Dir "\" )
		{
			FileCreateDir, %Output_Dir%
		}
		; File_Name := Format( "flyby_{1:0.2d}.{2:s}", File2_Index, Output_Format )
		
		File2_Name := RegExReplace( File2_Path, ".*\\(.*)", "$1" )
		File2_Name := RegExReplace( File2_Name, "(.*)\..*", "$1" )
		File_Name := Format( "{1:s}.{2:s}", File2_Name, Output_Format )
		
		Command = "%SoX%" -m 
		-c%Channels2% -v%volume2% "%File2_Path%" 
		-c%Channels1% -v%volume1% "%File1_Path%" 
		-c%Channels3% -t %Output_Format% "%Output_Dir%\%File_Name%" 
		>> "%Output_Dir%\Mix_Log.txt" 2>&1 & echo.>> "%Output_Dir%\Mix_Log.txt" 
		
		Output_Command = "`%SOX`%" -m 
		-c`%INPUT_2_CHANNELS`% -v%volume2% "%File2_Path%" 
		-c`%INPUT_1_CHANNELS`% -v%volume1% "%File1_Path%" 
		-c`%OUTPUT_CHANNELS`% -t `%OUTPUT_FORMAT`% "`%OUTPUT_DIR`%\%File_Name%" 
		>> "`%OUTPUT_DIR`%\Mix_Log.txt" 2>&1 & echo.>> "`%OUTPUT_DIR`%\Mix_Log.txt" 
		
		Output_Data .= Output_Command "`r`n"
		
		; RunWait, %Command%
		RunWait, %ComSpec% /k cd /d "%A_WorkingDir%" & %Command% & exit
	; }
}

Output_Data .= "`r`n" Separator "`r`n"

Copy_Command = copy "`%0" "`%OUTPUT_DIR`%\`%~nx0"
Output_Data .=  "`r`n" Copy_Command "`r`n"

If ( StrLen( Command ) > 0 )
{
	If FileExist( Mix_Table )
	{
		FileDelete, %Mix_Table%
	}
	FileAppend, %Output_Data%, %Mix_Table%
	If FileExist( Mix_Table )
	{
		Run, notepad.exe %Mix_Table%
	}
}

If FileExist( Output_Dir "\" )
{
	Run, %Output_Dir%
}

ExitApp

ToolTip( text, time := 800 )
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
			If ( not Process_ID = Current_ID ) {
				WinGet, Process_PID, PID, % Script_Full_Path . " ahk_id " . Process_ID
				Process, Close, %Process_PID%
			}
			Process_Count += 1
		}
	}

	Run_As_Admin( Params := "" )
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

