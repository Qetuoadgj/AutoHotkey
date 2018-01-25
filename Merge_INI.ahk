#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...

DetectHiddenWindows On

SplitPath, A_ScriptFullPath,,, A_ScriptExtension, A_ScriptNameNoExt, A_ScriptDrive

Script_Win_Title := A_ScriptName
ConfigFile := A_ScriptDir . "\" . A_ScriptNameNoExt . ".ini"

gosub Read_Config_File
gosub Create_GUI
gosub Set_GUI_Settings

Exit

Read_Config_File:
{
	IniRead InputEncoding, %ConfigFile%, Settings, InputEncoding, % "CP1251"
	IniRead OutputEncoding, %ConfigFile%, Settings, OutputEncoding, % "CP1251"
	IniRead Method, %ConfigFile%, Settings, Method, % "Keep Structure"
	IniRead OverwriteOutputFile, %ConfigFile%, Settings, OverwriteOutputFile, 1
	IniRead ShowResult, %ConfigFile%, Settings, ShowResult, 0
	IniRead ini_file_1, %ConfigFile%, Settings, ini_file_1, % A_Space ;% "Select Settings File"
	IniRead ini_file_2, %ConfigFile%, Settings, ini_file_2, % A_Space ; % "Select Default File"
	IniRead ini_file_3, %ConfigFile%, Settings, ini_file_3, % A_Space ;% "Select Output File"
	return
}

IniWrite(ByRef Key, ByRef File, ByRef Section, ByRef Value)
{ ; замена стандартного IniWrite (записывает только измененные параметры)
	static Test_Value
	;
	if (not File) {
		return
	}
	Value := Value = "ERROR" ? "" : Value
	IniRead Test_Value, %File%, %Section%, %Key%
	if (not Test_Value = Value) {
		IniWrite %Value%, %File%, %Section%, %Key%
	}
}

Write_Config_File:
{
	Gui Submit, NoHide
	IniWrite("InputEncoding", ConfigFile, "Settings", InputEncoding)
	IniWrite("OutputEncoding", ConfigFile, "Settings", OutputEncoding)
	IniWrite("Method", ConfigFile, "Settings", Method)
	IniWrite("OverwriteOutputFile", ConfigFile, "Settings", OverwriteOutputFile)
	IniWrite("ShowResult", ConfigFile, "Settings", ShowResult)
	IniWrite("ini_file_1", ConfigFile, "Settings", ini_file_1)
	IniWrite("ini_file_2", ConfigFile, "Settings", ini_file_2)
	IniWrite("ini_file_3", ConfigFile, "Settings", ini_file_3)
	return
}

Create_GUI:
{
	Gui -Resize +MaximizeBox
	;
	Gui Add, GroupBox, x5 y0 w450 h90, % "Files"
	Gui Add, Text, x10 y15 w60 h20, % "Copy From"
	Gui Add, Edit, x65 y15 w310 h20 vini_file_1, % ini_file_1
	Gui Add, Button, x380 y15 w70 h20 gBrowseOpen v1, % "Browse"
	;
	Gui Add, Text, x10 y40 w60 h20, % "Copy To"
	Gui Add, Edit, x65 y40 w310 h20 vini_file_2, % ini_file_2
	Gui Add, Button, x380 y40 w70 h20 gBrowseOpen v2, Browse
	;
	Gui Add, Text, x10 y65 w60 h20, % "Output File"
	Gui Add, Edit, x65 y65 w310 h20 vini_file_3, % ini_file_3
	Gui Add, Button, x380 y65 w70 h20 gBrowseSave v3, % "Browse"
	;
	Gui Add, GroupBox, x460 y0 w80 h90, % "Encoding"
	Gui Add, DropDownList, x465 y15 w70 h90 vInputEncoding gWrite_Config_File
	Gui Add, DropDownList, x465 y64 w70 h90 vOutputEncoding	gWrite_Config_File
	;
	Gui Add, GroupBox, x5 y90 w370 h50, % "Output Settings"
	Gui Add, Text, x10 y115 w40 h20, % "Method"
	Gui Add, DropDownList, x50 y110 w140 vMethod gWrite_Config_File
	; GuiControl +AltSubmit, Method ; возвращает выбранную позицию (начиная с 1) в списке вместо текста
	Gui Add, CheckBox, x205 y110 w80 h20 vOverwriteOutputFile gWrite_Config_File Disabled, % "Owerwrite"
	Gui Add, CheckBox, x285 y110 w80 h20 vShowResult gWrite_Config_File Disabled, % "Show Result"
	;
	Gui Add, Button, x380 y103 w70 h30, % "Exit"
	Gui Add, Button, x465 y103 w70 h30 gMerge, % "Merge"
	Gui Show, h145 w545, %Script_Win_Title%
	;
	Gui, +LastFound
	GUI_hwnd := WinExist()
	;
	Gui Add, Edit, Multi ReadOnly x5 y150 w0 h0 vini_file_1_text, % A_Space
	Gui Add, Edit, Multi ReadOnly x5 y150 w0 h0 vini_file_2_text, % A_Space
	Gui Add, Edit, Multi ReadOnly x5 y150 w0 h0 vini_file_3_text, % A_Space
	;
	Gui Add, Progress, x550 y5 w0 h0 vMsgBox1_Progress +Smooth ;cBlue
	return
}

DropDownDefault(ByRef DropDownListName, ByRef ListContents, ByRef DefaultValue)
{
	String := DefaultValue
	static Index, Char, Escape
	Escape := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]
	for Index, Char in Escape
	{
		String := StrReplace(String, Char, "\" . Char)
	}
	;
	ListContents := RegExReplace(ListContents, String "[|]?", DefaultValue "||",, 1)
	GuiControl,, % DropDownListName, % ListContents
}

Set_GUI_Settings:
{
	EncodingList := "UTF-8|CP1251"
	MethodsList := "Keep Structure|Only Settings|Only Difference|Only Difference (Invert)"
	;
	DropDownDefault("InputEncoding", EncodingList, InputEncoding)
	DropDownDefault("OutputEncoding", EncodingList, OutputEncoding)
	DropDownDefault("Method", MethodsList, Method)
	;
	GuiControl,, OverwriteOutputFile, % OverwriteOutputFile
	GuiControl,, ShowResult, % ShowResult
	;
	FileRead ini_file_contents, % ini_file_1
	GuiControl,, ini_file_1_text, % ini_file_contents
	FileRead ini_file_contents, % ini_file_2
	GuiControl,, ini_file_2_text, % ini_file_contents
	FileRead ini_file_contents, % ini_file_3
	GuiControl,, ini_file_3_text, % ini_file_contents
	ini_file_contents := ""
	return
}

BrowseOpen:
{
	FileSelectFile SelectedFilePath, 3,, % "Select file", % "*.ini"
	if (SelectedFilePath) {
		GuiControl ,,% "ini_file_" . A_GuiControl, % SelectedFilePath
		FileRead SelectedFileContents, % SelectedFilePath
		; StringReplace, SelectedFileContents, SelectedFileContents, `n, `r`n, All
		GuiControl ,,% "ini_file_" . A_GuiControl "_text", % SelectedFileContents
	}
	gosub Write_Config_File
	return
}

BrowseSave:
{
	FileSelectFile SelectedFilePath, S 26,, % "Select file", % "*.ini"
	if (SelectedFilePath) {
		SplitPath, SelectedFilePath, SelectedFileFileName, SelectedFileDir, SelectedFileExtension, SelectedFileNameNoExt, SelectedFileDrive
		if (not SelectedFileExtension = "ini") {
			SelectedFilePath := SelectedFileDir . "\" . SelectedFileNameNoExt . ".ini"
		}
		GuiControl ,,% "ini_file_" . A_GuiControl, % SelectedFilePath
	}
	gosub Write_Config_File
	return
}

GuiClose:
{
	gosub Write_Config_File
	ExitApp
}

ButtonExit:
{
	gosub Write_Config_File
	ExitApp
}

GuiSize:
{
	GuiState := ErrorLevel == 0 ? "Resized / Restored" : ErrorLevel == 1 ? "Minimized" : ErrorLevel == 2 ? "Maximized" : "N/A"	
	if (GUI_hwnd) {
		rect := WindowGetRect("ahk_id " . GUI_hwnd)
		; MsgBox % rect.width "`n" rect.height
		if (GuiState = "Maximized")
		{
			W := (rect.width-5*4)/3, H := rect.height-145-5
			GuiControl, Move, ini_file_1_text, % "*x" 5*1+W*0 "*y" 145 "*w" W "*h" H
			GuiControl, Move, ini_file_2_text, % "*x" 5*2+W*1 "*y" 145 "*w" W "*h" H
			GuiControl, Move, ini_file_3_text, % "*x" 5*3+W*2 "*y" 145 "*w" W "*h" H
			;
			W := rect.width-550-5*2, H := (145-5*2)/5
			X := 550, Y := (145-H)/2
			GuiControl, Move, MsgBox1_Progress, % "*x" 550 "*y" Y "*w" W "* h" H
			; GuiControl,, MsgBox1_Progress, 50
		}
	}
	return
}

WindowGetRect(windowTitle*)
{ ; //autohotkey.com/board/topic/91733-command-to-get-gui-client-areas-sizes/?p=578584
	static hwnd, rect
	;
    if hwnd := WinExist(windowTitle*)
	{
        VarSetCapacity(rect, 16, 0)
        DllCall("GetClientRect", "Ptr", hwnd, "Ptr", &rect)
        return {width: NumGet(rect, 8, "Int"), height: NumGet(rect, 12, "Int")}
    }
}

IniCountKeys(ByRef file)
{
	static count, sections, section_name, line_, line_1, line_2
	;
	count := 0
	IniRead, sections, % file
	Loop Parse, sections, `n, `r
	{
		section_name := A_LoopField
		IniRead section, % file, % section_name
		Loop Parse, section, `n, `r
		{
			StringSplit line_, A_LoopField, =
			key := Trim(line_1)
			if (key) {
				count++
			}
		}
	}
	return count
}

MergeINI(ini_merge_to, ini_merge_from, ini_result := "_merge_ini_file3.ini", ByRef method := 1, ByRef progress := "")
{
	; Keep Structure = 1
	; Only Settings = 2
	; Only Difference = 3
	; Only Difference (Invert) = 4
	;
	static file1, file2, file3, ret
	static sections, section_name, section, line_, line_1, line_2, key, value, value_1, value_2
	static count, pos, pct
	;
	file1 := ini_merge_to, file2 := ini_merge_from, file3 := ini_result, ret = ""
	;
	count := 0, pos := 0
	if FileExist(file2)
	{
		if (method = 1) {
			FileCopy % file1, % file3, 1
			if InStr(FileExist(file3), "R") { ; перед обработкой снять аттрибут "только чтение"
				FileSetAttrib, -R, % file3
			}
		}
		else {
			if InStr(FileExist(file3), "R") { ; перед обработкой снять аттрибут "только чтение"
				FileSetAttrib, -R, % file3
			}
			if (file3 != file1 and file3 != file2) {
				FileDelete % file3
			}
			if (method = 4) {
				file1 := ini_merge_from, file2 := ini_merge_to
			}
		}
		if (method < 3) {
			if (progress) {
				count := IniCountKeys(file1) + IniCountKeys(file2)
				progress := count ? progress : "" 
			}
			IniRead, sections, % file1
			Loop Parse, sections, `n, `r
			{
				section_name := A_LoopField
				IniRead section, % file1, % section_name
				Loop Parse, section, `n, `r
				{
					StringSplit line_, A_LoopField, =
					key := Trim(line_1)
					if (key) {
						if (progress) {
							pos++
							pct := pos/count*100
							; ToolTip % pos . " : " . count . " : " . pct
							GuiControl,, % progress, % pct
						}
						IniRead value, % file1, % section_name, % key
						if (method > 2) {
							IniRead value_2, % file2, % section_name, % key
							if (value_2 == value) {
								continue
							}
						}
						IniWrite % value, % file3, % section_name, % key
					}
				}
			}
		}
		else {
			if (progress) {
				count := IniCountKeys(file2)
				progress := count ? progress : "" 
			}
		}
		IniRead, sections, % file2
		Loop Parse, sections, `n, `r
		{
			section_name := A_LoopField
			IniRead section, % file2, % section_name
			Loop Parse, section, `n, `r
			{
				StringSplit line_, A_LoopField, =
				key := Trim(line_1)
				if (key) {
					if (progress) {
						pos++
						pct := pos/count*100
						; ToolTip % pos . " : " . count . " : " . pct
						GuiControl,, % progress, % pct
					}
					IniRead value, % file2, % section_name, % key
					if (method > 2) {
						IniRead value_1, % file1, % section_name, % key
						if (value_1 == value) {
							continue
						}
					}
					IniWrite % value, % file3, % section_name, % key
				}
			}
		}
		FileRead ret, % file3
	}
	return ret
}

Merge:
{
	GuiControl +AltSubmit, Method ; возвращает выбранную позицию (начиная с 1) в списке вместо текста
	Gui Submit, NoHide
	method_id := Method
	GuiControl -AltSubmit, Method ; возвращает выбранный в списке текст
	/*
	if (OverwriteOutputFile and (ini_file_3 != ini_file_1 and ini_file_1 != ini_file_2)) {
		FileDelete % ini_file_3
	}
	*/
	GuiControl,, % "ini_file_3_text", % A_Space
	result := MergeINI(ini_file_1, ini_file_2, ini_file_3, method_id, "MsgBox1_Progress")
	GuiControl,, % "ini_file_3_text", % result
	return
}
