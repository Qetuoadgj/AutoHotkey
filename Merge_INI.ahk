#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, Force

; Your code here...

OnExit, On_Exit

DetectHiddenWindows, On

SplitPath, A_ScriptFullPath,,, A_ScriptExtension, A_ScriptNameNoExt, A_ScriptDrive

Script_Win_Title := A_ScriptName
ConfigFile := A_ScriptDir . "\" . A_ScriptNameNoExt . ".ini"

global G_KEYS_TO_PROCESS := 0, G_KEYS_PROCESSED := 0, G_PROGRESS_BAR := "Progress_Bar_1", G_PROGRESS_TEXT := "Progress_Text_1"

gosub Read_Config_File
gosub Create_GUI
gosub Set_GUI_Settings

Exit

Read_Config_File:
{
	IniRead, InputEncoding, %ConfigFile%, Settings, InputEncoding, % "CP1251"
	IniRead, OutputEncoding, %ConfigFile%, Settings, OutputEncoding, % "CP1251"
	IniRead, Method, %ConfigFile%, Settings, Method, % "Keep Structure"
	IniRead, OverwriteOutputFile, %ConfigFile%, Settings, % "OverwriteOutputFile", 1
	IniRead, ShowResult, %ConfigFile%, Settings, % "ShowResult", 0
	IniRead, Ini_File_1, %ConfigFile%, Settings, % "ini_file_1", %A_Space%
	IniRead, Ini_File_2, %ConfigFile%, Settings, % "ini_file_2", %A_Space%
	IniRead, Ini_File_3, %ConfigFile%, Settings, % "ini_file_3", %A_Space%
	return
}

IniWrite(KeyName, FilePath, SectionName, Value)
{ ; замена стандартного IniWrite (записывает только измененные параметры)
	static CurrentValue
	Value := Value == "ERROR" ? "" : Value
	IniRead, CurrentValue, %FilePath%, %SectionName%, %KeyName%
	if (CurrentValue != Value) {
		IniWrite, %Value%, %FilePath%, %SectionName%, %KeyName%
	}
}

Write_Config_File:
{
	Gui, Submit, NoHide
	IniWrite("InputEncoding", ConfigFile, "Settings", InputEncoding)
	IniWrite("OutputEncoding", ConfigFile, "Settings", OutputEncoding)
	IniWrite("Method", ConfigFile, "Settings", Method)
	IniWrite("OverwriteOutputFile", ConfigFile, "Settings", OverwriteOutputFile)
	IniWrite("ShowResult", ConfigFile, "Settings", ShowResult)
	IniWrite("ini_file_1", ConfigFile, "Settings", Ini_File_1)
	IniWrite("ini_file_2", ConfigFile, "Settings", Ini_File_2)
	IniWrite("ini_file_3", ConfigFile, "Settings", Ini_File_3)
	return
}

Create_GUI:
{
	Gui, -Resize +MaximizeBox
	;
	Gui, Add, GroupBox, x5 y0 w450 h90, % "Files"
	Gui, Add, Text, x10 y15 w60 h20, % "Copy From"
	Gui, Add, Edit, x65 y15 w310 h20 vIni_File_1, % Ini_File_1
	Gui, Add, Button, x380 y15 w70 h20 gBrowseOpen v1, % "Browse"
	;
	Gui, Add, Text, x10 y40 w60 h20, % "Copy To"
	Gui, Add, Edit, x65 y40 w310 h20 vIni_File_2, % Ini_File_2
	Gui, Add, Button, x380 y40 w70 h20 gBrowseOpen v2, Browse
	;
	Gui, Add, Text, x10 y65 w60 h20, % "Output File"
	Gui, Add, Edit, x65 y65 w310 h20 vIni_File_3, % Ini_File_3
	Gui, Add, Button, x380 y65 w70 h20 gBrowseSave v3, % "Browse"
	;
	Gui, Add, GroupBox, x460 y0 w80 h90, % "Encoding"
	Gui, Add, DropDownList, x465 y15 w70 h90 vInputEncoding gWrite_Config_File
	Gui, Add, DropDownList, x465 y64 w70 h90 vOutputEncoding	gWrite_Config_File
	;
	Gui, Add, GroupBox, x5 y90 w370 h50, % "Output Settings"
	Gui, Add, Text, x10 y115 w40 h20, % "Method"
	Gui, Add, DropDownList, x50 y110 w140 vMethod gWrite_Config_File
	; GuiControl, +AltSubmit, Method ; возвращает выбранную позицию (начиная с 1) в списке вместо текста
	Gui, Add, CheckBox, x205 y110 w80 h20 vOverwriteOutputFile gWrite_Config_File Disabled, % "Owerwrite"
	Gui, Add, CheckBox, x285 y110 w80 h20 vShowResult gWrite_Config_File Disabled, % "Show Result"
	;
	Gui, Add, Button, x380 y103 w70 h30, % "Exit"
	Gui, Add, Button, x465 y103 w70 h30 gMerge, % "Merge"
	Gui, Show, h145 w545, %Script_Win_Title%
	;
	Gui, +LastFound
	Gui_Hwnd := WinExist()
	;
	Gui, Add, Edit, Multi ReadOnly x5 y150 w0 h0 vIni_File_1_Text, %A_Space%
	Gui, Add, Edit, Multi ReadOnly x5 y150 w0 h0 vIni_File_2_Text, %A_Space%
	Gui, Add, Edit, Multi ReadOnly x5 y150 w0 h0 vIni_File_3_Text, %A_Space%
	;
	Gui, Add, Progress, x550 y5 w0 h0 v%G_PROGRESS_BAR% +Smooth ;cBlue
	Gui, Add, Text, x550 y+5 w100 h20 v%G_PROGRESS_TEXT%, %A_Space%
	GuiControl, +Center, %G_PROGRESS_TEXT%
	return
}

DropDownDefault(DropDownListName, ListContents, DefaultValue)
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
	GuiControl,, OverwriteOutputFile, %OverwriteOutputFile%
	GuiControl,, ShowResult, %ShowResult%
	;
	FileRead, Ini_File_Contents, %Ini_File_1%
	GuiControl,, Ini_File_1_Text, %Ini_File_Contents%
	FileRead, Ini_File_Contents, %Ini_File_2%
	GuiControl,, Ini_File_2_Text, %Ini_File_Contents%
	FileRead, Ini_File_Contents, %Ini_File_3%
	GuiControl,, Ini_File_3_Text, %Ini_File_Contents%
	Ini_File_Contents := ""
	return
}

BrowseOpen:
{
	FileSelectFile SelectedFilePath, 3,, % "Select file", % "*.ini"
	if (SelectedFilePath) {
		GuiControl,, % "Ini_File_" . A_GuiControl, %SelectedFilePath%
		FileRead, SelectedFileContents, %SelectedFilePath%
		GuiControl,, % "Ini_File_" . A_GuiControl "_Text", %SelectedFileContents%
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
		GuiControl,, % "Ini_File_" . A_GuiControl, % SelectedFilePath
	}
	gosub Write_Config_File
	return
}

GuiClose:
{
	gosub Write_Config_File
	gosub On_Exit
	; ExitApp
}

ButtonExit:
{
	gosub Write_Config_File
	gosub On_Exit
	; ExitApp
}

GuiSize:
{
	GuiState := ErrorLevel == 0 ? "Resized / Restored" : ErrorLevel == 1 ? "Minimized" : ErrorLevel == 2 ? "Maximized" : "N/A"	
	if (Gui_Hwnd) {
		Rect := WindowGetRect("ahk_id " . Gui_Hwnd)
		if (GuiState = "Maximized") {
			W := (rect.width-5*4)/3, H := rect.height-145-5
			GuiControl, Move, Ini_File_1_Text, % "*x" 5*1+W*0 "*y" 145 "*w" W "*h" H
			GuiControl, Move, Ini_File_2_Text, % "*x" 5*2+W*1 "*y" 145 "*w" W "*h" H
			GuiControl, Move, Ini_File_3_Text, % "*x" 5*3+W*2 "*y" 145 "*w" W "*h" H
			;
			W := Rect.width-550-5*2, H := (145-5*2)/5
			X := 550, Y := (145-H)/2
			GuiControl, Move, %G_PROGRESS_BAR%, % "*x" 550 "*y" Y "*w" W "* h" H
			GuiControl, Move, %G_PROGRESS_TEXT%, % "*x" 550 "*y" Y+H+10 "*w" W "* h" 20
		}
	}
	return
}

WindowGetRect(WindowTitle)
{ ; //autohotkey.com/board/topic/91733-command-to-get-gui-client-areas-sizes/?p=578584
	static Hwnd, Rect
    if Hwnd := WinExist(WindowTitle) {
        VarSetCapacity(Rect, 16, 0)
        DllCall("GetClientRect", "Ptr",Hwnd, "Ptr",&Rect)
        return {width: NumGet(Rect, 8, "Int"), height: NumGet(Rect, 12, "Int")}
    }
}

INI_PREPARE(Ini_File_Path, Tmp_Ini_File_Name)
{
	static Ini_File_Name, Ini_File_Dir, Ini_File_Extension, Ini_File_Name_No_Ext, Ini_File_Drive
	static Prepared_Ini_File_Path, Prepared_Ini_File_Contents
	;
	static Ini_File_Contents
	FileRead, Ini_File_Contents, %Ini_File_Path%
	;
	; SplitPath, Ini_File_Path, Ini_File_Name, Ini_File_Dir, Ini_File_Extension, Ini_File_Name_No_Ext, Ini_File_Drive
	Prepared_Ini_File_Path := A_Temp . "\" . Tmp_Ini_File_Name
	;
	FileSetAttrib, -R, %Prepared_Ini_File_Path%
	FileDelete, %Prepared_Ini_File_Path%
	;
	Prepared_Ini_File_Contents := ""
	Loop, Parse, Ini_File_Contents, `n, `r
	{
		Parsed_Line := A_LoopField
		if (Trim(Parsed_Line) != "") && (!RegExMatch(Parsed_Line, "^[\t ]?+[;#\[]")) {
			if (!InStr(Parsed_Line, "=")) {
				Parsed_Line .= "={#-#-#-TREAT-AS-TEXT-#-#-#}"
			}
		}
		Prepared_Ini_File_Contents .= A_Index = 1 ? "" : "`n"
		Prepared_Ini_File_Contents .= Parsed_Line
	}
	FileAppend, %Prepared_Ini_File_Contents%, %Prepared_Ini_File_Path%, CP1251
	return Prepared_Ini_File_Path
}

INI_COUNT_KEYS(Ini_File_Path)
{
	static Keys_Count
	static Ini_File_Contents
	;
	Keys_Count := 0
	FileRead, Ini_File_Contents, %Ini_File_Path%
	Loop, Parse, Ini_File_Contents, `n, `r
	{
		Parsed_Line := A_LoopField
		if (Trim(Parsed_Line) != "") && (!RegExMatch(Parsed_Line, "^[\t ]?+[;#\[]")) {
			Keys_Count++
		}

	}
	return Keys_Count
}

GUI_UPDATE_PROGRESS_BAR(GUI_Progress_Bar, Max_Value, Current_Value)
{
	static Pct
	Pct := Current_Value / Max_Value * 100
	GuiControl,, %GUI_Progress_Bar%, %Pct%
}

GUI_UPDATE_PROGRESS_TEXT(GUI_Progress_Text, Max_Value, Current_Value)
{
	static Pct, Msg
	Pct := Round(Current_Value / Max_Value * 100)
	Msg = PROCESSED KEYS: %Current_Value% of %Max_Value% (%Pct%`%)
	GuiControl,, %GUI_Progress_Text%, %Msg%
}

INI_READ_TO_FILE(Input_Ini_File_Path, Output_Ini_File_Path)
{
	global G_KEYS_TO_PROCESS, G_KEYS_PROCESSED ; GUI_UPDATE_PROGRESS_BAR
	; 
	IniRead, Ini_File_Sections, %Input_Ini_File_Path%
	Loop, Parse, Ini_File_Sections, `n, `r
	{
		if (Section_Name := A_LoopField) {
			IniRead, Section_Contents, %Input_Ini_File_Path%, %Section_Name%
			if (Trim(Section_Contents) = "") {
				IniWrite, %Section_Contents%, %Output_Ini_File_Path%, %Section_Name%
			} 
			else {
				Loop, Parse, Section_Contents, `n, `r
				{
					if (Section_Line := A_LoopField) {
						if RegExMatch(Section_Line, "^(.*?)=(.*)$", Key_Data_) {				
							if (Key_Name := Trim(Key_Data_1)) {
								Key_Value := Trim(Key_Data_2)
								IniWrite, %Key_Value%, %Output_Ini_File_Path%, %Section_Name%, %Key_Name%
								; GUI_UPDATE_PROGRESS_BAR
								G_KEYS_PROCESSED++
								; ToolTip, G_KEYS_PROCESSED: %G_KEYS_PROCESSED% of %G_KEYS_TO_PROCESS%
								GUI_UPDATE_PROGRESS_BAR(G_PROGRESS_BAR, G_KEYS_TO_PROCESS, G_KEYS_PROCESSED)
								GUI_UPDATE_PROGRESS_TEXT(G_PROGRESS_TEXT, G_KEYS_TO_PROCESS, G_KEYS_PROCESSED)
								;
							}
						}
					}
				}
			}
		}
	}
	return Output_Ini_File_Path
}

INI_READ_DIFFS_TO_FILE(Ini_File_1_Path, Ini_File_2_Path, Output_Ini_File)
{
	global G_KEYS_TO_PROCESS, G_KEYS_PROCESSED ; GUI_UPDATE_PROGRESS_BAR
	; 
	IniRead, Ini_File_2_Sections, %Ini_File_2_Path%
	Loop, Parse, Ini_File_2_Sections, `n, `r
	{
		if (Section_Name := A_LoopField) {
			IniRead, Ini_File_2_Section_Contents, %Ini_File_2_Path%, %Section_Name%
			Loop, Parse, Ini_File_2_Section_Contents, `n, `r
			{
				if (Ini_File_2_Section_Line := A_LoopField) {
					if RegExMatch(Ini_File_2_Section_Line, "^(.*?)=(.*)$", Key_Data_) {
						if (Key_Name := Trim(Key_Data_1)) {
							Ini_File_2_Key_Value := Trim(Key_Data_2)
							IniRead, Ini_File_1_Key_Value, %Ini_File_1_Path%, %Section_Name%, %Key_Name%, % "{#-#-#-NOT-EXISTS-#-#-#}"
							; GUI_UPDATE_PROGRESS_BAR
							G_KEYS_PROCESSED++
							; ToolTip, G_KEYS_PROCESSED: %G_KEYS_PROCESSED% of %G_KEYS_TO_PROCESS%
							GUI_UPDATE_PROGRESS_BAR(G_PROGRESS_BAR, G_KEYS_TO_PROCESS, G_KEYS_PROCESSED)
							GUI_UPDATE_PROGRESS_TEXT(G_PROGRESS_TEXT, G_KEYS_TO_PROCESS, G_KEYS_PROCESSED)
							;
							if (Ini_File_1_Key_Value != Ini_File_2_Key_Value) {
								IniWrite, %Ini_File_2_Key_Value%, %Output_Ini_File%, %Section_Name%, %Key_Name%
							}
						}
					}
				}
			}
		}
	}
	return Output_Ini_File
}

FILE_CLEAN_UP(File_Path)
{
	FileRead, File_Contents, %File_Path%
	StringReplace, File_Contents, File_Contents, % "={#-#-#-TREAT-AS-TEXT-#-#-#}", % "", All
	FileDelete, %File_Path%
	FileAppend, %File_Contents%, %File_Path%
	return File_Path
}

INI_MERGE(Ini_File_1, Ini_File_2, Ini_File_3, Method_ID)
{
	global G_KEYS_TO_PROCESS, G_KEYS_PROCESSED
	;
	Ini_File_1 := INI_PREPARE(Ini_File_1, "__tmp_ini_file_1.ini")
	Ini_File_2 := INI_PREPARE(Ini_File_2, "__tmp_ini_file_2.ini")
	;
	Ini_File_1_Keys_Count := INI_COUNT_KEYS(Ini_File_1)
	Ini_File_2_Keys_Count := INI_COUNT_KEYS(Ini_File_2)
	;
	if (Method_ID = 1) {
		FileSetAttrib, -R, %Ini_File_3%
		FileCopy, %Ini_File_1%, %Ini_File_3%, 1
		G_KEYS_TO_PROCESS := Ini_File_2_Keys_Count, G_KEYS_PROCESSED := 0
		Ini_File_3 := INI_READ_TO_FILE(Ini_File_2, Ini_File_3)
	}
	if (Method_ID = 2) {
		G_KEYS_TO_PROCESS := Ini_File_2_Keys_Count+Ini_File_1_Keys_Count, G_KEYS_PROCESSED := 0
		Ini_File_3 := INI_READ_TO_FILE(Ini_File_1, Ini_File_3)
		Ini_File_3 := INI_READ_TO_FILE(Ini_File_2, Ini_File_3)
	}
	if (Method_ID = 3) {
		G_KEYS_TO_PROCESS := Ini_File_1_Keys_Count, G_KEYS_PROCESSED := 0
		Ini_File_3 := INI_READ_DIFFS_TO_FILE(Ini_File_1, Ini_File_2, Ini_File_3)
	}
	if (Method_ID = 4) {
		G_KEYS_TO_PROCESS := Ini_File_2_Keys_Count, G_KEYS_PROCESSED := 0
		Ini_File_3 := INI_READ_DIFFS_TO_FILE(Ini_File_2, Ini_File_1, Ini_File_3)
	}
	;
	Ini_File_3 := FILE_CLEAN_UP(Ini_File_3)
	FileRead, Ini_File_3_Contents, %Ini_File_3%
	return Ini_File_3_Contents
}

Merge:
{
	GuiControl, +AltSubmit, Method ; возвращает выбранную позицию (начиная с 1) в списке вместо текста
	Gui, Submit, NoHide
	Method_ID := Method
	GuiControl, -AltSubmit, Method ; возвращает выбранный в списке текст
	; /*
	if (OverwriteOutputFile && (Ini_File_3 != Ini_File_1 && Ini_File_1 != Ini_File_2)) {
		FileSetAttrib, -R, %Ini_File_3%
		FileDelete, %Ini_File_3%
	}
	; */
	GuiControl,, Ini_File_3_Text, %A_Space%
	Result := INI_MERGE(Ini_File_1, Ini_File_2, Ini_File_3, Method_ID)
	GuiControl,, Ini_File_3_Text, %Result%
	return
}

On_Exit:
{
	FileDelete, % A_Temp . "\" . "__tmp_ini_file_1.ini"
	FileDelete, % A_Temp . "\" . "__tmp_ini_file_2.ini"
	ExitApp
}
