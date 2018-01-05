#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...

if (not A_Args[1] or not FileExist(A_Args[1])) { ; скрипт запущен без аргументов
	FileSelectFile INI_File,, %A_WorkingDir% ; открываем окно дл€ выбора файла
	if (not INI_File) { ; файл не выбран
		ExitApp
	}
}
else { ; скрипт запущен с указанием аргументов
	INI_File := A_Args[1] ; 1й аргумент - файл с параметрами архивации
}

Loop Files, % INI_File, F
{ ; получаем полный путь к файлу с параметрами архивации
	INI_File := A_LoopFileLongPath
}
SplitPath, INI_File, INI_File_FileName, INI_File_Dir, INI_File_Extension, INI_File_NameNoExt, INI_File_Drive ; получаем путь к папке, в которой находитс€ файл с параметрами архивации

WinRAR_Params := ""
. " -u"								;  люч -U Ч обновить файлы
. " -as"							;  люч -AS Ч синхронизировать содержимое архива
. " -s"								;  люч -S Ч создать непрерывный архив
. " -r0"							;  люч -R0 Ч обрабатывать вложенные папки в соответствии с шаблоном
. " -m5"							;  люч -M<n> Ч метод сжати€ [0=min...5=max]
. " -ma5"							;  люч -MA[4|5] Ч верси€ формата архивировани€
. " -md4m"							;  люч -MD<n>[k,m,g] Ч размер словар€
. " -mc63:128t+"					; —жатие текста
. " -mc4a+"							; —жатие аудиоданных, дельта-сжатие
. " -mcc+"							; —жатие графических данных true color (RGB) 
. " -htb"							;  люч -HT[B|C] Ч выбрать тип хеша [BLAKE2|CRC32] дл€ контрольных сумм

IniRead Name, % INI_File, % "Description", % "Name", % INI_File_NameNoExt
IniRead RootDir, % INI_File, % "Description", % "RootDir", % INI_File_Dir
IniRead LockArchive, % INI_File, % "Description", % "LockArchive", 0
IniRead WriteComment, % INI_File, % "Description", % "WriteComment", 0
IniRead IncludeThisFile, % INI_File, % "Description", % "IncludeThisFile", 1
IniRead WinRAR, % INI_File, % "Description", % "WinRAR", % A_ProgramFiles . "\WinRAR\Rar.exe"
IniRead Password, % INI_File, % "Description", % "Password", % ""
IniRead Encrypt, % INI_File, % "Description", % "Encrypt", % 1
IniRead AddSuffix, % INI_File, % "Description", % "AddSuffix", % 0
IniRead CreateNewArchives, % INI_File, % "Description", % "CreateNewArchives", % 0
IniRead NewArchiveNumeration, % INI_File, % "Description", % "NewArchiveNumeration", % "0.2d"
IniRead WinRAR_Params, % INI_File, % "Description", % "WinRAR_Params", % WinRAR_Params

RootDir := ExpandEnvironmentVariables(RootDir)
WinRAR := ExpandEnvironmentVariables(WinRAR)

IniRead TimeStamp, % INI_File, % "Description", % "TimeStamp", % "yyyy.MM.dd"
FormatTime Date,, % TimeStamp ; ѕолучение текущей даты (2015.11.29)
Name .= (Date ? " (" . Date . ")" : "")
; Name .= ".rar"

ArchiveType := "rar"
ArchiveName := Name
Archive := INI_File_Dir . "\" . ArchiveName ; задаем изначальный путь к архиву

If (CreateNewArchives) {
	ArchiveCount := 0
	Loop Files, % Archive . "*" . ArchiveType, F
	{
		MatchString := "^" . Name . " - (\d+)( .*?)?" . "." . ArchiveType . "$"
		If RegExMatch(A_LoopFileName, MatchString, Match, 1) {
			ArchiveCount := Match1 + 1
		}
	}
	ArchiveCount := Format("{1:" . NewArchiveNumeration . "}", ArchiveCount) ; Format("{1:0.3d}",ArchiveCount)
	ArchiveName := Name . " - " . ArchiveCount
}

If (AddSuffix) {
	InputBox ArchiveSuffix, % ArchiveName . "." . ArchiveType,,,, 100
	If (StrLen(ArchiveSuffix) > 0) {
		ArchiveName .= " [" ArchiveSuffix "]"
	}
}

Archive := INI_File_Dir . "\" . ArchiveName ; обновл€ем путь к архиву
Archive .= "." . ArchiveType

Prefix := "DHFWEF90WE89_" ; префикс дл€ имЄн файлов-списков и файла-комментари€
Include_List_File := TextToFile(SplitINIFile(INI_File, "IncludeList"), A_Temp . "\" . Prefix . "Backup_Include_List_File.txt", "CP1251") ; создаем файл-список включений из секции [IncludeList]
Exclude_List_File := TextToFile(SplitINIFile(INI_File, "ExcludeList"), A_Temp . "\" . Prefix . "Backup_Exclude_List_File.txt", "CP1251") ; создаем файл-список исключений из секции [ExcludeList]
if (WriteComment) {
	Comments_Text := ReadINISection(INI_File, "Comments")										; создаем файл-комментарий из секции [Comments],
	Comments_Text := Comments_Text ? Comments_Text : ReadINISection(INI_File, "IncludeList")	; если она отсутствует, то из секции [IncludeList]
	Comments_File := TextToFile(Comments_Text, A_Temp . "\" . Prefix . "Backup_Comments_File.txt", "CP1251")
}

Message := ""
. "Name: " . Name . "`n"
. "ArchiveName: " . ArchiveName . "`n"
. "Password: " . Password . "`n"
. "Encrypt: " . Encrypt . "`n"
. "WinRAR: " . WinRAR . "`n"
. "RootDir: " . RootDir . "`n"
. "TimeStamp: " . TimeStamp . "`n"
. "LockArchive: " . LockArchive . "`n"
. "WriteComment: " . WriteComment . "`n"
. "IncludeThisFile: " . IncludeThisFile . "`n"
. "CreateNewArchives: " . CreateNewArchives . "`n"
. "NewArchiveNumeration: " . NewArchiveNumeration . "`n"
. "ArchiveSuffix: " . ArchiveSuffix . "`n"
. "Archive: " . Archive . "`n"
. "WinRAR_Params: " . WinRAR_Params . "`n"

MsgBox, 1,, % Message

IfMsgBox Ok
{
	gosub WinRAR_Compress
}
else {
	ExitApp
}

Exit

; #Include %A_ScriptDir%\..\Includes\FUNC_ExpandEnvironmentVariables.ahk ; содержит функцию обработки переменных среды
; /* INCLUDED IN "FUNC_ExpandEnvironmentVariables.ahk"
ExpandEnvironmentStrings(ByRef String)
{ ; функци€ обработки переменных среды Windows
  static nSize, Dest, size
  static NULL := ""
  ; Find length of dest string:
  nSize := DllCall("ExpandEnvironmentStrings", "Str", string, "Str", NULL, "UInt", 0, "UInt")
  ,VarSetCapacity(Dest, size := (nSize * (1 << !!A_IsUnicode)) + !A_IsUnicode) ; allocate dest string
  ,DllCall("ExpandEnvironmentStrings", "Str", String, "Str", Dest, "UInt", size, "UInt") ; fill dest string
  return Dest
}

ExpandEnvironmentStringsAHK(String)
{ ; функци€ обработки переменных среды AHK
  static Line, Match, Match1, Expanded
  Loop Parse, String, "\:"
  {
    Line := A_LoopField
    if RegExMatch(Line, "^%(A_\w+)%$", Match)
    {
      Expanded := %Match1%
      String := StrReplace(String, A_LoopField, Expanded)
    }
  }
  return String
}

ExpandEnvironmentVariables(ByRef String)
{ ; функци€ совместной обработки переменных AHK и Windows
  return ExpandEnvironmentStringsAHK(ExpandEnvironmentStrings(String))
}
; */

TextToFile(ByRef Text, ByRef File, ByRef Encoding := "")
{ ; функци€ записи текста в файл
	If FileExist(File) {
		FileDelete, % File
	}
	FileAppend, % Text . "`n", % File, % Encoding
	return ErrorLevel ? "" : File
}

SplitINIFile(ByRef File, ByRef Section)
{ ; функци€ чтени€ секций из файла с параметрами архивации, возвращает файл-список
	static Ret
	IniRead Ret, % File, % Section
	return Ret
}

ReadINISection(ByRef File, ByRef Section)
{ ; функци€ чтени€ секций из файла с параметрами архивации, возвращает содержимое секции
	static Start, End, Ret
	Start := 0, Ret := ""
	Loop Read, % File
	{
		if (Start) {
			if RegExMatch(Trim(A_LoopReadLine), "^\[") { ; достигнута следующа€ секци€
				return Ret
			}
			Ret .= A_LoopReadLine . "`n" ; продолжаем чтение
		}
		else {
			Start := Trim(A_LoopReadLine) = "[" . Section . "]" ; найдено начало секции
		}
	}
	return Ret ; достигнута последн€€ строка файла
}

WinRAR_Compress:
{ ; рутина обработки файлов архиватором WinRAR (сжатие файлов в архив и добавление комментари€)
	WinRAR_Binary := WinRAR
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\Rar.exe"
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\WinRAR.exe"
	WinRAR_Archive := Archive ; A_WorkingDir . "\" . Name
	;
	Loop Files, % WinRAR_Binary, F
	{ ; получаем полный путь к файлус параметрами архивации
		WinRAR_Binary := A_LoopFileLongPath
	}
	SplitPath, WinRAR_Binary, WinRAR_Binary_FileName, WinRAR_Binary_Dir, WinRAR_Binary_Extension, WinRAR_Binary_NameNoExt, WinRAR_Binary_Drive ; получаем путь к папке, в которой находитс€ файл с параметрами архивации
	WinRAR_Is_CMD := WinRAR_Binary_FileName = "Rar.exe" ? 1 : 0
	;
	WinRAR_Error_Log := A_WorkingDir . "\Backup_Errors.txt"	; файл журнала ошибок
	WinRAR_Backup_Log := A_WorkingDir . "\Backup_Log.txt"	; файл журнала обработки
	; удаление предыдущего журнала ошибок
	FileDelete % WinRAR_Error_Log 
	; —оздание архива WinRAR
	WinRAR_Command := (WinRAR_Is_CMD ? ("cd /d " . q(RootDir) . " & ") : "")
	. q(WinRAR_Binary)					; »сполн€емый файл Rar.exe
	. " a"								;  оманда A Ч добавить в архив
	/*
	. " -u"								;  люч -U Ч обновить файлы
	. " -as"							;  люч -AS Ч синхронизировать содержимое архива
	. " -s"								;  люч -S Ч создать непрерывный архив
	; . " -r"								;  люч -R Ч включить в обработку вложенные папки
	. " -r0"							;  люч -R0 Ч обрабатывать вложенные папки в соответствии с шаблоном
	. " -m5"							;  люч -M<n> Ч метод сжати€ [0=min...5=max]
	. " -ma5"							;  люч -MA[4|5] Ч верси€ формата архивировани€
	. " -md4m"							;  люч -MD<n>[k,m,g] Ч размер словар€
	. " -mc63:128t+"					; —жатие текста
	. " -mc4a+"							; —жатие аудиоданных, дельта-сжатие
	. " -mcc+"							; —жатие графических данных true color (RGB) 
	; . " -rr3p"							;  люч -RR[n] Ч добавить данные дл€ восстановлени€ [3%]
	. " -htb"							;  люч -HT[B|C] Ч выбрать тип хеша [BLAKE2|CRC32] дл€ контрольных сумм
	*/
	. (WinRAR_Params ? WinRAR_Params : "")
	. " -ilog" . q(WinRAR_Error_Log)	;  люч -ILOG[им€] Ч записывать журнал ошибок в файл
	; . " -logf=" . q(WinRAR_Backup_Log)	;  люч -LOG[формат][=им€] Ч записать имена в файл с журналом
	. " -x" . q(Include_List_File)		;  люч -X<файл> Ч не обрабатывать указанный файл или папку
	. " -x" . q(Exclude_List_File)		;  люч -X<файл> Ч не обрабатывать указанный файл или папку
	. " -x" . q(WinRAR_Error_Log)		;  люч -X<файл> Ч не обрабатывать указанный файл или папку
	. " -x" . q(WinRAR_Backup_Log)		;  люч -X<файл> Ч не обрабатывать указанный файл или папку
	; ¬ключение в обработку или исключение из обработки самого файла настроек %INI_File%
	if (not IncludeThisFile) {  
		WinRAR_Command .= " -x" . q(INI_File) ;  люч -X<файл> Ч не обрабатывать указанный файл или папку
	}
	; ƒобавление парол€
	if (Password) {  
		WinRAR_Command .= (Encrypt 
			? " -hp"	;  люч -HP[пароль] Ч шифровать содержимое файлов и оглавление архива
			: " -p")	;  люч -P<пароль> Ч указать пароль шифровани€ архива
		 . Password
	}
	WinRAR_Command .= " " . q(WinRAR_Archive)	; јрхив
	. " -x@" . q(Exclude_List_File)		;  люч -X@<файл-список> Ч не обрабатывать файлы, указанные в файле-списке
	. " @" . q(Include_List_File)		; @<файл-список> Ч обрабатывать файлы, указанные в файле-списке
	if (not WinRAR_Is_CMD) {
		RunWait %WinRAR_Command%
	}
	;  оманда добавлени€ комментари€ к архиву
	if WriteComment {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " c"									;  оманда C Ч добавить комментарий архива
		. " -z" . q(Comments_File)				;  люч -Z<файл> Ч прочитать комментарий архива из файла
		. (Password ? " -p" . Password : "")	;  люч -P<пароль> Ч указать пароль шифровани€ архива
		. " " . q(WinRAR_Archive)				; јрхив
		if (not WinRAR_Is_CMD) {
			RunWait %WinRAR_Command%
		}
	}
	;  оманда добавлени€ данных дл€ восстановлени€
	WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
	. q(WinRAR_Binary)
	. " rr5p"								;  оманда RR[n ] Ч добавить данные дл€ восстановлени€ [5%]
	. (Password ? " -p" . Password : "")	;  люч -P<пароль> Ч указать пароль шифровани€ архива
	. " " . q(WinRAR_Archive)				; јрхив
	if (not WinRAR_Is_CMD) {
		RunWait %WinRAR_Command%
	}
	;  оманда блокировани€ архива от перезаписи
	if LockArchive {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " k"									;  оманда K Ч заблокировать архив
		. (Password ? " -p" . Password : "")	;  люч -P<пароль> Ч указать пароль шифровани€ архива
		. " " . q(WinRAR_Archive)				; јрхив
		if (not WinRAR_Is_CMD) {
			RunWait %WinRAR_Command%
		}
	}
	; —оединение всех команд в одну
	if (WinRAR_Is_CMD) {
		WinRAR_Command .= " & pause & exit"
		; MsgBox % WinRAR_Command
		;
		; ¬ыполнение команды в коммандной строке Windows
		RunWait "%ComSpec%" /k %WinRAR_Command%
	}
	;
	; ќтображение журнала ошибок
	if (WinRAR_Is_CMD and FileExist(WinRAR_Error_Log)) {
		Run notepad "%WinRAR_Error_Log%"
	}
	return
}

q(ByRef Str)
{
	return """" . Str . """"
}