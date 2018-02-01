#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn	 ; Enable warnings to assist with detecting common errors.
SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%	 ; Ensures a consistent starting directory.

#SingleInstance,force
; #Persistent	 ; to make it run indefinitely
; SetBatchLines,-1	; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := "CopyAddons" ; GetScriptName()
SCRIPT_VERSION := "1.1.2"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION . " (by Ægir)"

; FileEncoding, UTF-8

/*
CreateLogo:
{
	logoFile = %A_ScriptDir%\Images\%SCRIPT_NAME%.png
	logoURL := "http://wow.blizzwiki.ru/images/a/a9/Blizzard_Entertainment_logo.png"
	logoSize := 64
	logoAlpha := 0.95

	GdipCreateLogo(logoFile,logoURL,logoSize,logoAlpha)
}
*/

CreateGUI:
{
	SoundPlay,*48
	Gui,MsgBox1_:Add,Progress,x5 y5 w395 h20 vMsgBox1_Progress -Smooth ;cBlue
	Gui,MsgBox1_:Add,Text,vMsgBox1_Text x5 y+5 w395 h80,Идет копирование файлов...
	Gui,MsgBox1_:Add,Button,vCancelButton x325 y135 w75 h25 gButtonCancel,Отмена
	Gui,MsgBox1_:Add,Button,vNoButton x245 y135 w75 h25 gButtonNo,Нет
	Gui,MsgBox1_:Add,Button,vYesButton x165 y135 w75 h25 gButtonYes,Да
	GuiControl,MsgBox1_:Hide,YesButton
	GuiControl,MsgBox1_:Hide,NoButton
	Gui,MsgBox1_:Show,xCenter yCenter h165 w405,%SCRIPT_WIN_TITLE%
}

DefineGlobals:
{
	INI_FILE = %SCRIPT_NAME%.ini
	INI_FILE = %A_ScriptDir%\%INI_FILE%
	INI_FILE := FileGetLongPath(INI_FILE)

	; FormatTime,Date,,yyyy.MM.dd ; Получение текущей даты (2015.11.29)

	; Чтение параметров из INI_FILE
	IniRead,GAME_DIR,%INI_FILE%,OPTIONS,GameDir,D:\Games\World of Warcraft\
	GAME_DIR := ParseEnvironmentVariables(GAME_DIR)
	GAME_DIR := FileGetLongPath(GAME_DIR)

	IniRead,ACCOUNT_1,%INI_FILE%,OPTIONS,Account_1,%A_Space%
	IniRead,ACCOUNT_2,%INI_FILE%,OPTIONS,Account_2,%A_Space%

	IniRead,REALM_1,%INI_FILE%,OPTIONS,Realm_1,%A_Space%
	IniRead,REALM_2,%INI_FILE%,OPTIONS,Realm_2,%A_Space%

	IniRead,CHARACTER_1,%INI_FILE%,OPTIONS,Character_1,%A_Space%
	IniRead,CHARACTER_2,%INI_FILE%,OPTIONS,Character_2,%A_Space%

	IniRead,COPY_TO_DIR,%INI_FILE%,OPTIONS,CopyToDir,%A_Desktop%\WoW Addons Copy\World of Warcraft
	COPY_TO_DIR := ParseEnvironmentVariables(COPY_TO_DIR)
	COPY_TO_DIR := FileGetLongPath(COPY_TO_DIR)

	IniRead,SEPARATE_DIRS,%INI_FILE%,OPTIONS,SeparateDirs,1
	IniRead,CONFIGS,%INI_FILE%,OPTIONS,Configs,1

	IniRead,TIMESTAMPS,%INI_FILE%,OPTIONS,Timestamps,%A_Space%
	If (TIMESTAMPS && TIMESTAMPS != "") {
		FormatTime,Date,,%TIMESTAMPS% ; Получение текущей даты (2015.11.29)
		COPY_TO_DIR := COPY_TO_DIR . " (" . Date . ")"
	}
	
	READ_ME_FILE := COPY_TO_DIR . "\README.txt"
	FIX_IT_FILE := COPY_TO_DIR . "\FIX_IT.txt"
	
	IniRead,CLEANING_MODE,%INI_FILE%,OPTIONS,CleaningMode,0
}

; Создание списка секций INI_FILE
GetSectionsList:
{
	Sections := Object()
		Loop,Read,%INI_FILE%
		{
			If RegExMatch(A_LoopReadLine,"^\[.*\]$") {
				Sections.Push(A_LoopReadLine)
		}
	}
}

; Создание списка файлов для обработки
GetFilesList:
{
	; Обновление текста
	GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет подготовка копирования файлов...

	FilesList := Object()
	COMMON_FILE_SIZE := 0

	; Создание списка ключей секции [OPTIONS]
	Options := Object()
	Options := FileReadSection(INI_FILE,"[OPTIONS]","^\[.*\]$",1)

	; Обработка списка ключей секции [OPTIONS]
	for index,element in Options
	{
		; Обработка ключей Dir_##
		If RegExMatch(element,"^Dir_(\d+)") {
			idNum := RegExReplace(element,"^Dir_(\d+).*","$1",,1) ; Получение idNum из Dir_##

			IniRead,DIR_%idNum%,%INI_FILE%,OPTIONS,Dir_%idNum%,"" ; Чтение из INI файла параметров для каждого ключа Dir_## и создание переменных DIR_##

			; Определение переменных
			dirKey = DIR_%idNum%
			If ( SEPARATE_DIRS == "1" ) {
				dirPath := COPY_TO_DIR . "\" . %dirKey%
				If (Date) {
					dirPath := dirPath . " (" . Date . ")"
				}
			} else {
				dirPath := COPY_TO_DIR
			}
			dirPath := TrimPath(dirPath)

			; Обработка каждой секции [FILES_##] из INI файла
			Section := "FILES_" . idNum
			Keys := FileReadSection(INI_FILE,Section,"^\[.*\]$",1)

			; Добавление выбранных путей в список файлов
			for index,element in Keys
			{
				queueCopy := (CONFIGS == 1) || !RegExMatch(element,"^WTF\\.*",configFile,1)
				; MsgBox,0,Error,element:%element%`nqueueCopy:`n%queueCopy%,0.5
				If (element != "" && queueCopy) {
					; Замена переменных из INI файла
					Key_1 := RegExReplace(element,"=.*$","",,1)
					Key_1 := StrReplace(Key_1,"$ACCOUNT$",ACCOUNT_1)
					Key_1 := StrReplace(Key_1,"$REALM$",REALM_1)
					Key_1 := StrReplace(Key_1,"$CHARACTER$",CHARACTER_1)

					Key_2 := RegExReplace(element,"=.*$","",,1)
					Key_2 := StrReplace(Key_2,"$ACCOUNT$",ACCOUNT_2)
					Key_2 := StrReplace(Key_2,"$REALM$",REALM_2)
					Key_2 := StrReplace(Key_2,"$CHARACTER$",CHARACTER_2)

					; Определение путей обработки
					copyFrom := GAME_DIR . "\" . Key_1
					copyTo := dirPath . "\" . Key_2

					; Возможное исправление путей обработки
					copyFrom := TrimPath(copyFrom)
					copyTo := TrimPath(copyTo)

					; Вычисление общего размера обрабатываемых файлов
					COMMON_FILE_SIZE := COMMON_FILE_SIZE + GetFileSize(copyFrom)

					; Создание списка файлов для обработки
					Line := copyFrom . "|" . copyTo
					FilesList.Push(Line)
				}
			}
		}
	}
}

ProcessFilesList:
{
	; Удаление существующей COPY_TO_DIR
	IfExist,%COPY_TO_DIR%
	{
		GuiControl,,MsgBox1_Text,Удаление %COPY_TO_DIR%...
		FileRemoveDir,%COPY_TO_DIR%,1
	}

	; Копирование файлов и каталогов
	PROCESSED_FILE_SIZE := 0
	configFileParsed := false
	for index,element in FilesList
	{
		If RegExMatch(element,"^(.*)\|(.*)$",Line,1) {
			; Получение путей из строк с разделителем "|
			copyFrom := Line1
			copyTo := Line2

			; Вычисление прогресса копирования
			PROCESSED_FILE_SIZE := PROCESSED_FILE_SIZE + GetFileSize(copyFrom)
			PROCESSED_FILE_PCT := PROCESSED_FILE_SIZE / COMMON_FILE_SIZE * 100

			; Обновление текста
			GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет копирование файлов...`n`n%Key_1%

			; Копирование файлов
			FileCopy(copyFrom,copyTo,1)

			; Копирование настроек ACCOUNT_1 в ACCOUNT_2
			; If (CONFIGS == 1) && RegExMatch(copyTo,".*\\WTF\\Account\\.*\.lua",filePath,1) {
				; GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет обработка файлов...`n`n%filePath%
				; find = ((.*)\["%CHARACTER_1% - %REALM_1%"\] = "(.*)",)
				; replace = $1`n$2["%CHARACTER_2% - %REALM_2%"] = "$3",
				; TF_RegExReplace("!" . copyTo,find,replace)
			; }

			; Удаление персональных данных из CopyAddons.ini
			If (not configFileParsed && RegExMatch(copyTo,".*\\Manager",filePath,1)) {
				configFile := filePath . "\extensions\AutoHotkey\CopyAddons.ini"
				IfExist, %configFile%
				{
					GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет обработка...`n`n%configFile%
					TF_RegExReplace("!" . configFile,"m)" . "^(Account_([12])).*=.*","$1 = АККАУНТ_$2")
					TF_RegExReplace("!" . configFile,"m)" . "^(Realm_([12])).*=.*","$1 = ИГРОВОЙ_МИР_$2")
					TF_RegExReplace("!" . configFile,"m)" . "^(Character_([12])).*=.*","$1 = НИК_$2")
					configFileParsed := true
				}
			}

			; Обновление прогрессбара
			GuiControl,MsgBox1_:,MsgBox1_Progress,%PROCESSED_FILE_PCT%
		}
	}

	If (CONFIGS = 1) {
		Loop, Files, % COPY_TO_DIR "\WTF\*.lua", RF
		{
			GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет обработка файлов...`n`n%A_LoopFileFullPath%
			FileEncoding_tmp := A_FileEncoding
			CurFile := A_LoopFileFullPath
			FileEncoding, UTF-8
			Loop, Read, % CurFile
			{
				CurLine := Trim( A_LoopReadLine )
				Find = .*%REALM_2% - %CHARACTER_1%.* ;["WoW Circle 3.3.5a Fun - Злаяпадла"] = {
				; MsgBox, % CurLine "`n" Find
				If RegExMatch( CurLine,  Find )
				{
					; MsgBox, % A_LoopFileFullPath
					Info := "FILE: " A_LoopFileFullPath "`n" "LINE: " A_Index "`n" "TEXT: " CurLine
					FileAppend,%Info%`n,%FIX_IT_FILE% ;,UTF-8
				}
			}
			FileEncoding, %FileEncoding_tmp%
		}
		Loop, Files, % COPY_TO_DIR "\WTF\*.lua", RF
		{
			GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет обработка файлов...`n`n%A_LoopFileFullPath%
			find = ((.*)\["%CHARACTER_2% - %REALM_2%"\] = "(.*)",)
			replace := "" ; 
			; MsgBox, % A_LoopFileFullPath "`n" find "`n" replace
			FileEncoding_tmp := A_FileEncoding
			FileEncoding, CP65001
			TF_RegExReplace( "!" . A_LoopFileFullPath, find, replace )
			FileEncoding, %FileEncoding_tmp%
			; MsgBox % TF_CountLines( "!" . A_LoopFileFullPath )
		}
		If ( CLEANING_MODE = 0 ) {
			Loop, Files, % COPY_TO_DIR "\WTF\*.lua", RF
			{
				GuiControl,MsgBox1_:Text,MsgBox1_Text,Идет обработка файлов...`n`n%A_LoopFileFullPath%
				find = ((.*)\["%CHARACTER_1% - %REALM_1%"\] = "(.*)",)
				replace = $1`n$2["%CHARACTER_2% - %REALM_2%"] = "$3",
				; MsgBox, % A_LoopFileFullPath "`n" find "`n" replace
				FileEncoding_tmp := A_FileEncoding
				FileEncoding, CP65001
				TF_RegExReplace( "!" . A_LoopFileFullPath, find, replace )
				FileEncoding, %FileEncoding_tmp%
				; MsgBox % TF_CountLines( "!" . A_LoopFileFullPath )
			}
		}
	}

	; Удаление прогрессбара
	GuiControl,MsgBox1_:Hide,MsgBox1_Progress

	; Чтение секции [DESCRIPTION]
	Description := Object()
	Description := FileReadSection(INI_FILE,"[DESCRIPTION]","^\[.*\]$",0,0)

	; Формирование Readme.txt из строк секции [DESCRIPTION]
	for index,element in Description
	{
		; Key := RegExReplace(element,"=.*$","",,1)
		Key := element
		Key := StrReplace(Key,"$ACCOUNT$",ACCOUNT_2)
		Key := StrReplace(Key,"$REALM$",REALM_2)
		Key := StrReplace(Key,"$CHARACTER$",CHARACTER_2)

		FileAppend,%Key%`n,%READ_ME_FILE% ;,UTF-8
	}

	; Завершающий диалог
	IfExist,%COPY_TO_DIR%
	{
		SoundPlay,*64
		GuiControl,MsgBox1_:Show,YesButton
		GuiControl,MsgBox1_:Show,NoButton
		GuiControl,MsgBox1_:Text,MsgBox1_Text,Копирование файлов завершено.`n`nОткрыть папку назначения?`n`n%COPY_TO_DIR%
		GuiControl,MsgBox1_:Move,MsgBox1_Text,x5 y10
	} else {
		Gui,MsgBox1_:Destroy
		SoundPlay,*16
		MsgBox,0,Error,Not found:`n%COPY_TO_DIR%,1.5
	}
}

; Run, % READ_ME_FILE

Exit

; ------------------ FUNCTIONS ------------------
GetFileSize(Path)
{
	; SetBatchLines,-1	; Make the operation run at maximum speed.
	FolderSize := 0

	IfExist,%Path%\*
	{
		Loop,Files,%Path%\*,RF
		{
			FolderSize += A_LoopFileSize
		}
	} else {
		Loop,Files,%Path%,F
		{
			FolderSize += A_LoopFileSize
		}
	}

	Return FolderSize
}

; ------------------ GUI SUBROUTINES ------------------
ButtonYes:
{
	SoundPlay,*64
	Run,%COPY_TO_DIR%
	ExitApp
}

ButtonNo:
{
	ExitApp
}

ButtonCancel:
{
	GuiControl,,MsgBox1_Text,Удаление скопированных файлов...
	IfExist,%COPY_TO_DIR%
	{
		FileRemoveDir,%COPY_TO_DIR%,1
	}
	SoundPlay,*64
	Gui,MsgBox1_:Submit,Close
	ExitApp
}

MsgBox1_GuiClose:
{
	ExitApp
}
