; https://github.com/Qetuoadgj/AutoHotkey
; https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/%D0%A0%D0%95%D0%97%D0%95%D0%A0%D0%92%D0%9D%D0%9E%D0%95%20%D0%9A%D0%9E%D0%9F%D0%98%D0%A0%D0%9E%D0%92%D0%90%D0%9D%D0%98%D0%95.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

; Run, %comspec% /k ipconfig /all & pause & exit
; Run, %comspec% /k Command & pause & exit

; �������� ������� "�����-���������"
If ( not %0% )
{
	MsgBox, 3,, ������� ������ ����?`n%A_ScriptDir%\������ BACKUP.ini, 5  ; 5-second timeout.
	IfMsgBox, No
	{
		ExitApp  ; User pressed the "No" button.
	}
	IfMsgBox, Yes
	{
		EmptyFile := A_ScriptDir "\������ BACKUP.ini"
		Encoding := "CP1251"
		
		IfExist, %EmptyFile%
		{
			FileDelete, %EmptyFile%
		}
		
		MsgText =
		( LTrim RTrim Join`r`n
		# -*- coding: cp1251 -*-
		; ��� ����������� ������ �������� ��������� ����� ����� ����������� ������ ����: WIN-1251 | CP1251
		
		[Description]
		; Name = ;��� ����� ( � �������� )
		; Password = ;������ ( ��� ������� )
		; RootDir = "`%AppData`%" ;�������� ����� ( � �������� )
		; SevenZip = "`%ProgramFiles`%\7-Zip\7z.exe" ;��������� 7-Zip ( � �������� )
		; WinRAR = "`%ProgramFiles`%\WinRAR\Rar.exe" ;��������� WinRAR ( � �������� )
		ArchiveType = zip, 7z, rar ;���� ����������� ������� ( zip, 7z, rar ) ( ��� ������� )
		; TimeStamp = yyyy.MM.dd ;������ ���������� ������ ������ ( ��� ������� )
		; CreateNewArchives = false ;�������� ����� ������� ������ ���������� ������������ ����� ( true, false ) ( ��� ������� )
		; NewArchiveNumeration = 0.2d ;������ ��������� ����� ������� ( ��� ������� )
		; LockArchive = true ;��������� ���������� ��������� ������ ( true, false ) ( ��� ������� )
		; IncludeThisFile = false ;�� �������� ���� ���� ���������� ����������� � ����� ��������� ����� ( true, false ) ( ��� ������� )
		; WriteComment = true ;������� � ������ �����������, ��������� �� ������ [IncludeList].
		; AddSuffix = true ; �������� ���������� ����
		
		[Zip_Options]
		Method = Deflate ; Copy, Deflate, Deflate64, BZip2, LZMA, PPMd
		Compression = 5  ; 0 | 1 | 3 | 5 | 7 | 9
		Parameters = -mfb=258 -mpass=15
		
		[7z_Options]
		Method = LZMA2  ; LZMA, LZMA2, PPMd, BZip2, Deflate, Delta, BCJ, BCJ2, Copy
		Compression = 9 ; 0 | 1 | 3 | 5 | 7 | 9
		Parameters = -m0=lzma -mfb=64 -md=32m -ms=on
		
		[Rar_Options]
		Compression = 5 ; 0 | 1 | 3 | 5
		Parameters = 
		
		[IncludeList]
		; ���������� ����� ( ��� ������� )
		
		[ExcludeList]
		; ����������� ����� ( ��� ������� )
		*Thumbs.db
		
		)
		FileAppend, %MsgText%, %EmptyFile%, %Encoding%
	}
	IfMsgBox, Timeout
	{
		ExitApp ; i.e. Assume "No" if it timed out.
	}
	; Otherwise, Continue:
	ExitApp
}

Loop, %0%
{ ; ���� ��� ���� ���������� / ������ �������� � ���� ����������
	GivenPath := %A_Index% ; Fetch the contents of the variable whose name is contained in A_Index.
	Loop, Files, %GivenPath%, FD
	{
		FullPath := A_LoopFileLongPath
	}
}

; ����������� ������� ���� �����-���������
SourceFile := FullPath

; ����������� ����� �����-���������
SplitPath, SourceFile, SourceFileShort, SourceFileDir, SourceFileExtension, SourceFileName, SourceFileDrive

; ���������� �������� �������� ���������
SetWorkingDir, %SourceFileDir%

; ��������� ���������� �� �����-���������
IniRead, Name, %SourceFile%, Description, Name, %SourceFileName%						; GetValue( SourceFile, "^Name[\s+]?=[\s+]?( .* )" ) ; ���
Name := RegExReplace( Name, "[ \t]+;.*$", "" )

If ( Name == "" )
{
	MsgBox, ������:`n����������� �������� "Name"
	ExitApp
}

IniRead, Password, %SourceFile%, Description, Password, %A_Space%						; GetValue( SourceFile, "^Password[\s+]?=[\s+]?( .* )" ) ; ������
Password := RegExReplace( Password, "[ \t]+;.*$", "" )

IniRead, RootDir, %SourceFile%, Description, RootDir, %A_Space%							; GetValue( SourceFile, "^RootDir[\s+]?=[\s+]?( .* )" ) ; �������� �����
RootDir := RegExReplace( RootDir, "[ \t]+;.*$", "" )
RootDir := ParseEnvironmentVariables( RootDir )											; ��������� ���������� �����
RootDir := FileGetLongPath( RootDir )													; ��������� �������� ����
global RootDir := RootDir																; ���������� ���������� ���������� ��� ���������� �� ���� ��������

IniRead, TimeStamp, %SourceFile%, Description, TimeStamp, yyyy.MM.dd					; ��������� �����
TimeStamp := RegExReplace( TimeStamp, "[ \t]+;.*$", "" )

IniRead, CreateNewArchives, %SourceFile%, Description, CreateNewArchives, %A_Space%		; ��������� ����� ����� ������ �������������
CreateNewArchives := RegExReplace( CreateNewArchives, "[ \t]+;.*$", "" )
CreateNewArchives := StrToBool( CreateNewArchives )										; to boolean
CreateNewArchivesStr := BoolToStr( CreateNewArchives )									; to string

IniRead, NewArchiveNumeration, %SourceFile%, Description, NewArchiveNumeration, 0.2d	; ��������� �������
NewArchiveNumeration := RegExReplace( NewArchiveNumeration, "[ \t]+;.*$", "" )

IniRead, LockArchive, %SourceFile%, Description, LockArchive, %A_Space%					; ��������� ��������� ������
LockArchive := RegExReplace( LockArchive, "[ \t]+;.*$", "" )
LockArchive := StrToBool( LockArchive ) ; to boolean
LockArchiveStr := BoolToStr( LockArchive ) ; to string

IniRead, IncludeThisFile, %SourceFile%, Description, IncludeThisFile, true				; �������� � ����� ���� ������� ���������� �����������
IncludeThisFile := RegExReplace( IncludeThisFile, "[ \t]+;.*$", "" )
IncludeThisFile := StrToBool( IncludeThisFile ) ; to boolean
IncludeThisFileStr := BoolToStr( IncludeThisFile ) ; to string

IniRead, WriteComment, %SourceFile%, Description, WriteComment, %A_Space%				; �������� � ������ �����������
WriteComment := RegExReplace( WriteComment, "[ \t]+;.*$", "" )
WriteComment := StrToBool( WriteComment ) ; to boolean
WriteCommentStr := BoolToStr( WriteComment ) ; to string

IniRead, AddSuffix, %SourceFile%, Description, AddSuffix, %A_Space%						; �������� ���������� ����
AddSuffix := RegExReplace( AddSuffix, "[ \t]+;.*$", "" )
AddSuffix := StrToBool( AddSuffix ) ; to boolean
AddSuffixStr := BoolToStr( AddSuffix ) ; to string

IniRead, ZipMethod, %SourceFile%, Zip_Options, Method, Deflate
ZipMethod := RegExReplace( ZipMethod, "[ \t]+;.*$", "" )
IniRead, ZipCompression, %SourceFile%, Zip_Options, Compression, 9
ZipCompression := RegExReplace( ZipCompression, "[ \t]+;.*$", "" )
IniRead, ZipParameters, %SourceFile%, Zip_Options, Parameters, -mfb=258 -mpass=15
ZipParameters := RegExReplace( ZipParameters, "[ \t]+;.*$", "" )

IniRead, 7zMethod, %SourceFile%, 7z_Options, Method, LZMA2
7zMethod := RegExReplace( 7zMethod, "[ \t]+;.*$", "" )
IniRead, 7zCompression, %SourceFile%, 7z_Options, Compression, 9
7zCompression := RegExReplace( 7zCompression, "[ \t]+;.*$", "" )
IniRead, 7zParameters, %SourceFile%, 7z_Options, Parameters, -m0=lzma -mfb=64 -md=32m -ms=on
7zParameters := RegExReplace( 7zParameters, "[ \t]+;.*$", "" )

; IniRead, RarMethod, %SourceFile%, Rar_Options, Method, Deflate
; RarMethod := RegExReplace( RarMethod, "[ \t]+;.*$", "" )
IniRead, RarCompression, %SourceFile%, Rar_Options, Compression, 5
RarCompression := RegExReplace( RarCompression, "[ \t]+;.*$", "" )
IniRead, RarParameters, %SourceFile%, Rar_Options, Parameters, %A_Space%
RarParameters := RegExReplace( RarParameters, "[ \t]+;.*$", "" )

; ����������� ����� �������� ������
If RegExMatch( TimeStamp, "^false$" )
{ ; ���� �� ������������
	Name := Name
}
Else
{ ; ���� ������������
	FormatTime, Date,, %TimeStamp% ; ��������� ������� ���� ( 2015.11.29 )
	Name := Name " (" Date ")"
}

IniRead, SevenZip, %SourceFile%, Description, SevenZip, %ProgramFiles%\7-Zip\7z.exe	; GetValue( SourceFile, "^SevenZip[\s+]?=[\s+]?( .* )" ) ; 7-Zip
SevenZip := RegExReplace( SevenZip, "[ \t]+;.*$", "" )
SevenZip := ParseEnvironmentVariables( SevenZip )									; ��������� ���������� �����
SevenZip := FileGetLongPath( SevenZip )												; ��������� �������� ����

IniRead, WinRAR, %SourceFile%, Description, WinRAR, %ProgramFiles%\WinRAR\Rar.exe	; GetValue( SourceFile, "^WinRAR[\s+]?=[\s+]?( .* )" ) ; WinRAR
WinRAR := RegExReplace( WinRAR, "[ \t]+;.*$", "" )
WinRAR := ParseEnvironmentVariables( WinRAR )										; ��������� ���������� �����
WinRAR := FileGetLongPath( WinRAR )													; ��������� �������� ����

IniRead, ArchiveType, %SourceFile%, Description, ArchiveType, zip					; GetValue( SourceFile, "^ArchiveType[\s+]?=[\s+]?( .* )" ) ; ���� �������
ArchiveType := RegExReplace( ArchiveType, "[ \t]+;.*$", "" )
; ArchiveType := Trim( ArchiveType, " " "`t" """" )

If not FileExist( SevenZip ) && InStr( ArchiveType, "zip" )
{ ; ���������, �� �� ������ 7-Zip
	MsgBox, 0, Error, Not found:`n%SevenZip%, 1.5
}
If not FileExist( SevenZip ) && InStr( ArchiveType, "7z" )
{ ; ���������, �� �� ������ 7-Zip
	MsgBox, 0, Error, Not found:`n%SevenZip%, 1.5
}
If not FileExist( WinRAR ) && InStr( ArchiveType, "rar" )
{ ; ���������, �� �� ������ WinRAR
	MsgBox, 0, Error, Not found:`n%WinRAR%, 1.5
}
If ( ArchiveType = "" )
{ ; �� ����� ��� ������
	MsgBox, 0, Error, ArchiveType was not set!, 1.5
}

; ����������� ������-������� ��� ��������� ������������
IncludeList := A_Temp "\IncludeList.txt" ; ������ ���������
ExcludeList := A_Temp "\ExcludeList.txt" ; ������ ����������
CommentFile := A_Temp "\CommentFile.txt" ; ���� �����������

ArchiveName := Name

If ( CreateNewArchives )
{ ; ���������� ����������� ������ ������
	ArchiveCount := 0
	Loop, Files, %Archive%*%ArchiveType%, F
	{
		MatchString := "^" ConvertToString( Name ) " - ( \d+ )( .*? )?" ConvertToString( "." ArchiveType ) "$"
		If RegExMatch( A_LoopFileName, MatchString, Match, 1 )
		{
			ArchiveCount := Match1 + 1
		}
	}
	ArchiveCount := Format( "{1:" NewArchiveNumeration "}", ArchiveCount ) ; Format( "{1:0.3d}", ArchiveCount )
	ArchiveName := Name " - " ArchiveCount
}

If ( AddSuffix )
{ ; ���������� �������� � �������� ������
	; InputBox, OutputVar [, Title, Prompt, HIDE, Width, Height, X, Y, Font, Timeout, Default]
	InputBox, ArchiveSuffix, %ArchiveName%.%ArchiveType%,,,, 100
	If ( StrLen( ArchiveSuffix ) > 0 )
	{ ; ������� �����
		ArchiveName .= " [" ArchiveSuffix "]"
	}
}

Archive := SourceFileDir "\" ArchiveName ; ����������� ������� ���� � ������

; ����� ���� � ������ ����������� � ������� ������
DebugMsgText := "[Description]"
DebugMsgText .= "`r`n" "Name = " ArchiveName
If ( Password )
{
	DebugMsgText .= "`r`n" "Password = " Password
}
If ( RootDir )
{
	DebugMsgText .= "`r`n" "RootDir = " RootDir
}
If ( InStr( ArchiveType, "zip" ) or InStr( ArchiveType, "7z" ) )
{
	DebugMsgText .= "`r`n" "SevenZip = " SevenZip
}
If InStr( ArchiveType, "rar" )
{
	DebugMsgText .= "`r`n" "WinRAR = " WinRAR
}
DebugMsgText .= "`r`n" "ArchiveType = " ArchiveType
DebugMsgText .= "`r`n" "TimeStamp = " TimeStamp
DebugMsgText .= "`r`n" "CreateNewArchives = " CreateNewArchivesStr
DebugMsgText .= "`r`n" "NewArchiveNumeration = " NewArchiveNumeration
If InStr( ArchiveType, "rar" )
{
	DebugMsgText .= "`r`n" "LockArchive = " LockArchiveStr
}
DebugMsgText .= "`r`n" "IncludeThisFile = " IncludeThisFileStr
DebugMsgText .= "`r`n" "WriteComment = " WriteCommentStr
DebugMsgText .= "`r`n" "AddSuffix = " AddSuffixStr
If InStr( ArchiveType, "zip" ) {
	DebugMsgText .= "`r`n" "`r`n[Zip_Options]"
	DebugMsgText .= "`r`n" "Method = " ZipMethod
	DebugMsgText .= "`r`n" "Compression = " ZipCompression
	DebugMsgText .= "`r`n" "Parameters = " ZipParameters
}
If InStr( ArchiveType, "7z" )
{
	DebugMsgText .= "`r`n" "`r`n[7z_Options]"
	DebugMsgText .= "`r`n" "Method = " 7zMethod
	DebugMsgText .= "`r`n" "Compression = " 7zCompression
	DebugMsgText .= "`r`n" "Parameters = " 7zParameters
}
If InStr( ArchiveType, "rar" )
{
	DebugMsgText .= "`r`n" "`r`n[Rar_Options]"
	DebugMsgText .= "`r`n" "Compression = " RarCompression
	DebugMsgText .= "`r`n" "Parameters = " RarParameters
}
MsgBox, 1,, %DebugMsgText%
IfMsgBox, Cancel
{ ; ���� ������ ������ ������
	ExitApp  ; User pressed the "No" button.
}

; �������� zip ������ � ������� 7-Zip
If ( FileExist( SevenZip ) and InStr( ArchiveType, "zip" ) )
{
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ ( ��������� UTF-8 )
	SplitTextFile( SourceFile, IncludeList, "[IncludeList]", "[ExcludeList]", "UTF-8" )
	SplitTextFile( SourceFile, ExcludeList, "[ExcludeList]", "", "UTF-8" )
	
	Type := "zip"											; ��� ������
	Password := Password != "" ? "-p" Password : Password	; ������ �� �����
	Compression := "-mm=" ZipMethod " -mx" ZipCompression	; �������� ������
	Include = -i@"%IncludeList%"      						; ����-������ ���������
	Exclude = -x@"%ExcludeList%"							; ����-������ ����������
	Synchronize := "p0q0r2x1y2z1w2"							; ���� �������������
	Incrimental := "p1q1r0x1y2z1w2"							; ���� �������� ������������� ������
	Parameters := ZipParameters								; �������������� ���������
	
	; ����������� ������� �� ���������� ���������
	If ( IncludeThisFile )
	{
		Command = "%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%" -spf2 -w"%A_Temp%"
	}
	Else
	{
		Command = "%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include% -spf2 -w"%A_Temp%"
	}
	
	; MsgBox, %Type%:`n`t%Command%
	
	; �������� ������� ��������� %RootDir% ( ����������� ��������� �������� ��������� )
	If ( RootDir == "" )
	{ ; ���� �������� ������� ��������� �� �����:
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%SourceFileDir%" & %Command% & Pause & Exit
	}
	Else
	{ ; ���� �������� ������� ��������� �����:
		SetWorkingDir, %RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
		SourceCopy := RootDir "\" SourceFileShort
		NoDelete := FileExist( SourceCopy )
		
		; ����������� �����-��������� � ��������� ������� ���������
		If ( SourceCopy!=SourceFile and IncludeThisFile )
		{ ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy, %SourceFile%, %SourceCopy%, 1 ; ����������� / ���������� ����� � �������� ������� ���������
		}
		
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%RootDir%" & %Command% & Pause & Exit
		
		If ( SourceCopy != SourceFile and IncludeThisFile and not NoDelete )
		{ ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete, %SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir, %SourceFileDir% ; �������������� �������� �������� ���������
	}
	
	; �������� ������-�������
	FileDelete, %IncludeList%
	FileDelete, %ExcludeList%
}

; �������� ������ � ������� 7-Zip
If ( FileExist( SevenZip ) and InStr( ArchiveType, "7z" ) )
{
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ ( ��������� UTF-8 )
	SplitTextFile( SourceFile, IncludeList, "[IncludeList]", "[ExcludeList]", "UTF-8" )
	SplitTextFile( SourceFile, ExcludeList, "[ExcludeList]", "", "UTF-8" )
	
	Type := "7z"											; ��� ������
	Password := Password != "" ? "-p" Password : Password	; ������ �� �����
	Compression := "-mm=" 7zMethod " -mx" 7zCompression		; �������� ������
	Include = -i@"%IncludeList%"							; ����-������ ���������
	Exclude = -x@"%ExcludeList%"							; ����-������ ����������
	Synchronize := "p0q0r2x1y2z1w2"							; ���� �������������
	Incrimental := "p1q1r0x1y2z1w2"							; ���� �������� ������������� ������
	Parameters := 7zParameters								; �������������� ���������
	
	; ����������� ������� �� ���������� ���������
	If ( IncludeThisFile )
	{
		Command = "%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%" -spf2 -w"%A_Temp%"
	}
	Else
	{
		Command = "%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include% -spf2 -w"%A_Temp%"
	}
	
	; MsgBox, %Type%:`n`t%Command%
	
	; �������� ������� ��������� %RootDir% ( ����������� ��������� �������� ��������� )
	If ( RootDir == "" )
	{ ; ���� �������� ������� ��������� �� �����:
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%SourceFileDir%" & %Command% & Pause & Exit		
	}
	Else
	{ ; ���� �������� ������� ��������� �����:
		SetWorkingDir, %RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
		SourceCopy := RootDir "\" SourceFileShort
		NoDelete := FileExist( SourceCopy )
		
		; ����������� �����-��������� � ��������� ������� ���������
		If ( SourceCopy != SourceFile and IncludeThisFile )
		{ ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy, %SourceFile%, %SourceCopy%, 1 ; ����������� / ���������� ����� � �������� ������� ���������
		}
		
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%RootDir%" & %Command% & Pause & Exit
		
		If ( SourceCopy != SourceFile and IncludeThisFile and not NoDelete ) { ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete, %SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir, %SourceFileDir% ; �������������� �������� �������� ���������
	}
	
	; �������� ������-�������
	FileDelete, %IncludeList%
	FileDelete, %ExcludeList%
}

; �������� ������ � ������� WinRAR
If ( FileExist( WinRAR ) and InStr( ArchiveType, "rar" ) )
{
	; ���������� �����-��������� �� �����-������ ���������� � ����������� ������ ( ��������� Windows-1251 )
	SplitTextFile( SourceFile, IncludeList, "[IncludeList]", "[ExcludeList]", "CP1251" )
	SplitTextFile( SourceFile, ExcludeList, "[ExcludeList]", "", "CP1251" )
	
	If ( WriteComment )
	{
		SplitTextFile( SourceFile, CommentFile, "[IncludeList]", "[ExcludeList]", "CP1251", false, false )
	}
	
	Type := "rar"									; ��� ������
	Password := Password != "" ? "-p" Password : "" ; ������ �� �����
	Compression := "-m" RarCompression " -rr5p"		; �������� ������
	Include = @"%IncludeList%"						; ����-������ ���������
	Exclude = -x@"%ExcludeList%"					; ����-������ ����������
	Synchronize := " -as"							; ���� �������������
	Incrimental := "p1q1r0x1y2z1w2"					; ���� �������� ������������� ������
	Parameters := RarParameters						; �������������� ���������
	
	; ����������� ������� �� ���������� ���������
	If ( IncludeThisFile )
	{
		Command = "%WinRAR%" u -u%Synchronize% %Compression% -r0 %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%"
	}
	Else
	{
		Command = "%WinRAR%" u -u%Synchronize% %Compression% -r0 %Password% %Parameters% "%Archive%.%Type%" %Exclude% %Include%
	}
	If ( WriteComment )
	{
		Command = %Command% -z"%CommentFile%"
	}
	If ( LockArchive )
	{
		Command = %Command% & "%WinRAR%" k %Compression% "%Archive%.%Type%"
	}
	
	; MsgBox, %Type%:`n`t%Command%
	
	; �������� ������� ��������� %RootDir% ( ����������� ��������� �������� ��������� )
	If ( RootDir == "" )
	{ ; ���� �������� ������� ��������� �� �����:
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%SourceFileDir%" & %Command% & Pause & Exit	
	}
	Else
	{ ; ���� �������� ������� ��������� �����:
		SetWorkingDir, %RootDir% ; ���������� ��������� �������� ��������� ������� ��������� ���������
		SourceCopy := RootDir "\" SourceFileShort
		NoDelete := FileExist( SourceCopy )
		
		; ����������� �����-��������� � ��������� ������� ���������
		If ( SourceCopy!=SourceFile and IncludeThisFile )
		{ ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileCopy, %SourceFile%, %SourceCopy%, 1 ; ����������� / ���������� ����� � �������� ������� ���������
		}
		
		; ���������� ������� ��������� � ��������� ������
		RunWait, %ComSpec% /k cd /d "%RootDir%" & %Command% & Pause & Exit
		
		If ( SourceCopy != SourceFile and IncludeThisFile and not NoDelete )
		{ ; �������� ���������� ���� �����-��������� � ���� ����������� �����-���������
			FileDelete, %SourceCopy% ; �������� ������������� ����� �����-��������� �� ��������� �������� ���������
		}
		SetWorkingDir, %SourceFileDir% ; �������������� �������� �������� ���������
	}
	
	; �������� ������-�������
	FileDelete, %IncludeList%
	FileDelete, %ExcludeList%
	
	If ( WriteComment )
	{
		FileDelete, %CommentFile%
	}
}

/*
; ===================================================================================
;                 ������� ��������� �������� �� ����� �����-���������
; ===================================================================================
GetValue( SourceFile, SearchPattern )
{
Loop, Read, %SourceFile%
{
If RegExMatch( A_LoopReadLine, SearchPattern )
{
Value := RegExReplace( A_LoopReadLine, SearchPattern, "$1",, 1 )
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
	If ( Encoding == "" ) { ; if no Encoding defined
		Encoding := A_FileEncoding
	}
	
	FileDelete, %OutputFile%
	RootDir = %RootDir%
	
	Loop, Read, %SourceFile%
	{
		IfInString, A_LoopReadLine, %StartString%
		StartLine := A_Index
		
		If ( EndString == "")
		{ ; if no EndString defined
			EndLine := A_Index + 1
		}
		Else
		{
			IfInString, A_LoopReadLine, %EndString%
			EndLine := A_Index
		}
	}
	
	Loop, Read, %SourceFile%
	{
		If ( SkipComments )
		{
			If A_LoopReadLine = ; if looped line is empty
			Continue ; skip the current Loop instance
			If RegExMatch( A_LoopReadLine, "^( \s+ )?;" )
			{ ; if looped line is commented
				Continue ; skip the current Loop instance
			}
			If RegExMatch( A_LoopReadLine, "^( \s+ )?//" )
			{ ; if looped line is commented
				Continue ; skip the current Loop instance
			}
		}
		
		CurrentLine := A_Index
		If ( CurrentLine > StartLine ) && ( CurrentLine < EndLine )
		{
			; CurrentString := RegExReplace( A_LoopReadLine, "^[ \t]+", "" )
			CurrentString := TrimLines ? Trim( A_LoopReadLine ) : A_LoopReadLine ; �������� ��������� � ���������� ��������
			CurrentString := ParseEnvironmentVariables( CurrentString )
			If ( RootDir != "" )
			{
				RootDirSlash := RootDir "`\"
				CurrentString := StrReplace( CurrentString, RootDirSlash, "" ) ; �������� ��������� �������� �� ����� �����-������
			}
			FileAppend, %CurrentString%`n, %OutputFile%, %Encoding%
		}
	}
	
	global IncludeThisFile
	If ( not IncludeThisFile and StartString == "[ExcludeList]" ) {
		global SourceFileName
		global SourceFileExtension
		FileAppend, %SourceFileName%.%SourceFileExtension%`n, %OutputFile%, %Encoding%
		;~ MsgBox, %SourceFile%
	}
}

; ===================================================================================
;                 ������� �������� �������� BOOOLEAN � STRING
; ===================================================================================
BoolToStr( v ) {
	If ( v and ( v == "true" or v = 1 ) ) {
	Return, "true"
	} else {
		Return, "false"
	}
}
StrToBool( v ) {
	v := Trim( v )
	b := ( v == "true" or v = 1 )
	Return, b
}
