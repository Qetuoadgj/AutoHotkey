;~ https://github.com/Qetuoadgj/AutoHotkey/tree/master/Flags

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

#SingleInstance, Force
DetectHiddenWindows,On
;~ Process,Priority,,High
#Persistent
#NoTrayIcon

OnExit, CloseApp

ForceSingleInstance()

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.0.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION . " (by Ægir)"
SCRIPT_WIN_TITLE_SHORT := SCRIPT_NAME . " v" . SCRIPT_VERSION

DefineGlobals:
{
	INI_FILE = %SCRIPT_NAME%.ini
	INI_FILE = %A_ScriptDir%\%INI_FILE%
	INI_FILE := FileGetLongPath(INI_FILE)

	IniRead,SizeX,%INI_FILE%,OPTIONS,SizeX,32
	IniRead,SizeY,%INI_FILE%,OPTIONS,SizeY,22

	PosX := A_ScreenWidth - SizeX - 100
	PosY := 100

	IniRead,PosX,%INI_FILE%,OPTIONS,PosX,%PosX%
	IniRead,PosY,%INI_FILE%,OPTIONS,PosY,%PosY%
	
	IniRead,Borders,%INI_FILE%,OPTIONS,Borders,%A_Space%
	IniRead,BordersColor,%INI_FILE%,OPTIONS,BordersColor,505050
}

CreateGUI:
{
	Gui, Margin, 0, 0
	GUI, +AlwaysOnTop -Border -SysMenu +Owner -Caption +ToolWindow
	PicSizeX := SizeX
	PicSizeY := SizeY
	If (Borders) {
		;~ Gui, +Border
		Gui, Color, %BordersColor%
		SizeX := SizeX + Borders*2
		SizeY := SizeY + Borders*2
		PicSizeX := SizeX - Borders*2
		PicSizeY := SizeY - Borders*2
		Gui, Margin, %Borders%, %Borders%
	}
	Gui, Add, Picture, w%PicSizeX% h%PicSizeY% vFlag,
	Gui, Show, w%SizeX% h%SizeY%, %SCRIPT_WIN_TITLE%
	Gui, +LastFound
	WinGet,GUIWinID,ID
    ;~ WinMove,ahk_id %GUIWinID%,,(A_ScreenWidth/2)-(SizeX/2),(A_ScreenHeight/2)-(SizeY/2)
    WinMove,ahk_id %GUIWinID%,,%PosX%,%PosY%
	OnMessage(0x201, "WM_LBUTTONDOWN")
	;~ Return
}

PreviousLocaleID := false

SetTimer,process_watcher,On
Return

process_watcher:
{
	LocaleID := GetCurrrentLang()
    If (PreviousLocaleID != LocaleID) {
		Image := A_WorkingDir . "\Images\" . LocaleID
		If FileExist(Image . ".png") {
			Image := Image . ".png"
		} else if FileExist(Image . ".jpg") {
			Image := Image . ".jpg"
		} else {
			SoundPlay,*16
			MsgBox,0,%SCRIPT_WIN_TITLE_SHORT% - Error,There is no image for:`n%LocaleID%,3.0
		}
		GuiControl,, Flag, *w%PicSizeX% *h%PicSizeY% %Image%
		PreviousLocaleID := LocaleID
    }
	Return
}

GetCurrrentLang() {
	SetFormat, Integer, H
	WinGet, WinID,, A
	ThreadID:=DllCall("GetWindowThreadProcessId", "UInt", WinID, "UInt", 0)
	InputLocaleID:=DllCall("GetKeyboardLayout", "UInt", ThreadID, "UInt")
	Return, InputLocaleID
}

WM_LBUTTONDOWN() {
	PostMessage, 0xA1, 2
	gosub, SaveConfig
}

GuiContextMenu:
{
  Menu, Tray, Show
  Return
}

SaveConfig:
{
	Borders := Borders ? Borders : 0
	WinGetPos, PosX, PosY, SizeX, SizeY, ahk_id %GUIWinID%
	IniWrite, %SizeX%, %INI_FILE%, OPTIONS, SizeX
	IniWrite, %SizeY%, %INI_FILE%, OPTIONS, SizeY
	IniWrite, %PosX%, %INI_FILE%, OPTIONS, PosX
	IniWrite, %PosY%, %INI_FILE%, OPTIONS, PosY
	IniWrite, %Borders%, %INI_FILE%, OPTIONS, Borders
	IniWrite, %BordersColor%, %INI_FILE%, OPTIONS, BordersColor
	Return
}

CloseApp:
{
	gosub, SaveConfig
	ExitApp
}

; ===================================================================================
;   ФУНКЦИЯ АВТОМАТИЧЕСКОГО ЗАВЕРШЕНИЯ ВСЕХ КОПИЙ ТЕКУЩЕГО ПРОЦЕССА (КРОМЕ АКТИВНОЙ)
; ===================================================================================
ForceSingleInstance() {
  DetectHiddenWindows,On
  #SingleInstance,Off

  WinGet,CurrentID,ID,%A_ScriptFullPath% ahk_class AutoHotkey
  WinGet,ProcessList,List,%A_ScriptFullPath% ahk_class AutoHotkey
  ProcessCount := 1
  Loop,%ProcessList% {
    ProcessID := ProcessList%ProcessCount%
    If (ProcessID != CurrentID) {
      WinGet,ProcessPID,PID,%A_ScriptFullPath% ahk_id %ProcessID%
      Process,Close,%ProcessPID%
    }
    ProcessCount += 1
  }
  Return
}
