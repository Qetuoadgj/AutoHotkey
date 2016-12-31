; https://github.com/Qetuoadgj/AutoHotkey
; https://raw.githubusercontent.com/Qetuoadgj/AutoHotkey/master/%D0%A0%D0%95%D0%97%D0%95%D0%A0%D0%92%D0%9D%D0%9E%D0%95%20%D0%9A%D0%9E%D0%9F%D0%98%D0%A0%D0%9E%D0%92%D0%90%D0%9D%D0%98%D0%95.ahk | v1.0.0

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn ; Enable warnings to assist with detecting common errors.
SendMode,Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir,%A_ScriptDir% ; Ensures a consistent starting directory.

; run,%comspec% /k ipconfig /all & pause & exit
; run,%comspec% /k Command & pause & exit

; Проверка наличия "Файла-Источника"
If (not %0%) {
  MsgBox,3,,Создать пустой файл?`n%A_ScriptDir%\Пустой BACKUP.ini,5  ; 5-second timeout.
  IfMsgBox,No
    ExitApp  ; User pressed the "No" button.

  IfMsgBox,Yes
  {
    EmptyFile = %A_ScriptDir%\Пустой BACKUP.ini
    Encoding = CP1251

    IfExist,%EmptyFile%
      FileDelete,%EmptyFile%
      
    MsgText =
    ( LTrim RTrim Join`r`n
      ; ДЛЯ ПРАВИЛЬНОГО ЧТЕНИЯ СИМВОЛОВ КОДИРОВКА ЭТОГО ФАЙЛА ОБЯЗАТЕЛЬНО ДОЛЖНА БЫТЬ: WIN-1251 | CP1251
      
      [Description]
      ; Name = ;Имя Файла (в кавычках)
      ; Password = ;Пароль (без кавычек)
      RootDir = ;Корневая Папка (в кавычках)
      ; SevenZip = "`%ProgramFiles`%\7-Zip\7z.exe" ;архиватор 7-Zip (в кавычках)
      ; WinRAR = "`%ProgramFiles`%\WinRAR\Rar.exe" ;архиватор WinRAR (в кавычках)
      ArchiveType = 7z,rar ;Типы создаваемых архивов (7z,rar) (без кавычек)
      ; TimeStamp = yyyy.MM.dd ;Формат временного штампа архива (без кавычек)
      ; CreateNewArchives = false ;Создание новых архивов вместо обновления существующей копии (true, false) (без кавычек)
      ; NewArchiveNumeration = 0.2d ;Формат нумерации новых архивов (без кавычек)
      ; LockArchive = true ;Запретить дальнейшее изменение архива (true, false) (без кавычек)

      [IncludeList]
      ; Включаемые файлы (без кавычек)

      [ExcludeList]
      ; Исключаемые файлы (без кавычек)
      *Thumbs.db
      
    )
    FileAppend,%MsgText%,%EmptyFile%,%Encoding%
  }

  IfMsgBox,Timeout
    ExitApp ; i.e. Assume "No" if it timed out.
  ; Otherwise,continue:
  ExitApp
}

; Цикл для всех параметров / файлов открытых в этом приложении
Loop,%0%
{
  GivenPath := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
  Loop,%GivenPath%,1
  {
    FullPath := A_LoopFileLongPath
  }
}

; Определение полного пути файла-источника
SourceFile := FullPath

; Определение путей файла-источника
SplitPath,SourceFile,SourceFileShort,SourceFileDir,SourceFileExtension,SourceFileName,SourceFileDrive

; Назначение рабочего каталога программы
SetWorkingDir %SourceFileDir%

; Получение переменных из файла-источника
IniRead,Name,%SourceFile%,Description,Name,%SourceFileName% ; GetValue(SourceFile,"^Name[\s+]?=[\s+]?(.*)") ; Имя
Name := RegExReplace(Name,"[ \t]+;.*$","")

If (Name == "") {
  MsgBox,ОШИБКА:`nОтсутствует параметр "Name"
  ExitApp
}

IniRead,Password,%SourceFile%,Description,Password,%A_Space% ; GetValue(SourceFile,"^Password[\s+]?=[\s+]?(.*)") ; Пароль
Password := RegExReplace(Password,"[ \t]+;.*$","")

IniRead,RootDir,%SourceFile%,Description,RootDir,%A_Space%      ; GetValue(SourceFile,"^RootDir[\s+]?=[\s+]?(.*)") ; Корневая папка
RootDir := RegExReplace(RootDir,"[ \t]+;.*$","")
RootDir := ParseEnvironmentVariables(RootDir)                   ; Обработка переменных среды
RootDir := FileGetLongPath(RootDir)                             ; Получение длинного пути
global RootDir := RootDir                                       ; Назначение глобальной переменной для применения во всех функциях

IniRead,TimeStamp,%SourceFile%,Description,TimeStamp,yyyy.MM.dd ; Временной штамп
TimeStamp := RegExReplace(TimeStamp,"[ \t]+;.*$","")
IniRead,CreateNewArchives,%SourceFile%,Description,CreateNewArchives,%A_Space% ; Создавать новый архив вместо синхронизации
CreateNewArchives := RegExReplace(CreateNewArchives,"[ \t]+;.*$","")
IniRead,NewArchiveNumeration,%SourceFile%,Description,NewArchiveNumeration,0.2d ; Нумерация архивов
NewArchiveNumeration := RegExReplace(NewArchiveNumeration,"[ \t]+;.*$","")

IniRead,LockArchive,%SourceFile%,Description,LockArchive,%A_Space% ; Запретить изменение архива
LockArchive := RegExReplace(LockArchive,"[ \t]+;.*$","")

; Определение имени будущего архива
If (RegExMatch(TimeStamp,"false")) {
  Name = %Name%
} else if (TimeStamp == "") {
  FormatTime,Date,,yyyy.MM.dd ; Получение текущей даты (2015.11.29)
  Name = %Name% (%Date%)
} else {
  FormatTime,Date,,%TimeStamp% ; Получение текущей даты (2015.11.29)
  Name = %Name% (%Date%)
}

IniRead,SevenZip,%SourceFile%,Description,SevenZip,%ProgramFiles%\7-Zip\7z.exe  ; GetValue(SourceFile,"^SevenZip[\s+]?=[\s+]?(.*)") ; 7-Zip
SevenZip := RegExReplace(SevenZip,"[ \t]+;.*$","")
SevenZip := ParseEnvironmentVariables(SevenZip)                                 ; Обработка переменных среды
SevenZip := FileGetLongPath(SevenZip)                                           ; Получение длинного пути

IniRead,WinRAR,%SourceFile%,Description,WinRAR,%ProgramFiles%\WinRAR\Rar.exe    ; GetValue(SourceFile,"^WinRAR[\s+]?=[\s+]?(.*)") ; WinRAR
WinRAR := RegExReplace(WinRAR,"[ \t]+;.*$","")
WinRAR := ParseEnvironmentVariables(WinRAR)                                     ; Обработка переменных среды
WinRAR := FileGetLongPath(WinRAR)                                               ; Получение длинного пути

IniRead,ArchiveType,%SourceFile%,Description,ArchiveType,7z                     ; GetValue(SourceFile,"^ArchiveType[\s+]?=[\s+]?(.*)") ; Типы архивов
ArchiveType := RegExReplace(ArchiveType,"[ \t]+;.*$","")
; ArchiveType := Trim(ArchiveType," " . "`t" . """")

DebugMsgText =
( LTrim RTrim Join`r`n
  Name = %Name%
  Password = %Password%
  RootDir = %RootDir%
  SevenZip = %SevenZip%
  WinRAR = %WinRAR%
  ArchiveType = %ArchiveType%
  TimeStamp = %TimeStamp%
  CreateNewArchives = %CreateNewArchives%
  NewArchiveNumeration = %NewArchiveNumeration%
  LockArchive = %LockArchive%
)
MsgBox,1,,%DebugMsgText%
IfMsgBox,Cancel
  ExitApp  ; User pressed the "No" button.
  
If (!FileExist(SevenZip) && InStr(ArchiveType,"7z")) {
  MsgBox,0,Error,Not found:`n%SevenZip%,1.5
}
If (!FileExist(WinRAR) && InStr(ArchiveType,"rar")) {
  MsgBox,0,Error,Not found:`n%WinRAR%,1.5
}
If (ArchiveType = "") {
  MsgBox,0,Error,ArchiveType was not set!,1.5
}

; Определение файлов-списков для обработки архиваторами
IncludeList=%A_Temp%\IncludeList.txt ;%SourceFileDir%\IncludeList.txt
ExcludeList=%A_Temp%\ExcludeList.txt ;%SourceFileDir%\ExcludeList.txt

ArchiveName := Name

If (CreateNewArchives == "true") {
  ArchiveCount := 0
  Loop,Files,%Archive%*%ArchiveType%,F
  {
    MatchString := ConvertToString(Name) . " - (\d+)( .*?)?" . ConvertToString("." . ArchiveType)
    If (RegExMatch(A_LoopFileName,MatchString,Match,1)) {
      ArchiveCount := Match1 + 1
    }
  }
  ArchiveCount := Format("{1:" . NewArchiveNumeration . "}",ArchiveCount) ; Format("{1:0.3d}",ArchiveCount)
  ArchiveName := Name . " - " . ArchiveCount
}

Archive=%SourceFileDir%\%ArchiveName%

; Создание архива с помощью 7-Zip
If (FileExist(SevenZip) && (InStr(ArchiveType,"7z") or ArchiveType = "")) {
  ; Разделение файла-источника на файлы-списки включаемых и исключаемых файлов (кодировка UTF-8)
  SplitTextFile(SourceFile,IncludeList,"[IncludeList]","[ExcludeList]","UTF-8")
  SplitTextFile(SourceFile,ExcludeList,"[ExcludeList]","","UTF-8")

  Type:="7z"                      ; Тип архива
  ; Если пароль задан
  If (Password != "") {
    Password=-p%Password%         ; Пароль на архив
  }
  Compression:="-m0=LZMA2 -mx9"   ; Алгоритм сжатия
  Include=-i@"%IncludeList%"      ; Файл-список включений
  Exclude=-x@"%ExcludeList%"      ; Файл-список исключений
  Synchronize:="p0q0r2x1y2z1w2"   ; Ключ синхронизации
  Incrimental:="p1q1r0x1y2z1w2"   ; Ключ создания инкриментного архива

  ; Определение команды на выполнение архивации
  Command="%SevenZip%" u -u%Synchronize% %Compression% -r0 -slp -t%Type% %Password% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%" -spf2 -w"%A_Temp%"

  ; Проверка наличия параметра %RootDir% (определение корневого каталога архивации)
  ; Если корневой каталог архивации не задан:
  If (RootDir == "") {
    ; RunWait,%Command% ; Выполнение команды архивации в командной строке
    RunWait,%comspec% /k cd /d "%SourceFileDir%" & %Command% & pause & exit

  ; Если корневой каталог архивации задан:
  } else {
    SetWorkingDir %RootDir% ; Назначение корневого каталога архивации рабочим каталогом программы
    ; Копирование файла-источника в корневуой каталог архивации
    If ("%RootDir%\%SourceFileShort%"!="%SourceFile%") { ; Проверка совпадения пути файла-источника с путём копирования файла-источника
      FileCopy,%SourceFile%,%RootDir%\%SourceFileShort%,1 ; Копирование / перезапесь файла в корневой каталог архивации
    }

    ; RunWait,%Command% ; Выполнение команды архивации
    ; Выполнение команды архивации в командной строке
    RunWait,%comspec% /k cd /d "%RootDir%" & %Command% & pause & exit

    If ("%RootDir%\%SourceFileShort%"!="%SourceFile%") { ; Проверка совпадения пути файла-источника с путём копирования файла-источника
      FileDelete,%RootDir%\%SourceFileShort% ;,1 ; Удаление скопированого ранее файла-источника из корневого каталога архивации
    }
    SetWorkingDir %SourceFileDir% ; Восстановление рабочего каталога программы
  }

  ; Удаление файлов-списков
  FileDelete,%IncludeList%
  FileDelete,%ExcludeList%
}

; Создание архива с помощью WinRAR
If (FileExist(WinRAR) && (InStr(ArchiveType,"rar") or ArchiveType = "")) {
  ; Разделение файла-источника на файлы-списки включаемых и исключаемых файлов (кодировка Windows-1251)
  SplitTextFile(SourceFile,IncludeList,"[IncludeList]","[ExcludeList]","CP1251")
  SplitTextFile(SourceFile,ExcludeList,"[ExcludeList]","","CP1251")

  Type:="rar"                     ; Тип архива
  ; Если пароль задан
  If (Password != "") {
    Password=-p%Password%         ; Пароль на архив
  }
  Compression:="-m5 -rr5p"        ; Алгоритм сжатия
  Include=@"%IncludeList%"        ; Файл-список включений
  Exclude=-x@"%ExcludeList%"      ; Файл-список исключений
  Synchronize:=" -as"             ; Ключ синхронизации
  Incrimental:="p1q1r0x1y2z1w2"   ; Ключ создания инкриментного архива

  ; Определение команды на выполнение архивации
  Command="%WinRAR%" u -u%Synchronize% %Compression% -r0 %Password% "%Archive%.%Type%" %Exclude% %Include% "%SourceFileShort%"
  If (LockArchive) {
    Command = %Command% & "%WinRAR%" k "%Archive%.%Type%"
  }

  ; Проверка наличия параметра %RootDir% (определение корневого каталога архивации)
  ; Если корневой каталог архивации не задан:
  If (RootDir == "") {
    ; RunWait,%Command% ; Выполнение команды архивации в командной строке
    RunWait,%comspec% /k cd /d "%SourceFileDir%" & %Command% & pause & exit

  ; Если корневой каталог архивации задан:
  } else {
    SetWorkingDir %RootDir% ; Назначение корневого каталога архивации рабочим каталогом программы
    ; Копирование файла-источника в корневуой каталог архивации
    If ("%RootDir%\%SourceFileShort%"!="%SourceFile%") { ; Проверка совпадения пути файла-источника с путём копирования файла-источника
      FileCopy,%SourceFile%,%RootDir%\%SourceFileShort%,1 ; Копирование / перезапесь файла в корневой каталог архивации
    }

    ; RunWait,%Command% ; Выполнение команды архивации
    ; Выполнение команды архивации в командной строке
    RunWait,%comspec% /k cd /d "%RootDir%" & %Command% & pause & exit

    If ("%RootDir%\%SourceFileShort%"!="%SourceFile%") { ; Проверка совпадения пути файла-источника с путём копирования файла-источника
      FileDelete,%RootDir%\%SourceFileShort%,1 ; Удаление скопированого ранее файла-источника из корневого каталога архивации
    }
    SetWorkingDir %SourceFileDir% ; Восстановление рабочего каталога программы
  }

  ; Удаление файлов-списков
  FileDelete,%IncludeList%
  FileDelete,%ExcludeList%
}

/*
; ===================================================================================
;                 ФУНКЦИЯ ПОЛУЧЕНИЯ ЗНАЧЕНИЙ ИЗ СТРОК ФАЙЛА-ИСТОЧНИКА
; ===================================================================================
GetValue(SourceFile,SearchPattern)
{
  Loop,Read,%SourceFile%
  {
    If RegExMatch(A_LoopReadLine,SearchPattern)
    {
      Value := RegExReplace(A_LoopReadLine,SearchPattern,"$1",,1)
      Return Value
    }
  }
}
*/

; ===================================================================================
;                 ФУНКЦИЯ РАЗДЕЛЕНИЯ ФАЙЛА-ИСТОЧНИКА НА ФАЙЛЫ-СПИСКИ
; ===================================================================================
SplitTextFile(SourceFile,OutputFile,StartString,EndString = "",Encoding = "")
{
  If % Encoding = "" ; if no Encoding defined
  Encoding := A_FileEncoding

  FileDelete,%OutputFile%
  RootDir = %RootDir%

  Loop,Read,%SourceFile%
  {
    IfInString,A_LoopReadLine,%StartString%
    StartLine:=A_Index

    If % EndString = "" ; if no EndString defined
    {
      EndLine:=A_Index + 1
    } else {
      IfInString,A_LoopReadLine,%EndString%
      EndLine:=A_Index
    }
  }

  Loop,Read,%SourceFile%
  {
    If A_LoopReadLine = ; if looped line is empty
    Continue ; skip the current Loop instance

    If RegExMatch(A_LoopReadLine,"^(\s+)?;") ; if looped line is commented
    Continue ; skip the current Loop instance

    If RegExMatch(A_LoopReadLine,"^(\s+)?//") ; if looped line is commented
    Continue ; skip the current Loop instance

    CurrentLine:=A_Index
    If (CurrentLine > StartLine) && (CurrentLine < EndLine)
    {
      CurrentString := ParseEnvironmentVariables(A_LoopReadLine)
      If (RootDir != "") {
        RootDirSlash:=RootDir "`\"
        CurrentString := StrReplace(CurrentString,RootDirSlash,"") ; Удаление корневого каталога из путей файла-списка
      }
      FileAppend,%CurrentString%`n,%OutputFile%,%Encoding%
    }
  }
}
