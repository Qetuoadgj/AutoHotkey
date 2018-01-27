#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...

SetWorkingDir, C:\Users\Anton\Desktop\Новая папка (4)

Ini_File_Path = %A_WorkingDir%\ini_write_test.ini

; IniRead, Ini_File_Sections, %Ini_File_Path%, Controls, Slide LeftZ, 5555
; IniWrite, 4444, %Ini_File_Path%, Controls, Slide LeftZ


; MsgBox, %Ini_File_Sections%

; Exit

FileRead, Ini_File_Text, %Ini_File_Path%
;
/*
MsgBox, % "------------`n" . ENUMERATE_LINES(Ini_File_Text, 0) . "`n------------"
Section_Starts_With := "^\[Controls\]", Section_Ends_With := "^\[.*?\]"
;
Section_Text_First_Line_Index := 0, Section_Text_End_Line_Index := 0, Section_Text_Lines_Count := 0
Section_Text := TEXT_GET_PART(Ini_File_Text, Section_Text_First_Line_Index, Section_Text_End_Line_Index, Section_Text_Lines_Count, Section_Starts_With, Section_Ends_With)
MsgBox, % "------------`n" . ENUMERATE_LINES(Section_Text, Section_Text_First_Line_Index-1) . "`n------------"
;
; Section_Contents_First_Line_Index := 0, Section_Contents_End_Line_Index := 0, Section_Contents_Lines_Count := 0
; Section_Contents := GET_SECTION_CONTENTS(Ini_File_Text, Section_Contents_First_Line_Index, Section_Contents_End_Line_Index, Section_Contents_Lines_Count, Section_Starts_With, Section_Ends_With)
; MsgBox, % "------------`n" . ENUMERATE_LINES(Section_Contents, Section_Contents_First_Line_Index-1) . "`n------------"
;
Section_Contents_First_Line_Index := 0, Section_Contents_End_Line_Index := 0, Section_Contents_Lines_Count := 0
Section_Contents := GET_INI_SECTION_CONTENTS(Ini_File_Text, "Controls", Section_Contents_First_Line_Index, Section_Contents_End_Line_Index, Section_Contents_Lines_Count)
MsgBox, % "------------`n" . ENUMERATE_LINES(Section_Contents, Section_Contents_First_Line_Index-1) . "`n------------"
*/

MsgBox, % "Ini_File_Text" . "`n" . "------------`n" . ENUMERATE_LINES(Ini_File_Text, 0) . "`n------------"
;
Section_Starts_With := "^\[Controls\]", Section_Ends_With := "^\[.*?\]"
;
Section_Text_Data := TEXT_GET_DATA(Ini_File_Text, Section_Starts_With, Section_Ends_With)
Section_Text := Section_Text_Data.text
Section_Lines_Count := Section_Text_Data.lines
Section_Lines_Pos_Start := Section_Text_Data.start
Section_Lines_Pos_End := Section_Text_Data.end
MsgBox, % "Section_Text_Data" . "`n" . "------------`n" . ENUMERATE_LINES(Section_Text, Section_Lines_Pos_Start-1) . "`n------------"
/*
Section_Contents_Data := TEXT_GET_SECTION_CONTENTS(Ini_File_Text, Section_Starts_With, Section_Ends_With)
Section_Contents := Section_Contents_Data.text
Section_Contents_Lines_Count := Section_Contents_Data.lines
Section_Contents_Lines_Pos_Start := Section_Contents_Data.start
Section_Contents_Lines_Pos_End := Section_Contents_Data.end
MsgBox, % "Section_Contents_Data" . "`n" . "------------`n" . ENUMERATE_LINES(Section_Contents, Section_Contents_Lines_Pos_Start-1) . "`n------------"
*/
Section_Contents_Data := INI_GET_SECTION_CONTENTS(Ini_File_Text, "Controls")
Section_Contents := Section_Contents_Data.text
Section_Contents_Lines_Count := Section_Contents_Data.lines
Section_Contents_Lines_Pos_Start := Section_Contents_Data.start
Section_Contents_Lines_Pos_End := Section_Contents_Data.end
MsgBox, % "Section_Contents_Data" . "`n" . "------------`n" . ENUMERATE_LINES(Section_Contents, Section_Contents_Lines_Pos_Start-1) . "`n------------"
;
Key_Name := "Slide LeftZ"
Section_Key_Data := INI_GET_SECTION_KEY(Section_Contents, Key_Name, "ERROR")
Section_Key_Full_Text := Section_Key_Data.text
Section_Key_Lines_Pos := Section_Key_Data.pos
Section_Key_Lines_Value := Section_Key_Data.value
MsgBox, % "Section_Key_Data" . "`n" . "------------`n" . ENUMERATE_LINES(Section_Key_Full_Text, Section_Contents_Lines_Pos_Start+Section_Key_Lines_Pos-1) . "`n------------"
MsgBox, % "Section_Key_Data" . "`n" . "------------`n" . Section_Key_Full_Text . "`n" . Section_Key_Lines_Pos . " | " . Section_Key_Lines_Pos+Section_Contents_Lines_Pos_Start . "`n" . Section_Key_Lines_Value . "`n------------"
;
Section_Key_Data := INI_SET_SECTION_KEY(Section_Contents, Key_Name, "22222")
Section_Key_Full_Text := Section_Key_Data.text
Section_Key_Lines_Pos := Section_Key_Data.pos
Section_Key_Lines_Value := Section_Key_Data.value
MsgBox, % "Section_Key_Data" . "`n" . "------------`n" . ENUMERATE_LINES(Section_Key_Full_Text, Section_Contents_Lines_Pos_Start+Section_Key_Lines_Pos-1) . "`n------------"
MsgBox, % "Section_Key_Data" . "`n" . "------------`n" . Section_Key_Full_Text . "`n" . Section_Key_Lines_Pos . " | " . Section_Key_Lines_Pos+Section_Contents_Lines_Pos_Start . "`n" . Section_Key_Lines_Value . "`n------------"
;
/*
TEXT_GET_PART(Input_Text, ByRef First_Line_Index := 0, ByRef End_Line_Index := 0, ByRef Part_Lines_Count := 0, Starts_With := "", Ends_With := "")
{
	static Output_Text, Text_Line
	First_Line_Index := 0, End_Line_Index := 0, Part_Lines_Count := 0 ; ByRef
	;
	Output_Text := ""
	Loop, Parse, Input_Text, `n, `r
	{
		Text_Line := A_LoopField
		if (Starts_With) {
			if (Starts_With && RegExMatch(Text_Line, Starts_With)) {
				First_Line_Index := A_Index
			}
			if (First_Line_Index) {
				Part_Lines_Count++
				End_Line_Index := A_Index
				Output_Text .= (Part_Lines_Count == 1 ? "" : "`n") . Text_Line
				if (Ends_With && RegExMatch(Text_Line, Ends_With) && (End_Line_Index > First_Line_Index)) {
					break
				}
			}
		}
		else {
			First_Line_Index := 1
			End_Line_Index := A_Index
		}
	}
	return Output_Text
}

GET_SECTION_CONTENTS(Input_Text, ByRef Section_Contents_First_Line_Index := 0, ByRef Section_Contents_End_Line_Index := 0, ByRef Section_Contents_Lines_Count := 0, Section_Starts_With := "", Section_Ends_With := "")
{
	static Output_Text, Section_Text, Text_Line
	static Section_Text_First_Line_Index, Section_Text_End_Line_Index, Section_Text_Lines_Count ; ByRef
	;
	Output_Text := ""
	Section_Text_First_Line_Index := 0, Section_Text_End_Line_Index := 0, Section_Text_Lines_Count := 0 ; ByRef
	Section_Text := TEXT_GET_PART(Input_Text, Section_Text_First_Line_Index, Section_Text_End_Line_Index, Section_Text_Lines_Count, Section_Starts_With, Section_Ends_With)
	Section_Contents_First_Line_Index := Section_Text_First_Line_Index, Section_Contents_End_Line_Index := Section_Text_End_Line_Index, Section_Contents_Lines_Count := 0
	Loop, Parse, Section_Text, `n, `r
	{
		Text_Line := A_LoopField
		if (A_Index == 1) {
			Section_Contents_First_Line_Index++
			continue
		}
		if (Section_Ends_With && RegExMatch(Text_Line, Section_Ends_With) && (Section_Contents_End_Line_Index > Section_Contents_First_Line_Index)) {
			Section_Contents_End_Line_Index--
			break
		}
		Section_Contents_Lines_Count++
		Output_Text .= (Section_Contents_Lines_Count == 1 ? "" : "`n") . Text_Line
	}
	return Output_Text
}

GET_INI_SECTION_CONTENTS(Input_Text, Section_Name, ByRef Section_Contents_First_Line_Index := 0, ByRef Section_Contents_End_Line_Index := 0, ByRef Section_Contents_Lines_Count := 0)
{
	static White_Space, Section_Starts_With, Section_Ends_With
	;
	White_Space := "[\t ]?+"
	Section_Starts_With := "i)" . "^" . White_Space . "\[" . Section_Name . "\]"
	Section_Ends_With := "i)" . "^" . White_Space . "^\[.*?\]"
	;
	return GET_SECTION_CONTENTS(Input_Text, Section_Contents_First_Line_Index, Section_Contents_End_Line_Index, Section_Contents_Lines_Count, Section_Starts_With, Section_Ends_With)
}
*/

Exit

ENUMERATE_LINES(Input_Text, Add := 0, Delimiter := ".`t")
{
	static Output_Text
	;
	Output_Text := ""
	Loop, Parse, Input_Text, `n, `r
	{
		Output_Text .= A_Index = 1 ? "" : "`n"
		Output_Text .= Add == "" ? A_LoopField : (A_Index + Add) . Delimiter . A_LoopField
	}
	return Output_Text
}

TEXT_GET_DATA(Input_Text, Starts_With := "", Ends_With := "", Single_Line := 0)
{
	static Parsed_Line, Output_Text
	static First_Line_Index, End_Line_Index, Text_Lines_Count
	;
	Output_Text := ""
	First_Line_Index := 0, End_Line_Index := 0, Text_Lines_Count := 0
	Loop, Parse, Input_Text, `n, `r
	{
		Parsed_Line := A_LoopField
		if (Starts_With) {
			if (Starts_With && RegExMatch(Parsed_Line, Starts_With)) {
				First_Line_Index := A_Index
			}
			if (First_Line_Index) {
				Text_Lines_Count++
				End_Line_Index := A_Index
				Output_Text .= (Text_Lines_Count == 1 ? "" : "`n") . Parsed_Line
				if (Ends_With && RegExMatch(Parsed_Line, Ends_With) && ((End_Line_Index > First_Line_Index) || Single_Line)) {
					break
				}
			}
		}
		else {
			First_Line_Index := 1
			End_Line_Index := A_Index
			Text_Lines_Count++
		}
	}
	return {text: Output_Text, start: First_Line_Index, end: End_Line_Index, lines: Text_Lines_Count}
}

TEXT_GET_SECTION_CONTENTS(Input_Text, Section_Starts_With := "", Section_Ends_With := "")
{
	static Parsed_Line, Output_Text
	static Section_Text_Data, Section_Text, Section_Lines_Count, Section_Lines_Pos_Start, Section_Lines_Pos_End
	;
	Section_Text_Data := TEXT_GET_DATA(Input_Text, Section_Starts_With, Section_Ends_With)
	Section_Text := Section_Text_Data.text
	Section_Lines_Count := 0 ;Section_Text_Data.lines
	Section_Lines_Pos_Start := Section_Text_Data.start
	Section_Lines_Pos_End := Section_Text_Data.end
	;
	Output_Text := ""
	Loop, Parse, Section_Text, `n, `r
	{
		Parsed_Line := A_LoopField
		if (A_Index == 1) {
			Section_Lines_Pos_Start++
			continue
		}
		if (Section_Ends_With && RegExMatch(Parsed_Line, Section_Ends_With) && (Section_Lines_Pos_End > Section_Lines_Pos_Start)) {
			Section_Lines_Pos_End--
			break
		}
		Section_Lines_Count++
		Output_Text .= (Section_Lines_Count == 1 ? "" : "`n") . Parsed_Line
	}
	return {text: Output_Text, start: Section_Lines_Pos_Start, end: Section_Lines_Pos_End, lines: Section_Lines_Count}
}

INI_GET_SECTION_CONTENTS(Input_Text, Section_Name)
{
	static White_Space, Section_Starts_With, Section_Ends_With
	;
	White_Space := "[\t ]?+"
	Section_Starts_With := "i)" . "^" . White_Space . "\[" . Section_Name . "\]"
	Section_Ends_With := "i)" . "^" . White_Space . "^\[.*?\]"
	;
	return TEXT_GET_SECTION_CONTENTS(Input_Text, Section_Starts_With, Section_Ends_With)
}

INI_GET_SECTION_KEY(Input_Text, Key_Name, Default_Value := "ERROR")
{
	static White_Space, Comment_Signs, Key_Starts_With, Key_Ends_With
	static Section_Key_Data, Section_Key_Full_Text, Section_Key_Value
	;
	White_Space := "[\t ]?+"
	Comment_Signs := "[\t ]+[;#]"
	Key_Starts_With := "i)" . "^" . White_Space . Key_Name
	Key_Ends_With := "^"
	;
	Section_Key_Data := TEXT_GET_DATA(Input_Text, Key_Starts_With, Key_Ends_With, 1)
	if (Section_Key_Full_Text := Section_Key_Data.text) {
		Section_Key_Value := RegExReplace(Section_Key_Full_Text, ".*?=[\t ]?+(.*)", "$1", 1)
		Section_Key_Value := RegExReplace(Section_Key_Value, Comment_Signs . ".*$", "", 1)
		Section_Key_Value := Trim(Section_Key_Value)
		Section_Key_Value := RegExReplace(Section_Key_Value, "^""" . "(.*)" . """$", "$1", 1)
	}
	else {
		return {value: Default_Value, text: (Key_Name . "=" . Default_Value)}
	}
	;
	return {value: Section_Key_Value, text: Section_Key_Full_Text, pos: Section_Key_Data.start}
}

INI_SET_SECTION_KEY(Input_Text, Key_Name, New_Value := "")
{
	static White_Space, Comment_Signs, Key_Starts_With, Key_Ends_With
	static Section_Key_Data, Section_Key_Full_Text, Section_Key_Value, Section_Key_Pos
	White_Space := "[\t ]?+"
	Section_Key_Data := INI_GET_SECTION_KEY(Input_Text, Key_Name)
	if (Section_Key_Pos := Section_Key_Data.pos) {
		Section_Key_Value := Section_Key_Data.value
		Section_Key_Full_Text := Section_Key_Data.text
		if InStr(Section_Key_Full_Text, "=") {
			Section_Key_Full_Text := RegExReplace(Section_Key_Full_Text, "(" . Key_Name . White_Space . ")" . "=" . "(" . White_Space . ")" . Section_Key_Data, "$1=$2" . New_Value)
		}
		else {
			Section_Key_Full_Text := RegExReplace(Section_Key_Full_Text, "(" . Key_Name . ")", "$1=" . New_Value)
		}
		Section_Key_Data.text := Section_Key_Full_Text
		Section_Key_Data.value := New_Value
	}
	;
	return Section_Key_Data
}
