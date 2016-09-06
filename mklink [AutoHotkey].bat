@echo off
:: Определение пути каталога "Мои документы"
  for /f "tokens=3* delims= " %%a in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal"') do (set UserDocuments=%%a)
:: Определение разрядности системы
  reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" /v "Identifier" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
:: Определение пути каталога "Program Files"
  if /i %OS%==64BIT ( set "pf=%programfiles(x86)%" ) else ( set "pf=%programfiles%" )
:: Создание ссылок
  if exist "%UserDocuments%" (
    mklink /d "%UserDocuments%\AutoHotkey\Lib" "%~dp0\Lib"
  ) else (
    echo.%UserDocuments% not found!
  )
pause