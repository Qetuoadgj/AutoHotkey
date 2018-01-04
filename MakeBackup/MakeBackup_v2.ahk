#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn All ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance Force

; Your code here...

if (not A_Args[1] or not FileExist(A_Args[1])) { ; ������ ������� ��� ����������
	FileSelectFile INI_File,, %A_WorkingDir% ; ��������� ���� ��� ������ �����
	if (not INI_File) { ; ���� �� ������
		ExitApp
	}
}
else { ; ������ ������� � ��������� ����������
	INI_File := A_Args[1] ; 1� �������� - ���� � ����������� ���������
}

Loop Files, % INI_File, F
{ ; �������� ������ ���� � ������ ����������� ���������
	INI_File := A_LoopFileLongPath
}
SplitPath, INI_File, INI_File_FileName, INI_File_Dir, INI_File_Extension, INI_File_NameNoExt, INI_File_Drive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������

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

RootDir := ExpandEnvironmentVariables(RootDir)
WinRAR := ExpandEnvironmentVariables(WinRAR)

IniRead TimeStamp, % INI_File, % "Description", % "TimeStamp", % "yyyy.MM.dd"
FormatTime Date,, % TimeStamp ; ��������� ������� ���� (2015.11.29)
Name .= (Date ? " (" . Date . ")" : "")
; Name .= ".rar"

ArchiveType := "rar"
ArchiveName := Name
Archive := INI_File_Dir . "\" . ArchiveName ; ������ ����������� ���� � ������

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

Archive := INI_File_Dir . "\" . ArchiveName ; ��������� ���� � ������
Archive .= "." . ArchiveType

Prefix := "DHFWEF90WE89_" ; ������� ��� ��� ������-������� � �����-�����������
Include_List_File := TextToFile(SplitINIFile(INI_File, "IncludeList"), A_Temp . "\" . Prefix . "Backup_Include_List_File.txt", "CP1251") ; ������� ����-������ ��������� �� ������ [IncludeList]
Exclude_List_File := TextToFile(SplitINIFile(INI_File, "ExcludeList"), A_Temp . "\" . Prefix . "Backup_Exclude_List_File.txt", "CP1251") ; ������� ����-������ ���������� �� ������ [ExcludeList]
if (WriteComment) {
	Comments_Text := ReadINISection(INI_File, "Comments")										; ������� ����-����������� �� ������ [Comments],
	Comments_Text := Comments_Text ? Comments_Text : ReadINISection(INI_File, "IncludeList")	; ���� ��� �����������, �� �� ������ [IncludeList]
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

MsgBox, 1,, % Message

IfMsgBox Ok
{
	gosub WinRAR_Compress
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
{ ; ������� ���������� ��������� ���������� AHK � Windows
  return ExpandEnvironmentStringsAHK(ExpandEnvironmentStrings(String))
}
; */

TextToFile(ByRef Text, ByRef File, ByRef Encoding := "")
{ ; ������� ������ ������ � ����
	If FileExist(File) {
		FileDelete, % File
	}
	FileAppend, % Text . "`n", % File, % Encoding
	return ErrorLevel ? "" : File
}

SplitINIFile(ByRef File, ByRef Section)
{ ; ������� ������ ������ �� ����� � ����������� ���������, ���������� ����-������
	static Ret
	IniRead Ret, % File, % Section
	return Ret
}

ReadINISection(ByRef File, ByRef Section)
{ ; ������� ������ ������ �� ����� � ����������� ���������, ���������� ���������� ������
	static Start, End, Ret
	Start := 0, Ret := ""
	Loop Read, % File
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
	WinRAR_Binary := WinRAR
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\Rar.exe"
	; WinRAR_Binary := A_ProgramFiles . "\WinRAR\WinRAR.exe"
	WinRAR_Archive := Archive ; A_WorkingDir . "\" . Name
	;
	Loop Files, % WinRAR_Binary, F
	{ ; �������� ������ ���� � ������ ����������� ���������
		WinRAR_Binary := A_LoopFileLongPath
	}
	SplitPath, WinRAR_Binary, WinRAR_Binary_FileName, WinRAR_Binary_Dir, WinRAR_Binary_Extension, WinRAR_Binary_NameNoExt, WinRAR_Binary_Drive ; �������� ���� � �����, � ������� ��������� ���� � ����������� ���������
	WinRAR_Is_CMD := WinRAR_Binary_FileName = "Rar.exe" ? 1 : 0
	;
	WinRAR_Error_Log := A_WorkingDir . "\Backup_Errors.txt"	; ���� ������� ������
	WinRAR_Backup_Log := A_WorkingDir . "\Backup_Log.txt"	; ���� ������� ���������
	; �������� ����������� ������� ������
	FileDelete % WinRAR_Error_Log 
	; �������� ������ WinRAR
	WinRAR_Command := (WinRAR_Is_CMD ? ("cd /d " . q(RootDir) . " & ") : "")
	. q(WinRAR_Binary)					; ����������� ���� Rar.exe
	. " a"								; ������� A � �������� � �����
	. " -u"								; ���� -U � �������� �����
	. " -as"							; ���� -AS � ���������������� ���������� ������
	. " -s"								; ���� -S � ������� ����������� �����
	; . " -r"								; ���� -R � �������� � ��������� ��������� �����
	. " -r0"							; ���� -R0 � ������������ ��������� ����� � ������������ � ��������
	. " -m5"							; ���� -M<n> � ����� ������ [0=min...5=max]
	. " -ma5"							; ���� -MA[4|5] � ������ ������� �������������
	. " -md4m"							; ���� -MD<n>[k,m,g] � ������ �������
	. " -mc63:128t+"					; ������ ������
	. " -mc4a+"							; ������ �����������, ������-������
	. " -mcc+"							; ������ ����������� ������ true color (RGB) 
	; . " -rr3p"							; ���� -RR[n] � �������� ������ ��� �������������� [3%]
	. " -htb"							; ���� -HT[B|C] � ������� ��� ���� [BLAKE2|CRC32] ��� ����������� ����
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
	if (not WinRAR_Is_CMD) {
		RunWait %WinRAR_Command%
	}
	; ������� ���������� ����������� � ������
	if WriteComment {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " c"									; ������� C � �������� ����������� ������
		. " -z" . q(Comments_File)				; ���� -Z<����> � ��������� ����������� ������ �� �����
		. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
		. " " . q(WinRAR_Archive)				; �����
		if (not WinRAR_Is_CMD) {
			RunWait %WinRAR_Command%
		}
	}
	; ������� ���������� ������ ��� ��������������
	WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
	. q(WinRAR_Binary)
	. " rr5p"								; ������� RR[n ] � �������� ������ ��� �������������� [5%]
	. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
	. " " . q(WinRAR_Archive)				; �����
	if (not WinRAR_Is_CMD) {
		RunWait %WinRAR_Command%
	}
	; ������� ������������ ������ �� ����������
	if LockArchive {
		WinRAR_Command := (WinRAR_Is_CMD ? (WinRAR_Command . " & ") : "")
		. q(WinRAR_Binary)
		. " k"									; ������� K � ������������� �����
		. (Password ? " -p" . Password : "")	; ���� -P<������> � ������� ������ ���������� ������
		. " " . q(WinRAR_Archive)				; �����
		if (not WinRAR_Is_CMD) {
			RunWait %WinRAR_Command%
		}
	}
	; ���������� ���� ������ � ����
	if (WinRAR_Is_CMD) {
		WinRAR_Command .= " & pause & exit"
		; MsgBox % WinRAR_Command
		;
		; ���������� ������� � ���������� ������ Windows
		RunWait "%ComSpec%" /k %WinRAR_Command%
	}
	;
	; ����������� ������� ������
	if (WinRAR_Is_CMD and FileExist(WinRAR_Error_Log)) {
		Run notepad "%WinRAR_Error_Log%"
	}
	return
}

q(ByRef Str)
{
	return """" . Str . """"
}