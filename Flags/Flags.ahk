;~ https://github.com/Qetuoadgj/AutoHotkey/tree/master/Flags

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
;~ #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance,Force
DetectHiddenWindows,On
;~ Process,Priority,,High
#Persistent
#NoTrayIcon

OnExit,CloseApp

ForceSingleInstance()

SCRIPT_NAME:=GetScriptName()
SCRIPT_VERSION:="1.0.0"
SCRIPT_WIN_TITLE:=SCRIPT_NAME . " v" . SCRIPT_VERSION . " (by Ægir)"
SCRIPT_WIN_TITLE_SHORT:=SCRIPT_NAME . " v" . SCRIPT_VERSION

DefineGlobals:
{
	INI_FILE=%SCRIPT_NAME%.ini
	INI_FILE=%A_ScriptDir%\%INI_FILE%
	INI_FILE:=FileGetLongPath(INI_FILE)

	IniRead,SizeX,%INI_FILE%,OPTIONS,SizeX,32
	IniRead,SizeY,%INI_FILE%,OPTIONS,SizeY,22

	PosX:=A_ScreenWidth-SizeX-100
	PosY:=100

	IniRead,PosX,%INI_FILE%,OPTIONS,PosX,%PosX%
	IniRead,PosY,%INI_FILE%,OPTIONS,PosY,%PosY%
	
	IniRead,Borders,%INI_FILE%,OPTIONS,Borders,%A_Space%
	IniRead,BordersColor,%INI_FILE%,OPTIONS,BordersColor,505050
	
	IniRead,FixPosition,%INI_FILE%,OPTIONS,FixPosition,%A_Space%
	
	CurrentVariables:=["SizeX","SizeY","PosX","PosY","Borders","BordersColor","FixPosition"]
	
	IniRead,LANG_ENG,%INI_FILE%,LANGUAGES,ENG,%A_Space%
	IniRead,LANG_RUS,%INI_FILE%,LANGUAGES,RUS,%A_Space%
	IniRead,LANG_UKR,%INI_FILE%,LANGUAGES,UKR,%A_Space%
	
	IniRead,DICT_ENG,%INI_FILE%,DICTIONARIES,%LANG_ENG%,%A_Space%
	IniRead,DICT_RUS,%INI_FILE%,DICTIONARIES,%LANG_RUS%,%A_Space%
	IniRead,DICT_UKR,%INI_FILE%,DICTIONARIES,%LANG_UKR%,%A_Space%
	
	If (not LANG_ENG) {
		LANG_ENG := "0409"
		IniWrite,%LANG_ENG%,%INI_FILE%,LANGUAGES,ENG
	}
	If (not LANG_RUS) {
		LANG_RUS := "0419"
		IniWrite,%LANG_RUS%,%INI_FILE%,LANGUAGES,RUS
	}
	If (not LANG_UKR) {
		LANG_UKR := "0422"
		IniWrite,%LANG_UKR%,%INI_FILE%,LANGUAGES,UKR
	}
	If (not DICT_ENG) {
		DICT_ENG := "~QWERTYUIOP{}ASDFGHJKL:""ZXCVBNM<>``qwertyuiop[]asdfghjkl;'zxcvbnm,.?&@#"
		IniWrite,%DICT_ENG%,%INI_FILE%,DICTIONARIES,%LANG_ENG%
	}
	If (not DICT_RUS) {
		DICT_RUS := "ЁЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮёйцукенгшщзхъфывапролджэячсмитьбю,?""№"
		IniWrite,%DICT_RUS%,%INI_FILE%,DICTIONARIES,%LANG_RUS%
	}
	If (not DICT_UKR) {
		DICT_UKR := "ЁЙЦУКЕНГШЩЗХЇФІВАПРОЛДЖЄЯЧСМИТЬБЮёйцукенгшщзхїфівапролджєячсмитьбю.?""№"
		IniWrite,%DICT_UKR%,%INI_FILE%,DICTIONARIES,%LANG_UKR%
	}
}

CreateGUI:
{
	Gui,Margin,0,0
	GUI,+AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
	WinSizeX:=SizeX
	WinSizey:=Sizey
	PicSizeX:=SizeX
	PicSizeY:=SizeY
	If (Borders) {
		;~ Gui,+Border
		Gui,Color,%BordersColor%
		WinSizeX:=SizeX+Borders*2
		WinSizeY:=SizeY+Borders*2
		PicSizeX:=WinSizeX-Borders*2
		PicSizeY:=WinSizeY-Borders*2
		Gui,Margin,%Borders%,%Borders%
	}
	Gui,Add,Picture,w%PicSizeX% h%PicSizeY% vFlag
	Gui,Show,w%WinSizeX% h%WinSizey%,%SCRIPT_WIN_TITLE%
	Gui,+LastFound
	WinGet,GUIWinID,ID
    ;~ WinMove,ahk_id %GUIWinID%,,(A_ScreenWidth/2)-(SizeX/2),(A_ScreenHeight/2)-(SizeY/2)
    WinMove,ahk_id %GUIWinID%,,%PosX%,%PosY%
	OnMessage(0x201,"WM_LBUTTONDOWN")
	;~ Menu,Tray,NoStandard ;remove standard Menu items
	;~ Menu,Tray,Add,E&xit,CloseApp ;add a item named Exit that goes to the ButtonExit label
	Menu,Tray,Add
	Menu,Tray,Add,Fix Position,Menu_ToggleFixPosition
	If (FixPosition) {
		Menu,Tray,Check,Fix Position
	}
	Menu,Tray,Add,Borders,Menu_ToggleBorders
	If (Borders) {
		Menu,Tray,Check,Borders
	}
}

PreviousLocaleID:=false

SetTimer,process_watcher,On
Return

process_watcher:
{
	LocaleID:=GetCurrrentLang()
    If (PreviousLocaleID!=LocaleID) {
		Image:=A_WorkingDir . "\Images\" . LocaleID
		If FileExist(Image . ".png") {
			Image:=Image . ".png"
		} else if FileExist(Image . ".jpg") {
			Image:=Image . ".jpg"
		} else {
			SoundPlay,*16
			MsgBox,0,%SCRIPT_WIN_TITLE_SHORT% - Error,There is no image for:`n%LocaleID%,3.0
		}
		GuiControl,,Flag,*w%PicSizeX% *h%PicSizeY% %Image%
		PreviousLocaleID:=LocaleID
    }
	Return
}

GetCurrrentLang() {
	SetFormat,Integer,H
	WinGet,WinID,,A
	ThreadID:=DllCall("GetWindowThreadProcessId","UInt",WinID,"UInt",0)
	InputLocaleID:=DllCall("GetKeyboardLayout","UInt",ThreadID,"UInt")
	InputLocaleID:=SubStr(InputLocaleID, -3)
	Return,InputLocaleID
}

WM_LBUTTONDOWN() {
	global FixPosition
	If (FixPosition) {
		Return
	}
	PostMessage,0xA1,2
	GoSub,SaveConfig
}

GuiContextMenu:
{
  Menu,Tray,Show
  Return
}

SaveConfig:
{
	FixPosition:=FixPosition?FixPosition:0
	Borders:=Borders?Borders:0
	WinGetPos,WinPosX,WinPosY,WinSizeX,WinSizeY,ahk_id %GUIWinID%
	;~ IniWrite,%SizeX%,%INI_FILE%,OPTIONS,SizeX
	;~ IniWrite,%SizeY%,%INI_FILE%,OPTIONS,SizeY
	;~ IniWrite,%PosX%,%INI_FILE%,OPTIONS,PosX
	;~ IniWrite,%PosY%,%INI_FILE%,OPTIONS,PosY
	;~ IniWrite,%Borders%,%INI_FILE%,OPTIONS,Borders
	;~ IniWrite,%BordersColor%,%INI_FILE%,OPTIONS,BordersColor
	PosX:=WinPosX ;Borders?WinPosX-Borders:WinPosX
	PosY:=WinPosY ;Borders?WinPosY-Borders:WinPosY
	For index,element in CurrentVariables
	{
		Key=%element%
		Value:=%Key%
		TestKey=%Key%_test
		IniRead,%TestKey%,%INI_FILE%,OPTIONS,%Key%
		TestValue:=%TestKey%
		If (TestValue!=Value) {
			;~ MsgBox,0,%SCRIPT_WIN_TITLE_SHORT%,%Key%=%Value%`n%TestValue%,3.0
			IniWrite,%Value%,%INI_FILE%,OPTIONS,%Key%
		}
	}
	Return
}

CloseApp:
{
	GoSub,SaveConfig
	ExitApp
}

Menu_ToggleFixPosition:
{
	FixPosition:=!FixPosition
	GoSub,SaveConfig
	Menu,Tray,ToggleCheck,Fix Position
	Return
}

Menu_ToggleBorders:
{
	Borders:=!Borders
	GoSub,SaveConfig
	Menu,Tray,ToggleCheck,Borders
	Reload
}

; ===================================================================================
;   ФУНКЦИЯ АВТОМАТИЧЕСКОГО ЗАВЕРШЕНИЯ ВСЕХ КОПИЙ ТЕКУЩЕГО ПРОЦЕССА (КРОМЕ АКТИВНОЙ)
; ===================================================================================
ForceSingleInstance() {
  DetectHiddenWindows,On
  #SingleInstance,Off

  WinGet,CurrentID,ID,%A_ScriptFullPath% ahk_class AutoHotkey
  WinGet,ProcessList,List,%A_ScriptFullPath% ahk_class AutoHotkey
  ProcessCount:=1
  Loop,%ProcessList% {
    ProcessID:=ProcessList%ProcessCount%
    If (ProcessID!=CurrentID) {
      WinGet,ProcessPID,PID,%A_ScriptFullPath% ahk_id %ProcessID%
      Process,Close,%ProcessPID%
    }
    ProcessCount+=1
  }
  Return
}

;~ #Include,Lib\SwitchKeysLocale.ahk

$~Break::SwitchKeysLocale()

SwitchKeysLocale()
{
	Critical
	SetBatchLines, -1
	SetKeyDelay, 0

	TempClipboard := ClipboardAll
	Clipboard =
	SendInput, ^{vk43}   ; Ctrl + C
	ClipWait, 0
	; если буфер обмена пуст (ничего не выделено), определяем и выделяем
	; с помощью ф-ции GetWord() последнее слово слева от курсора
	SelText := ErrorLevel ? GetWord() : Clipboard
	pResult := ConvertText(SelText)   ; получаем конвертированный текст и раскладку последней найденной буквы

	Clipboard := StrGet(pResult + A_PtrSize)
	SendInput, ^{vk56}   ; Ctrl + V
	; переключаем раскладку клавиатуры в зависимости от раскладки последней найденной буквы
	Sleep, 200
	SwitchLocale(NumGet(pResult+0, "UInt"))
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


ConvertText(Text)
{
	static Result

	global LANG_ENG
	global DICT_ENG
	global DICT_RUS
	global DICT_UKR
	
	;~ global INI_FILE

	;~ IniRead,LANG_ENG,%INI_FILE%,LANGUAGES,ENG,0409
	;~ IniRead,LANG_RUS,%INI_FILE%,LANGUAGES,RUS,0419
	;~ IniRead,LANG_UKR,%INI_FILE%,LANGUAGES,UKR,0422
	
	;~ IniRead,DICT_ENG,%INI_FILE%,DICTIONARIES,%LANG_ENG%,%DICT_ENG%
	;~ IniRead,DICT_RUS,%INI_FILE%,DICTIONARIES,%LANG_RUS%,%DICT_RUS%
	;~ IniRead,DICT_UKR,%INI_FILE%,DICTIONARIES,%LANG_UKR%,%DICT_UKR%
	
	;~ MsgBox,%LANG_ENG%`n%DICT_ENG%

	If (GetCurrrentLang() == LANG_ENG) {
		Loop, parse, Text
		{
			found =
			if found := InStr(DICT_ENG, A_LoopField, 1)
				NewText .= SubStr(DICT_RUS, found, 1), lastfound := 2

			if !found
				if found := InStr(DICT_UKR, A_LoopField, 1)
					NewText .= SubStr(DICT_RUS, found, 1), lastfound := 2

			if !found
				NewText .= A_LoopField
		}
	} else {
		Loop, parse, Text
		{
			found =
			if found := InStr(DICT_RUS, A_LoopField, 1)
				NewText .= SubStr(DICT_ENG, found, 1), lastfound := 1

			if !found
				if found := InStr(DICT_UKR, A_LoopField, 1)
					NewText .= SubStr(DICT_ENG, found, 1), lastfound := 1

			if !found
				NewText .= A_LoopField
		}
	}

	VarSetCapacity(Result, A_PtrSize + StrPut(NewText)*(A_IsUnicode ? 2 : 1))
	NumPut(lastfound, &Result), StrPut(NewText, &Result + A_PtrSize)
	Return &Result
}

SwitchLocale(lastfound)
{
	SetFormat, IntegerFast, H
	VarSetCapacity(List, A_PtrSize*2)
	DllCall("GetKeyboardLayoutList", Int, 2, Ptr, &List)
	Locale1 := NumGet(List)
	b := SubStr(Locale2 := NumGet(List, A_PtrSize), -3) = 0409
	En := b ? Locale2 : Locale1
	Ru := b ? Locale1 : Locale2
	SendMessage, WM_INPUTLANGCHANGEREQUEST := 0x50,, lastfound = 1 ? En : Ru,, A
}
