; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher  | v1.0.0

#NoEnv ;Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ;Enable warnings to assist with detecting common errors.
SendMode, Input ;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ;Ensures a consistent starting directory.

;~ #SingleInstance,Force
;~ #Persistent ;to make it run indefinitely
;~ #NoTrayIcon

;~ Process,Priority,,High
;~ SetBatchLines,-1 ;Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

;~ DetectHiddenWindows,Off

ForceSingleInstance() ; Закрыть все открытые копии скрпита
;~ RunAsAdmin(A_ScriptFullPath) ; Запустить скрипт от имени администратора

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME " v" SCRIPT_VERSION " (by Ægir)"
SCRIPT_WIN_TITLE_SHORT := SCRIPT_NAME " v" SCRIPT_VERSION

CreateLocalization:
{
	L := {}
	
	L["Show Borders"] := "Show Borders"
	L["Fix Position"] := "Fix Position"
	L["Edit Config"] := "Edit Config"
	L["Save Config"] := "Save Config"
	L["Generate Dictionary"] := "Generate Dictionary"
	L["Open project site"] := "Open project site"
	L["Predict Layout"] := "Predict Layout"
	
	If (A_Language = "0419") {
		L["Show Borders"] := "Показать границы"
		L["Fix Position"] := "Зафиксировать"
		L["Save Config"] := "Сохранить настройки"
		L["Edit Config"] := "Открыть настройки"
		L["Generate Dictionary"] := "Создать словари"
		L["Open project site"] := "Открыть сайт программы"
		L["Predict Layout"] := "Определять раскладку текста"
	}
}

;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ ОСНОВНЫХ ПЕРЕМЕННЫХ
;~ ===================================================================================
DefineGlobals:
{
	INI_FILE := SCRIPT_NAME ".ini"
	INI_FILE := A_ScriptDir "\" INI_FILE
	INI_FILE := FileGetLongPath(INI_FILE)
	
	SITE := "https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher"
}

;~ ===================================================================================
;~ ОБРАБОТКА ФАЙЛА НАСТРОЕК
;~ ===================================================================================
ReadConfigFile:
{
	SizeX := 32
	SizeY := 22
	IniRead,SizeX,%INI_FILE%,OPTIONS,SizeX,%SizeX%
	IniRead,SizeY,%INI_FILE%,OPTIONS,SizeY,%SizeY%
	
	PosX := A_Space
	PosY := A_Space
	IniRead,PosX,%INI_FILE%,OPTIONS,PosX,%PosX%
	IniRead,PosY,%INI_FILE%,OPTIONS,PosY,%PosY%
	
	Borders := 1
	IniRead,Borders,%INI_FILE%,OPTIONS,Borders,%Borders%
	
	FixPosition := 0
	IniRead,FixPosition,%INI_FILE%,OPTIONS,FixPosition,%FixPosition%
	
	;~ English := "``1234567890-=qwertyuiop[]asdfghjkl;'\zxcvbnm,./~!@#$`%^&*()_+QWERTYUIOP{}ASDFGHJKL:""|ZXCVBNM<>?"
	;~ Russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\ячсмитьбю.Ё!""№;`%:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ/ЯЧСМИТЬБЮ,"
	;~ Ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ячсмитьбю.Ё!""№;`%:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ЯЧСМИТЬБЮ,"
	
	English := "``1234567890-=qwertyuiop[]asdfghjkl;'\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""|ZXCVBNM<>?"
	Russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\ячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ/ЯЧСМИТЬБЮ,"
	Ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ЯЧСМИТЬБЮ,"
	
	IniRead,English,%INI_FILE%,DICTIONARIES,English,%English%
	IniRead,Russian,%INI_FILE%,DICTIONARIES,Russian,%Russian%
	IniRead,Ukrainian,%INI_FILE%,DICTIONARIES,Ukrainian,%Ukrainian%	
	
	PredictLayout := 1
	IniRead,PredictLayout,%INI_FILE%,OPTIONS,PredictLayout,%PredictLayout%
}

;~ ===================================================================================
;~ СОЗДАНИЕ GUI
;~ ===================================================================================
CreateGUI:
{
	Gui, Margin, 0, 0
	GUI, +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
	
	Gui, Add, Picture, w%SizeX% h%SizeY% vFlagTexture
	
	if Borders
		Gui, +Border
	
	Gui, Show, w%SizeX% h%SizeY%, %SCRIPT_WIN_TITLE_SHORT%
	Gui, +LastFound
	
	WinGet, GUIWinID, ID
	WinMove, ahk_id %GUIWinID%,, %PosX%, %PosY%
	
	OnMessage(0x201, "WM_LBUTTONDOWN")
}

AddMenuItems:
{
	Menu, Tray, Add
	
	Menu, Tray, Add, % L["Show Borders"], Menu_ToggleBorders
	If Borders
		Menu, Tray, Check, % L["Show Borders"]
	
	Menu, Tray, Add, % L["Fix Position"], Menu_ToggleFixPosition
	If FixPosition
		Menu, Tray, Check, % L["Fix Position"]
	
	Menu, Tray, Add
	Menu, Tray, Add, % L["Predict Layout"],  Menu_TogglePredictLayout
	If PredictLayout
		Menu, Tray, Check, % L["Predict Layout"]
	
	Menu, Tray, Add
	Menu, Tray, Add, % L["Save Config"], WriteConfigFile
	Menu, Tray, Add, % L["Edit Config"], Menu_EditConfig
	
	Menu, Tray, Add
	Menu, Tray, Add, % L["Generate Dictionary"], Menu_GenerateDictionary
	
	Menu, Tray, Add
	Menu, Tray, Add, % L["Open project site"], Menu_OpenProjectSite
}

;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ НАЗНАЧЕНИЙ КЛАВИШ
;~ ===================================================================================
DefineBindings:
{
	;~ Hotkey, Capslock, CycleLayouts
	Hotkey, $~Break, SwitchKeysLocale
}

OnExit, CloseApp

;~ MsgBox, 0, %SCRIPT_WIN_TITLE_SHORT%, Ready!, 0.5

PreviousLocale := "English"
SetTimer, ChangeGUIImage, On

Return

;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ ВЫЗЫВАЕМЫХ ФУНКЦИЙ И ЯРЛЫКОВ
;~ ===================================================================================
SaveWinPosition()
{
	global GUIWinID
	global INI_FILE
	WinGetPos, X, Y,,, ahk_id %GUIWinID%
	IniWrite("PosX", INI_FILE, "OPTIONS", X)
	IniWrite("PosY", INI_FILE, "OPTIONS", Y)
	return
}

WriteConfigFile:
{
	IniWrite("SizeX", INI_FILE, "OPTIONS", SizeX)
	IniWrite("SizeY", INI_FILE, "OPTIONS", SizeY)
	
	SaveWinPosition()
	
	IniWrite("Borders", INI_FILE, "OPTIONS", Borders)
	IniWrite("FixPosition", INI_FILE, "OPTIONS", FixPosition)
	
	IniWrite("English", INI_FILE, "DICTIONARIES", English)
	IniWrite("Russian", INI_FILE, "DICTIONARIES", Russian)
	IniWrite("Ukrainian", INI_FILE, "DICTIONARIES", Ukrainian)
	
	IniWrite("PredictLayout", INI_FILE, "OPTIONS", PredictLayout)
	
	return
}

CloseApp:
{
	;~ gosub WriteConfigFile
	ExitApp
}

ChangeGUIImage:
{
	CurrentLocale := CurrentKeyboardLayout("A")[1].Locale
	if (not CurrentLocale or CurrentLocale == "") {
		CurrentLocale := "English"
	}
	If (PreviousLocale != CurrentLocale) {
		Image := A_WorkingDir "\Images\" CurrentLocale
		If FileExist(Image ".png") {
			Image := Image ".png"
		} else if FileExist(Image ".jpg") {
			Image := Image ".jpg"
		} else {
			SoundPlay, *16
			MsgBox, 0, %SCRIPT_WIN_TITLE_SHORT% - Error, There is no image for:`n%CurrentLocale%, 3.0
		}
		GuiControl,, FlagTexture, *w%SizeX% *h%SizeY% %Image%
		PreviousLocale := CurrentLocale
		NextLocale := CurrentKeyboardLayout("A")[2].Locale
	}
	return
}

SwitchKeysLocale:
{
	SwitchKeysLocale()
	return
}
;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ ФУНКЦИЙ, ВЫЗЫВАЕМЫХ GUI
;~ ===================================================================================
GuiContextMenu:
{
	Menu, Tray, Show
	return
}

Menu_ToggleBorders:
{
	Borders := !Borders
	
	if Borders
		Gui, +Border
	else
		Gui, -Border
	
	IniWrite("Borders", INI_FILE, "OPTIONS", Borders)
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	return
}

Menu_ToggleFixPosition:
{
	FixPosition := !FixPosition
	IniWrite("FixPosition", INI_FILE, "OPTIONS", FixPosition)
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	return
}

Menu_TogglePredictLayout:
{
	PredictLayout := !PredictLayout
	IniWrite("PredictLayout", INI_FILE, "OPTIONS", PredictLayout)
	Menu, Tray, ToggleCheck, %A_ThisMenuItem%
	return
}


Menu_GenerateDictionary:
{
	GenerateDictionary()
	return
}


Menu_EditConfig:
{
	Run, notepad.exe "%INI_FILE%"
	return
}

Menu_OpenProjectSite:
{
	Run, %SITE%
}

WM_LBUTTONDOWN()
{
	global FixPosition
	if FixPosition
		return
	
	PostMessage,0xA1,2
	SaveWinPosition()
	return
}

GenerateDictionary()
{
	static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()
	
	Run,notepad.exe /W,,,WinPID
	
	WinWait,ahk_pid %WinPID%
	WinGet,WinID,ID
	WinTitle = ahk_id %WinID%
	
	WinActivate, %WinTitle%
	WinWaitActive, %WinTitle%
	
	Critical
	
	Keys:=["SC029","SC002","SC003","SC004","SC005","SC006","SC007","SC008","SC009","SC00A","SC00B","SC00C","SC00D","SC010","SC011","SC012","SC013","SC014","SC015","SC016","SC017","SC018","SC019","SC01A","SC01B","SC01E","SC01F","SC020","SC021","SC022","SC023","SC024","SC025","SC026","SC027","SC028","SC02B","SC02C","SC02D","SC02E","SC02F","SC030","SC031","SC032","SC033","SC034","SC035"]
		
	Sleep, 500
	PostMessage, 0x50, 0, 0x4090409,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
		
	For pos, InputLayout in LayoutsList {
		Sleep, 500
		PostMessage, 0x50, 0, LayoutsList[pos].HKL,, %WinTitle% ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
		Sleep, 500
	
		Dict := LayoutsList[pos].Locale
	
		SendRaw,% Dict "="
	
		For k,v in Keys {
			Send,{%v%}
		}
		
		Send,{SC039}
		
		For k,v in Keys {
			Send,+{%v%}
		}
		
		SendRaw,% "`n"
		
	}
}

;~ ===================================================================================
;~ ФУНКЦИИ КОНВЕРТАЦИИ ТЕКСТА
;~ ===================================================================================
SwitchKeysLocale()
{
	Critical
	SetBatchLines, -1
	SetKeyDelay, 0

	TempClipboard := ClipboardAll
	Clipboard =
	SendInput, ^{vk43} ; Ctrl + C
	ClipWait, 0
	; если буфер обмена пуст (ничего не выделено), определяем и выделяем
	; с помощью ф-ции GetWord() последнее слово слева от курсора
	SelText := ErrorLevel ? GetWord() : Clipboard
	;~ pResult := ConvertText(SelText)   ; получаем конвертированный текст и раскладку последней найденной буквы
	;~ Clipboard := StrGet(pResult + A_PtrSize)
	
	if not SelText or SelText == ""
		return
	
	global PredictLayout
	
	if (PredictLayout) {
		global English
		global Russian
		global Ukrainian
		
		static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()
		
		For pos, InputLayout in LayoutsList {
			LocaleName := InputLayout.Locale
			Dict := %LocaleName%
			if (Dict) {
				isDict := false
				Loop, parse, SelText
				{
					isDict := InStr(Dict, A_LoopField, 1)
					if not isDict
						break
				}
				if (isDict) {
					;~ MsgBox, % "isDict = " LocaleName "`n" InputLayout.HKL
					PostMessage, 0x50, 0, % InputLayout.HKL,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
					Sleep, 250
				}
			}
		}
		;~ MsgBox % GetKeyboardLayoutByLocale("English").Locale
	}
	
	Dict1 := CurrentKeyboardLayout("A")[1].Locale
	Dict2 := CurrentKeyboardLayout("A")[2].Locale
	
	if (Dict1 == Dict2) {
		return
	}
	
	pResult := ConvertText(SelText, %Dict1%, %Dict2%)
	Clipboard := pResult
	
	SendInput, ^{vk56}   ; Ctrl + V
	; переключаем раскладку клавиатуры в зависимости от раскладки последней найденной буквы
	Sleep, 200
	;~ SwitchLocale(NumGet(pResult+0, "UInt"))
	
	SwitchKeyboardLayout("A")
	
	Sleep, 200
	Clipboard := TempClipboard
}

GetWord()
{
	While A_Index < 10
	{
		Clipboard =
		SendInput, ^+{Left}^{vk43}
		ClipWait, 1
		if ErrorLevel
			Return

		if RegExMatch(Clipboard, "P).*([ \t])", Found)
		{
			SendInput, ^+{Right}
			Return SubStr(Clipboard, FoundPos1 + 1)
		}

		PrevClipboard := Clipboard
		Clipboard =
		SendInput, +{Left}^{vk43}
		ClipWait, 1
		if ErrorLevel
			Return

		if (StrLen(Clipboard) = StrLen(PrevClipboard))
		{
			Clipboard =
			SendInput, +{Left}^{vk43}
			ClipWait, 1
			if ErrorLevel
				Return

			if (StrLen(Clipboard) = StrLen(PrevClipboard))
				Return Clipboard
			Else
			{
				SendInput, +{Right 2}
				Return PrevClipboard
			}
		}

		SendInput, +{Right}

		s := SubStr(Clipboard, 1, 1)
		if s in %A_Space%,%A_Tab%,`n,`r
		{
			Clipboard =
			SendInput, +{Left}^{vk43}
			ClipWait, 1
			if ErrorLevel
				Return

			Return Clipboard
		}
	}
}

ConvertText(Text, Dict1, Dict2)
{
	static Result
	NewText := ""
	Loop, parse, Text
	{
		found =
			if found := InStr(Dict1, A_LoopField, 1)
				NewText .= SubStr(Dict2, found, 1)
			if !found
				NewText .= A_LoopField
	}
	Result := NewText
	return Result
}
;~ ===================================================================================

;~ ===================================================================================
;~ ФУНКЦИИ УПРАВЛЕНИЯ РАСКЛАДКАМИ КЛАВИАТУРЫ
;~ ===================================================================================
CycleLayouts:
{
    Tooltip % SwitchKeyboardLayout("A")
    SetTimer, REMOVE_TOOLTIP, -800
    return
}

REMOVE_TOOLTIP:
{
    ToolTip
    return
}

/*
GetKeyboardLayoutByLocale(Locale)
{
    static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()
	
	For pos, InputLayout in LayoutsList {
		if (InputLayout.Locale == Locale) {
			return InputLayout
		}
	}
}
*/

CurrentKeyboardLayout(window)
{
    static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()

    If !hWnd := WinExist(window)
        return

    WinGetClass, winClass
    If (winClass == "ConsoleWindowClass")
    {
        WinGet, consolePID, PID
        currentDisplayName := GetLayoutDisplayName(GetConsoleKeyboardLayoutName(consolePID))
        For pos, InputLayout in LayoutsList
            continue
        Until InputLayout.DisplayName = currentDisplayName
    }
    Else
    {
        currentHKL := GetKeyboardLayout(hWnd)
        For pos, InputLayout in LayoutsList
            continue
        Until InputLayout.HKL = currentHKL
    }
    nextPos := Mod(pos, layoutsListSize)+1
	
	return [LayoutsList[pos], LayoutsList[nextPos]]
}

;~ ---------

SwitchKeyboardLayout(window)
{
    static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()

    If !hWnd := WinExist(window)
        return

    WinGetClass, winClass
    If (winClass == "ConsoleWindowClass")
    {
        WinGet, consolePID, PID
        currentDisplayName := GetLayoutDisplayName(GetConsoleKeyboardLayoutName(consolePID))
        For pos, InputLayout in LayoutsList
            continue
        Until InputLayout.DisplayName = currentDisplayName
    }
    Else
    {
        currentHKL := GetKeyboardLayout(hWnd)
        For pos, InputLayout in LayoutsList
            continue
        Until InputLayout.HKL = currentHKL
    }
    nextPos := Mod(pos, layoutsListSize)+1

    ;~ PostMessage, 0x50,, LayoutsList[nextPos].HKL
	PostMessage, 0x50, 0, LayoutsList[nextPos].HKL,, A ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
	
    return LayoutsList[nextPos].Locale . " - " . LayoutsList[nextPos].DisplayName
}

CreateLayoutsList()
{
	static LayoutsList
    LayoutsList := {}
    , keyboardLayoutListSize := DllCall("GetKeyboardLayoutList", "UInt", 0, "UInt", 0)
    , VarSetCapacity(keyboardLayoutList, keyboardLayoutListSize * A_PtrSize)
    , DllCall("GetKeyboardLayoutList", "UInt", keyboardLayoutListSize, "Ptr", &keyboardLayoutList)

    Loop %keyboardLayoutListSize%
        HKL := NumGet(keyboardLayoutList, (A_Index-1)*A_PtrSize)
        , LayoutsList.Insert({HKL: HKL, DisplayName: GetLayoutDisplayName(HKLtoKLID(HKL)), Locale: GetLocaleInfo(HKL & 0xFFFF)})
    return LayoutsList
}

GetLayoutDisplayName(KLID)
{
    RegRead, displayName, HKEY_LOCAL_MACHINE, SYSTEM\CurrentControlSet\Control\Keyboard Layouts\%KLID%, Layout Display Name

    if !displayName
        return false

    SHLoadIndirectString(displayName, displayName)

    return displayName
}

GetLocaleInfo(langId)
{
    VarSetCapacity(localeSig, size :=  DllCall("GetLocaleInfo", "UInt", langId, "UInt", 0x1001, "UInt", 0, "UInt", 0) * 2)
    , DllCall("GetLocaleInfo"
        , "UInt", langId
        , "UInt", 0x1001
        , "Str" , localeSig
        , "UInt", size)
    return localeSig
}

HKLtoKLID(HKL)
{
    VarSetCapacity(KLID, 8*(A_IsUnicode+1))

    priorHKL := GetKeyboardLayout(0)

    if !ActivateKeyboardLayout(HKL, 0)
        return false

    if !GetKeyboardLayoutName(KLID)
        return false

    if !ActivateKeyboardLayout(priorHKL, 0)
        return false

    return StrGet(&KLID)
}

GetConsoleKeyboardLayoutName(ByRef consolePID)
{
    VarSetCapacity(KLID, 16)

    DllCall("AttachConsole", "Ptr", consolePID)
    DllCall("GetConsoleKeyboardLayoutName", "Ptr", &KLID)
    DllCall("FreeConsole")

    VarSetCapacity(KLID, -1)
    return KLID
}

ActivateKeyboardLayout(ByRef HKL, flags)
{
    return DllCall("ActivateKeyboardLayout", "Ptr", HKL, "UInt", flags)
}

GetKeyboardLayout(ByRef hWnd)
{
    return DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", hWnd, "UInt", 0, "Ptr"), "Ptr")
}

GetKeyboardLayoutName(ByRef KLID)
{
    return DllCall("GetKeyboardLayoutName", "Ptr", &KLID)
}

SHLoadIndirectString(ByRef source, ByRef outBuf, outBufSize = 50)
{
    return DllCall("Shlwapi.dll\SHLoadIndirectString", "Ptr", &source, "Ptr", &outBuf, "UInt", outBufSize, "UInt", 0)
}
;~ ===================================================================================



;~ ОБЩИЕ ФУНКЦИИ (БИБЛИОТЕКА)

;~ ===================================================================================
;~ ФУНКЦИЯ ЗАПУСКА СКРИПТА С ПРАВАМИ АДИМИНИСТРАТОРА
;~ ===================================================================================
RunAsAdmin(ScriptPath:=False) {
	If (not A_IsAdmin) {
		ScriptPath:=ScriptPath?ScriptPath:A_ScriptFullPath
		Try
		{
			Run,*RunAs "%ScriptPath%"
		} Catch {
			; MsgBox,You cancelled when asked to elevate to admin!
		}
		ExitApp
	}
}

; ===================================================================================
; ФУНКЦИЯ АВТОМАТИЧЕСКОГО ЗАВЕРШЕНИЯ ВСЕХ КОПИЙ ТЕКУЩЕГО ПРОЦЕССА (КРОМЕ АКТИВНОЙ)
; ===================================================================================
ForceSingleInstance() { 
	DetectHiddenWindows,On
	#SingleInstance,Off
	WinGet, CurrentID, ID, %A_ScriptFullPath% ahk_class AutoHotkey
	WinGet, ProcessList, List, %A_ScriptFullPath% ahk_class AutoHotkey
	ProcessCount := 1
	Loop, %ProcessList% {
		ProcessID := ProcessList%ProcessCount%
		If (ProcessID != CurrentID) {
			WinGet, ProcessPID, PID, %A_ScriptFullPath% ahk_id %ProcessID%
			Process, Close, %ProcessPID%
		}
		ProcessCount += 1
	}	 
	Return
}

;~ ===================================================================================
;~ ФУНКЦИЯ ПОЛУЧЕНИЯ ИМЕНИ ТЕКУЩЕГО СКРИПТА
;~ ===================================================================================
GetScriptName() {
	SplitPath,A_ScriptFullPath,,,,Name,
	Return,Name
}

;~ ===================================================================================
;~ ФУНКЦИЯ УДАЛЕНИЯ ЛИШНИХ СИМВОЛОВ ИЗ ПУТЕЙ
;~ ===================================================================================
TrimPath(GivenPath) {
	GivenPath := StrReplace(GivenPath, """", "") ; Удаление кавычек из пути
	GivenPath := RegExReplace(GivenPath, "[\\+]$", "", ,1) ; Удаление замыкающего слэша из пути
	GivenPath := RegExReplace(GivenPath, "^[\\+]", "", ,1) ; Удаление предшествующего слэша из пути
	Return,GivenPath
}

;~ ===================================================================================
;~ ФУНКЦИЯ ПОЛУЧЕНИЯ ПОЛНОГО ПУТИ К ФАЙЛУ
;~ ===================================================================================
FileGetLongPath(GivenPath) {
	GivenPath := TrimPath(GivenPath)
	IfExist,%GivenPath%
	{
		Loop,%GivenPath%,1
		{
			Return,A_LoopFileLongPath
		}
	} Else {
		Return,GivenPath
	}
}

IniWrite(Key, File, Section, Value) {
	IniRead, TestValue ,%File%, %Section%, %Key%
	If (TestValue != Value) {
		IniWrite ,%Value%, %File%, %Section%, %Key%
	}
}
