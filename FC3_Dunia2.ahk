#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
; SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#SingleInstance,force
#Persistent  ; to make it run indefinitely
; SetBatchLines,-1  ; Use SetBatchLines -1 to run the script at maximum speed (Affects CPU utilization).

SCRIPT_NAME := GetScriptName()
SCRIPT_VERSION := "1.1.0"
SCRIPT_WIN_TITLE := SCRIPT_NAME . " v" . SCRIPT_VERSION . " (by Ægir)"

CreateLogo:
{
  logoFile = %A_ScriptDir%\Images\%SCRIPT_NAME%.png
  logoURL := "http://orig01.deviantart.net/362a/f/2013/089/e/7/far_cry_3___icon_by_blagoicons-d5ztu42.png"
  logoSize := 128
  logoAlpha := 0.95
  
  GdipCreateLogo(logoFile,logoURL,logoSize,logoAlpha)
}

CreateGUI:
{
  SoundPlay,*48
  ; Gui,MsgBox1_:Add,Progress,x5 y5 w395 h20 vMsgBox1_Progress -Smooth ;cBlue
  ; Gui,MsgBox1_:Add,Text,vMsgBox1_Text x5 y+5 w395 h80,Идет копирование файлов...
  Gui,MsgBox1_:Add,Button,vCancelButton x325 y135 w75 h25 gButtonCancel,Отмена
  Gui,MsgBox1_:Add,Button,vNoButton x245 y135 w75 h25 gButtonNo,Unpack
  Gui,MsgBox1_:Add,Button,vYesButton x165 y135 w75 h25 gButtonYes,Pack
  ; GuiControl,MsgBox1_:Hide,YesButton
  ; GuiControl,MsgBox1_:Hide,NoButton
  Gui,MsgBox1_:Show,xCenter yCenter h165 w405,%SCRIPT_WIN_TITLE%
}

DefineGlobals:
{
  INI_FILE = %SCRIPT_NAME%.ini
  INI_FILE = %A_WorkingDir%\%INI_FILE%
  INI_FILE := FileGetLongPath(INI_FILE)
  
  IfNotExist, %INI_FILE%
  {
    CreateEmptyFile(INI_FILE)
    ExitApp
  }
  
  FormatTime,Date,,yyyy.MM.dd ; Получение текущей даты (2015.11.29)
  
  ; Чтение параметров из INI_FILE
  IniRead,EXECUTABLES_DIRECTORY,%INI_FILE%,OPTIONS,ExecutablesDirectory,%A_WorkingDir%\bin
  EXECUTABLES_DIRECTORY := ParseEnvironmentVariables(EXECUTABLES_DIRECTORY)
  EXECUTABLES_DIRECTORY := FileGetLongPath(EXECUTABLES_DIRECTORY)
  
  IniRead,UNPACK_OUTPUT_DIR,%INI_FILE%,OPTIONS,UnpackOutputDir,%A_WorkingDir%\Patch
  UNPACK_OUTPUT_DIR := ParseEnvironmentVariables(UNPACK_OUTPUT_DIR)
  UNPACK_OUTPUT_DIR := FileGetLongPath(UNPACK_OUTPUT_DIR)
  
  IniRead,FILE_TO_UNPACK,%INI_FILE%,OPTIONS,FileToUnpack,patch.fat
  FILE_TO_UNPACK := ParseEnvironmentVariables(FILE_TO_UNPACK)
  FILE_TO_UNPACK := FileGetLongPath(FILE_TO_UNPACK)
  
  IniRead,FILE_TO_PACK,%INI_FILE%,OPTIONS,FileToPack,new_patch.fat
  FILE_TO_PACK := ParseEnvironmentVariables(FILE_TO_PACK)
  FILE_TO_PACK := FileGetLongPath(FILE_TO_PACK)
  
  ; Создание списка ключей секции [LIBs]
  LIBs := Object()
  LIBs := FileReadSection(INI_FILE,"[LIBs]","^\[.*\]$",1)
  
  ; Создание списка ключей секции [INCLUSIONS]
  INCLUSIONS := Object()
  INCLUSIONS := FileReadSection(INI_FILE,"[INCLUSIONS]","^\[.*\]$",1)
  
  IniRead,COMPRESSION,%INI_FILE%,OPTIONS,Compression,yes
}

Exit

UnPack:
{
  ; UnPackFAT:
  Executable := EXECUTABLES_DIRECTORY . "\Gibbed.Dunia2.Unpack.exe"
  IfExist, %FILE_TO_UNPACK%
  {
    ; Удаление существующей COPY_TO_DIR
    IfExist, %UNPACK_OUTPUT_DIR%
    {
      FileRemoveDir, %UNPACK_OUTPUT_DIR%, 1
    }
    FileCreateDir, %UNPACK_OUTPUT_DIR%
    
    Command = "%Executable%" -o "%FILE_TO_UNPACK%" "%UNPACK_OUTPUT_DIR%"
    Command := "echo." . FILE_TO_UNPACK . " & " . Command
  RunWait, %comspec% /k cd /d "%A_WorkingDir%" & %Command% & exit
  } else {
    MsgBox,0,Error,Not found:`n%A_WorkingDir%\%FILE_TO_UNPACK%,1.5
  }
  ;
  
  ; DecompileLIBs:
  Executable := EXECUTABLES_DIRECTORY . "\Gibbed.Dunia2.ConvertBinaryObject.exe"
  For index,SourceFile in LIBs
  {
    If (SourceFile != "") {
      SourceFile := FileGetLongPath(UNPACK_OUTPUT_DIR . "\" . SourceFile)
      IfExist, %SourceFile%
      {
        SplitPath, SourceFile, SourceFileShort, SourceFileDir, SourceFileExtension, SourceFileName, SourceFileDrive ; Определение путей файла-источника
        OutputFile := SourceFileDir . "\" . SourceFileName . ".fcb"
        Command = "%Executable%" -e -v "%SourceFile%" "%OutputFile%"
        Command := "echo." . SourceFile . " & " . Command
        RunWait, %comspec% /k cd /d "%UNPACK_OUTPUT_DIR%" & %Command% & exit
        If (SourceFileExtension == "lib") {
          IfExist, %OutputFile%
          {
            FileDelete, %SourceFile%
          }
        }
      }
      } else {
        MsgBox,0,Error,Not found:`n%SourceFile%,1.5
      }
  }
  ;
  
  ExitApp
}


Pack:
{
  /*
    ReplaceFilesDir := FileGetLongPath(A_WorkingDir . "\Include")
    IfExist,%ReplaceFilesDir%\*
    {
    MsgBox, %ReplaceFilesDir%
    Loop,Files,%ReplaceFilesDir%,DF ;RF
    {
    MsgBox, %A_LoopFileFullPath%
    ; Копирование файлов
    FileCopy(A_LoopFileFullPath,UNPACK_OUTPUT_DIR,1)
    }
    }
  */
  
  ; Include INCLUSIONS
  For index,Source in INCLUSIONS
  {
    If (Source != "") {
      Source := FileGetLongPath(Source)
      IfExist, %Source%
      {
        ; SplitPath, Source, SourceShort, SourceDir, SourceExtension, SourceName, SourceDrive ; Определение путей файла-источника
        Output := UNPACK_OUTPUT_DIR . "\" . RegExReplace(Source, "^.*Inclusion_.*?\\(.*)$", "$1")
      FileCopy(Source,Output,1)
      } else {
        MsgBox,0,Error,Not found:`n%Source%,1.0
      }
    }
  }
  ;
  
  ; CompileLIBs:
  Executable := EXECUTABLES_DIRECTORY . "\Gibbed.Dunia2.ConvertBinaryObject.exe"
  For index,SourceFile in LIBs
  {
    If (SourceFile != "") {
      SourceFile := FileGetLongPath(UNPACK_OUTPUT_DIR . "\" . SourceFile)
      SplitPath, SourceFile, SourceFileShort, SourceFileDir, SourceFileExtension, SourceFileName, SourceFileDrive ; Определение путей файла-источника
      ; If (SourceFileExtension != "fcb") {
        SourceFile := SourceFileDir . "\" . SourceFileName . ".fcb"
        IfExist, %SourceFile%
        {
          OutputFile := SourceFileDir . "\" . SourceFileName . "." . SourceFileExtension
          IfExist, %SourceFileDir%\%SourceFileName%
          {
            Command = "%Executable%" -i -v "%SourceFile%" "%OutputFile%"
            Command := "echo." . SourceFile . " & " . Command
            RunWait, %comspec% /k cd /d "%UNPACK_OUTPUT_DIR%" & %Command% & exit
            FileRemoveDir, %SourceFileDir%\%SourceFileName%, 1
            If (SourceFileExtension != "fcb") {
              FileDelete, %SourceFile%
            }
          }
        } else {
          MsgBox,0,Error,Not found:`n%SourceFile%,1.5
        }
      ; }
    }
  }
  ;
  
  ; PackFAT:
  Executable := EXECUTABLES_DIRECTORY . "\Gibbed.Dunia2.Pack.exe"
  IfExist, %UNPACK_OUTPUT_DIR%
  {
    /*
      ; Удаление существующих FILE_TO_PACK
      IfExist, %FILE_TO_PACK%
      {
      FileDelete, %FILE_TO_PACK%
    }
    */
    If (COMPRESSION == "yes") {
    Command = "%Executable%" -c "%FILE_TO_PACK%" "%UNPACK_OUTPUT_DIR%"
    } else {
      Command = "%Executable%" "%FILE_TO_PACK%" "%UNPACK_OUTPUT_DIR%"
    }
    Command := "echo." . UNPACK_OUTPUT_DIR . " & " . Command
  RunWait, %comspec% /k cd /d "%A_WorkingDir%" & %Command% & exit
  } else {
    MsgBox,0,Error,Not found:`n%UNPACK_OUTPUT_DIR%,1.5
  }
  ;
  
  ExitApp
}

; ------------------ GUI SUBROUTINES ------------------
ButtonYes:
{
  SoundPlay,*64
  Action := "pack"
  Gosub, Pack
}

ButtonNo:
{
  Action := "unpack"
  Gosub, Unpack
}

ButtonCancel:
{
  SoundPlay,*64
  Gui,MsgBox1_:Submit,Close
  ExitApp
}

MsgBox1_GuiClose:
{
  ExitApp
}

CreateEmptyFile(EmptyFile)
{
  Encoding = CP1251
  
  text =
  ( LTrim RTrim
  [OPTIONS]
  ExecutablesDirectory = %A_WorkingDir%\bin
  UnpackOutputDir = Patch
  FileToUnpack = patch.fat
  FileToPack = new_patch.fat
  ; Compression = no
  
  [LIBs]
  generated\databases\generic\shoppingitems.lib
  generated\databases\generic\shopsubcategory2.lib
  ;
  worlds\fc3_main\generated\entitylibrary.fcb
  
  [INCLUSIONS]
  ; Inclusion_BetterSights\graphics\__fc3_graphics\_common\_textures\weapons\_shared\sight_01_d.xbt
    ; Inclusion_BetterSights\graphics\__fc3_graphics\_common\_textures\weapons\_shared\sight_02_d.xbt
    ; Inclusion_BetterSights\graphics\__fc3_graphics\_common\_textures\weapons\_shared\sight_03_d.xbt
    ; Inclusion_BetterSights\graphics\__fc3_graphics\_common\_textures\weapons\_shared\sight_04_d.xbt
    ; 
  ; Inclusion_RebalancedWeapons\worlds\
  )
  FileAppend, %text%, %EmptyFile%, %Encoding%
}