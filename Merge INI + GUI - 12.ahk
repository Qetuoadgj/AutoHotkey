#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

#SingleInstance, force

#Include AHK Functions\TrimPath.ahk
#Include AHK Functions\FileGetLongPath.ahk
#Include AHK Functions\FileReadSection.ahk
#Include AHK Functions\FileCheckExtension.ahk
; #Include AHK Functions\FileChangeEncoding.ahk
#Include AHK Functions\GUI_Functions.ahk
; #Include AHK Functions\ConvertToString.ahk


SCRIPT_NAME := "Merge INI"
SCRIPT_VERSION := "1.0.3"
SCRIPT_WIN_TITLE = %SCRIPT_NAME% v%SCRIPT_VERSION%

INI_FILE := SCRIPT_NAME ".ini"
INI_FILE := FileGetLongPath(INI_FILE)

; Чтение настроек из %INI_FILE%
	IniRead, INPUT_ENCODING, %INI_FILE%, Settings, InputEncoding, CP1251
	IniRead, OUTPUT_ENCODING, %INI_FILE%, Settings, OutputEncoding, CP1251

	IniRead, METHOD, %INI_FILE%, Settings, Method, Keep Structure
	IniRead, REWRITE_OUTPUT_FILE, %INI_FILE%, Settings, RewriteOutputFile, 1
	IniRead, SHOW_RESULT, %INI_FILE%, Settings, ShowResult, 0

	IniRead, INI_FILE_1, %INI_FILE%, Files, CopyFrom, Select Settings File
	INI_FILE_1 := FileGetLongPath(INI_FILE_1)

	IniRead, INI_FILE_2, %INI_FILE%, Files, CopyTo, Select Default File
	INI_FILE_2 := FileGetLongPath(INI_FILE_2)

	IniRead, INI_FILE_3, %INI_FILE%, Files, OutputFile, Select Output File
	INI_FILE_3 := FileGetLongPath(INI_FILE_3)
;

; Создание GUI
	Gui, Add, GroupBox, x2 y0 w460 h90 , Files
		Gui, Add, Text, x12 y23 w60 h20 , Copy From
		Gui, Add, Edit, x72 y20 w310 h20 vINI_FILE_1, %INI_FILE_1%
		Gui, Add, Button, x382 y20 w70 h20 gBrowseOpen v1, Browse

		Gui, Add, Text, x12 y43 w60 h20 , Copy To
		Gui, Add, Edit, x72 y40 w310 h20 vINI_FILE_2, %INI_FILE_2%
		Gui, Add, Button, x382 y40 w70 h20 gBrowseOpen v2, Browse

		Gui, Add, Text, x12 y63 w60 h20 , Output File
		Gui, Add, Edit, x72 y60 w310 h20 vINI_FILE_3, %INI_FILE_3%
		Gui, Add, Button, x382 y60 w70 h20 gBrowseSave v3, Browse

	Gui, Add, GroupBox, x462 y0 w110 h90 , Encoding
		Gui, Add, DropDownList, x472 y20 w90 h90 vINPUT_ENCODING
		Gui, Add, DropDownList, x472 y60 w90 h90 vOUTPUT_ENCODING

	Gui, Add, GroupBox, x2 y90 w370 h50, Output Settings
		Gui, Add, Text, x12 y113 w40 h20, Method
		Gui, Add, DropDownList, x52 y110 w140 vMETHOD
		Gui, Add, CheckBox, x202 y110 w70 h20 vREWRITE_OUTPUT_FILE, Owerwrite
		Gui, Add, CheckBox, x282 y110 w80 h20 vSHOW_RESULT, Open Result

	Gui, Add, Button, x492 y103 w80 h30 , Exit
	Gui, Add, Button, x392 y103 w80 h30 , Merge
	; Generated using SmartGUI Creator 4.0
	Gui, Show, h150 w582, %SCRIPT_WIN_TITLE%

	GoSub, SetDefaultSettings
Return

SetDefaultSettings:
{
	EncodingList := "UTF-8|CP1251"
	MethodsList := "Keep Structure|Only Settings|Only Difference|Only Difference (Invert)"

	DropDownDefault("INPUT_ENCODING", EncodingList, INPUT_ENCODING)
	DropDownDefault("OUTPUT_ENCODING", EncodingList, OUTPUT_ENCODING)
	DropDownDefault("METHOD", MethodsList, METHOD)

	GuiControl,,REWRITE_OUTPUT_FILE, %REWRITE_OUTPUT_FILE%
	GuiControl,,SHOW_RESULT, %SHOW_RESULT%

	Return
}

; Buttons
	GuiClose:
	{
		ExitApp
	}

	ButtonExit:
	{
		ExitApp
	}

	BrowseOpen:
	{
		FileSelectFile, SelectedFile, 3, ,Select file, *.ini
		If % SelectedFile != ""
		{
			GuiControl,,INI_FILE_%A_GuiControl%,%SelectedFile%
		}
		Return
	}

	BrowseSave:
	{
		FileSelectFile, SelectedFile, S 26, ,Select file, *.ini
		If % SelectedFile != ""
		{
			SelectedFile := FileCheckExtension(SelectedFile, "ini")
			GuiControl,,INI_FILE_%A_GuiControl%,%SelectedFile%
		}
		Return
	}

	ButtonMerge:
	{
		Gui, Submit, NoHide
		GoSub, CheckErrors
		GoSub, SaveSettings
		GoSub, ParseINI
	}
;

EXIT

; Subroutines
	CheckErrors:
	{
		INI_FILE_3 := FileCheckExtension(INI_FILE_3, "ini")

		INI_FILE_1 := FileGetLongPath(INI_FILE_1)
		INI_FILE_2 := FileGetLongPath(INI_FILE_2)
		INI_FILE_3 := FileGetLongPath(INI_FILE_3)

		IfNotExist, %INI_FILE_1%
		{
			MsgBox, "CopyFrom" file not found !
			exit
		}
		IfNotExist, %INI_FILE_2%
		{
			MsgBox, "CopyTo" file not found !
			exit
		}

		If % INI_FILE_3 = INI_FILE_1
		{
			MsgBox, CHECK YOUR INI FILES !`n`nOutputFile = CopyFrom
			exit
		}
		If % INI_FILE_3 = INI_FILE_2
		{
			MsgBox, CHECK YOUR INI FILES !`n`nOutputFile = CopyTo
			exit
		}
		If % INI_FILE_3 = ""
		{
			MsgBox, CHECK YOUR INI FILES !`n`nOutputFile = ""
			exit
		}

		Return
	}

	SaveSettings:
	{
		SAVE_TO_FILE := % INI_FILE

		SECTION := "Settings"
			IniWrite, %Input_Encoding%, %SAVE_TO_FILE%, %SECTION%, InputEncoding
			IniWrite, %Output_Encoding%, %SAVE_TO_FILE%, %SECTION%, OutputEncoding
			IniWrite, %METHOD%, %SAVE_TO_FILE%, %SECTION%, Method
			IniWrite, %REWRITE_OUTPUT_FILE%, %SAVE_TO_FILE%, %SECTION%, RewriteOutputFile
			IniWrite, %SHOW_RESULT%, %SAVE_TO_FILE%, %SECTION%, ShowResult

		SECTION := "Files"
			IniWrite, %INI_FILE_1%, %SAVE_TO_FILE%, %SECTION%, CopyFrom
			IniWrite, %INI_FILE_2%, %SAVE_TO_FILE%, %SECTION%, CopyTo
			IniWrite, %INI_FILE_3%, %SAVE_TO_FILE%, %SECTION%, OutputFile

		Return
	}

	ParseINI:
	{
		FileEncoding, %INPUT_ENCODING%

		If % METHOD = "Only Difference (Invert)"
		{
			INVERT_INI_FILE_1 := INI_FILE_2
			INVERT_INI_FILE_2 := INI_FILE_1

			INI_FILE_1 := INVERT_INI_FILE_1
			INI_FILE_2 := INVERT_INI_FILE_2
		}

		Sections := Object()
		Loop, Read, %INI_FILE_1%
		{
			If RegExMatch(A_LoopReadLine, "^\[.*\]$")
			{
				Sections.Push(A_LoopReadLine)
			}
		}

		If % REWRITE_OUTPUT_FILE = 1
		{
			FileDelete, %INI_FILE_3%
		}

		If % METHOD = "Keep Structure"
		{
			FileCopy, %INI_FILE_2%, %INI_FILE_3%, 1
			FileSetAttrib, -R, %INI_FILE_3%

		} else If % METHOD = "Only Settings"
		{
			Loop, Read, %INI_FILE_2%
			{
				If A_LoopReadLine = ; if looped line is empty
					Continue ; skip the current Loop instance

				If RegExMatch(A_LoopReadLine, "^(\s+)?;") ; if looped line is commented
					Continue ; skip the current Loop instance

				If RegExMatch(A_LoopReadLine, "^(\s+)?//") ; if looped line is commented
					Continue ; skip the current Loop instance

				FileAppend, %A_LoopReadLine%`n, %INI_FILE_3% ;, %OUTPUT_ENCODING%
			}
		} else If % METHOD = "Only Difference" or METHOD = "Only Difference (Invert)"
		{
			; Continue
		} else {
			MsgBox, CHECK YOUR INI FILES !`n`nMethod = %Method%
			exit
		}

		Keys := Object()
		for index, element in Sections
		{
			Section := element
			SectionName := RegExReplace(Section, "^\[(.*)\]$", "$1", ,1)

			Keys := FileReadSection(INI_FILE_1, Section, "^\[.*\]$", 1)

			for index2, element2 in Keys
			{
				If not element2 = ""
				{
					Key := RegExReplace(element2, "=.*$", "", ,1)
					IniRead, Value1, %INI_File_1%, %SectionName%, %Key%
					IniRead, Value2, %INI_File_2%, %SectionName%, %Key%
					If % Value1 != Value2
					{
						IniWrite, %Value1%, %INI_File_3%, %SectionName%, %Key%
					}
				}
			}
		}

		FormatTime, CurrentDateTime,, yyyy.MM.dd HH:mm:ss
		FileRead, TmpFile, %INI_File_3%
		FileDelete, %INI_File_3%
		If % METHOD != "Keep Structure"
		{
			FileAppend, `; Created with "%SCRIPT_WIN_TITLE%"`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `; %CurrentDateTime%`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `; ===================================================================================`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `; %INI_FILE_1%`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `; %INI_FILE_2%`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `; ===================================================================================`n, %INI_FILE_3%, %OUTPUT_ENCODING%
			FileAppend, `n, %INI_FILE_3%, %OUTPUT_ENCODING%
		}
		FileAppend, %TmpFile%, %INI_File_3%, %OUTPUT_ENCODING%

		; FileChangeEncoding(INI_File_3, OUTPUT_ENCODING)

		If % SHOW_RESULT = 1
		{
			RunWait, %INI_FILE_3%
			WinActivate, %SCRIPT_WIN_TITLE%
		}

		Return
	}
;
