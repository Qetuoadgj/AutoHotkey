#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

; #Persistent
; #SingleInstance, Ignore

#SingleInstance, Off
Script_Name := Script.Name()
Script_Args := Script.Args()
Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])
; Script.Run_As_Admin(Script_Args)

; Your code here...

OnExit, CloseApp

TIME_STAMP_FORMAT := "yyyy.MM.dd hh.mm.ss"
FormatTime, TIME_STAMP,, %TIME_STAMP_FORMAT%

GSWIN32C := A_ScriptDir . "\Ghostscript\bin\gswin32c.exe"

gosub, Test_Args
gosub, Init_GUI

Exit

Init_GUI:
{
	Gui, PROMPT_GUI_: Add, Edit, % " y" . 10 . " w" . (358) . " h" . (21) . " vGUI_FILE_NAME", %TIME_STAMP%
	Gui, PROMPT_GUI_: Add, Checkbox, % " x" . 10 . " y" . (10+21+10) . " h" . (24) . " vGUI_CONVERT_TO_GRAYSCALE", % "Convert to grayscale"
	Gui, PROMPT_GUI_: Add, Checkbox, % " x+" . 10 . " y" . (10+21+10) . " h" . (24) . " vGUI_AUTO_CROP", % "Auto Crop"
	Gui, PROMPT_GUI_: Add, Button, % " x" . (358 - 80 + 10) . " y" . (10+21+10) . " w" . (80) . " h" . (24) . " gPressed_Ok_Button", % "&OK"
	Gui, PROMPT_GUI_: Show, AutoSize, %Script_Name%

	return
}

CloseApp:
PROMPT_GUI_GuiEscape:
PROMPT_GUI_GuiClose:
{
	; MsgBox, Exit
	ExitApp
}

Pressed_OK_Button:
{
	; MsgBox, Go
	Gui, PROMPT_GUI_: Submit, Hide
	GuiControlGet, combined_file_name,, GUI_FILE_NAME
	GuiControlGet, convert_to_grayscale,, GUI_CONVERT_TO_GRAYSCALE
	GuiControlGet, auto_crop,, GUI_AUTO_CROP
	; MsgBox, combined_file_name: %combined_file_name%`nconvert_to_grayscale: %convert_to_grayscale%`nauto_crop: %auto_crop%

	combined_file_name := Trim(combined_file_name)
	if (combined_file_name = "") {
		ExitApp
	}
	else {
		gosub, Process_Files
	}
	return
}

Test_Args:
{
	PROCEED := 0
	for n, given_path in A_Args  ; For each parameter (or file dropped onto a script):
	{
		Loop, Files, %given_path%, F  ; Include files and directories.
		{
			file_long_path := A_LoopFileLongPath
			SplitPath, file_long_path, file_name, file_directory, file_extension, file_name_no_extension, file_drive
			if (file_extension = "pdf" and FileExist(file_long_path)) {
				PROCEED := 1
				break
			}
		}
	}
	if (PROCEED != 1) {
		ExitApp
	}
	return
}

Process_Files:
{
	TRIMMED_FILES_LIST := ""
	gosub, Trim_Files
	if (TRIMMED_FILES_LIST != "") {
		COMBINED_FILE := ""
		gosub, Combine_Files
		if FileExist(COMBINED_FILE) {
			MsgBox, 262144, % Script_Name, % "OK", 1
			Run, %COMBINED_FILE%
		}
		else {
			MsgBox, 262144, % Script_Name, % "ERROR", 1
		}
	}
	ExitApp
	return
}

Trim_Files:
{
	TRIMMED_FILES_LIST := ""
	for n, given_path in A_Args  ; For each parameter (or file dropped onto a script):
	{
		Loop, Files, %given_path%, F  ; Include files and directories.
		{
			input_file_long_path := A_LoopFileLongPath
			SplitPath, input_file_long_path, input_file_name, input_file_directory, input_file_extension, input_file_name_no_extension, input_file_drive
			if (input_file_extension = "pdf" and FileExist(input_file_long_path)) {
				if (n = 1) {
					SetWorkingDir, %input_file_directory%
				}
				input_file := input_file_long_path
				if (auto_crop) {
					trimmed_file := input_file_directory . "\" . input_file_name_no_extension . ".trimmed." . input_file_extension
					gswin32c_pdf_trim(input_file, trimmed_file)
					if FileExist(trimmed_file) {
						TRIMMED_FILES_LIST .= "`n" . trimmed_file
					}
				}
				else {
					TRIMMED_FILES_LIST .= "`n" . input_file
				}
			}
		}
	}
	TRIMMED_FILES_LIST := Trim(TRIMMED_FILES_LIST, " `t`n`r")
	return
}

Combine_Files:
{
	if (combined_file_name != "") {
		COMBINED_FILE := input_file_directory . "\" . combined_file_name
		gswin32c_pdf_combine(TRIMMED_FILES_LIST, COMBINED_FILE, convert_to_grayscale)
		if (auto_crop) {
			Loop, Parse, TRIMMED_FILES_LIST, `n, `r
			{
				FileDelete, % Trim(A_LoopField, " `t""")
			}
		}
	}
	return
}

#Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk

gswin32c_bbox_info(input_file)
{
	global GSWIN32C

	static gswin32c_stdout
	gswin32c_stdout := A_WorkingDir . "\gswin32c_stdout.txt"

	if FileExist(gswin32c_stdout) {
		FileSetAttrib, -R, %gswin32c_stdout%, 0, 0
		FileDelete, %gswin32c_stdout%
	}

	static command
	command =
	( LTrim RTrim Join`s&`s
		cls
		@echo off
		cd /d "%A_WorkingDir%"
		"%GSWIN32C%" -q -dBATCH -dNOPAUSE -sDEVICE=bbox -f "%input_file%" > "%gswin32c_stdout%" 2>&1 & type "%gswin32c_stdout%"
		exit
	)

	RunWait, %ComSpec% /k %command%,, Hide

	static line_text
	static match_, match_1, match_2, match_3, match_4
	static bbox_X, bbox_Y, bbox_W, bbox_H
	Loop, Read, %gswin32c_stdout%
	{
		line_text := Trim(A_LoopReadLine)
		; MsgBox, % line_text
		if RegExMatch(line_text, "i)^%%BoundingBox: ([\d.]+) ([\d.]+) ([\d.]+) ([\d.]+)$", match_) {
			bbox_X := match_1
			bbox_Y := match_2
			bbox_W := match_3
			bbox_H := match_4
		}
	}

	FileDelete, %gswin32c_stdout%

	return { x: bbox_X, y: bbox_Y, w: bbox_W, h: bbox_H }
}

gswin32c_pdf_trim(input_file, output_file, margins_x := 20, margins_y := 10)
{
	global GSWIN32C

	bbox := gswin32c_bbox_info(input_file)
	; MsgBox, % "X`t" . bbox.x . "`n" . "Y`t" . bbox.y . "`n" . "W`t" . bbox.w . "`n" . "H`t" . bbox.h

	/*
	bbox.x = 14
	bbox.y = 226
	bbox.w = 582
	bbox.h = 404
	*/

	static offset_x, offset_y
	static page_w, page_h

	/*
	offset_x := -bbox.x+margins_x
	offset_y := -bbox.y+margins_y

	page_w := (bbox.w + margins_x*2) * 10
	page_h := (bbox.h-bbox.y + margins_y*2) * 10
	*/
	
	offset_x := -bbox.x
	offset_y := -bbox.y

	page_w := bbox.w-bbox.x
	page_h := bbox.h-bbox.y
	
	page_w += margins_x*2
	page_h += margins_y*2
	
	offset_x += margins_x
	offset_y += margins_y
	
	page_w *= 10
	page_h *= 10

	static command
	command =
	( LTrim RTrim Join`s&`s
		cls
		@echo off
		cd /d "%A_WorkingDir%"
		"%GSWIN32C%" -o "%output_file%" -sDEVICE=pdfwrite -g%page_w%x%page_h% -c "<</PageOffset [%offset_x% %offset_y%]>> setpagedevice" -f "%input_file%"
		exit
	)

	RunWait, %ComSpec% /k %command%,, Hide

	return
}

gswin32c_pdf_combine(input_files_list, output_file, convert_to_grayscale := 0)
{
	global GSWIN32C

	static formatted_files_list, input_file
	formatted_files_list := ""
	Loop, Parse, input_files_list, `n, `r
	{
		input_file := Trim(A_LoopField, " `t""")
		formatted_files_list .= " " . """" input_file """"
	}
	formatted_files_list := Trim(formatted_files_list)

	if (formatted_files_list != "") {
		output_file := RegExReplace(output_file, "i)(\.pdf)+$", "") . ".pdf"
		if FileExist(output_file) {
			FileSetAttrib, -R, %output_file%, 0, 0
			FileDelete, %output_file%
		}

		static greyscale_parameters
		greyscale_parameters := convert_to_grayscale ? "-sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibilityLevel=1.4" : ""

		RunWait, %GSWIN32C% -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="%output_file%" -dBATCH %greyscale_parameters% %formatted_files_list%,, Hide

		global COMBINED_FILE
		COMBINED_FILE := output_file
	}
}
