#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.
;
#Persistent
;
Script_Init:
{
	#SingleInstance, Off
	Script_Name := Script.Name()
	Script_Args := Script.Args()
	Script.Force_Single_Instance([RegExReplace(Script_Name, "_x(32|64)", "") . "*"])
	for index, argument in A_Args {
		if (argument = "/RunAs*") {
			Script.Run_As_Admin(Script_Args)
		}
	}
	OnExit, CloseApp
}
;
; Your code here...
;
global DevManView := A_Is64bitOS ? A_ScriptDir . "\DevManView\DevManView_x64.exe" : A_ScriptDir . "\DevManView\DevManView_x32.exe"
global GeForce610M := "NVIDIA GeForce 610M" ;"VideoMate TV Capture" ;"NVIDIA GeForce 610M"
global GeForce610mIsDisabled := 0
; gosub, GeForce610mDisable
;
gosub, GUI_Init
gosub, GUI_AutoResize
;
Trial_Reset := 0
;
Exit
;
GUI_Init:
{
	; ------------------------------------
	Gui, Margin, 0, 0
	Gui, Add, ListView, r20 w600 gMyListViewEvents vMyListView, % "Ярлык|Приложение|Аргументы|Рабочая папка"
	;
	ImageList_1 := IL_Create(100) ; будущий список иконок
	LV_SetImageList(ImageList_1) ; инициализация списка иконок
	; ------------------------------------
	TargetDir := A_WorkingDir
	is_AKVIS := 0
	Loop, Files, %TargetDir%\*.lnk, F
	{ ; наполнение ListView
		LnkTarget := "", LnkDir := ""
		FileGetShortcut, %A_LoopFileFullPath%, LnkTarget, LnkDir, LnkArgs, LnkDescription, LnkIcon, LnkIconNum, LnkRunState ; получение информации из ярлыка
		if (not LnkTarget) {
			LnkTarget := A_LoopFileFullPath
		}
		SplitPath, LnkTarget, LnkTargetFullName, LnkTargetDir, LnkTargetExt, LnkTargetName, LnkTargetDrive
		if (not LnkDir) {
			LnkDir := A_LoopFileDir ; LnkTargetDir
		}
		LnkIcon := LnkIcon ? LnkIcon : LnkTarget ; перестраховка на случай, если в ярлыке не указан значок (вместо значка LnkIcon бирем значок из LnkTarget)
		ImageList_1_Index := IL_Add(ImageList_1, LnkIcon, LnkIconNum)
		if (not ImageList_1_Index) {
			LnkIconData := getExtIcon(LnkTargetExt)
			LnkIcon := LnkIconData.Src
			LnkIconNum := LnkIconData.Num
			ImageList_1_Index := IL_Add(ImageList_1, LnkIcon, LnkIconNum)
		}
		if (not ImageList_1_Index) {
			ImageList_1_Index := IL_Add(ImageList_1, "shell32.dll", 1)
		}
		if (ImageList_1_Index) {
			LnkName := StrReplace(A_LoopFileName, ".lnk", "")
			LV_Add("Icon" . ImageList_1_Index, LnkName, LnkTarget, LnkArgs, LnkDir) ; добавляем готовый элемент (пункт) в ListView
			is_AKVIS := is_AKVIS or InStr(LnkTarget, "\AKVIS\")
		}
		;
		LV_ModifyCol() ; автоподбор ширины колонок ListView
	}
	if (is_AKVIS) {
		gosub, GeForce610mDisable
	}
	Gui, Show ; инициализация окна GUI
	; ------------------------------------
	return
}
;
GUI_AutoResize:
{
	; ------------------------------------
	hwGui := 0 ; инициализация переменной (ID окна GUI)
	Gui, +HWNDhwGui ; сохранение ID окна GUI в переменную
	; Gui, Show ; инициализация окна GUI для вычисления суммы ширины колонок ListView
	if (hwGui) { ; автоподбор ширины окна GUI
		ListView := "SysListView321" ; ID элемента ListView
		ListView_Width := 0 ; инициализация переменной (суммы ширины колонок)
		Loop, % LV_GetCount("Column")
		{ ; получение суммарной ширины всех колонок ListView
			SendMessage, % 0x1000+29, % (A_Index - 1), 0, %ListView%, ahk_id %hwGui% ; получение ширины колонки #A_Index-1
			ListView_Width += ErrorLevel ; добавление полученной ширины к общей сумме
		}
		;
		ListView_Width_Min := 500 ; лимит минимальной ширины
		ListView_Width_Max := 800 ; лимит максимальной ширины
		;
		ListView_Width := ListView_Width > ListView_Width_Max ? ListView_Width_Max : ListView_Width ; ограничение по максимальной ширине
		ListView_Width := ListView_Width < ListView_Width_Min ? ListView_Width_Min : ListView_Width ; ограничение по минимальной ширине
		;
		ListView_Width += 8 ; прибавка к ширине окна для того, чтобы можно было "растягивать" последнюю колонку
		;
		GuiControl, Move, MyListView, w%ListView_Width% ; обновление ширины ListView
		Gui, Show, w%ListView_Width% ; обновление окна GUI
	}
	; ------------------------------------
	return
}
;
GuiClose:
{
	ExitApp
	return
}
;
CloseApp:
{
	gosub, GeForce610mEnable
	ExitApp
	return
}
;
GeForce610mDisable:
{
	if FileExist(DevManView) {
		try {
			RunWait, *RunAs %DevManView% /disable "%GeForce610M%"
		}
		catch {
			MsgBox, 262160, % "ОШИБКА", % "Не удалось остановить устройство """ . GeForce610M . """.`nВозможно, приложение devmanview.exe было запущено без прав Администратора." ;, 2
			ExitApp
			return
		}
		; gosub, CheckGeForce610mStatus
		GeForce610mIsDisabled := 1
	}
	return
}
;
GeForce610mEnable:
{
	if (not GeForce610mIsDisabled) {
		return
	}
	if FileExist(DevManView) {
		try {
			RunWait, *RunAs %DevManView% /enable "%GeForce610M%"
		}
		catch {
			MsgBox, 262160, % "ОШИБКА", % "Не удалось запустить устройство """ . GeForce610M . """.`nВозможно, приложение devmanview.exe было запущено без прав Администратора." ;, 2
			ExitApp
			return
		}
		; gosub, CheckGeForce610mStatus
	}
	return
}
;
MyListViewEvents:
{
	if (A_GuiEvent = "DoubleClick") {
		LV_GetText(LnkTarget, A_EventInfo, 2)
		LV_GetText(LnkArgs, A_EventInfo, 3)
		SplitPath, LnkTarget, LnkTargetFullName, LnkTargetDir, LnkTargetExt, LnkTargetName, LnkTargetDrive
		;
		LnkTargetPID := 0
		is_AKVIS := InStr(LnkTarget, "\AKVIS\")
		if (is_AKVIS) {
			gosub, AKVIS_Trial_Reset
			if (AbortExecution) {
				return
			}
			if (A_IsAdmin) {
				; ShellRun(LnkTarget, LnkArgs,,, Show := 1)
				ShellRun(LnkTarget, LnkArgs, LnkDir,, Show := 1)
			}
			else {
				Run, "%LnkTarget%" %LnkArgs%,,, LnkTargetPID
			}
			gosub, AKVIS_Skip_Trial_Dialogue
		}
		else {
			if (A_IsAdmin) {
				; ShellRun(LnkTarget, LnkArgs,,, Show := 1)
				ShellRun(LnkTarget, LnkArgs, LnkDir,, Show := 1)
			}
			else {
				Run, "%LnkTarget%" %LnkArgs%,,, LnkTargetPID
			}
		}
	}
	return
}
;
AKVIS_Trial_Reset:
{
	if (not Trial_Reset) {
		AbortExecution := 0
		/*
		if (A_IsAdmin) {
			MsgBox, 262160, ОШИБКА сброса пробного периода AKVIS., Программа запущена с правами Администратора.`nПерезапустите %Script_Name% в обычном режиме.
			AbortExecution := 1
			return
		}
		*/
		AKVIS_Trial_Reset := A_ScriptDir . "\AKVIS TrialReset.vbs"
		if FileExist(AKVIS_Trial_Reset) {
			if (A_IsAdmin) {
				MyCommand = cscript.exe "%AKVIS_Trial_Reset%" -S
				ShellRun("cmd.exe", "/K TITLE Z1" . " & " . MyCommand . " & EXIT",,, Show := 1)
				CmdTitle := "Z1 ahk_class ConsoleWindowClass ahk_exe cmd.exe"
				WinWait, %CmdTitle%
				WinWaitClose, %CmdTitle%
			}
			else {
				RunWait, cscript.exe "%AKVIS_Trial_Reset%" -S ;,, Hide
			}
		}
		Trial_Reset := 1
	}
	return
}
;
AKVIS_Skip_Trial_Dialogue:
{
	TargetWinTitles := []
	;
	TargetWinTitles.Push("ahk_pid " . LnkTargetPID . " ahk_exe " . LnkTargetFullName)
	TargetWinTitles.Push("ahk_class Qt5QWindow" . " ahk_exe " . LnkTargetFullName)
	TargetWinTitles.Push("ahk_class QWidget" . " ahk_exe " . LnkTargetFullName)
	;
	LnkTargetID := WinWait(TargetWinTitles, 30*1000)
	if (LnkTargetID) {
		WinTitle = ahk_id %LnkTargetID%
		WinActivate, %WinTitle%
		WinWaitActive, %WinTitle%
		;
		CoordMode, Mouse, Client
		WinGetPos,,, ActiveWinWidth, ActiveWinHeight, ahk_id %LnkTargetID% ; A
		CloseButtonOptions := "*50"
		if (not SearchImage(ButtonX, ButtonY, ImagePath := A_ScriptDir . "\ButtonClose.bmp", 0, 0, ActiveWinWidth, ActiveWinHeight, CloseButtonOptions, 24/2, 24/2)) {
			MsgBox, 262160, % "ОШИБКА", % "Не удалось обнаружить " . ImagePath . " на экране.", 1
			return
		}
		Sleep, 1000
		;
		CoordMode, Mouse, Screen
		MouseGetPos, PosX, PosY
		;
		CoordMode, Mouse, Client
		MouseClick, Left, %ButtonX%, %ButtonY%, 1, 0
		;
		CoordMode, Mouse, Screen
		MouseMove, %PosX%, %PosY%, 0
	}
	return
}
;
getExtIcon(Ext) {
	static From, DefaultIcon
	;
	DefaultIcon := ""
	RegRead, From, HKEY_CLASSES_ROOT, .%Ext%
	RegRead, CLSID, HKEY_CLASSES_ROOT, %From%\CLSID
	if (CLSID) {
		RegRead, DefaultIcon, HKEY_CLASSES_ROOT, CLSID\%CLSID%\DefaultIcon
	}
	if (DefaultIcon = "") {
		RegRead, DefaultIcon, HKEY_CLASSES_ROOT, %From%\DefaultIcon
	}
	if (DefaultIcon = "") {
		RegRead, Progid, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%Ext%\UserChoice, Progid
		RegRead, Command, HKEY_CURRENT_USER, Software\Classes\%Progid%\shell\open\command
		if RegExMatch(Command, """(.*?)""", CommandMatch) {
			DefaultIcon := CommandMatch1 . "," . 0
		}
	}
	;
	StringReplace, DefaultIcon, DefaultIcon, `",, All
	StringReplace, DefaultIcon, DefaultIcon, `%SystemRoot`%, %A_WinDir%, All
	StringReplace, DefaultIcon, DefaultIcon, `%ProgramFiles`%, %A_ProgramFiles%, All
	StringReplace, DefaultIcon, DefaultIcon, `%WinDir`%, %A_WinDir%, All
	;
	static IconInfo, IconInfo1, IconInfo2, IconSrc, IconNum
	IconInfo1 := "", IconInfo2 := ""
	StringSplit, IconInfo, DefaultIcon, `,
	;
	IconSrc := IconInfo1
	IconNum := (IconInfo2 < 0) ? IconInfo2 : IconInfo2 + 1
	;
	return {Src:IconSrc, Num:IconNum}
}
;
#include <CLASS_Script>
#Include <FUNC_WinWait>
#Include <FUNC_SearchImage>
#Include <FUNC_ShellRun>
;