#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn, All, MsgBox ; Enable warnings to assist with detecting common errors.
SendMode, Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir% ; Ensures a consistent starting directory.

OnExit, HANDLE_EXIT

#Warn, ClassOverwrite, Off

ListLines, Off	; Disable them as they're only useful for debugging purposes.
#KeyHistory, 0	; ListLines and #KeyHistory are functions used to "log your keys".

DetectHiddenWindows, On

Process, Priority,, High

app_name := Script.Name()
Script.Force_Single_Instance([RegExReplace(app_name, "_x(32|64)", "") . "*"])

app_id := DllCall("GetCurrentProcessId")

app_arguments := Get_Args()

config_file := app_arguments.INI_FILE ? app_arguments.INI_FILE : A_ScriptDir . "\" . "Magnifier" . ".ini"

gosub, SET_DEFAULTS
gosub, READ_CONFIFILE
gosub, SAVE_CONFIFILE

gosub, INIT_MAGNIFIER

Exit
; ===========================================================================================================
SET_DEFAULTS:
{
	defaults := {}
	
	; Params
	defaults.zoom := 2
	defaults.follow := 1
	defaults.width := 350
	defaults.height := 250
	defaults.antialiasing := 1
	defaults.processing_delay := 10
	
	; HotKeys
	defaults.key_close_app := "Escape"
	defaults.key_toggle_follow := "Space"
	
	defaults.key_zoom_in := "WheelUp"
	defaults.key_zoom_out := "WheelDown"
	defaults.key_size_encrease := "+WheelUp"
	defaults.key_size_decrease := "+WheelDown"
	
	return
}
READ_CONFIFILE:
{
	; Params
	IniRead, zoom, %config_file%, Params, zoom, % defaults.zoom
	IniRead, follow, %config_file%, Params, follow, % defaults.follow
	IniRead, ww, %config_file%, Params, width, % defaults.width
	IniRead, wh, %config_file%, Params, height, % defaults.height
	IniRead, antialias, %config_file%, Params, antialiasing, % defaults.antialiasing
	IniRead, delay, %config_file%, Params, processing_delay, % defaults.processing_delay
	
	; HotKeys
	IniRead, key_close_app, %config_file%, HotKeys, key_close_app, % defaults.key_close_app
	IniRead, key_toggle_follow, %config_file%, HotKeys, key_toggle_follow, % defaults.key_toggle_follow
	
	IniRead, key_zoom_in, %config_file%, HotKeys, key_zoom_in, % defaults.key_zoom_in
	IniRead, key_zoom_out, %config_file%, HotKeys, key_zoom_out, % defaults.key_zoom_out
	IniRead, key_size_encrease, %config_file%, HotKeys, key_size_encrease, % defaults.key_size_encrease
	IniRead, key_size_decrease, %config_file%, HotKeys, key_size_decrease, % defaults.key_size_decrease
	
	Get_Binds(config_file, "HotKeys", "key_")
	
	return
}
SAVE_CONFIFILE:
{	
	; Params
	IniWrite("zoom", config_file, "Params", zoom)
	IniWrite("follow", config_file, "Params", follow)
	IniWrite("width", config_file, "Params", ww)
	IniWrite("height", config_file, "Params", wh)
	IniWrite("antialiasing", config_file, "Params", antialias)
	IniWrite("processing_delay", config_file, "Params", delay)
	
	; HotKeys
	IniWrite("key_close_app", config_file, "HotKeys", key_close_app)
	IniWrite("key_toggle_follow", config_file, "HotKeys", key_toggle_follow)
	
	IniWrite("key_zoom_in", config_file, "HotKeys", key_zoom_in)
	IniWrite("key_zoom_out", config_file, "HotKeys", key_zoom_out)
	IniWrite("key_size_encrease", config_file, "HotKeys", key_size_encrease)
	IniWrite("key_size_decrease", config_file, "HotKeys", key_size_decrease)
	
	return
}
; ===========================================================================================================
INIT_MAGNIFIER:
{ ; Autohotkey script "Screen Magnifier" -  //autohotkey.com/board/topic/10660-screenmagnifier/?p=456256
	; -----------------------------------------------------------------------------------------------------------
	; Init variables
	; -----------------------------------------------------------------------------------------------------------
	follow    := 1
	ZOOMFX    := 1.189207115
	zoom      := 2
	antialias := 1
	delay     := 10


	whMax     := 
	wh        := 10
	whMin     := 10

	wwMax     := 
	ww        := 100
	wwMin     := 20


	mx        := 0
	my        := 0
	mxp       := mx
	myp       := my
	wwD       := 0
	whD       := 0
	
	gosub, READ_CONFIFILE
	whMin     := Round(wh * 0.5)
	wwMin     := Round(ww * 0.5)
	
	delay := delay < 5 ? 5 : delay
	SetWinDelay, %delay%
	
	; -----------------------------------------------------------------------------------------------------------
	; Init zoom window
	; -----------------------------------------------------------------------------------------------------------
	MouseGetPos, mx, my

	Gui, +AlwaysOnTop  +Owner -Resize -ToolWindow +E0x00000020
	Gui, Show, NoActivate W%ww% H%wh% X-1000 Y-1000, MagWindow ; start offscreen

	WinSet, Transparent  , 254, MagWindow
	Gui, -Caption
	Gui, +Border

	WinGet, PrintSourceID, id
	hdd_frame := DllCall("GetDC", UInt, PrintSourceID)

	WinGet, PrintScreenID,  id, MagWindow
	hdc_frame := DllCall("GetDC", UInt, PrintScreenID)
	if(antialias != 0) {
	  DllCall("gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 4*antialias)
	}
	; -----------------------------------------------------------------------------------------------------------
	Gosub, Repaint
	return
}
; ===========================================================================================================
; Input events

; WheelUp::       ; zoom in
zoom_in:
  if zoom < 4
      zoom *= %ZOOMFX%
return

; WheelDown::     ; zoom out
zoom_out:
  if zoom > %ZOOMFX%
      zoom /= %ZOOMFX%
return

; +WheelDown::    ; larger
size_encrease:
  wwD :=  Round(ww * 0.25) ;32
  whD :=  Round(wh * 0.25) ;32
  Gosub, Repaint
return

; +WheelUp::      ; smaller
size_decrease:
  wwD := Round(ww * -0.25) ;-32
  whD := Round(wh * -0.25) ;-32
  Gosub, Repaint
return

; ===========================================================================================================
; toggle_follow
toggle_follow:
    follow := 1 - follow
return

; Repaint
Repaint:
    CoordMode,   Mouse, Screen
    MouseGetPos, mx, my
    WinGetPos,   wx, wy, ww, wh, MagWindow

    if(wwD != 0)
    {
       ww  += wwD
       wh  += whD
       wwD = 0
       whD = 0
	   ww  := ww < wwMin ? wwMin : ww
	   wh  := wh < whMin ? whMin : wh
    }

    if(mx != mxp) OR (my !- myp)
    {
        DllCall( "gdi32.dll\StretchBlt"
                , UInt, hdc_frame
                , Int , 2                       ; nXOriginDest
                , Int , 2                       ; nYOriginDest
                , Int , ww-6                    ; nWidthDest
                , Int , wh-6                    ; nHeightDest
                , UInt, hdd_frame               ; hdcSrc
                , Int , mx - (ww / 2 / zoom)    ; nXOriginSrc
                , Int , my - (wh / 2 / zoom)    ; nYOriginSrc
                , Int , ww / zoom               ; nWidthSrc
                , Int , wh / zoom               ; nHeightSrc
                , UInt, 0xCC0020)               ; dwRop (raster operation)

       if(follow == 1)
           WinMove, MagWindow, ,mx-ww/2, my-wh/2, %ww%, %wh%

        mxp = mx
        myp = my
    }

    SetTimer, Repaint , %delay%
return

; GuiClose handle_exit
GuiClose:
handle_exit:
close_app:
   DllCall("gdi32.dll\DeleteDC"    , UInt,hdc_frame )
   DllCall("gdi32.dll\DeleteDC"    , UInt,hdd_frame )
Process, Priority, , Normal
ExitApp

; ===========================================================================================================
; ===========================================================================================================
#Include D:\Google Диск\AutoHotkey\Includes\CLASS_Script.ahk
#Include D:\Google Диск\AutoHotkey\Includes\FUNC_IniWrite.ahk
; ===========================================================================================================
Get_Args()
{
	local
	global A_Args
	ret := {}
	for index, arg in A_Args
	{
		if RegExMatch(arg, "^(.*?)=(.*)$", match) {
			key := match1
			val := match2
			ret[key] := val
			MsgBox, %index%. %key%  =  %val%
		}
	}
	return ret
}
Get_Binds(config_file, Section, Prefix := "")
{ ; функция получения назначений клавиш из файла настроек
	local
	static Binds_List, Match, Match1, Key, Value
	;
	IniRead, Binds_List, %config_file%, %Section%
	Loop, Parse, Binds_List, `n, `r
	{
		if RegExMatch(A_LoopField, Prefix . "(.*?)=(.*)", Match) {
			Key := Trim(Match1)
			IniRead, Value, %config_file%, %Section%, % Prefix . Key
			if (Value != "ERROR" and IsLabel(Key)) {
				Hotkey, %Value%, %Key%, UseErrorLevel
				; MsgBox, % Key "`n" Value
			}
			if (not IsLabel(Key)) {
				MsgBox, % "NO LABEL:`n" . Key " = " Value
			}
		}
	}
}
; ===========================================================================================================
