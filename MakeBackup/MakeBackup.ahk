; https://github.com/Qetuoadgj/AutoHotkey
; https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/%D0%A0%D0%95%D0%97%D0%95%D0%A0%D0%92%D0%9D%D0%9E%D0%95%20%D0%9A%D0%9E%D0%9F%D0%98%D0%A0%D0%9E%D0%92%D0%90%D0%9D%D0%98%D0%95.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

; run,%comspec% /k ipconfig /all & pause & exit
; run,%comspec% /k Command & pause & exit

; �������� ������� "�����-���������"
If (not %0%) {
	MsgBox,3,,������� ������ ����?`n%A_ScriptDir%\������ BACKUP.ini,5  ; 5-second timeout.
	IfMsgBox,No
		ExitApp  ; User pressed the "No" button.

	IfMsgBox,Yes
	{
		EmptyFile = %A_ScriptDir%\������ BACKUP.ini
		Encoding = CP1251

		IfExist,%EmptyFile%
			FileDelete,%EmptyFile%

		MsgText =
		( LTrim RTrim Join`r`n
			; ��� ����������� ������ �������� ��������� ����� ����� ����������� ������ ����: WIN-1251 | CP1251

			[Description]
			; Name = ;��� ����� (� ��������)
			; Password = ;������ (��� �������)
			; RootDir = "`%AppData`%" ;�������� ����� (� ��������)
			; SevenZip = "`%ProgramFiles`%\7-Zip\7z.exe" ;��������� 7-Zip (� ��������)
			; WinRAR = "`%ProgramFiles`%\WinRAR\Rar.exe" ;��������� WinRAR (� ��������)
			ArchiveType = zip,7z,rar ;���� ����������� ������� (zip,7z,rar) (��� �������)
			; TimeStamp = yyyy.MM.dd ;������ ���������� ������ ������ (��� �������)
			; CreateNewArchives = false ;�������� ����� ������� ������ ���������� ������������ ����� (true,false) (��� �������)
			; NewArchiveNumeration = 0.2d ;������ ��������� ����� ������� (��� �������)
			; LockArchive = true ;��������� ���������� ��������� ������ (true,false) (��� �������)
			; IncludeThisFile = false ;�� �������� ���� ���� ���������� ����������� � ����� ��������� ����� (true,false) (��� �������)
			; WriteComment = true ;������� � ������ �����������, ��������� �� ������ [IncludeList].
			; AddSuffix = true ; �������� ���������� ����

			[Zip_Options]
			Method = Deflate ; Copy,Deflate,Deflate64,BZip2,LZMA,PPMd
			Compression = 5  ; 0 | 1 | 3 | 5 | 7 | 9

			[7z_Options]
			Method = LZMA2:27 ; LZMA,LZMA2,PPMd,BZip2,Deflate,Delta,BCJ,BCJ2,Copy
			Compression = 9 ; 0 | 1 | 3 | 5 | 7 | 9

			[Rar_Options]
			Compression = 5 ; 0 | 1 | 3 | 5

			[IncludeList]
			; ���������� ����� (��� �������)

			[ExcludeList]
			; ����������� ����� (��� �������)
			*Thumbs.db

		)
		FileAppend,%MsgText%,%EmptyFile%,%Encoding%
	}

	IfMsgBox,Timeout
		ExitApp ; i.e. Assume "No" if it timed out.
	; Otherwise,continue:
	ExitApp
}

; ���� ��� ���� ���������� / ������ �������� � ���� ����������
Loop,%0%
{
	GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
	Loop,%GivenPath%,1
	{
		FullPath := A_LoopFileLongPath
	}
}

; ����������� ������� ���� �����-���������
SourceFile := FullPath

; ����������� ����� �����-���������
SplitPath,SourceFile,SourceFileShort,SourceFileDir,SourceFileExtension,SourceFileName,SourceFileDrive

; ���������� �������� �������� ���������
SetWorkingDir,%SourceFileDir%

; ��������� ���������� �� �����-���������
IniRead,Name,%SourceFile%,Description,Name,%SourceFileName% ; GetValue(SourceFile,"^Name[\s+]?=[\s+]?(.*)") ; ���
Name := RegExReplace(Name,"[ \t]+;.*$","")

If (Name == "") {
	MsgBox,������:`n����������� �������� "Name"
	ExitApp
}

IniRead,Password,%SourceFile%,Description,Password,%A_Space% ; GetValue(SourceFile,"^Password[\s+]?=[\s+]?(.*)") ; ������
Password := RegExReplace(Password,"[ \t]+;.*$","")

IniRead,RootDir,%SourceFile%,Description,RootDir,%A_Space%      ; GetValue(SourceFile,"^RootDir[\s+]?=[\s+]?(.*)") ; �������� �����
RootDir := RegExReplace(RootDir,"[ \t]+;.*$","")
RootDir := ParseEnvironmentVariables(RootDir)                   ; ��������� ���������� �����
RootDir := FileGetLongPath(RootDir)                             ; ��������� �������� ����
global RootDir := RootDir                                       ; ���������� ���������� ���������� ��� ���������� �� ���� ��������

IniRead,TimeStamp,%SourceFile%,Description,TimeStamp,yyyy.MM.dd ; ��������� �����
TimeStamp := RegExReplace(TimeStamp,"[ \t]+;.*$","")

IniRead,CreateNewArchives,%SourceFile%,Description,CreateNewArchives,%A_Space% ; ��������� ����� ����� ������ �������������
CreateNewArchives := RegExReplace(CreateNewArchives,"[ \t]+;.*$","")
CreateNewArchives := StrToBool(CreateNewArchives) ; to boolean
CreateNewArchivesStr := BoolToStr(CreateNewArchives) ; to string

IniRead,NewArchiveNumeration,%SourceFile%,Description,NewArchiveNumeration,0.2d ; ��������� �������
NewArchiveNumeration := RegExReplace(NewArchiveNumeration,"[ \t]+;.*$","")

IniRead,LockArchive,%SourceFile%,Description,LockArchive,%A_Space% ; ��������� ��������� ������
LockArchive := RegExReplace(LockArchive,"[ \t]+;.*$","")
LockArchive := StrToBool(LockArchive) ; to boolean
LockArchiveStr := BoolToStr(LockArchive) ; to string

IniRead,IncludeThisFile,%SourceFile%,Description,IncludeThisFile,true ; �������� � ����� ���� ������� ���������� �����������
IncludeThisFile := RegExReplace(IncludeThisFile,"[ \t]+;.*$","")
IncludeThisFile := StrToBool(IncludeThisFile) ; to boolean
IncludeThisFileStr := BoolToStr(IncludeThisFile) ; to string

IniRead,WriteComment,%SourceFile%,Description,WriteComment,%A_Space% ; �������� � ������ �����������
WriteComment := RegExReplace(WriteComment,"[ \t]+;.*$","")
WriteComment := StrToBool(WriteComment) ; to boolean
WriteCommentStr := BoolToStr(WriteComment) ; to string

IniRead,AddSuffix,%SourceFile%,Description,AddSuffix,%A_Space% ; �������� ���������� ����
AddSuffix := RegExReplace(AddSuffix,"[ \t]+;.*$","")
AddSuffix := StrToBool(AddSuffix) ; to boolean
AddSuffixStr := BoolToStr(AddSuffix) ; to string

IniRead,ZipMethod,%SourceFile%,Zip_Options,Method,Deflate
ZipMethod := RegExReplace(ZipMethod,"[ \t]+;.*$","")
IniRead,ZipCompression,%SourceFile%,Zip_Options,Compression,9
ZipCompression := RegExReplace(ZipCompression,"[ \t]+;.*$","")

IniRead,7zMethod,%SourceFile%,7z_Options,Method,LZMA2:27
7zMethod := RegExReplace(7zMethod,"[ \t]+;.*$","")
IniRead,7zCompression,%SourceFile%,7z_Options,Compression,9
7zCompression := RegExReplace(7zCompression,"[ \t]+;.*$","")

; IniRead,RarMethod,%SourceFile%,Rar_Options,Method,Deflate
; RarMethod := RegExReplace(RarMethod,"[ \t]+;.*$","")
IniRead,RarCompression,%SourceFile%,Rar_Options,Compression,5
RarCompression := RegExReplace(RarCompression,"[ \t]+;.*$","")

; ����������� ����� �������� ������
If (RegExMatch(TimeStamp,"^false$")) {
	Name = %Name%
} else {
	FormatTime,Date,,%TimeStamp% ; ��������� ������� ���� (2015.11.29)
	Name = %Name% (%Date%)
}

IniRead,SevenZip,%SourceFile%,Description,SevenZip,%ProgramFiles%\7-Zip\7z.exe  ; GetValue(SourceFile,"^SevenZip[\s+]?=[\s+]?(.*)") ; 7-Zip
SevenZip := RegExReplace(SevenZip,"[ \t]+;.*$","")
SevenZip := ParseEnvironmentVariables(SevenZip)                                 ; ��������� ���������� �����
SevenZip := FileGetLongPath(SevenZip)                                           ; ��������� �������� ����

IniRead,WinRAR,%SourceFile%,Description,WinRAR,%ProgramFiles%\WinRAR\Rar.exe    ; GetValue(SourceFile,"^WinRAR[\s+]?=[\s+]?(.*)") ; WinRAR
WinRAR := RegExReplace(WinRAR,"[ \t]+;.*$","")
WinRAR := ParseEnvironmentVariables(WinRAR)                                     ; ��������� ���������� �����
WinRAR := FileGetLongPath(WinRAR)                                               ; ��������� �������� ����

IniRead,ArchiveType,%SourceFile%,Description,ArchiveType,zip                    ; GetValue(SourceFile,"^ArchiveType[\s+]?=[\s+]?(.*)") ; ���� �������
ArchiveType := RegExReplace(ArchiveType,"[ \t]+;.*$","")
; ArchiveType := Trim(ArchiveType," " . "`t" . """")

If (!FileExist(SevenZip) && InStr(ArchiveType,"zip")) {
	MsgBox,0,Error,Not found:`n%SevenZip%,1.5
}
If (!FileExist(SevenZip) && InStr(ArchiveType,"7z")) {
	MsgBox,0,Error,Not found:`n%SevenZip%,1.5
}
If (!FileExist(WinRAR) && InStr(ArchiveType,"rar")) {
	MsgBox,0,Error,Not found:`n%WinRAR%,1.5
}
If (ArchiveType = "") {
	MsgBox,0,Error,ArchiveType was not set!,1.5
}

; ����������� ������-������� ��� ��������� ������������
IncludeList=%A_Temp%\IncludeList.txt ;%SourceFileDir%\IncludeList.txt
ExcludeList=%A_Temp%\ExcludeList.txt ;%SourceFileDir%\ExcludeList.txt
CommentFile=%A_Temp%\CommentFile.txt

ArchiveName := Name

If (CreateNewArchives) {
	ArchiveCount := 0
	Loop,Files,%Archive%*%ArchiveType%,F
	{
		MatchString := "^" . ConvertToString(Name) . " - (\d+)( .*?)?" . ConvertToString("." . ArchiveType) . "$"
		If (RegExMatch(A_LoopFileName,MatchString,Match,1)) {
			ArchiveCount := Match1 + 1
		}
	}
	ArchiveCount := Format("{1:" . NewArchiveNumeration . "}",ArchiveCount) ; Format("{1:0.3d}",ArchiveCount)
	ArchiveName := Name . " - " . ArchiveCount
}

If (AddSuffix) {
	; InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default]
	InputBox, ArchiveSuffix, %ArchiveName%.%ArchiveType%,,,, 100
	If ( StrLen(ArchiveSuffix) > 0 ) {
		ArchiveName .= " [" ArchiveSuffix "]"
	}
}

Archive=%SourceFileDir%\%ArchiveName%

/*
DebugMsgText =
( LTrim RTrim Join`r`n
	[Description]
	Name = %ArchiveName%
	Password = %Password%
	RootDir = %RootDir%
	SevenZip = %SevenZip%
	WinRAR = %WinRAR%
	ArchiveType = %ArchiveType%
	TimeStamp = %TimeStamp%
	CreateNewArchives = %CreateNewArchivesStr%
	NewArchiveNumeration = %NewArchiveNumeration%
	LockArchive = %LockArchiveStr%
	IncludeThisFile = %IncludeThisFileStr%
	WriteComment = %WriteCommentStr%
	AddSuffix = %AddSuffixStr%
)
*/

DebugMsgText := "[Description]"
DebugMsgText := DebugMsgText . "`r`n" . "Name = " . ArchiveName
If (Password) {
 DebugMsgText := DebugMsgText . "`r`n" . "Password = " . Password
}
If (RootDir) {
	DebugMsgText := DebugMsgText . "`r`n" . "RootDir = " . RootDir
}
If (InStr(ArchiveType,"zip") or InStr(ArchiveType,"7z")) {
 DebugMsgText := DebugMsgText . "`r`n" . "SevenZip = " . SevenZip
}
If InStr(ArchiveType,"rar") {
		DebugMsgText := DebugMsgText . "`r`n" . "WinRAR = " . WinRAR
}
DebugMsgText := DebugMsgText . "`r`n" . "ArchiveType = " . ArchiveType
DebugMsgText := DebugMsgText . "`r`n" . "TimeStamp = " . TimeStamp
DebugMsgText := DebugMsgText . "`r`n" . "CreateNewArchives = " . CreateNewArchivesStr
DebugMsgText := DebugMsgText . "`r`n" . "NewArchiveNumeration = " . NewArchiveNumeration
If (InStr(ArchiveType,"rar")) {
		DebugMsgText := DebugMsgText . "`r`n" . "LockArchive = " . LockArchiveStr
}
DebugMsgText := DebugMsgText . "`r`n" . "IncludeThisFile = " . IncludeThisFileStr
DebugMsgText := DebugMsgText . "`r`n" . "WriteComment = " . WriteCommentStr
DebugMsgText := DebugMsgText . "`r`n" . "AddSuffix = " . AddSuffixStr

If InStr(ArchiveType,"zip") {
		DebugMsgText := DebugMsgText . "`r`n" . "`r`n[Zip_Options]"
		DebugMsgText := DebugMsgText . "`r`n" . "Method = " . ZipMethod
		DebugMsgText := DebugMsgText . "`r`n" . "Compression = " . ZipCompression
}
If InStr(ArchiveType,"7z") {
		DebugMsgText := DebugMsgText . "`r`n" . "`r`n[7z_Options]"
		DebugMsgText := DebugMsgText . "`r`n" . "Method = " . 7zMethod
		DebugMsgText := DebugMsgText . "`r`n" . "Compression = " . 7zCompression
}
If InStr(ArchiveType,"rar") {
		DebugMsgText := DebugMsgText . "`r`n" . "`r`n[Rar_Options]"
		DebugMsgText := DebugMsgText . "`r`n" . "Compression = " . RarCompression
}


MsgBox,1,,%DebugMsgText%
IfMsgBox,Cancel
	ExitApp  ; User pressed the "No" button.

; �������� zip ������ � ������� 7-Zip
If (FileExist(SevenZip) && InStr(ArchiveType,"zip")) {
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ (��������� UTF-8)
	SplitTextFile(SourceFile,IncludeList,"[IncludeList]","[ExcludeList]","UTF-8")
	SplitTextFile(SourceFile,ExcludeList,"[ExcludeList]","","UTF-8")

	Type:="zip"                     ; ��� ������
	; ���� ������ �����
	If (Password != "") {
		Password=-p%Password%         ; ������ �� �����
	}
	Compression=-mm=%ZipMethod% -mx%ZipCompression% ; �������� ������
	Include=-i@"%IncludeList%"      ; ����-������ ���������
	Exclude=-x@"%ExcludeList%"      ; ����-������ ����������
	Synchronize:="p0q0r2x1y2z1w2"   ; ���� �������������
	Incrimental:="p1q1r0x1y2z1w2"   ; ���� �������� ������������� ������

	; ����������� ������� �� ���������� ���������
		If (IncludeThisFile) {
		Command="%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%" -spf2 -w"%A_Temp%"
		} Else {
		Command="%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% "%Archive%.%Type%" %Exclude% %Include% -spf2 -w"%A_Temp%"
		}

	; �������� ������� ��������� %RootDir% (����������� ��������� �������� ���������)
	; ���� �������� ������� ��������� �� �����:
	If (RootDir == "") {
		; RunWait,%Command% ; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%SourceFileDir%" & %Command% & pause & exit

	; ���� �������� ������� ��������� �����:
	} else {
		SetWorkingDir,%RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
				SourceCopy := RootDir . "\" . SourceFileShort
				NoDelete := FileExist(SourceCopy)

		; ����������� �����-��������� � ��������� ������� ���������
		If (SourceCopy!=SourceFile and IncludeThisFile) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy,%SourceFile%,%SourceCopy%,1 ; ����������� / ���������� ����� � �������� ������� ���������
		}

		; RunWait,%Command% ; ���������� ������� ���������
		; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%RootDir%" & %Command% & pause & exit

		If (SourceCopy!=SourceFile and IncludeThisFile and not NoDelete) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete,%SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir,%SourceFileDir% ; �������������� �������� �������� ���������
	}

	; �������� ������-�������
	FileDelete,%IncludeList%
	FileDelete,%ExcludeList%
}

; �������� ������ � ������� 7-Zip
If (FileExist(SevenZip) && InStr(ArchiveType,"7z")) {
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ (��������� UTF-8)
	SplitTextFile(SourceFile,IncludeList,"[IncludeList]","[ExcludeList]","UTF-8")
	SplitTextFile(SourceFile,ExcludeList,"[ExcludeList]","","UTF-8")

	Type:="7z"                      ; ��� ������
	; ���� ������ �����
	If (Password != "") {
		Password=-p%Password%         ; ������ �� �����
	}
	Compression=-mm=%7zMethod% -mx%7zCompression%   ; �������� ������
	Include=-i@"%IncludeList%"      ; ����-������ ���������
	Exclude=-x@"%ExcludeList%"      ; ����-������ ����������
	Synchronize:="p0q0r2x1y2z1w2"   ; ���� �������������
	Incrimental:="p1q1r0x1y2z1w2"   ; ���� �������� ������������� ������

	; ����������� ������� �� ���������� ���������
	If (IncludeThisFile) {
		Command="%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%" -spf2 -w"%A_Temp%"
	} Else {
		Command="%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% "%Archive%.%Type%" %Exclude% %Include% -spf2 -w"%A_Temp%"
	}

	; �������� ������� ��������� %RootDir% (����������� ��������� �������� ���������)
	; ���� �������� ������� ��������� �� �����:
	If (RootDir == "") {
		; RunWait,%Command% ; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%SourceFileDir%" & %Command% & pause & exit

	; ���� �������� ������� ��������� �����:
	} else {
		SetWorkingDir,%RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
				SourceCopy := RootDir . "\" . SourceFileShort
				NoDelete := FileExist(SourceCopy)

		; ����������� �����-��������� � ��������� ������� ���������
		If (SourceCopy!=SourceFile and IncludeThisFile) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy,%SourceFile%,%SourceCopy%,1 ; ����������� / ���������� ����� � �������� ������� ���������
		}

		; RunWait,%Command% ; ���������� ������� ���������
		; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%RootDir%" & %Command% & pause & exit

		If (SourceCopy!=SourceFile and IncludeThisFile and not NoDelete) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete,%SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir,%SourceFileDir% ; �������������� �������� �������� ���������
	}

	; �������� ������-�������
	FileDelete,%IncludeList%
	FileDelete,%ExcludeList%
}

; �������� ������ � ������� WinRAR
If (FileExist(WinRAR) && InStr(ArchiveType,"rar")) {
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ (��������� Windows-1251)
	SplitTextFile(SourceFile,IncludeList,"[IncludeList]","[ExcludeList]","CP1251")
	SplitTextFile(SourceFile,ExcludeList,"[ExcludeList]","","CP1251")
	
	If ( WriteComment ) {
		SplitTextFile(SourceFile,CommentFile,"[IncludeList]","[ExcludeList]","CP1251",false,false)
	}

	Type:="rar"                     ; ��� ������
	; ���� ������ �����
	If (Password != "") {
		Password=-p%Password%         ; ������ �� �����
	}
	Compression=-m%RarCompression% -rr5p        ; �������� ������
	Include=@"%IncludeList%"        ; ����-������ ���������
	Exclude=-x@"%ExcludeList%"      ; ����-������ ����������
	Synchronize:=" -as"             ; ���� �������������
	Incrimental:="p1q1r0x1y2z1w2"   ; ���� �������� ������������� ������

	; ����������� ������� �� ���������� ���������
	If (IncludeThisFile) {
		Command="%WinRAR%" u -u%Synchronize% %Compression% -r0 %Password% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%"
	} Else {
		Command="%WinRAR%" u -u%Synchronize% %Compression% -r0 %Password% "%Archive%.%Type%" %Exclude% %Include%
	}
	If (WriteComment) {
		Command = %Command% -z"%CommentFile%"
	}
	If (LockArchive) {
		Command = %Command% & "%WinRAR%" k %Compression% "%Archive%.%Type%"
	}

	; �������� ������� ��������� %RootDir% (����������� ��������� �������� ���������)
	; ���� �������� ������� ��������� �� �����:
	If (RootDir == "") {
		; RunWait,%Command% ; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%SourceFileDir%" & %Command% & pause & exit

	; ���� �������� ������� ��������� �����:
	} else {
		SetWorkingDir,%RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
		SourceCopy := RootDir . "\" . SourceFileShort
		NoDelete := FileExist(SourceCopy)

		; ����������� �����-��������� � ��������� ������� ���������
		If (SourceCopy!=SourceFile and IncludeThisFile) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy,%SourceFile%,%SourceCopy%,1 ; ����������� / ���������� ����� � �������� ������� ���������
		}

		; RunWait,%Command% ; ���������� ������� ���������
		; ���������� ������� ��������� � ��������� ������
		RunWait,%comspec% /k cd /d "%RootDir%" & %Command% & pause & exit

		If (SourceCopy!=SourceFile and IncludeThisFile and not NoDelete) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete,%SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir,%SourceFileDir% ; �������������� �������� �������� ���������
	}

	; �������� ������-�������
	FileDelete,%IncludeList%
	FileDelete,%ExcludeList%
	If ( WriteComment ) {
		FileDelete,%CommentFile%
	}
}

/*
; ===================================================================================
;                 ������� ��������� �������� �� ����� �����-���������
; ===================================================================================
GetValue(SourceFile,SearchPattern)
{
	Loop,Read,%SourceFile%
	{
		If RegExMatch(A_LoopReadLine,SearchPattern)
		{
			Value := RegExReplace(A_LoopReadLine,SearchPattern,"$1",,1)
			Return Value
		}
	}
}
*/

; ===================================================================================
;                 ������� ���������� �����-��������� �� �����-������
; ===================================================================================
SplitTextFile( ByRef SourceFile, ByRef OutputFile, ByRef StartString, ByRef EndString := "", ByRef Encoding := "", ByRef SkipComments := true, ByRef TrimLines := true )
{
	If (Encoding == "") { ; if no Encoding defined
		Encoding := A_FileEncoding
	}

	FileDelete,%OutputFile%
	RootDir = %RootDir%

	Loop,Read,%SourceFile%
	{
		IfInString,A_LoopReadLine,%StartString%
		StartLine:=A_Index

		If (EndString == "") { ; if no EndString defined
			EndLine:=A_Index + 1
		} else {
			IfInString,A_LoopReadLine,%EndString%
			EndLine:=A_Index
		}
	}

	Loop,Read,%SourceFile%
	{
		If ( SkipComments ) {
			If A_LoopReadLine = ; if looped line is empty
				Continue ; skip the current Loop instance

			If RegExMatch(A_LoopReadLine,"^(\s+)?;") ; if looped line is commented
				Continue ; skip the current Loop instance

			If RegExMatch(A_LoopReadLine,"^(\s+)?//") ; if looped line is commented
				Continue ; skip the current Loop instance
		}

		CurrentLine:=A_Index
		If (CurrentLine > StartLine) && (CurrentLine < EndLine)
		{
			; CurrentString := RegExReplace(A_LoopReadLine,"^[ \t]+","")
			CurrentString := TrimLines ? Trim( A_LoopReadLine ) : A_LoopReadLine ; �������� ��������� � ���������� ��������
			CurrentString := ParseEnvironmentVariables(CurrentString)
			If (RootDir != "") {
				RootDirSlash:=RootDir "`\"
				CurrentString := StrReplace(CurrentString,RootDirSlash,"") ; �������� ��������� �������� �� ����� �����-������
			}
			FileAppend,%CurrentString%`n,%OutputFile%,%Encoding%
		}
	}
	
	global IncludeThisFile
	If (!IncludeThisFile and StartString == "[ExcludeList]") {
		global SourceFileName
		global SourceFileExtension
		FileAppend,%SourceFileName%.%SourceFileExtension%`n,%OutputFile%,%Encoding%
		;~ MsgBox, %SourceFile%
	}
}

; ===================================================================================
;                 ������� �������� �������� BOOOLEAN � STRING
; ===================================================================================
BoolToStr(v) {
		If (v and (v == "true" or v = 1)) {
			Return,"true"
		} else {
				Return,"false"
		}
}
StrToBool(v) {
		v := Trim(v)
	b := (v == "true" or v = 1)
	Return,b
}
