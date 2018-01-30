#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode, Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,force
; #Persistent  ; to make it run indefinitely
SetBatchLines,-1  ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION . " (by Ægir)"


CreateLogo:
{
	logoFile = %A_ScriptDir%\%SCRIPT_NAME%.png
	logoURL := "http://pngimg.com/upload/keyboard_PNG5863.png"
	logoSize := 64*2
	logoAlpha := 0.95
	
	IconNumber = 1
	IconSize = "256"
	
	GdipCreateLogo(logoFile,logoURL,logoSize,logoAlpha,IconNumber,IconSize)
}


DefineGlobals:
{
	INI_FILE = %SCRIPT_NAME%.ini
	INI_FILE = %A_ScriptDir%\%INI_FILE%
	INI_FILE := FileGetLongPath(INI_FILE)
	
	IfNotExist,%INI_FILE%
	{
		CreateEmptyFile(INI_FILE)
		Run, "%A_ScriptFullPath%"
		ExitApp
	}
	
	IniRead,CycleState,%INI_FILE%,OPTIONS,CycleState,%A_Space%
	if (CycleState == "false") {
		CycleState := false
	}
}

MsgBox,0,%SCRIPT_WIN_TITLE%,Ready!,0.5

RefreshGlobals:
{
	IniRead,SendMode,%INI_FILE%,OPTIONS,SendMode,Input
	SendMode := RegExReplace(SendMode,"[ \t]+;.*$","")
	SendMode,%SendMode%
	
	IniRead,BindKey,%INI_FILE%,OPTIONS,BindKey,SC01C
	BindKey := RegExReplace(BindKey,"[ \t]+;.*$","")
	Hotkey,%BindKey%,BindKeyPressed
	
	IniRead,TargetProcess,%INI_FILE%,OPTIONS,TargetProcess,%A_Space%
	TargetProcess := RegExReplace(TargetProcess,"[ \t]+;.*$","")
	
	IniRead,TogglePauseKey,%INI_FILE%,OPTIONS,TogglePauseKey,SC045
	TogglePauseKey := RegExReplace(TogglePauseKey,"[ \t]+;.*$","")
	Hotkey,%TogglePauseKey%,PauseKeyPressed
	
	IniRead,ToggleCycleKey,%INI_FILE%,OPTIONS,ToggleCycleKey,SC04C
	ToggleCycleKey := RegExReplace(ToggleCycleKey,"[ \t]+;.*$","")
	Hotkey,%ToggleCycleKey%,CycleKeyPressed
	
	IniRead,SendDelayMin,%INI_FILE%,OPTIONS,SendDelayMin,0
	SendDelayMin := RegExReplace(SendDelayMin,"[ \t]+;.*$","")
	IniRead,SendDelayMax,%INI_FILE%,OPTIONS,SendDelayMax,0
	SendDelayMax := RegExReplace(SendDelayMax,"[ \t]+;.*$","")
	SendDelayMin := Eval(SendDelayMin)
	SendDelayMax := Eval(SendDelayMax)
	Random,SendDelay,%SendDelayMin%,%SendDelayMax%
	
	IniRead,CycleTimeMin,%INI_FILE%,OPTIONS,CycleTimeMin,0
	CycleTimeMin := RegExReplace(CycleTimeMin,"[ \t]+;.*$","")
	IniRead,CycleTimeMax,%INI_FILE%,OPTIONS,CycleTimeMax,0
	CycleTimeMax := RegExReplace(CycleTimeMax,"[ \t]+;.*$","")
	CycleTimeMin := Eval(CycleTimeMin)
	CycleTimeMax := Eval(CycleTimeMax)
	Random,CycleTime,%CycleTimeMin%,%CycleTimeMax%
	
	; Создание списка ключей секции
	KEYS := Object()
	KEYS := FileReadSection(INI_FILE,"[KEYS]","^\[.*\]$",1)
	
	; Создание списка
	KeysList := Object()
	
	; Обработка списка ключей секции
	for index,element in KEYS
	{
		; Обработка ключей
		if RegExMatch(element,"^Key(\d+)") {
			idNum := RegExReplace(element,"^Key(\d+).*","$1",,1) ; Получение номера idNum
			IniRead,KEY_%idNum%,%INI_FILE%,KEYS,Key%idNum%
			KeysList.Push(KEY_%idNum%)
		}
	}
	
	return
}

PauseKeyPressed:
{
	Paused := !Paused
	Hotkey,%BindKey%,Toggle
	gosub,RefreshGlobals
	
	if (Paused) {
	MsgBox,0,%SCRIPT_WIN_TITLE%,Paused,0.5
	} else {
		gosub,ShowInfo
	}
	
	return
}

CycleKeyPressed:
{
	CycleState := !CycleState
	gosub,RefreshGlobals
	
	Text =
	( LTrim RTrim Join`r`n
    [OPTIONS]
    CycleState = %CycleState%
	
    CycleTimeMin = %CycleTimeMin%
    CycleTimeMax = %CycleTimeMax%
    CycleTime = %CycleTime%
	)
	
	if (CycleState) {
	MsgBox,0,%SCRIPT_WIN_TITLE%,%text%,1.0
	} else {
		MsgBox,0,%SCRIPT_WIN_TITLE%,CycleState = %CycleState%,1.0
	}
	
	return
}

BindKeyPressed:
{
	if (not TargetProcess or WinActive(TargetProcess)) {
		for index,keyCode in KeysList
		{
			Random,SendDelay,%SendDelayMin%,%SendDelayMax%
			Send,%keyCode%
			Sleep,%SendDelay%
		}
		if (CycleState) {
			Random,CycleTime,%CycleTimeMin%,%CycleTimeMax%
		Sleep,%CycleTime%
		} else {
			KeyWait,%BindKey%
		}
		return
	}
	return
}

ShowInfo:
{
	Text =
	( LTrim RTrim Join`r`n
    [OPTIONS]
    SendMode, = %SendMode%
    BindKey = %BindKey%
    TargetProcess = %TargetProcess%
    TogglePauseKey = %TogglePauseKey%
    ToggleCycleKey = %ToggleCycleKey%
	
    SendDelayMin = %SendDelayMin%
    SendDelayMax = %SendDelayMax%
    SendDelay = %SendDelay%
	
    CycleState = %CycleState%
	
    CycleTimeMin = %CycleTimeMin%
    CycleTimeMax = %CycleTimeMax%
    CycleTime = %CycleTime%
	)
	
	MsgBox,0,%SCRIPT_WIN_TITLE%,%text%,1.0
	
	return
}

; ------------------ FUNCTIONS ------------------
CreateEmptyFile(EmptyFile)
{
	Encoding = CP1251
	Text =
	( LTrim RTrim Join`r`n
    ; ДЛЯ ПРАВИЛЬНОГО ЧТЕНИЯ СИМВОЛОВ КОДИРОВКА ЭТОГО ФАЙЛА ОБЯЗАТЕЛЬНО ДОЛЖНА БЫТЬ: WIN-1251 | CP1251
	
    [OPTIONS]
    SendMode, = Event                      ; Метод ввода (Input|Play|Event|InputThenPlay)
    BindKey = SC012                       ; Переназначаемая клавиша (желательно использовать сканкод клавиши)
    TargetProcess = ahk_exe notepad++.exe ; Идентификатор процесса-цели (этот параметр можно просто отключить)
    TogglePauseKey = NumpadEnter          ; Кнопка вкл./выкл. паузы (желательно использовать сканкод клавиши)
    ToggleCycleKey = Numpad5              ; Кнопка вкл./выкл. повторения (желательно использовать сканкод клавиши)
    ; SendDelayMin = 12                   ; Минимальная задержка для каждой отправки (мс)
    ; SendDelayMax = 18                   ; Максимальная задержка для каждой отправки (мс)
    CycleState = true                     ; Кнопка для вкл./выкл. повторения по умолчанию
    CycleTimeMin = 30                     ; Минимальная задержка между циклами (мс)
    CycleTimeMax = 100                    ; Максимальная задержка между циклами (мс)
	
    [KEYS]
    ; Очерёдность действий, выполняемых по нажатию/циклу
    Key1 = {А}
    Key2 = {Б}
    Key3 = {В}
    Key4 = {Г}
    Key5 = {Д}
    Key6 = {Enter}
	
    [DESCRIPTION]
    ; Для указания действий, выполняемых по нажатию назначенной клавиши возможно использование как сканкодов и названий клавиш (для использования их непосредственно как клавиш клавиатуры), так и использование целых текстовых фраз (для отправки текста).
    ; Примеры:
    ;   {NumpadEnter} - означает нажатие клавиши "Enter" на нампаде.
    ;   NumpadEnter - означает отправку текста "NumpadEnter".
    ;   {Q} - означает отправку/нажатие латинской "Q" (в независимости от текущей раскладки).
    ;   {SC010} - означает нажатие клавиши "Q" на клавиатуре (в зависимости от текущей раскладки это будет "Q" или "Й"),
    ;   {q}{w}{e}{r}{t}{y} - qwerty, как последовательность нажатий латинских букв;
    ;   qwerty - qwerty, как текстовая строка;
    ;
    ; Для корректной работы сразу на всех раскладками необходимо использовать сканкоды буквенных клавиш вместо их названий {Q} --> {SC010}.
    ; Для не буквенных клавиш типа {NumpadEnter} {1} {2} {3} сканкоды не требуются.
    ;
    ; В разделе [OPTIONS] сканкоды и названия клавиш указываются без фигурных скобок {SC010} --> SC010.
    ; Также возможно использование модификаторов:
    ; ! - Alt
    ; ^ - Control
    ; + - Shift
    ; Пример: ^!s = Ctrl+Alt+S
    ; Подробней: https://autohotkey.com/docs/Hotkeys.htm
	
	)
	FileAppend,%text%,%EmptyFile%,%Encoding%
}
