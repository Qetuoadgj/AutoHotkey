; https://github.com/Qetuoadgj/AutoHotkey
; https://github.com/Qetuoadgj/AutoHotkey/tree/master/LayoutSwitcher  | v1.0.0

#NoEnv ;Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ;Enable warnings to assist with detecting common errors.
SendMode,Input ;Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ;Ensures a consistent starting directory.

#SingleInstance,Force
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
	L["Tray Icon"] := "Tray Icon"
	L["Reload"] := "Reload"
	L["Suspend"] := "Suspend HotKeys"
	L["Exit"] := "Exit"
	L["Error"] := "Error"
	L["There is no image for: "] := "There is no image for: "
	L["There is no dictionary for: "] := "There is no dictionary for: "
	L["Auto Start"] := "Auto Start"
	L["Run as Admin"] := "Run as Admin"
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
}

If (AdminRights) {
	RunAsAdmin(A_ScriptFullPath) 
}

;~ ===================================================================================
;~ СОЗДАНИЕ GUI
;~ ===================================================================================
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

	Menu,Tray,Add,% L["Suspend"],Menu_Suspend
	If (SuspendHotKeys) {
		Suspend,On
		Menu,Tray,Check,% L["Suspend"]
	}
	
	Menu,Tray,Add,% L["Auto Start"],Menu_AutoStart
	If (AutoStart) {
		Menu,Tray,Check,% L["Auto Start"]
	}
	Menu,Tray,Add,% L["Run as Admin"],Menu_AdminRights
	If (AdminRights) {
		Menu,Tray,Check,% L["Run as Admin"]
	}
	
	Menu,Tray,Add
	
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
	
	Menu,Tray,Add
	
	Menu,Tray,Add,% L["Predict Layout"],Menu_TogglePredictLayout
	If (PredictLayout) {
		Menu,Tray,Check,% L["Predict Layout"]
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

;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ НАЗНАЧЕНИЙ КЛАВИШ
;~ ===================================================================================
DefineBindings:
{
	Hotkey,Capslock,CycleLayouts
	Hotkey,$~Break,SwitchKeysLocale
}

OnExit,CloseApp

;~ MsgBox,0,%SCRIPT_WIN_TITLE_SHORT%,Ready!,0.5

PreviousLocale := "English"
SetTimer,ChangeGUIImage,On

Exit

;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ ВЫЗЫВАЕМЫХ ФУНКЦИЙ И ЯРЛЫКОВ
;~ ===================================================================================
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
	
	IniWrite("English",INI_FILE,"DICTIONARIES",English)
	IniWrite("Russian",INI_FILE,"DICTIONARIES",Russian)
	IniWrite("Ukrainian",INI_FILE,"DICTIONARIES",Ukrainian)
	
	IniWrite("PredictLayout",INI_FILE,"OPTIONS",PredictLayout)

	IniWrite("TrayIcon",INI_FILE,"OPTIONS",TrayIcon)
	
	IniWrite("SuspendHotKeys",INI_FILE,"OPTIONS",SuspendHotKeys)
	
	IniWrite("AutoStart",INI_FILE,"OPTIONS",AutoStart)
	IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)
	
	Return
}

CloseApp:
{
	;~ GoSub,WriteConfigFile
	ExitApp
}

ChangeGUIImage:
{
	CurrentLocale := KeyboardLayoutQueue("A")[1].Locale
	If (not CurrentLocale or CurrentLocale == "") {
		Return
	}
	
	If (PreviousLocale != CurrentLocale) {
		ImageFile := False
		ImageTypes := [".png",".jpg"]
		For index,ImageType in ImageTypes {
			FilePattern := A_WorkingDir "\Images\" CurrentLocale ImageType
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
			MsgBox,0,% SCRIPT_WIN_TITLE_SHORT " - " L["Error"],% L["There is no image for: "] "`n" CurrentLocale,3.0
		}
		
		If (TrayIcon) {
			IconFile := A_WorkingDir "\Icons\" CurrentLocale ".ico"
			If FileExist(IconFile) {
				Menu,Tray,Icon,%IconFile%
			}
		} Else {
			Menu,Tray,NoIcon
		}
		
		PreviousLocale := CurrentLocale
	}
	Return
}

SwitchKeysLocale:
{
	SwitchKeysLocale(PredictLayout)
	Return
}
;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ ФУНКЦИЙ, ВЫЗЫВАЕМЫХ GUI
;~ ===================================================================================
GuiContextMenu:
{
	Menu,Tray,Show
	Return
}

Menu_Suspend:
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

Menu_TogglePredictLayout:
{
	PredictLayout := !PredictLayout
	IniWrite("PredictLayout",INI_FILE,"OPTIONS",PredictLayout)
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
}

Menu_AdminRights:
{
	If (AdminRights) {
		RunAsAdmin(A_ScriptFullPath)
		AdminRights := !AdminRights
		IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)
		Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	} Else {
		AdminRights := !AdminRights
		IniWrite("AdminRights",INI_FILE,"OPTIONS",AdminRights)
		Reload
	}
	Return
}

Menu_AutoStart:
{
	RunAsAdmin(A_ScriptFullPath)
	AutoStart := !AutoStart
	IniWrite("AutoStart",INI_FILE,"OPTIONS",AutoStart)
	Menu,Tray,ToggleCheck,%A_ThisMenuItem%
	schtasks = "%A_WinDir%\System32\schtasks.exe"
	TaskName := "CustomTasks\" SCRIPT_NAME
	If (AutoStart) {
		cmd = %schtasks% /create /TN "%TaskName%" /TR "%A_ScriptFullPath%" /SC ONLOGON
		cmd .= AdminRights ? " /RL HIGHEST /F" : " /F"		
	} Else {
		cmd = %schtasks% /delete /TN "%TaskName%" /F
	}
	RunWait,%cmd%
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
	WinGet,WinID,ID
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
	
	static LayoutsList := CreateLayoutsList()
	
	For pos,InputLayout in LayoutsList {
		Sleep,500
		PostMessage,0x50,2,LayoutsList[pos].HKL,,%WinTitle% ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
		WinActivate,%WinTitle%
		Sleep,100
		IfWinActive,%WinTitle%
		{
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
	Critical,Off
}

;~ ===================================================================================
;~ ФУНКЦИИ КОНВЕРТАЦИИ ТЕКСТА
;~ http://forum.script-coding.com/viewtopic.php?id=7186
;~ ===================================================================================
SwitchKeysLocale(PredictLayout)
{
	Critical
	SetBatchLines,-1
	SetKeyDelay,0

	TempClipboard := ClipboardAll
	Clipboard = ; Empty
	SendInput,^{vk43} ; Ctrl + C
	ClipWait,0
	
	SelText := ErrorLevel ? GetWord() : Clipboard ; если буфер обмена пуст (ничего не выделено), определяем и выделяем с помощью ф-ции GetWord() последнее слово слева от курсора
		
	;~ pResult := ConvertText(SelText)   ; получаем конвертированный текст и раскладку последней найденной буквы
	;~ Clipboard := StrGet(pResult + A_PtrSize)
	
	If (not SelText or SelText == "") {
		Return
	}
		
	If (PredictLayout) {
		global INI_FILE,SCRIPT_WIN_TITLE_SHORT,L		
		For pos,InputLayout in CreateLayoutsList() {
			LocaleName := InputLayout.Locale
			IniRead,Dict,%INI_FILE%,DICTIONARIES,%LocaleName%,A_Space
			;~ Dict := %LocaleName%
			If (Dict) {
				isDict := False
				Loop,Parse,SelText
				{
					isDict := InStr(Dict,A_LoopField,1) or RegExMatch(A_LoopField,"(\s+)",WhiteSpace)
					If (not isDict) {
						Break
					}
				}
				If (isDict) {
					;~ MsgBox,% "isDict = " LocaleName "`n" InputLayout.HKL
					PostMessage,0x50,2,% InputLayout.HKL ; 0x50 is WM_INPUTLANGCHANGEREQUEST.
					Sleep,250
				}
			} Else {
				SoundPlay,*16
				MsgBox,0,% SCRIPT_WIN_TITLE_SHORT " - " L["Error"],% L["There is no dictionary for: "] "`n" LocaleName,3.0
			}
		}
	}
	
	TranslateQueue := KeyboardLayoutQueue("A")
	
	LocaleTranslateFrom := TranslateQueue[1].Locale
	LocaleTranslateTo := TranslateQueue[2].Locale
	
	;~ MsgBox,% LocaleTranslateFrom "`n" LocaleTranslateTo
	
	If (LocaleTranslateTo == LocaleTranslateFrom) {
		Return
	}
	
	DictTranslateFrom := %LocaleTranslateFrom%
	DictTranslateTo := %LocaleTranslateTo%
	
	pResult := ConvertText(SelText,DictTranslateFrom,DictTranslateTo)
	
	/*
	If RegExMatch(pResult,"^(\s+)",WhiteSpace) {
		SendRaw,%WhiteSpace%
	}
	*/
	
	Clipboard := pResult
	
	SendInput,^{vk56} ; Ctrl + V
	
	Sleep,200
	
	;~ SwitchLocale(NumGet(pResult+0,"UInt")) ; переключаем раскладку клавиатуры в зависимости от раскладки последней найденной буквы
	
	Tooltip,% SwitchKeyboardLayout("A")
    SetTimer,REMOVE_TOOLTIP,-800
	
	Sleep,200
	Clipboard := TempClipboard
	
	Critical,Off
}

GetWord()
{
	While (A_Index < 10) {
		Clipboard = ; Empty
		SendInput,^+{Left}^{vk43}
		ClipWait,1
		If (ErrorLevel) {
			Return
		}

		If RegExMatch(Clipboard,"P).*(\s)",Found) {
			SendInput,^+{Right}
			Return,SubStr(Clipboard,FoundPos1 + 1)
		}

		PrevClipboard := Clipboard
		Clipboard = ; Empty
		SendInput,+{Left}^{vk43}
		ClipWait,1
		If (ErrorLevel) {
			Return
		}

		If (StrLen(Clipboard) = StrLen(PrevClipboard)) {
			Clipboard = ; Empty
			SendInput,+{Left}^{vk43}
			ClipWait,1
			If (ErrorLevel) {
				Return
			}

			If (StrLen(Clipboard) = StrLen(PrevClipboard)) {
				Return,Clipboard
			} Else {
				SendInput,+{Right 2}
				Return,PrevClipboard
			}
		}

		SendInput,+{Right}

		s := SubStr(Clipboard,1,1)
		If RegExMatch(s,"(\s+)",WhiteSpace) {
			Clipboard = ; Empty
			SendInput,+{Left}^{vk43}
			ClipWait,1
			If (ErrorLevel) {
				Return
			}

			Return,Clipboard
		}
	}
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
;~ ===================================================================================

;~ ===================================================================================
;~ ФУНКЦИИ УПРАВЛЕНИЯ РАСКЛАДКАМИ КЛАВИАТУРЫ
;~ http://forum.script-coding.com/viewtopic.php?id=5650&p=2
;~ ===================================================================================
CycleLayouts:
{
    Tooltip,% SwitchKeyboardLayout("A")
    SetTimer,REMOVE_TOOLTIP,-800
    Return
}

REMOVE_TOOLTIP:
{
    ToolTip
    Return
}

KeyboardLayoutQueue(window)
{
    static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()
    If (!hWnd := WinExist(window)) {
        Return
	}
    WinGetClass,winClass
    If (winClass == "ConsoleWindowClass")
    {
        WinGet,consolePID,PID
        currentDisplayName := GetLayoutDisplayName(GetConsoleKeyboardLayoutName(consolePID))
        For pos,InputLayout in LayoutsList {
            continue
		} Until (InputLayout.DisplayName = currentDisplayName)
    } Else {
        currentHKL := GetKeyboardLayout(hWnd)
        For pos,InputLayout in LayoutsList {
            continue
		} Until (InputLayout.HKL = currentHKL)
    }
    nextPos := Mod(pos,layoutsListSize)+1
	return [LayoutsList[pos],LayoutsList[nextPos]]
}

SwitchKeyboardLayout(window)
{
    static LayoutsList := CreateLayoutsList(), layoutsListSize := LayoutsList.MaxIndex()
    If (!hWnd := WinExist(window)) {
        Return
	}
    WinGetClass,winClass
    If (winClass == "ConsoleWindowClass")
    {
        WinGet,consolePID,PID
        currentDisplayName := GetLayoutDisplayName(GetConsoleKeyboardLayoutName(consolePID))
        For pos,InputLayout in LayoutsList {
            continue
		} Until (InputLayout.DisplayName = currentDisplayName)
    } Else {
        currentHKL := GetKeyboardLayout(hWnd)
        For pos,InputLayout in LayoutsList {
            continue
		} Until (InputLayout.HKL = currentHKL)
    }
    nextPos := Mod(pos,layoutsListSize)+1
	PostMessage,0x50,2,LayoutsList[nextPos].HKL,,%window%
    return LayoutsList[nextPos].Locale . " - " . LayoutsList[nextPos].DisplayName
}

CreateLayoutsList()
{
	static LayoutsList
    LayoutsList := {}
    keyboardLayoutListSize := DllCall("GetKeyboardLayoutList","UInt",0,"UInt",0)
    VarSetCapacity(keyboardLayoutList,keyboardLayoutListSize * A_PtrSize)
    DllCall("GetKeyboardLayoutList","UInt",keyboardLayoutListSize,"Ptr",&keyboardLayoutList)
    Loop,%keyboardLayoutListSize%
	{
        HKL := NumGet(keyboardLayoutList,(A_Index-1)*A_PtrSize)
        LayoutsList.Insert({HKL: HKL,DisplayName: GetLayoutDisplayName(HKLtoKLID(HKL)),Locale: GetLocaleInfo(HKL & 0xFFFF)})
	}
    Return,LayoutsList
}

GetLayoutDisplayName(KLID)
{
    RegRead,displayName,HKEY_LOCAL_MACHINE,% "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" KLID,% "Layout Display Name"
    If (not displayName) {
        Return,False
	}
    SHLoadIndirectString(displayName,displayName)
    Return,displayName
}

GetLocaleInfo(langId)
{
    VarSetCapacity(localeSig,size := DllCall("GetLocaleInfo","UInt",langId,"UInt",0x1001,"UInt",0,"UInt",0) * 2)
    DllCall("GetLocaleInfo","UInt",langId,"UInt",0x1001,"Str",localeSig,"UInt",size)
    Return,localeSig
}

HKLtoKLID(HKL)
{
    VarSetCapacity(KLID,8*(A_IsUnicode+1))
	
    priorHKL := GetKeyboardLayout(0)
	
    If (not ActivateKeyboardLayout(HKL,0)) {
        Return,False
	}
    If (not GetKeyboardLayoutName(KLID)) {
        Return,False
	}
    If (not ActivateKeyboardLayout(priorHKL,0)) {
        Return,False
	}
	
    Return,StrGet(&KLID)
}

GetConsoleKeyboardLayoutName(ByRef consolePID)
{
    VarSetCapacity(KLID,16)

    DllCall("AttachConsole","Ptr",consolePID)
    DllCall("GetConsoleKeyboardLayoutName","Ptr",&KLID)
    DllCall("FreeConsole")

    VarSetCapacity(KLID,-1)
    Return,KLID
}

ActivateKeyboardLayout(ByRef HKL,flags)
{
    Return,DllCall("ActivateKeyboardLayout","Ptr",HKL,"UInt",flags)
}

GetKeyboardLayout(ByRef hWnd)
{
    Return,DllCall("GetKeyboardLayout","Ptr",DllCall("GetWindowThreadProcessId","Ptr",hWnd,"UInt",0,"Ptr"),"Ptr")
}

GetKeyboardLayoutName(ByRef KLID)
{
    Return,DllCall("GetKeyboardLayoutName","Ptr",&KLID)
}

SHLoadIndirectString(ByRef source,ByRef outBuf,outBufSize = 50)
{
    Return,DllCall("Shlwapi.dll\SHLoadIndirectString","Ptr",&source,"Ptr",&outBuf,"UInt",outBufSize,"UInt",0)
}
;~ ===================================================================================



;~ ОБЩИЕ ФУНКЦИИ (БИБЛИОТЕКА)

;~ ===================================================================================
;~ ФУНКЦИЯ ЗАПУСКА СКРИПТА С ПРАВАМИ АДИМИНИСТРАТОРА
;~ ===================================================================================
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
	WinGet,CurrentID,ID,%A_ScriptFullPath% ahk_class AutoHotkey
	WinGet,ProcessList,List,%A_ScriptFullPath% ahk_class AutoHotkey
	ProcessCount := 1
	Loop,%ProcessList%
	{
		ProcessID := ProcessList%ProcessCount%
		If (ProcessID != CurrentID) {
			WinGet,ProcessPID,PID,%A_ScriptFullPath% ahk_id %ProcessID%
			Process,Close,%ProcessPID%
		}
		ProcessCount += 1
	}	 
	Return
}

;~ ===================================================================================
;~ ФУНКЦИЯ ПОЛУЧЕНИЯ ИМЕНИ ТЕКУЩЕГО СКРИПТА
;~ ===================================================================================
GetScriptName() {
	SplitPath,A_ScriptFullPath,,,,Name
	Return,Name
}

;~ ===================================================================================
;~ ФУНКЦИЯ УДАЛЕНИЯ ЛИШНИХ СИМВОЛОВ ИЗ ПУТЕЙ
;~ ===================================================================================
TrimPath(GivenPath) {
	GivenPath := StrReplace(GivenPath,"""","") ; Удаление кавычек из пути
	GivenPath := RegExReplace(GivenPath,"[\\+]$","",,1) ; Удаление замыкающего слэша из пути
	GivenPath := RegExReplace(GivenPath,"^[\\+]","",,1) ; Удаление предшествующего слэша из пути
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

;~ ===================================================================================
;~ ЗАМЕНА СТАНДАРТОНГО IniWrite (ЗАПИСЫВАЕТ ТОЛЬКО ИЗМЕНЕННЫЕ ПАРАМЕТРЫ)
;~ ===================================================================================
IniWrite(Key,File,Section,Value) {
	IniRead,TestValue,%File%,%Section%,%Key%
	If (TestValue != Value) {
		IniWrite,%Value%,%File%,%Section%,%Key%
	}
}

/* НЕ ИСПОЛЬЗУЕМОЕ
;~ ===================================================================================
;~ ОПРЕДЕЛЕНИЕ РАСКЛАДКИ ПО ТЕКСТОВОМУ НАЗВАНИЮ (Locale)
;~ ===================================================================================
GetKeyboardLayoutByLocale(Locale)
{
	For i,InputLayout in CreateLayoutsList() {
		If (InputLayout.Locale == Locale) {
			Return,InputLayout
		}
	}
}

;~ ===================================================================================
;~ ПЕРВОД ДЕСЯТИЧНОГО ЧИСЛА В HEX
;~ ===================================================================================
DecToHex(Dec)
{
	SetFormat,IntegerFast,Hex
	Return,Dec
}
*/
