#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

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
    Run "%A_ScriptFullPath%"
    ExitApp
  }

  IniRead,CycleState,%INI_FILE%,OPTIONS,CycleState,%A_Space%
  If (CycleState == "false") {
    CycleState := false
  }
}

MsgBox,0,%SCRIPT_WIN_TITLE%,Ready!,0.5

RefreshGlobals:
{
  IniRead,SendMode,%INI_FILE%,OPTIONS,SendMode,Input
  SendMode,%SendMode%

  IniRead,BindKey,%INI_FILE%,OPTIONS,BindKey,SC01C
  Hotkey,%BindKey%,BindKeyPressed

  IniRead,TargetProcess,%INI_FILE%,OPTIONS,TargetProcess

  IniRead,TogglePauseKey,%INI_FILE%,OPTIONS,TogglePauseKey,SC045
  Hotkey,%TogglePauseKey%,PauseKeyPressed

  IniRead,CYCLE_KEY,%INI_FILE%,OPTIONS,ToggleCycleKey,SC04C
  Hotkey,%CYCLE_KEY%,CycleKeyPressed

  IniRead,SendDelayMin,%INI_FILE%,OPTIONS,SendDelayMin,0
  IniRead,SendDelayMax,%INI_FILE%,OPTIONS,SendDelayMax,0
  SendDelayMin := Eval(SendDelayMin)
  SendDelayMax := Eval(SendDelayMax)
  Random,SendDelay,%SendDelayMin%,%SendDelayMax%

  IniRead,CycleTimeMin,%INI_FILE%,OPTIONS,CycleTimeMin,0
  IniRead,CycleTimeMax,%INI_FILE%,OPTIONS,CycleTimeMax,0
  CycleTimeMin := Eval(CycleTimeMin)
  CycleTimeMax := Eval(CycleTimeMax)
  Random,CycleTime,%CycleTimeMin%,%CycleTimeMax%

  ; Создание списка ключей секции
  KEYS := Object()
  KEYS := FileReadSection(INI_FILE,"[KEYS]","^\[.*\]$",1)

  ; Создание списка
  KeysList := Object()

  ; Обработка списка ключей секции
  For index,element in KEYS
  {
    ; Обработка ключей
    If RegExMatch(element,"^Key(\d+)") {
      idNum := RegExReplace(element,"^Key(\d+).*","$1",,1) ; Получение номера idNum
      IniRead,KEY_%idNum%,%INI_FILE%,KEYS,Key%idNum%
      KeysList.Push(KEY_%idNum%)
    }
  }

  Return
}

PauseKeyPressed:
{
  Paused := !Paused
  Hotkey,%BindKey%,Toggle
  Gosub,RefreshGlobals

  If (Paused) {
    MsgBox,0,%SCRIPT_WIN_TITLE%,Paused,0.5
  } else {
    Gosub,ShowInfo
  }

  Return
}

CycleKeyPressed:
{
  CycleState := !CycleState
  Gosub,RefreshGlobals

  text =
  ( LTrim RTrim
    [OPTIONS]
    CycleState = %CycleState%

    CycleTimeMin = %CycleTimeMin%
    CycleTimeMax = %CycleTimeMax%
    CycleTime = %CycleTime%
  )

  If (CycleState) {
    MsgBox,0,%SCRIPT_WIN_TITLE%,%text%,1.0
  } else {
    MsgBox,0,%SCRIPT_WIN_TITLE%,CycleState = %CycleState%,1.0
  }

  Return
}

BindKeyPressed:
{
  #If WinActive(TargetProcess)
  {
    For index,keyCode in KeysList
    {
      Random,SendDelay,%SendDelayMin%,%SendDelayMax%
      Send,%keyCode%
      Sleep,%SendDelay%
    }
    If (CycleState) {
      Random,CycleTime,%CycleTimeMin%,%CycleTimeMax%
      Sleep,%CycleTime%
    } else {
      KeyWait,%BindKey%
    }
    Return
  }
  Return
}

ShowInfo:
{
  text =
  ( LTrim RTrim
    [OPTIONS]
    SendMode = %SendMode%
    BindKey = %BindKey%
    TargetProcess = %TargetProcess%
    TogglePauseKey = %TogglePauseKey%
    ToggleCycleKey = %CYCLE_KEY%

    SendDelayMin = %SendDelayMin%
    SendDelayMax = %SendDelayMax%
    SendDelay = %SendDelay%

    CycleState = %CycleState%

    CycleTimeMin = %CycleTimeMin%
    CycleTimeMax = %CycleTimeMax%
    CycleTime = %CycleTime%
  )

  MsgBox,0,%SCRIPT_WIN_TITLE%,%text%,1.0

  Return
}

; ------------------ FUNCTIONS ------------------
CreateEmptyFile(EmptyFile)
{
  Encoding = CP1251
  text =
  ( LTrim RTrim
    ; ДЛЯ ПРАВИЛЬНОГО ЧТЕНИЯ СИМВОЛОВ КОДИРОВКА ЭТОГО ФАЙЛА ОБЯЗАТЕЛЬНО ДОЛЖНА БЫТЬ: WIN-1251 | CP1251

    [OPTIONS]
    ; Метод ввода (Input|Play|Event|InputThenPlay)
    SendMode = Event
    ; Переназначаемая клавиша (желательно использовать сканкод клавиши)
    BindKey = SC012
    ; Идентификатор процесса-цели
    TargetProcess = ahk_exe notepad++.exe
    ; Кнопка вкл./выкл. паузы (желательно использовать сканкод клавиши)
    TogglePauseKey = NumpadEnter
    ; Кнопка вкл./выкл. повторения (желательно использовать сканкод клавиши)
    ToggleCycleKey = Numpad5
    ; Минимальная/максимальная задержка для каждой отправки (мс)
    ; SendDelayMin = 12
    ; SendDelayMax = 18
    ; Кнопка для вкл./выкл. повторения по умолчанию
    CycleState = true
    ; Минимальная/максимальная задержка между циклами (мс)
    CycleTimeMin = 30
    CycleTimeMax = 100

    [KEYS]
    ; Очерёдность действий, выполняемых по нажатию/циклу
    Key1 = {А}
    Key2 = {Б}
    Key3 = {В}
    Key4 = {Г}
    Key5 = {Д}
    Key6 = {Enter}

    [DESCRIPTION]
    ; Для указания действий, выполняемых по нажатию возможно использование как
    ; сканкодов и названий клавиш для использования их непосредственно как
    ; клавиш клавиатуры, так и использование целых текстовых фраз.
    ; Пример:
    ; {NumpadEnter} - клавиша "Enter" на нампаде,
    ; NumpadEnter - как обычный текст "NumpadEnter",
    ; {Q} - клавиша "Q", но ТОЛЬКО лат.
    ; {SC010} - все клавиши на "Q" ("Q", "Й" и т.д.),
    ; {q}{w}{e}{r}{t}{y} - qwerty, как последовательность нажатий латинских букв;
    ; qwerty - qwerty, как текстовая строка;
    ;
    ; Для работы сразу со всеми языковыми раскладками необходимо использовать
    ; сканкоды буквенных клавиш вместо их названий {Q} --> {SC010}
    ; Для названий клавиш типа {NumpadEnter} {1} {2} {3} сканкод не нужен
    ; в разделе [OPTIONS] сканкоды и названия клавиш указываются
    ; без фигурных скобок {SC010} --> SC010
    ; так же возможно использование модификаторов:
    ; !	- Alt
    ; ^	- Control
    ; +	- Shift
    ; Пример: ^!s = Ctrl+Alt+S
    ; Подробней: https://autohotkey.com/docs/Hotkeys.htm

  )
  FileAppend,%text%,%EmptyFile%,%Encoding%
}
