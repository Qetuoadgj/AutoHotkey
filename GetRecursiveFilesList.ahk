; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/raw/master/GetRecursiveFilesList.ahk| v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force ; [Force|Ignore|Off]

if (not %0%) {
	ExitApp
}

FileList := ""

Loop %0% ; For each parameter (or file dropped onto a script):
{
    TargetPath := %A_Index% ; Fetch the contents of the variable whose name is contained in A_Index.
	TargetPath := InStr(FileExist(TargetPath), "D") ? (TargetPath . "\*") : TargetPath
	Loop Files, % TargetPath, FR ; Loop Files, %1%\*, FR
	{
		File := A_LoopFileLongPath
		SplitPath, File, FileName, FileDir ;, FileExtension, FileNameNoExt, FileDrive ; получаем путь к папке, в которой находится файл с параметрами архивации
		FileList .= File . "|" . FileDir "`n"
	}
}

if (FileList) {
	MsgBox, 36, Recursive Files List, Sort list?
	IfMsgBox Yes
	{
		Sort, FileList, \ ;R
	}
	
	PreviousDir := ""
	Output := ""
	Loop, parse, FileList, `n, `r
	{
		if (A_LoopField == "") { ; Ignore the blank item at the end of the list.
			Output .= ";"
			continue
		}
		FileData := StrSplit(A_LoopField, "|")
		File := FileData[1]
		FileDir := FileData[2]
		if (not FileDir == PreviousDir) {
			if (A_Index != 1) {
				Output .= ";`r`n"
			}
			Output .=  "; " . FileDir . "\`r`n"
		}
		Output .= "`t" . File . "`r`n"
		PreviousDir := FileDir
	}
	
	/*
	Clipboard := "" ; Empty the clipboard.
	Clipboard := Output
	ClipWait ;2.0
	MsgBox 0,, %Clipboard%, 1.5
	*/
	
	PasteToNotepad(Output)
}

Exit

PasteToNotepad(ByRef Text)
{
	Run % "notepad.exe",,, Notepad_PID
	WinWait ahk_pid %Notepad_PID%,, 3
	IfWinExist ahk_pid %Notepad_PID%
	{
		WinActivate ahk_pid %Notepad_PID%
		ControlSetText, % "Edit1", % Text, ahk_pid %Notepad_PID%
	}
}
