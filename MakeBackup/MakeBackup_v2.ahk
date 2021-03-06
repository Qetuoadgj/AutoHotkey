; site: https://github.com/Qetuoadgj/AutoHotkey/tree/master/MakeBackup

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, Force

; Your code here...

NoExec := 0

KeyWait, Shift, D T0.005
if (not ErrorLevel) {
	NoExec := 1
	gosub, Set_Params
	gosub, Make_Help_File
	ExitApp
}

KeyWait, Ctrl, D T0.005
if (not ErrorLevel) {
	FileSelectFolder, Get_File_List_Folder, *%A_WorkingDir%, 4
	if (Get_File_List_Folder) {
		gosub, Get_Recursive_Files_List
	}
	ExitApp
}

Set_Params:
{
	if (not NoExec) {
		if (not A_Args[1] or not FileExist(A_Args[1])) { ; ������ ������� ��� ����������
			FileSelectFile, INI_File,, %A_WorkingDir% ; ��������� ���� ��� ������ �����
			if (not INI_File) { ; ���� �� ������
				ExitApp
			}
		}
		else { ; ������ ������� � ��������� ����������
			INI_File := A_Args[1] ; 1� �������� - ���� � ����������� ���������
		}
		
		Loop, Files, %INI_File%, F
		{ ; �������� ������ ���� � ����� � ����������� ���������
			INI_File := A_LoopFileLongPath
		}
	}
	else {
		INI_File := ""
	}
	
	SplitPath, INI_File, INI_File_FileName, INI_File_Dir, INI_File_Extension, INI_File_NameNoExt, INI_File_Drive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������
	
	WinRAR_RAR_Params := ""
	. " A"				; ������� A � �������� � �����
	. " -u"				; ���� -U � �������� �����
	. " -as"			; ���� -AS � ���������������� ���������� ������
	. " -s"				; ���� -S � ������� ����������� �����
	. " -r0"			; ���� -R0 � ������������ ��������� ����� � ������������ � ��������
	. " -m5"			; ���� -M<n> � ����� ������ [0=min...5=max]
	. " -ma5"			; ���� -MA[4|5] � ������ ������� �������������
	. " -md4m"			; ���� -MD<n>[k,m,g] � ������ �������
	. " -mc63:128t+"	; ������ ������
	. " -mc4a+"			; ������ �����������, ������-������
	. " -mcc+"			; ������ ����������� ������ true color (RGB)
	. " -htb"			; ���� -HT[B|C] � ������� ��� ���� [BLAKE2|CRC32] ��� ����������� ����
	
	WinRAR_ZIP_Params := ""
	. " A"				; ������� A � �������� � �����
	. " -afZIP"			; ���� -AF<���> � ������� ������ ������
	. " -u"				; ���� -U � �������� �����
	. " -as"			; ���� -AS � ���������������� ���������� ������
	. " -s"				; ���� -S � ������� ����������� �����
	. " -r0"			; ���� -R0 � ������������ ��������� ����� � ������������ � ��������
	. " -m5"			; ���� -M<n> � ����� ������ [0=min...5=max]
	. " -ma5"			; ���� -MA[4|5] � ������ ������� �������������
	. " -md4m"			; ���� -MD<n>[k,m,g] � ������ �������
	. " -mc63:128t+"	; ������ ������
	. " -mc4a+"			; ������ �����������, ������-������
	. " -mcc+"			; ������ ����������� ������ true color (RGB)
	. " -htb"			; ���� -HT[B|C] � ������� ��� ���� [BLAKE2|CRC32] ��� ����������� ����
	
	7Zip_Sync := "p1q0r2x1y2z1w2" ; ����� ������ ��� ������������� ������ ������ ������, ������ ����� -AS � WinRAR
	7Zip_7Z_Params := ""
	. " U"				; u (Update) command
	. " -u" . 7Zip_Sync	; -u (Update options) switch
	. " -r0"			; -r (Recurse subdirectories) switch
	. " -spf2"			; -spf (Use fully qualified file paths) switch
	. " -slp"			; -slp (Set Large Pages mode) switch
	. " -mx"			; -m (Set compression Method) switch
	. " -myx"			; Sets level of file analysis.
	. " -ms=on"			; Sets solid mode.
	. " -scrcBLAKE2sp"	; -scrc (Set hash function) switch
	
	7Zip_ZIP_Params := ""
	. " U"				; u (Update) command
	. " -u" . 7Zip_Sync	; -u (Update options) switch
	. " -r0"			; -r (Recurse subdirectories) switch
	. " -spf2"			; -spf (Use fully qualified file paths) switch
	. " -slp"			; -slp (Set Large Pages mode) switch
	. " -mx"			; -m (Set compression Method) switch
	. " -myx"			; Sets level of file analysis.
	. " -ms=on"			; Sets solid mode.
	. " -scrcBLAKE2sp"	; -scrc (Set hash function) switch
	
	IniRead, Name, %INI_File%, % "Description", % "Name", %INI_File_NameNoExt%
	IniRead, RootDir, %INI_File%, % "Description", % "RootDir", %INI_File_Dir%
	IniRead, WorkingDir, %INI_File%, % "Description", % "WorkingDir", 0
	IniRead, WinRAR_RAR_LockArchive, %INI_File%, % "Description", % "WinRAR_RAR_LockArchive", 0
	IniRead, WinRAR_WriteComment, %INI_File%, % "Description", % "WinRAR_WriteComment", 0
	IniRead, IncludeThisFile, %INI_File%, % "Description", % "IncludeThisFile", 1
	IniRead, WinRAR, %INI_File%, % "Description", % "WinRAR", % A_ProgramFiles . "\WinRAR\Rar.exe"
	IniRead, WinRAR_UI, %INI_File%, % "Description", % "WinRAR_UI", % A_ProgramFiles . "\WinRAR\WinRar.exe"
	IniRead, Password, %INI_File%, % "Description", % "Password", 0
	IniRead, Encrypt, %INI_File%, % "Description", % "Encrypt", 1
	IniRead, AddSuffix, %INI_File%, % "Description", % "AddSuffix", 0
	IniRead, MakeArchiveReadOnly, %INI_File%, % "Description", % "MakeArchiveReadOnly", 0
	IniRead, CreateNewArchives, %INI_File%, % "Description", % "CreateNewArchives", 0
	IniRead, NewArchiveNumeration, %INI_File%, % "Description", % "NewArchiveNumeration", % "0.2d"
	IniRead, WinRAR_RAR_Params, %INI_File%, % "Description", % "WinRAR_RAR_Params", %WinRAR_RAR_Params%
	IniRead, WinRAR_ZIP_Params, %INI_File%, % "Description", % "WinRAR_ZIP_Params", %WinRAR_ZIP_Params%
	
	IniRead, 7Zip, %INI_File%, % "Description", % "7Zip", % A_ProgramFiles . "\7-Zip\7z.exe"
	IniRead, 7Zip_7Z_Params, %INI_File%, % "Description", % "7Zip_7Z_Params", %7Zip_7Z_Params%
	IniRead, 7Zip_ZIP_Params, %INI_File%, % "Description", % "7Zip_ZIP_Params", %7Zip_ZIP_Params%
	
	RootDir := ExpandEnvironmentVariables(RootDir)
	WorkingDir := ExpandEnvironmentVariables(WorkingDir)
	WinRAR := ExpandEnvironmentVariables(WinRAR)
	WinRAR_UI := ExpandEnvironmentVariables(WinRAR_UI)
	7Zip := ExpandEnvironmentVariables(7Zip)
	
	IniRead, CmdTimeout, %INI_File%, % "Description", % "CmdTimeout", %A_Space% ; 2
	IniRead, Debug, %INI_File%, % "Description", % "Debug", 0
	
	IniRead, TimeStamp, %INI_File%, % "Description", % "TimeStamp", 0 ;% "yyyy.MM.dd"
	FormatTime, Date,, %TimeStamp% ; ��������� ������� ���� (2015.11.29)
	Name .= (Date ? " (" . Date . ")" : "")
	; Name .= ".rar"
	
	; ArchiveType := "rar"
	IniRead, ArchiveType, %INI_File%, % "Description", % "ArchiveType", % "rar"
		
	Archiver := (ArchiveType = "7z") ? "7Zip" : "WinRAR"
	Archiver := (ArchiveType = "zip") ? (FileExist(WinRAR_UI) ? "WinRAR" : "7Zip") : Archiver
	
	WinRAR_Params := ArchiveType = "zip" ? WinRAR_ZIP_Params : WinRAR_RAR_Params
	WinRAR_Params := Trim(WinRAR_Params)
	
	7Zip_Params := ArchiveType = "zip" ? 7Zip_ZIP_Params : 7Zip_7Z_Params
	7Zip_Params := Trim(7Zip_Params)
	
	; WinRAR := ArchiveType = "zip" ? (WinRAR_UI or RegExReplace(WinRAR, "i)\\Rar.exe$", "\WinRar.exe")) : WinRAR
	
	ArchiveName := Name
	Archive := INI_File_Dir . "\" . ArchiveName ; ������ ����������� ���� � ������
	
	if (CreateNewArchives) {
		ArchiveCount := 0
		Loop, Files, % Archive . "*" . ArchiveType, F
		{
			MatchString := "^" . Escape(Name) . " - (\d+)( .*?)?" . "." . Escape(ArchiveType) . "$"
			if RegExMatch(A_LoopFileName, MatchString, Match, 1) {
				ArchiveCount := Match1 + 1
			}
		}
		ArchiveCount := Format("{1:" . NewArchiveNumeration . "}", ArchiveCount) ; Format("{1:0.3d}",ArchiveCount)
		ArchiveName := Name . " - " . ArchiveCount
	}
	
	If (AddSuffix) {
		InputBox, ArchiveSuffix, % ArchiveName . "." . ArchiveType,,,, 100
		If (StrLen(ArchiveSuffix) > 0) {
			ArchiveName .= " [" ArchiveSuffix "]"
		}
	}
	
	Archive := INI_File_Dir . "\" . ArchiveName ; ��������� ���� � ������
	Archive .= "." . ArchiveType
	
	Prefix := "DHFWEF90WE89_" ; ������� ��� ��� ������-������� � �����-�����������
	Include_List_Text := SplitINIFile(INI_File, "IncludeList") ; ������� ������ ��������� �� ������ [IncludeList]
	Exclude_List_Text := SplitINIFile(INI_File, "ExcludeList") ; ������� ������ ���������� �� ������ [ExcludeList]
	
	; Sort, Include_List_Text, U ; �������� ���������� �� ������
	; Sort, Exclude_List_Text, U ; �������� ���������� �� ������
	
	IniRead, ComSpecParamsInit, %INI_File%, % "ComSpecParams",, %A_Space%
	; ComSpecParamsInit := (ComSpecParamsInit == "") ? ("mode con: cols=100 lines=25") : (ComSpecParamsInit)
	ComSpecParams := ""
	Loop, Parse, ComSpecParamsInit, `n, `r
	{
		ComSpecLine := Trim(A_LoopField)
		if (ComSpecLine == "" or RegExMatch(ComSpecLine, "i)^[;#]|\bREM\b")) {
			continue
		}
		ComSpecParams .= A_LoopField . "`n"
	}
	ComSpecParams := Trim(ComSpecParams, "`r`n`t ")
	ComSpecParams := RegExReplace(ComSpecParams, "[\r\n]+", " & ")
	
	if (NoExec) {
		return
	}
}

if (WinRAR_WriteComment) {
	Comments_Text := ReadINISection(INI_File, "Comments")										; ������� ����-����������� �� ������ [Comments],
	Comments_Text := Comments_Text ? Comments_Text : ReadINISection(INI_File, "IncludeList")	; ���� ��� �����������, �� �� ������ [IncludeList]
	Comments_File := TextToFile(Comments_Text, A_Temp . "\" . Prefix . "Backup_Comments_File.txt", "CP1251")
}

Message := ""
. "ArchiveType = " . ArchiveType . "`n"
. "Name = " . Name . "`n"
. "`n"
. "RootDir = " . RootDir . "`n"
. "WorkingDir = " . WorkingDir . "`n"
. "`n"
. "TimeStamp = " . TimeStamp . "`n"
. (CreateNewArchives ? ""
. "CreateNewArchives = " . CreateNewArchives . "`n"
. "NewArchiveNumeration = " . NewArchiveNumeration . "`n"
: "")
. "AddSuffix = " . AddSuffix . "`n"
. (Password ? ""
. "`n"
. "Password = " . Password . "`n"
. "Encrypt = " . Encrypt . "`n"
: "")
. "`n"
. "Archiver = " . Archiver . "`n"
. (Archiver = "7Zip" ? ""
; . "`n"
. "7Zip = " . 7Zip . "`n"
. "7Zip_Params = " . 7Zip_Params . "`n"
: "")
. (Archiver = "WinRAR" ? ""
; . "`n"
. (ArchiveType = "zip" ? "WinRAR_UI = " . WinRAR_UI : "WinRAR = " . WinRAR) . "`n"
. "WinRAR_Params = " . WinRAR_Params . "`n"
. "WinRAR_WriteComment = " . WinRAR_WriteComment . "`n"
. (ArchiveType = "zip" ? "" : "WinRAR_RAR_LockArchive = " . WinRAR_RAR_LockArchive . "`n")
: "")
. "`n"
. "ArchiveName: " . ArchiveName . "`n"
. "Archive: " . Archive . "`n"
. "`n"
. "IncludeThisFile = " . IncludeThisFile . "`n"
. "MakeArchiveReadOnly = " . MakeArchiveReadOnly . "`n"
. (CmdTimeout ? ""
. "CmdTimeout = " . CmdTimeout . "`n"
: "")
. (ComSpecParams != "" ? ""
. "`n"
. "[ComSpecParams]`n" . ComSpecParams . "`n"
: "")
. (Debug ? ""
. "`n"
. "Debug = " . Debug . "`n"
: "")

MsgBox, 1,, %Message%

IfMsgBox, Ok
{
	WinRAR_Command := "", 7Zip_Command := "" ; ����������� ���������� ��� ��������� ������ "if" � �������
	if (WorkingDir && InStr(FileExist(WorkingDir), "D")) {
		SetWorkingDir, %WorkingDir%
	}
	if (Archiver = "WinRAR") {
		gosub, WinRAR_Compress
	}
	if (Archiver = "7Zip") {
		gosub, 7Zip_Compress
	}
}
else {
	ExitApp
}

Exit

; #Include %A_ScriptDir%\..\Includes\FUNC_ExpandEnvironmentVariables.ahk ; �������� ������� ��������� ���������� �����
; /* INCLUDED IN "FUNC_ExpandEnvironmentVariables.ahk"
ExpandEnvironmentStrings(ByRef String)
{ ; ������� ��������� ���������� ����� Windows
	static nSize, Dest, size
	static NULL := ""
	; Find length of dest string:
	nSize := DllCall("ExpandEnvironmentStrings", "Str", string, "Str", NULL, "UInt", 0, "UInt")
	,VarSetCapacity(Dest, size := (nSize * (1 << !!A_IsUnicode)) + !A_IsUnicode) ; allocate dest string
	,DllCall("ExpandEnvironmentStrings", "Str", String, "Str", Dest, "UInt", size, "UInt") ; fill dest string
	return Dest
}

ExpandEnvironmentStringsAHK(String)
{ ; ������� ��������� ���������� ����� AHK
	static Line, Match, Match1, Expanded
	Loop, Parse, String, "\:"
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
{ ; ������� ���������� ��������� ���������� AHK � Windows
	return ExpandEnvironmentStringsAHK(ExpandEnvironmentStrings(String))
}
; */

TextToFile(ByRef Text, ByRef File, ByRef Encoding := "")
{ ; ������� ������ ������ � ����
	If FileExist(File) {
		FileDelete, %File%
	}
	FileAppend, % Text . "`n", %File%, %Encoding%
	return ErrorLevel ? "" : File
}

SplitINIFile(ByRef File, ByRef Section)
{ ; ������� ������ ������ �� ����� � ����������� ���������, ���������� ����-������
	static Ret
	IniRead, Ret, %File%, %Section%
	return Ret
}

ReadINISection(ByRef File, ByRef Section)
{ ; ������� ������ ������ �� ����� � ����������� ���������, ���������� ���������� ������
	static Start, End, Ret
	Start := 0, Ret := ""
	Loop, Read, %File%
	{
		if (Start) {
			if RegExMatch(Trim(A_LoopReadLine), "^\[") { ; ���������� ��������� ������
				return Ret
			}
			Ret .= A_LoopReadLine . "`n" ; ���������� ������
		}
		else {
			Start := Trim(A_LoopReadLine) = "[" . Section . "]" ; ������� ������ ������
		}
	}
	return Ret ; ���������� ��������� ������ �����
}

WinRAR_Compress:
{ ; ������ ��������� ������ ����������� WinRAR (������ ������ � ����� � ���������� �����������)
	Include_List_Text := ParseList(Include_List_Text, RootDir)
	Exclude_List_Text := ParseList(Exclude_List_Text, RootDir)
	;
	Include_List_File := TextToFile(Include_List_Text, A_Temp . "\" . Prefix . "Backup_Include_List_File.txt", "CP1251") ; ������� ����-������ ��������� �� ������ [IncludeList]
	Exclude_List_File := TextToFile(Exclude_List_Text, A_Temp . "\" . Prefix . "Backup_Exclude_List_File.txt", "CP1251") ; ������� ����-������ ���������� �� ������ [ExcludeList]
	;
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\Rar.exe"
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\WinRAR.exe"
	WinRAR_Binary := (ArchiveType = "zip") ? WinRAR_UI : WinRAR
	WinRAR_Archive := Archive ; A_WorkingDir . "\" . Name
	;
	Loop, Files, %WinRAR_Binary%, F
	{ ; �������� ������ ���� � ����� � ����������� ���������
		WinRAR_Binary := A_LoopFileLongPath
	}
	SplitPath, WinRAR_Binary, WinRAR_Binary_FileName, WinRAR_Binary_Dir, WinRAR_Binary_Extension, WinRAR_Binary_NameNoExt, WinRAR_Binary_Drive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������
	WinRAR_Is_CMD := WinRAR_Binary_FileName = "Rar.exe" ? 1 : 0
	ComSpecParams := WinRAR_Is_CMD ? ComSpecParams : "" 
	;
	WinRAR_Error_Log := INI_File_Dir . "\Backup_Errors.txt"	; ���� ������� ������
	WinRAR_Backup_Log := INI_File_Dir . "\Backup_Log.txt"	; ���� ������� ���������
	; �������� ����������� ������� ������
	FileDelete, %WinRAR_Error_Log%
	; �������� ������ WinRAR
	WinRAR_Command := (WinRAR_Is_CMD ? ("cd /d " . q(RootDir) . " & " . (ComSpecParams ? ComSpecParams . " & " : "")) : "")
	. q(WinRAR_Binary)					; ����������� ���� Rar.exe
	/*
	; ��������� ������
	*/
	. (WinRAR_Params ? " " . Trim(WinRAR_Params) : "")
	. " -ilog" . q(WinRAR_Error_Log)	; ���� -ILOG[���] � ���������� ������ ������ � ����
	; . " -logf=" . q(WinRAR_Backup_Log)	; ���� -LOG[������][=���] � �������� ����� � ���� � ��������
	. " -x" . q(Include_List_File)		; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	. " -x" . q(Exclude_List_File)		; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	. " -x" . q(WinRAR_Error_Log)		; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	. " -x" . q(WinRAR_Backup_Log)		; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	; ��������� � ��������� ��� ���������� �� ��������� ������ ����� �������� %INI_File%
	if (not IncludeThisFile) {
		WinRAR_Command .= " -x" . q(INI_File) ; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	}
	; ���������� ������
	if (Password) {
		WinRAR_Command .= (Encrypt
		? " -hp"	; ���� -HP[������] � ��������� ���������� ������ � ���������� ������
		: " -p")	; ���� -P<������> � ������� ������ ���������� ������
		. Password
	}
	WinRAR_Command .= " " . q(WinRAR_Archive)	; �����
	. " -x@" . q(Exclude_List_File)		; ���� -X@<����-������> � �� ������������ �����, ��������� � �����-������
	. " @" . q(Include_List_File)		; @<����-������> � ������������ �����, ��������� � �����-������
	if (IncludeThisFile) {
		gosub, Include_INI_File
	}
	if (not WinRAR_Is_CMD) {
		RunWait, %WinRAR_Command%
	}
	; ������� ���������� ����������� � ������
	if WinRAR_WriteComment {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " c"									; ������� C � �������� ����������� ������
		. " -z" . q(Comments_File)				; ���� -Z<����> � ��������� ����������� ������ �� �����
		. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
		. " " . q(WinRAR_Archive)				; �����
		if (not WinRAR_Is_CMD) {
			RunWait, %WinRAR_Command%
		}
	}
	; ������� ���������� ������ ��� ��������������
	WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
	. q(WinRAR_Binary)
	. " rr5p"								; ������� RR[n ] � �������� ������ ��� �������������� [5%]
	. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
	. " " . q(WinRAR_Archive)				; �����
	if (not WinRAR_Is_CMD) {
		RunWait, %WinRAR_Command%
	}
	; ������� ������������ ������ �� ����������
	if WinRAR_RAR_LockArchive {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " k"									; ������� K � ������������� �����
		. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
		. " " . q(WinRAR_Archive)				; �����
		if (not WinRAR_Is_CMD) {
			RunWait, %WinRAR_Command%
		}
	}
	; ���������� ���� ������ � ����
	if (WinRAR_Is_CMD) {
		WinRAR_Command .= (CmdTimeout != "") ? (" & timeout " . CmdTimeout) : " & pause"
		WinRAR_Command .= " & exit"
		if (Debug ) {
			MsgBox, %WinRAR_Command%
		}
		;
		; ���������� ������� � ��������� ������ Windows
		RunWait, "%ComSpec%" /k %WinRAR_Command%
	}
	;
	if (MakeArchiveReadOnly) {
		FileSetAttrib, +R, %WinRAR_Archive%
	}
	;
	gosub, Clean_UP
	;
	; ����������� ������� ������
	if (WinRAR_Is_CMD and FileExist(WinRAR_Error_Log)) {
		Run, notepad "%WinRAR_Error_Log%"
	}
	return
}

7Zip_Compress:
{
	Include_List_Text := ParseList(Include_List_Text, RootDir)
	Exclude_List_Text := ParseList(Exclude_List_Text, RootDir)
	;
	Include_List_File := TextToFile(Include_List_Text, A_Temp . "\" . Prefix . "Backup_Include_List_File.txt", "UTF-8") ; ������� ����-������ ��������� �� ������ [IncludeList]
	Exclude_List_File := TextToFile(Exclude_List_Text, A_Temp . "\" . Prefix . "Backup_Exclude_List_File.txt", "UTF-8") ; ������� ����-������ ���������� �� ������ [ExcludeList]
	;
	; 7Zip_Binary := A_ProgramFiles . "\7Zip\7z.exe"
	7Zip_Binary := 7Zip
	7Zip_Archive := Archive ; A_WorkingDir . "\" . Name
	;
	Loop, Files, %7Zip_Binary%, F
	{ ; �������� ������ ���� � ����� � ����������� ���������
		7Zip_Binary := A_LoopFileLongPath
	}
	SplitPath, 7Zip_Binary, 7Zip_Binary_FileName, 7Zip_Binary_Dir, 7Zip_Binary_Extension, 7Zip_Binary_NameNoExt, 7Zip_Binary_Drive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������
	7Zip_Is_CMD := 7Zip_Binary_FileName = "7z.exe" ? 1 : 0
	ComSpecParams := 7Zip_Is_CMD ? ComSpecParams : "" 
	;
	7Zip_Error_Log := INI_File_Dir . "\Backup_Errors.txt"	; ���� ������� ������
	7Zip_Backup_Log := INI_File_Dir . "\Backup_Log.txt"	; ���� ������� ���������
	; �������� ����������� ������� ������
	FileDelete, %7Zip_Error_Log%
	; �������� ������ 7Zip
	7Zip_Command := (7Zip_Is_CMD ? ("cd /d " . q(RootDir) . " & " . (ComSpecParams ? ComSpecParams . " & " : "")) : "")
	. q(7Zip_Binary)					; ����������� ���� 7z.exe
	/*
	; ��������� ������
	*/
	. (7Zip_Params ? " " . Trim(7Zip_Params) : "")
	; . " -ilog" . q(7Zip_Error_Log)	; ���� -ILOG[���] � ���������� ������ ������ � ����
	; . " -logf=" . q(7Zip_Backup_Log)	; ���� -LOG[������][=���] � �������� ����� � ���� � ��������
	. " -x!" . q(Include_List_File)		; -x (Exclude filenames) switch
	. " -x!" . q(Exclude_List_File)		; -x (Exclude filenames) switch
	. " -x!" . q(7Zip_Error_Log)		; -x (Exclude filenames) switch
	. " -x!" . q(7Zip_Backup_Log)		; -x (Exclude filenames) switch
	; ��������� � ��������� ��� ���������� �� ��������� ������ ����� �������� %INI_File%
	if (not IncludeThisFile) {
		7Zip_Command .= " -x!" . q(INI_File) ; ���� -X<����> � �� ������������ ��������� ���� ��� �����
	}
	; ���������� ������
	if (Password) {
		7Zip_Command .= (Encrypt
		? " -mhe=on -p"					; Enables or disables archive header encryption.
		: " -p")						; -p (set Password) switch
		. Password
	}
	7Zip_Command .= ""
	. " " . q(7Zip_Archive)	; �����
	. " -x@" . q(Exclude_List_File)		; -x (Exclude filenames) switch
	. " -i@" . q(Include_List_File)		; -i (Include filenames) switch
	if (IncludeThisFile) {
		gosub, Include_INI_File
	}
	if (not 7Zip_Is_CMD) {
		RunWait, %7Zip_Command%
	}
	; ���������� ���� ������ � ����
	if (7Zip_Is_CMD) {
		7Zip_Command .= (CmdTimeout != "") ? (" & timeout " . CmdTimeout) : " & pause"
		7Zip_Command .= " & exit"
		if (Debug ) {
			MsgBox, %7Zip_Command%
		}
		;
		; ���������� ������� � ��������� ������ Windows
		RunWait, "%ComSpec%" /k %7Zip_Command%
		; Run notepad "%Include_List_File%"
	}
	;
	if (MakeArchiveReadOnly) {
		FileSetAttrib, +R, %7Zip_Archive%
	}
	;
	gosub, Clean_UP
	;
	; ����������� ������� ������
	if (7Zip_Is_CMD and FileExist(7Zip_Error_Log)) {
		Run, notepad "%7Zip_Error_Log%"
	}
	return
}

Include_INI_File:
{
	if (IncludeThisFile) {
		INI_Needs_To_Be_Copied := 0, Made_INI_Safe_Copy := 0
		if (RootDir != INI_File_Dir) { ; if (RootDir != A_WorkingDir) {
			INI_Needs_To_Be_Copied := 1
			Target_INI_File := RootDir . "\" . INI_File_FileName
			Temp_INI_File := RootDir . "\" . Prefix . INI_File_FileName
			Exist_Old_INI := FileExist(Target_INI_File)
			Made_INI_Safe_Copy := SafeCopy(INI_File, Target_INI_File, Temp_INI_File)
		}
		7Zip_Command .= " -i!" . q(INI_File_FileName)	; �������� ��������� ���� ��� ����� � ���������
		WinRAR_Command .= " " . q(INI_File_FileName)	; �������� ��������� ���� ��� ����� � ���������
	}
	return
}

Clean_UP:
{
	if (IncludeThisFile && INI_Needs_To_Be_Copied) {
		if (Exist_Old_INI) {
			if (Made_INI_Safe_Copy) {
				FileMove, %Temp_INI_File%, %Target_INI_File%, 1
				if (ErrorLevel) {
					MsgBox, % "Old INI has not been restored."
				}
			}
		}
		else {
			FileDelete, %Target_INI_File%
			if (ErrorLevel) {
				MsgBox, % "Target INI has not been deleted."
			}
		}
	}
	return
}

SafeCopy(ByRef FileToCopyPath, ByRef TargetFilePath, ByRef TmpFilePath)
{
	static MadeSafeCopy, RenamedOldFile, CopiedNewFile
	MadeSafeCopy := 0, RenamedOldFile = 0, CopiedNewFile = 0
	if FileExist(TargetFilePath) {
		FileMove, %TargetFilePath%, %TmpFilePath%, 0
		if (not ErrorLevel) {
			RenamedOldFile := 1
			FileCopy, %FileToCopyPath%, %TargetFilePath%, 0
			if (not ErrorLevel) {
				CopiedNewFile := 1
				MadeSafeCopy := RenamedOldFile * CopiedNewFile
			}
		}
	}
	else {
		FileCopy, %FileToCopyPath%, %TargetFilePath%, 0
		MadeSafeCopy := not ErrorLevel
	}
	return MadeSafeCopy ? TargetFilePath : 0
}

GetAbsolutePath(Path, RootPath := "")
{
	RootPath := RootPath ? RootPath : A_WorkingDir
	StringReplace, Path, Path, % "..\", % "..\", UseErrorLevel
	Loop, %ErrorLevel%
	{
		RootPath := RegExReplace(RootPath, "^(.*)\\.*$", "$1",, 1)
	}
	Path := RegExReplace(Path, "(\.\.\\)+", RootPath . "\")
	return Path
}

ParseList(List, RootPath := "")
{
	static Line, Ret
	Ret := ""
	Loop, Parse, List, `n, `r
	{
		Line := ExpandEnvironmentVariables(A_LoopField)
		if RegExMatch(Line, "\.\.\\") { ; ��������� ������������� ����� ���� "..\..\����"
			Line := GetAbsolutePath(Line, A_WorkingDir)
		}
		if (not RegExMatch(Line, "^\w+:\\")) {
			Line := A_WorkingDir . "\" . Line
		}
		Ret .= Line . "`n"
		; MsgBox, 4,, File number %A_Index% is %Line%.`n`nContinue?
		; IfMsgBox, No, break
	}
	if (RootPath) {
		Ret := StrReplace(Ret, RootPath . "\", "")
	}
	Sort, Ret, U ; �������� ���������� �� ������
	return Ret
}

Escape(String)
{ ; ������� �������������� String � RegExp
	static Escape := ["\", ".", "*", "?", "+", "[", "]", "{", "}", "|", "(", ")", "^", "$"]
	for Index, Char in Escape
	{
		String := StrReplace(String, Char, "\" . Char)
	}
	return String
}

Make_Help_File:
{
	MsgText =
	( LTrim RTrim Join`r`n
	; ��� ����������� ������ �������� ��������� ����� ����� ����������� ������ ����: WIN-1251 | CP1251
	
	[Description]
	; Name = __0003
	;
	; RootDir = %A_WorkingDir%
	; WorkingDir = %A_WorkingDir%
	;
	ArchiveType = 7z
	; ArchiveType = rar
	; ArchiveType = zip
	;
	TimeStamp = yyyy.MM.dd
	; CreateNewArchives = 1
	; NewArchiveNumeration = 0.2d
	; AddSuffix = 1
	;
	; MakeArchiveReadOnly = 1
	; Password = 567576
	; Encrypt = 0
	;
	; 7Zip = `%ProgramFiles`%\7-Zip\7z.exe
	; 7Zip_7Z_Params =%7Zip_7Z_Params%
	; 7Zip_ZIP_Params =%7Zip_ZIP_Params%
	;
	; WinRAR = `%ProgramFiles`%\WinRAR\Rar.exe
	; WinRAR_RAR_Params =%WinRAR_RAR_Params%
	; WinRAR_RAR_LockArchive = 1
	;
	; WinRAR_UI = `%ProgramFiles`%\WinRAR\WinRar.exe
	; WinRAR_ZIP_Params =%WinRAR_ZIP_Params%
	;
	; WinRAR_WriteComment = 1
	;
	; IncludeThisFile = 0
	;
	; CmdTimeout = 2
	; Debug = 1
	
	[IncludeList]
	; ����� ������ ��� �������������
	
	[ExcludeList]
	; ����� ������, ����������� �� ��������� �����
	
	; �������� �����
	*Thumbs.db
	*desktop.ini
	
	; ������
	*.lnk
	
	; ������
	*.rar
	*.7z
	*.zip
	
	; [ComSpecParams]
	color 1f
	mode con: cols=100 lines=25
	; powershell -command "& {$H=get-host; $W=$H.ui.rawui; $B=$W.buffersize; $B.width=100; $B.height=9999; $W.buffersize=$B;}"
	
	; [Comments]
	; �����������, ������� ����� �������� � �������� ������ (������ ��� WinRAR)
	
	)
	PasteToNotepad(MsgText)
	return
}

Get_Recursive_Files_List:
{
	FileList := ""
	
	TargetPath = %Get_File_List_Folder% ;1
	TargetPath := InStr(FileExist(TargetPath), "D") ? (TargetPath . "\*") : TargetPath
	
	Loop, Files, %TargetPath%, FR ; ; Loop Files, 1\*, FR
	{
		File := A_LoopFileLongPath
		SplitPath, File, FileName, FileDir ;, FileExtension, FileNameNoExt, FileDrive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������
		FileList .= File . "|" . FileDir "`n"
	}
	
	if (FileList) {
		MsgBox, 36, Recursive Files List, Sort list?
		IfMsgBox, Yes
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
		MsgBox, 0,, %Clipboard%, 1.5
		*/
		
		PasteToNotepad(Output)
	}
	return
}

q(ByRef Str)
{
	return """" . Str . """"
}

PasteToNotepad(ByRef MsgText)
{
	Run, % "notepad.exe",,, Notepad_PID
	WinWait, ahk_pid %Notepad_PID%,, 3
	IfWinExist, ahk_pid %Notepad_PID%
	{
		WinActivate, ahk_pid %Notepad_PID%
		ControlSetText, % "Edit1", %MsgText%, ahk_pid %Notepad_PID%
	}
}
