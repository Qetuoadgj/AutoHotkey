@echo off

cls
	cd /d "%~dp0"
	set "compiler_dir=D:\Program Files\AutoHotkey\Compiler"
	set "Script_Name=Layout_Switcher"
	"%compiler_dir%\Ahk2Exe.exe" /in "%Script_Name%.ahk" /out "%Script_Name%_x32.exe" /icon "%Script_Name%.ico" /bin "%compiler_dir%\Unicode 32-bit.bin" /mpress 1
	"%compiler_dir%\Ahk2Exe.exe" /in "%Script_Name%.ahk" /out "%Script_Name%_x64.exe" /icon "%Script_Name%.ico" /bin "%compiler_dir%\Unicode 64-bit.bin" /mpress 1
pause
