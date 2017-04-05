﻿; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher  | v1.0.0

#NoEnv ;Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ;Enable warnings to assist with detecting common errors.
SendMode,Input ;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ;Ensures a consistent starting directory.

#SingleInstance,Force
; #Persistent ;to make it run indefinitely
; #NoTrayIcon

Process,Priority,,High
; SetBatchLines,-1 ;Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

; DetectHiddenWindows,Off
DetectHiddenWindows,On

ForceSingleInstance() ; Закрыть все открытые копии скрпита
; RunAsAdmin(A_ScriptFullPath) ; Запустить скрипт от имени администратора

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
	L["Tray Icon"] := "Tray Icon"
	L["Reload"] := "Reload"
	L["Suspend"] := "Suspend HotKeys"
	L["Exit"] := "Exit"
	L["Error"] := "Error"
	L["There is no image for: "] := "There is no image for: "
	L["There is no dictionary for: "] := "There is no dictionary for: "
	L["Auto Start"] := "Auto Start"
	L["Run as Admin"] := "Run as Admin"
	L["Always on Top"] := "Always on Top"
	L["Sounds"] := "Sounds"
	L["Encoding Compatibility Mode"] := "Encoding Compatibility Mode"
	L["Hide in Fullscreen Mode"] := "Hide in Fullscreen Mode"
	If (A_Language = "0419") {
		L["Show Borders"] := "Показать границы"
		L["Fix Position"] := "Зафиксировать"
		L["Save Config"] := "Сохранить настройки"
		L["Edit Config"] := "Открыть настройки"
		L["Generate Dictionary"] := "Создать словари"
		L["Open project site"] := "Открыть сайт программы"
		L["Predict Layout"] := "Определять раскладку текста"
		L["Tray Icon"] := "Иконка в трее"
		L["Reload"] := "Перезапустить"
		L["Suspend"] := "Отключить кнопки"
		L["Exit"] := "Закрыть"
		L["Error"] := "Ошибка"
		L["There is no image for: "] := "Отсутствует картинка для: "
		L["There is no dictionary for: "] := "Отсутствует словарь для: "
		L["Auto Start"] := "Автозагрузка"
		L["Run as Admin"] := "Права администратора"
		L["Always on Top"] := "Поверх других окон"
		L["Sounds"] := "Звуки"
		L["Encoding Compatibility Mode"] := "Режим совместимости кодировок"
		L["Hide in Fullscreen Mode"] := "Скрывать в полноэкранном режиме"
	}
}

; ===================================================================================
; ОПРЕДЕЛЕНИЕ ОСНОВНЫХ ПЕРЕМЕННЫХ
; ===================================================================================
DefineGlobals:
{
	INI_FILE := SCRIPT_NAME ".ini"
	INI_FILE := A_ScriptDir "\" INI_FILE
	INI_FILE := FileGetLongPath(INI_FILE)
	SITE := "https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher"
	CtrlC = ^{vk43}
	CtrlV = ^{vk56}
}

; ===================================================================================
; ОБРАБОТКА ФАЙЛА НАСТРОЕК
; ===================================================================================
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

	Russian := "ё1234567890-=йцукенгшщзхъфывапролджэ\\ячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭ//ЯЧСМИТЬБЮ,"
	English := "``1234567890-=qwertyuiop[]asdfghjkl;'\\zxcvbnm,./ ~!@#$%^&*()_+QWERTYUIOP{}ASDFGHJKL:""||ZXCVBNM<>?"
	Ukrainian := "ё1234567890-=йцукенгшщзхїфівапролджє\ґячсмитьбю. Ё!""№;%:?*()_+ЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄ/ҐЯЧСМИТЬБЮ,"

	IniRead,English,%INI_FILE%,DICTIONARIES,English,%English%
	IniRead,Russian,%INI_FILE%,DICTIONARIES,Russian,%Russian%
	IniRead,Ukrainian,%INI_FILE%,DICTIONARIES,Ukrainian,%Ukrainian%

	PredictLayout := 1
	IniRead,PredictLayout,%INI_FILE%,OPTIONS,PredictLayout,%PredictLayout%

	TrayIcon := 1
	IniRead,TrayIcon,%INI_FILE%,OPTIONS,T rayIcon,%TrayIcon%

	SuspendHotKeys := 0
	IniRead,SuspendHotKeys,%INI_FILE%,OPTIONS,SuspendHotKeys,%SuspendHotKeys%

	AdminRights := 0
	IniRead,AdminRights,%INI_FILE%,OPTIONS,AdminRights,%AdminRights%

	AutoStart := 0
	IniRead,AutoStart,%INI_FILE%,OPTIONS,AutoStart,%AutoStart%

	AlwaysOnTop := 1
	IniRead,AlwaysOnTop,%INI_FILE%,OPTIONS,AlwaysOnTop,%AlwaysOnTop%
	
	Sounds := 1
	IniRead,Sounds,%INI_FILE%,OPTIONS,Sounds,%Sounds%
	
	EncodingCompatibilityMode := 0
	IniRead,EncodingCompatibilityMode,%INI_FILE%,OPTIONS,EncodingCompatibilityMode,%EncodingCompatibilityMode%
	
	HideInFullscreenMode := 1
	IniRead,HideInFullscreenMode,%INI_FILE%,OPTIONS,HideInFullscreenMode,%HideInFullscreenMode%
	
	CycleKeyboardLayouts_HotKey := "CapsLock"
	IniRead,CycleKeyboardLayouts_HotKey,%INI_FILE%,HOTKEYS,CycleKeyboardLayouts,%CycleKeyboardLayouts_HotKey%
	CycleKeyboardLayouts_Disabled := 0
	IniRead,CycleKeyboardLayouts_Disabled,%INI_FILE%,DISABLED,CycleKeyboardLayouts,%CycleKeyboardLayouts_Disabled%

	SwitchTextLayout_HotKey := "$~Break"
	IniRead,SwitchTextLayout_HotKey,%INI_FILE%,HOTKEYS,SwitchTextLayout,%SwitchTextLayout_HotKey%
	SwitchTextLayout_Disabled := 0
	IniRead,SwitchTextLayout_Disabled,%INI_FILE%,DISABLED,SwitchTextLayout,%SwitchTextLayout_Disabled%
	
	SwitchTextCase_HotKey := "$~!Break"
	IniRead,SwitchTextCase_HotKey,%INI_FILE%,HOTKEYS,SwitchTextCase,%SwitchTextCase_HotKey%
	SwitchTextCase_Disabled := 0
	IniRead,SwitchTextCase_Disabled,%INI_FILE%,DISABLED,SwitchTextCase,%SwitchTextCase_Disabled%
}

If (AdminRights) {
	RunAsAdmin(A_ScriptFullPath)
}

; ===================================================================================
; ОПРЕДЕЛЕНИЕ НАЗНАЧЕНИЙ КЛАВИШ
; ===================================================================================
DefineBindings:
{
	FunctionList := ["CycleKeyboardLayouts", "SwitchTextLayout", "SwitchTextCase"]
	DefineBindings(FunctionList)
}

DefineBindings(FunctionList)
{
	static i, Function, HK
	For i,Function in FunctionList {
		HK = %Function%_HotKey
		HK := %HK%
		D = %Function%_Disabled
		D := %D%
		If (HK and not D) {
			Hotkey,%HK%,%Function%
			; MsgBox % Function " : " HK
		}
	}
}

; ===================================================================================
; СОЗДАНИЕ GUI
; ===================================================================================
CreateGUI:
{
	Gui,Margin,0,0
	Gui,Color,FFFFFF
	GUI,+AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow

	Gui,Add,Picture,w%SizeX% h%SizeY% vFlagTexture

	if (Borders) {
		Gui,+Border
	}

	Gui,Show,w%SizeX% h%SizeY%,%SCRIPT_WIN_TITLE_SHORT%

	Gui,+LastFound
	WinGet,GUIWinID,ID
	WinMove,ahk_id %GUIWinID%,,%PosX%,%PosY%

	OnMessage(0x201,"WM_LBUTTONDOWN")
}

AddMenuItems:
{
	Menu,Tray,NoStandard

	Menu,Tray,Add,% L["Suspend"],Menu_ToggleSuspend
	If (SuspendHotKeys) {
		Suspend,On
		Menu,Tray,Check,% L["Suspend"]
	}

	Menu,Tray,Add,% L["Auto Start"],Menu_ToggleAutoStart
	If (AutoStart) {
		Menu,Tray,Check,% L["Auto Start"]
	}
	Menu,Tray,Add,% L["Run as Admin"],Menu_ToggleAdminRights
	If (AdminRights) {
		Menu,Tray,Check,% L["Run as Admin"]
	}

	Menu,Tray,Add

	Menu,Tray,Add,% L["Always on Top"],Menu_ToggleAlwaysOnTop
	If (AlwaysOnTop) {
		Menu,Tray,Check,% L["Always on Top"]
	}
	
	Menu,Tray,Add,% L["Hide in Fullscreen Mode"],Menu_ToggleHideInFullscreenMode
	If (HideInFullscreenMode) {
		Menu,Tray,Check,% L["Hide in Fullscreen Mode"]
	}

	Menu,Tray,Add,% L["Show Borders"],Menu_ToggleBorders
	If (Borders) {
		Menu,Tray,Check,% L["Show Borders"]
	}

	Menu,Tray,Add,% L["Fix Position"],Menu_ToggleFixPosition
	If (FixPosition) {
		Menu,Tray,Check,% L["Fix Position"]
	}

	Menu,Tray,Add,% L["Tray Icon"],Menu_ToggleTrayIcon
	If (TrayIcon) {
		Menu,Tray,Icon
		Menu,Tray,Check,% L["Tray Icon"]
	} Else {
		Menu,Tray,NoIcon
	}
	
	Menu,Tray,Add,% L["Sounds"],Menu_ToggleSounds
	If (Sounds) {
		Menu,Tray,Check,% L["Sounds"]
	}

	Menu,Tray,Add

	Menu,Tray,Add,% L["Predict Layout"],Menu_TogglePredictLayout
	If (PredictLayout) {
		Menu,Tray,Check,% L["Predict Layout"]
	}
	
	Menu,Tray,Add,% L["Encoding Compatibility Mode"],Menu_ToggleEncodingCompatibilityMode
	If (EncodingCompatibilityMode) {
		Menu,Tray,Check,% L["Encoding Compatibility Mode"]
	}

	Menu,Tray,Add

	Menu,Tray,Add,% L["Save Config"],WriteConfigFile
	Menu,Tray,Add,% L["Edit Config"],Menu_EditConfig

	Menu,Tray,Add

	Menu,Tray,Add,% L["Generate Dictionary"],Menu_GenerateDictionary

	Menu,Tray,Add

	Menu,Tray,Add,% L["Open project site"],Menu_OpenProjectSite

	Menu,Tray,Add

	Menu,Tray,Add,% L["Reload"],Menu_Reload
	Menu,Tray,Add,% L["Exit"],Menu_Exit
}

OnExit,CloseApp

; MsgBox,0,%SCRIPT_WIN_TITLE_SHORT%,Ready!,0.5

PreviousLang = ; empty
LayoutSwitchCount := 0
CurrentCase := 0

SetTimer,UpdateGUI,On

Exit

; ===================================================================================
; ОПРЕДЕЛЕНИЕ ВЫЗЫВАЕМЫХ ФУНКЦИЙ И ЯРЛЫКОВ
; ===================================================================================
SaveWinPosition()
{
	global GUIWinID
	global INI_FILE
	WinGetPos,X,Y,,,ahk_id %GUIWinID%
	IniWrite("PosX",INI_FILE,"OPTIONS",X)
	IniWrite("PosY",INI_FILE,"OPTIONS",Y)
	Return
}

WriteConfigFile:
{
	IniWrite("SizeX",INI_FILE,"OPTIONS",SizeX)
	IniWrite("SizeY",INI_FILE,"OPTIONS",SizeY)

	SaveWinPosition()

	IniWrite("Borders",INI_FILE,"OPTIONS",Borders)
	IniWrite("FixPosition",INI_FILE,"OPTIONS",FixPosition)

	IniWrite("PredictLayout",INI_FILE,"OPTIONS",PredictLayout)
	IniWrite("EncodingCompatibilityMode",INI_FILE,"OPTIONS",EncodingCompatibilityMode)

	IniWrite("TrayIcon",INI_FILE,"OPTIONS",TrayIcon)
	IniWrite("Sounds",INI_FILE,"OPTIONS",Sounds)

	IniWrite("SuspendHotKeys",INI_FILE,"OPTIONS",SuspendHotKeys)

	IniWrite("AutoStart",INI_FILE,"OPTIONS",AutoStart)
	IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)

	IniWrite("AlwaysOnTop",INI_FILE,"OPTIONS",AlwaysOnTop)
	IniWrite("HideInFullscreenMode",INI_FILE,"OPTIONS",HideInFullscreenMode)
	
	IniWrite("CycleKeyboardLayouts",INI_FILE,"HOTKEYS",CycleKeyboardLayouts_HotKey)
	IniWrite("CycleKeyboardLayouts",INI_FILE,"DISABLED",CycleKeyboardLayouts_Disabled)
	
	IniWrite("SwitchTextLayout",INI_FILE,"HOTKEYS",SwitchTextLayout_HotKey)
	IniWrite("SwitchTextLayout",INI_FILE,"DISABLED",SwitchTextLayout_Disabled)
	
	IniWrite("SwitchTextCase",INI_FILE,"HOTKEYS",SwitchTextCase_HotKey)
	IniWrite("SwitchTextCase",INI_FILE,"DISABLED",SwitchTextCase_Disabled)
	
	IniWrite("English",INI_FILE,"DICTIONARIES",English)
	IniWrite("Russian",INI_FILE,"DICTIONARIES",Russian)
	IniWrite("Ukrainian",INI_FILE,"DICTIONARIES",Ukrainian)

	Return
}

CloseApp:
{
	ExitApp
}


SwitchTextLayout:
{
	If (isWindowFullScreen("A")) {
		SwitchTextLayout(PredictLayout, true)
	} Else {
		SwitchTextLayout(PredictLayout, EncodingCompatibilityMode)
	}
	Return
}

SwitchTextCase:
{
	If (isWindowFullScreen("A")) {
		SwitchTextCase(true)
	} Else {
		SwitchTextCase(EncodingCompatibilityMode)
	}
	Return
}
; ===================================================================================
; ОПРЕДЕЛЕНИЕ ФУНКЦИЙ, ВЫЗЫВАЕМЫХ GUI
; ===================================================================================
GuiContextMenu:
{
	Menu,Tray,Show
	Return
}

Menu_ToggleSuspend:
{
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	SuspendHotKeys := !SuspendHotKeys
	IniWrite("SuspendHotKeys",INI_FILE,"OPTIONS",SuspendHotKeys)
	Suspend,Toggle
	Return
}

Menu_Reload:
{
	Reload
	Return
}

Menu_Exit:
{
	ExitApp
	Return
}

Menu_ToggleAlwaysOnTop:
{
	AlwaysOnTop := !AlwaysOnTop
	If (AlwaysOnTop) {
		Gui,+AlwaysOnTop
	} Else {
		Gui,-AlwaysOnTop
	}
	IniWrite("AlwaysOnTop",INI_FILE,"OPTIONS",AlwaysOnTop)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleHideInFullscreenMode:
{
	HideInFullscreenMode := !HideInFullscreenMode
	IniWrite("HideInFullscreenMode",INI_FILE,"OPTIONS",HideInFullscreenMode)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleBorders:
{
	Borders := !Borders
	If (Borders) {
		Gui,+Border
	} Else {
		Gui,-Border
	}
	Gui,Show,w%SizeX% h%SizeY%,%SCRIPT_WIN_TITLE_SHORT%
	IniWrite("Borders",INI_FILE,"OPTIONS",Borders)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleFixPosition:
{
	FixPosition := !FixPosition
	IniWrite("FixPosition",INI_FILE,"OPTIONS",FixPosition)
	SaveWinPosition()
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleTrayIcon:
{
	TrayIcon := !TrayIcon
	IniWrite("TrayIcon",INI_FILE,"OPTIONS",TrayIcon)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	If (TrayIcon) {
		Menu,Tray,Icon
	} Else {
		Menu,Tray,NoIcon
	}
	Return
}

Menu_ToggleSounds:
{
	Sounds := !Sounds
	IniWrite("Sounds",INI_FILE,"OPTIONS",Sounds)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_TogglePredictLayout:
{
	PredictLayout := !PredictLayout
	IniWrite("PredictLayout",INI_FILE,"OPTIONS",PredictLayout)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleEncodingCompatibilityMode:
{
	EncodingCompatibilityMode := !EncodingCompatibilityMode
	IniWrite("EncodingCompatibilityMode",INI_FILE,"OPTIONS",EncodingCompatibilityMode)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_GenerateDictionary:
{
	GenerateDictionary()
	Return
}

Menu_EditConfig:
{
	GoSub,WriteConfigFile
	Run,notepad.exe "%INI_FILE%"
	Return
}

Menu_OpenProjectSite:
{
	Run,%SITE%
	Return
}

Menu_ToggleAdminRights:
{
	If (AdminRights) {
		RunAsAdmin(A_ScriptFullPath)
		AdminRights := !AdminRights
		IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)
	} Else {
		AdminRights := !AdminRights
		IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)
		Reload
	}
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

Menu_ToggleAutoStart:
{
	; RunAsAdmin(A_ScriptFullPath)
	AutoStart := !AutoStart
	IniWrite("AutoStart",INI_FILE,"OPTIONS",AutoStart)
	TaskName := "CustomTasks\" SCRIPT_NAME
	If (AutoStart) {
		cmd = "%A_WinDir%\System32\schtasks.exe" /create /TN "%TaskName%" /TR """"%A_ScriptFullPath%"""" /SC ONLOGON
		cmd .= AdminRights ? " /RL HIGHEST /F" : " /F"
	} Else {
		cmd = "%A_WinDir%\System32\schtasks.exe" /delete /TN "%TaskName%" /F
	}
	RunWait,*RunAs %cmd%
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	Return
}

WM_LBUTTONDOWN()
{
	global FixPosition
	If (FixPosition) {
		Return
	}

	PostMessage,0xA1,2
	SaveWinPosition()
	Return
}

GenerateDictionary()
{
	Run,% "notepad.exe /W",,,WinPID

	WinWait,ahk_pid %WinPID%
	WinGet,WinID,ID,ahk_pid %WinPID%

	WinTitle = ahk_id %WinID%

	Keys := ["SC029","SC002","SC003","SC004"
	,"SC005","SC006","SC007","SC008","SC009"
	,"SC00A","SC00B","SC00C","SC00D","SC010"
	,"SC011","SC012","SC013","SC014","SC015"
	,"SC016","SC017","SC018","SC019","SC01A"
	,"SC01B","SC01E","SC01F","SC020","SC021"
	,"SC022","SC023","SC024","SC025","SC026"
	,"SC027","SC028","SC02B","SC056","SC02C"
	,"SC02D","SC02E","SC02F","SC030","SC031"
	,"SC032","SC033","SC034","SC035"]

	Critical

	WinActivate,%WinTitle%
	WinWaitActive,%WinTitle%

	For LayoutIndex,InputLayout in Lyt.GetList() {
		WinActivate,%WinTitle%
		WinWaitActive,%WinTitle%
		IfWinActive,%WinTitle%
		{
			While (Lyt.GetInputHKL(WinTitle) != InputLayout.h and A_Index < 5) {
				Lyt.Set(InputLayout.h,WinTitle)
				Sleep,50
				UpdateGUIImage()
				Sleep,100
			}
			If (Lyt.GetInputHKL(WinTitle) = InputLayout.h) {
				Dict := InputLayout.LngFullName
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
	}

	Critical,Off
}

; ===================================================================================
; ФУНКЦИИ КОНВЕРТАЦИИ ТЕКСТА
; http://forum.іcript-coding.com/viewtopic.php?id=7186
; ===================================================================================
SwitchTextCase(EncodingCompatibilityMode)
{
	Critical
	SetBatchLines,-1
	SetKeyDelay,0

	global CtrlC, CtrlV
	
	SavedClip := ClipboardAll

	SelectedText := GetSelection()

	If (not SelectedText) {
		return
	}
	
	global CurrentCase
	
	ConvertedText = ; empty
	
	if (CurrentCase = 0) { ; lower case
		StringLower, ConvertedText, SelectedText
	} else if (CurrentCase = 1) { ; title case
		StringLower, ConvertedText, SelectedText, T
	} else if (CurrentCase = 2) { ; upper case
		StringUpper, ConvertedText, SelectedText
	}
	
	CurrentCase := CurrentCase < 2 ? CurrentCase + 1 : 0
	
	if (EncodingCompatibilityMode) {
		ConvertedText := RegExReplace(ConvertedText, "`r`n", "`n")
		SetKeyDelay,10
		SendEvent,%ConvertedText%
	} else {
		Clipboard = ; empty
		Clipboard := ConvertedText
		ClipWait,1
		SendInput,%CtrlV%
	}
	
	global Sounds
	If (Sounds) {
		static SoundFile :=  A_WorkingDir "\Sounds\" "CaseSwitched.wav"
		If FileExist(SoundFile) {
			SoundPlay,%SoundFile%
		}
	}
		
	Clipboard = ; empty
	Sleep,100
	Clipboard := SavedClip
	ClipWait,1
	
}

SwitchTextLayout(PredictLayout, EncodingCompatibilityMode)
{
	; ShowToolTip("PredictLayout:" PredictLayout)

	Critical
	SetBatchLines,-1
	SetKeyDelay,0

	global CtrlC, CtrlV
	
	SavedClip := ClipboardAll

	SelectedText := GetSelection()

	If (not SelectedText) {
		return
	}

	If (PredictLayout) {
		global LayoutSwitchCount
		If (LayoutSwitchCount < 1) {
			global INI_FILE, SCRIPT_WIN_TITLE_SHORT, L
			For LayoutIndex,InputLayout in Lyt.GetList() {
				Language := InputLayout.LngFullName
				IniRead,Dictionary,%INI_FILE%,DICTIONARIES,%Language%,A_Space
				If (Dictionary) {
					isDict := False
					Loop, Parse, SelectedText
					{
						isDict := InStr(Dictionary,A_LoopField,1) or RegExMatch(A_LoopField,"(\s+)",WhiteSpace)
						If (not isDict) {
							Break
						}
					}
					If (isDict) {
						; ShowToolTip("isDict = " Language "`n" InputLayout.HKL)
						LayoutSwitchCount += 1
						SwitchResetTimeout := EncodingCompatibilityMode ? -Max(1000, StrLen(SelectedText)*10) : -1000
						SetTimer,ResetSwitchCount,%SwitchResetTimeout%
						; MsgBox % SwitchResetTimeout
						Lyt.Set(InputLayout.h)
						Sleep,50
						UpdateGUIImage()						
						Break
					}
				} Else {
					SoundPlay,*16
					MsgBox,0,% SCRIPT_WIN_TITLE_SHORT " - " L["Error"],% L["There is no dictionary for: "] "`n" Language,3.0
				}
			}
		}
	}

	layoutsList := Lyt.GetList()
	layoutsListSize := layoutsList.MaxIndex()
	curLayoutNum := Lyt.GetNum()
	nextLayoutNum := Mod(curLayoutNum, layoutsListSize) + 1
	LangTranslateFrom := layoutsList[curLayoutNum].LngFullName
	LangTranslateTo := layoutsList[nextLayoutNum].LngFullName
	; ShowToolTip("LangTranslateFrom: " LangTranslateFrom "`nLangTranslateTo: " LangTranslateTo)
	If (LangTranslateTo = LangTranslateFrom) {
		return
	}
	DictTranslateFrom := %LangTranslateFrom%
	DictTranslateTo := %LangTranslateTo%
	
	Lyt.Set(layoutsList[nextLayoutNum].h)
	Sleep,50

	ConvertedText = ; empty
	ConvertedText := ConvertText(SelectedText, DictTranslateFrom, DictTranslateTo)
	
	if (EncodingCompatibilityMode) {
		ConvertedText := RegExReplace(ConvertedText, "`r`n", "`n")
		SetKeyDelay,10
		SendEvent,%ConvertedText%
	} else {
		Clipboard = ; empty
		Clipboard := ConvertedText
		ClipWait,1
		SendInput,%CtrlV%
	}

	UpdateGUIImage()
	ShowLangTooltip()
	
	global Sounds
	If (Sounds) {
		static SoundFile :=  A_WorkingDir "\Sounds\" "TextConverted.wav"
		If FileExist(SoundFile) {
			SoundPlay,%SoundFile%
		}
	}
		
	Clipboard = ; empty
	Sleep,100
	Clipboard := SavedClip
	ClipWait,1
}

GetSelection()
{
	global CtrlC

	Clipboard = ; empty
	Sleep,100
	SendInput,%CtrlC%
	ClipWait,1

	SelectedText = ; empty
	If (Clipboard) {
		SelectedText := Clipboard
	} else {
		WhiteSpace := False
		Loop, 100 {
			Clipboard = ; empty
			SendInput,^+{Left}
			SendInput,%CtrlC%
			ClipWait,1
			if (StrLen(Clipboard) = StrLen(SelectedText)) {
				Break
			}
			if RegExMatch(Clipboard, "(\s+)", WhiteSpace) {
				Clipboard = ; empty
				SendInput,^+{Right}
				SendInput,%CtrlC%
				ClipWait,1
				Break
			}
			SelectedText := Clipboard
		}
		SelectedText := Clipboard
	}
	
	Return,Clipboard
}

ConvertText(Text,Dict1,Dict2)
{
	NewText = ; Empty
	Loop,Parse,Text
	{
		Found = ; Empty
		If (Found := InStr(Dict1,A_LoopField,1)) {
			NewText .= SubStr(Dict2,Found,1)
		} Else {
			NewText .= A_LoopField
		}
	}
	Return,NewText
}
; ===================================================================================

; ===================================================================================
; ФУНКЦИИ УПРАВЛЕНИЯ ЭЛЕМЕНТАМИ GUI
; ===================================================================================
UpdateGUI:
{
	UpdateGUIImage()
	If (AlwaysOnTop and HideInFullscreenMode) {
		isInFullScreen := isWindowFullScreen("A")
		if (isInFullScreen) {
			Gui,-AlwaysOnTop
		} else {
			Gui,+AlwaysOnTop
		}
	}
	Return
}

UpdateGUIImage()
{
	static CurrentLang
	global PreviousLang, SCRIPT_WIN_TITLE_SHORT, L
	global TrayIcon, FlagTexture, SizeX, SizeY
	
	If (!CurrentLang := Lyt.GetLng(,,true)) {
		Return
	}

	If (CurrentLang = PreviousLang) {
		Return
	} else {
		ImageFile = ; empty
		ImageTypes := [".png",".jpg"]
		For i,ImageType in ImageTypes {
			FilePattern := A_WorkingDir "\Images\" . CurrentLang . ImageType
			Loop,Files,%FilePattern%,F
			{
				ImageFile := A_LoopFileFullPath
				Break
			}
		}

		If (ImageFile) {
			GuiControl,,FlagTexture,*w%SizeX% *h%SizeY% %ImageFile%
		} Else {
			SoundPlay,*16
			MsgBox,0,% SCRIPT_WIN_TITLE_SHORT " - " L["Error"],% L["There is no image for: "] "`n" CurrentLang,3.0
		}

		If (TrayIcon) {
			IconFile := A_WorkingDir "\Icons\" CurrentLang ".ico"
			If FileExist(IconFile) {
				Menu,Tray,Icon,%IconFile%
			}
		} Else {
			Menu,Tray,NoIcon
		}

		PreviousLang := CurrentLang
	}
}

; ===================================================================================
; ФУНКЦИИ УПРАВЛЕНИЯ РАСКЛАДКАМИ КЛАВИАТУРЫ
; ===================================================================================
CycleKeyboardLayouts:
{
	Lyt.Set("Forward")
	Sleep,50
	UpdateGUIImage()	
	ShowLangTooltip()
	
	If (Sounds) {
		SoundFile :=  A_WorkingDir "\Sounds\" "LayoutChanged.wav"
		If FileExist(SoundFile) {
			SoundPlay,%SoundFile%
		}
	}
	return
}

ShowLangTooltip(win := 0, HKL := 0, time := -800)
{
	text := Lyt.GetLng(win,HKL,true) " - " Lyt.GetDisplayName(win)
	ShowToolTip(text, time)
}

ShowToolTip(text, time := -800)
{
	Tooltip, %text%
	SetTimer,ClearToolTips,%time%
}

ClearToolTips:
{
	ToolTip
	return
}

ResetSwitchCount:
{
	LayoutSwitchCount := 0
}
; ===================================================================================



; ОБЩИЕ ФУНКЦИИ (БИБЛИОТЕКА)

; ===================================================================================
; ФУНКЦИЯ ЗАПУСКА СКРИПТА С ПРАВАМИ АДИМИНИСТРАТОРА
; ===================================================================================
RunAsAdmin(ScriptPath := False)
{
	If (not A_IsAdmin) {
		ScriptPath := ScriptPath ? ScriptPath : A_ScriptFullPath
		Try {
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
ForceSingleInstance()
{
	DetectHiddenWindows,On
	#SingleInstance,Off
	FileTypes := [".exe",".ahk"]
	For i,FileType in FileTypes {
		ScriptName := RegExReplace(A_ScriptName, "^(.*)\.(.*)$", "$1") . FileType
		ScriptFullPath := A_ScriptDir . "\" . ScriptName
		CloseOtherScriptInstances(ScriptFullPath . "ahk_class AutoHotkey")
	}
}

CloseOtherScriptInstances(ScriptFullPath)
{
	ScriptFullPath := ScriptFullPath ? ScriptFullPath : A_ScriptFullPath " ahk_class AutoHotkey"
	WinGet,CurrentID,ID,%A_ScriptFullPath% ahk_class AutoHotkey
	WinGet,ProcessList,List,%ScriptFullPath% ahk_class AutoHotkey
	ProcessCount := 1
	Loop,%ProcessList%
	{
		ProcessID := ProcessList%ProcessCount%
		If (ProcessID != CurrentID) {
			WinGet,ProcessPID,PID,%ScriptFullPath% ahk_id %ProcessID%
			Process,Close,%ProcessPID%
		}
		ProcessCount += 1
	}
}

; ===================================================================================
; ФУНКЦИЯ ПОЛУЧЕНИЯ ИМЕНИ ТЕКУЩЕГО СКРИПТА
; ===================================================================================
GetScriptName() {
	SplitPath,A_ScriptFullPath,,,,Name
	Return,Name
}

; ===================================================================================
; ФУНКЦИЯ УДАЛЕНИЯ ЛИШНИХ СИМВОЛОВ ИЗ ПУТЕЙ
; ===================================================================================
TrimPath(GivenPath) {
	GivenPath := StrReplace(GivenPath,"""","") ; Удаление кавычек из пути
	GivenPath := RegExReplace(GivenPath,"[\\+]$","",,1) ; Удаление замыкающего слэша из пути
	GivenPath := RegExReplace(GivenPath,"^[\\+]","",,1) ; Удаление предшествующего слэша из пути
	Return,GivenPath
}

; ===================================================================================
; ФУНКЦИЯ ПОЛУЧЕНИЯ ПОЛНОГО ПУТИ К ФАЙЛУ
; ===================================================================================
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

; ===================================================================================
; ЗАМЕНА СТАНДАРТОНГО IniWrite (ЗАПИСЫВАЕТ ТОЛЬКО ИЗМЕНЕННЫЕ ПАРАМЕТРЫ)
; ===================================================================================
IniWrite(Key,File,Section,Value) {
	IniRead,TestValue,%File%,%Section%,%Key%
	If (TestValue != Value) {
		IniWrite,%Value%,%File%,%Section%,%Key%
	}
}

/* НЕ ИСПОЛЬЗУЕМОЕ
; ===================================================================================
; ПЕРВОД ДЕСЯТИЧНОГО ЧИСЛА В HEX
; ===================================================================================
DecToHex(Dec)
{
	SetFormat,IntegerFast,Hex
	Return,Dec
}
*/

isWindowFullScreen(winTitle := "A") {
	;checks if the specified window is full screen
	winID := WinExist(winTitle)
	If (!winID) {
		Return,false
	}
	WinGet,style,Style,ahk_id %WinID%
	WinGetPos,,,winW,winH,%winTitle%
	; 0x800000 is WS_BORDER.
	; 0x20000000 is WS_MINIMIZE.
	; no border and not minimized
	Return,((style & 0x20800000) or winH < A_ScreenHeight or winW < A_ScreenWidth) ? false : true
}

Min(a, b)
{
	If (a < b) {
		Return,a
	} Else {
		Return,b
	}
}

Max(a, b)
{
	If (a > b) {
		Return,a
	} Else {
		Return,b
	}
}

#Include Lyt.ahk
; #Include Clip.ahk
