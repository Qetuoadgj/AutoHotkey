@echo off
cls
	cd /d "%~dp0"
	set "compiler_dir=%SystemDrive%\Program Files\AutoHotkey\Compiler"
	set "Script_Name=Layout_Switcher"
	if exist "%Script_Name%_x32.exe" (erase %Script_Name%_x32.exe)
	if exist "%Script_Name%_x32.exe" (erase %Script_Name%_x32.exe)

	"%compiler_dir%\Ahk2Exe.exe" /in "%Script_Name%.ahk" /out "%Script_Name%_x32.exe" /icon "%Script_Name%.ico" /bin "%compiler_dir%\Unicode 32-bit.bin" /mpress 1
	if exist "%Script_Name%_x32.exe" (echo.%Script_Name%_x32.exe)
	"%compiler_dir%\Ahk2Exe.exe" /in "%Script_Name%.ahk" /out "%Script_Name%_x64.exe" /icon "%Script_Name%.ico" /bin "%compiler_dir%\Unicode 64-bit.bin" /mpress 1
	if exist "%Script_Name%_x64.exe" (echo.%Script_Name%_x64.exe)
pause
