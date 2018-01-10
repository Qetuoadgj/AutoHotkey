#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...
/*
if (not A_Args[1] or not FileExist(A_Args[1])) { ; скрипт запущен без аргументов
	FileSelectFile TargetFile,, % A_WorkingDir,, % "*.url" ; открываем окно для выбора файла
	if (not TargetFile) { ; файл не выбран
		ExitApp
	}
}
else { ; скрипт запущен с указанием аргументов
	TargetFile := A_Args[1] ; 1й аргумент - файл с параметрами архивации
}

Loop Files, % TargetFile, F
{ ; получаем полный путь к файлу с параметрами архивации
	TargetFile := A_LoopFileLongPath
}
*/

FileSelectFile, TargetFile, M32,,, *.url
if (not TargetFile) { ; файл не выбран
	ExitApp
}
/*
Loop Files, % TargetFile, F
{ ; получаем полный путь к файлу с параметрами архивации
	TargetFile := A_LoopFileLongPath
}
*/

Loop Parse, % TargetFile, `n
{
	if (not A_LoopField) {
		break
	}
	if( a_index = 1) {
		; MsgBox, The selected files are all contained in %A_LoopField%.
		FileDir := A_LoopField
	}
	else {
		Loop Files, % FileDir . "\" . A_LoopField, F
		{ ; получаем полный путь к файлу
			TargetFile := A_LoopFileLongPath
			Convert(TargetFile)
		}
	}
}

Exit

q(ByRef Str)
{
	return """" . Str . """"
}

SelectIcon(ByRef IconPath := "", ByRef Index := 0)
{ ; функция вызова диалога выбора файла иконки и самой иконки из него
	static Call
	IconPath := IconPath ? IconPath : A_WinDir . "\system32\shell32.dll"
	Call := DllCall("shell32\PickIconDlg", "Uint", "null", "str", IconPath, "Uint", 260, "intP", Index)
	if (Call) {
		return IconPath . "," . Index+1
	}
}

Convert(ByRef File)
{
	static FileName, FileDir, FileExtension, FileNameNoExt, FileDrive
	static OutTarget, OutDir, OutArgs, OutDesc, OutIcon, OutIconNum, OutRunState
	static SelectedIcon
	static Target, LinkFile, WorkingDir, Args, Description, IconFile, ShortcutKey, IconNumber, RunState
	;
	SplitPath, File, FileName, FileDir, FileExtension, FileNameNoExt, FileDrive
	FileGetShortcut, % File, OutTarget, OutDir, OutArgs, OutDesc, OutIcon, OutIconNum, OutRunState
	if (OutTarget) {
		return
	}
	else {
		IniRead URL, % File, InternetShortcut, URL, 0
		if (URL) {
			CoordMode, ToolTip
			ToolTip % FileNameNoExt, 50, 45
			SelectedIcon := StrSplit(SelectIcon(), ",", "`s")
			if (SelectedIcon[1] && SelectedIcon[2]) {
				;
				Target := q("%WinDir%\explorer.exe")
				LinkFile := FileDir . "\" . FileNameNoExt . ".lnk"
				WorkingDir := ""
				Args := q(URL)
				Description := ""
				IconFile := SelectedIcon[1]
				ShortcutKey := ""
				IconNumber := SelectedIcon[2]
				RunState := ""
				;
				FileCreateShortcut, % Target, % LinkFile, % WorkingDir, % Args, % Description, % IconFile, % ShortcutKey, % IconNumber, % RunState
				if (not ErrorLevel) {
					; MsgBox, % FileDir . "\" . FileNameNoExt . ".lnk" . "`n" "OK!"
					; FileDelete % File
					MsgBox, 262144, , OK!, 1
				}
			}
		}
	}
}