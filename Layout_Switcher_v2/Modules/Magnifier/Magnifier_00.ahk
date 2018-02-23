;====================================================================================================
; Screen Magnifier-by Holomind://autohotkey.com/board/topic/10660-screenmagnifier/?p=67011
;====================================================================================================

#SingleInstance, Ignore

OnExit, HANDLE_EXIT

/*
delay := 10
antialiasing := 0
follow := 1 ;0
zoom := 2^0.5
zoom_min := 1.0 ;0.5
zoom_max := 32.0
zoom_step := 2^0.5
width := 400
height := 400/1.5
*/

config_file := A_ScriptDir . "\Magnifier.ini"

hotkeys_created := 0

gosub, SET_DEFAULTS
gosub, GET_SETTINGS
gosub, ASSIGN_HOTKEYS

if (hotkeys_created) {
	gosub, INIT_LUPE
	follow := 1 - follow
	gosub, TOGGLE_FOLLOW
}

gosub, SAVE_CONFIG_FILE

if (not hotkeys_created) {
	Reload
}

/*
HotKey, Esc, HANDLE_EXIT
HotKey, Space, TOGGLE_FOLLOW
HotKey, WheelUp, ZOOM_IN
HotKey, WheelDown, ZOOM_OUT
*/
/*
Down::
{
	dy -= 1
	return
}
Up::
{
	dy += 1
	return
}
Left::
{
	dx -= 1
	return
}
Right::
{
	dx += 1
	return
}
*/
Exit

;====================================================================================================
SET_DEFAULTS:
{
	defaults := {}

	; Params
	defaults.zoom := 2 ;^0.5
	defaults.zoom_min := 1
	defaults.zoom_max := 32
	defaults.zoom_step := 2 ;^0.5
	defaults.follow := 1
	defaults.width := 400
	defaults.height := 400/2 ;^0.5
	defaults.antialiasing := 0 ;1
	defaults.processing_delay := 15

	; HotKeys
	defaults.key_close_app := "Escape"
	defaults.key_toggle_follow := "Space"
	defaults.key_zoom_in := "WheelUp"
	defaults.key_zoom_out := "WheelDown"

	return
}
GET_SETTINGS:
{
	; Params
	IniRead, zoom, %config_file%, Params, zoom, % defaults.zoom
	IniRead, zoom_min, %config_file%, Params, zoom_min, % defaults.zoom_min
	IniRead, zoom_max, %config_file%, Params, zoom_max, % defaults.zoom_max
	IniRead, zoom_step, %config_file%, Params, zoom_step, % defaults.zoom_step
	IniRead, follow, %config_file%, Params, follow, % defaults.follow
	IniRead, width, %config_file%, Params, width, % defaults.width
	IniRead, height, %config_file%, Params, height, % defaults.height
	IniRead, antialiasing, %config_file%, Params, antialiasing, % defaults.antialiasing
	IniRead, delay, %config_file%, Params, processing_delay, % defaults.processing_delay

	; HotKeys
	IniRead, key_close_app, %config_file%, HotKeys, key_close_app, % defaults.key_close_app
	IniRead, key_toggle_follow, %config_file%, HotKeys, key_toggle_follow, % defaults.key_toggle_follow
	IniRead, key_zoom_in, %config_file%, HotKeys, key_zoom_in, % defaults.key_zoom_in
	IniRead, key_zoom_out, %config_file%, HotKeys, key_zoom_out, % defaults.key_zoom_out

	return
}
ASSIGN_HOTKEYS:
{
	; HotKeys
	Get_Binds(config_file, "HotKeys", "key_")
	return
}
#Include D:\Google Диск\AutoHotkey\Includes\FUNC_IniWrite.ahk
SAVE_CONFIG_FILE:
{
	; Params
	IniWrite("zoom", config_file, "Params", zoom)
	IniWrite("zoom_min", config_file, "Params", zoom_min)
	IniWrite("zoom_max", config_file, "Params", zoom_max)
	IniWrite("zoom_step", config_file, "Params", zoom_step)
	IniWrite("follow", config_file, "Params", follow)
	IniWrite("width", config_file, "Params", width)
	IniWrite("height", config_file, "Params", height)
	IniWrite("antialiasing", config_file, "Params", antialiasing)
	IniWrite("processing_delay", config_file, "Params", delay)

	; HotKeys
	IniWrite("key_close_app", config_file, "HotKeys", key_close_app)
	IniWrite("key_toggle_follow", config_file, "HotKeys", key_toggle_follow)
	IniWrite("key_zoom_in", config_file, "HotKeys", key_zoom_in)
	IniWrite("key_zoom_out", config_file, "HotKeys", key_zoom_out)

	return
}
;====================================================================================================
Get_Binds(config_file, Section, Prefix := "")
{ ; функция получения назначений клавиш из файла настроек
	local
	static Binds_List, Match, Match1, Key, Value
	;
	global hotkeys_created
	;
	IniRead, Binds_List, %config_file%, %Section%
	Loop, Parse, Binds_List, `n, `r
	{
		if RegExMatch(A_LoopField, Prefix . "(.*?)=(.*)", Match) {
			Key := Trim(Match1)
			IniRead, Value, %config_file%, %Section%, % Prefix . Key
			if (Value != "Error" and IsLabel(Key)) {
				Hotkey, %Value%, %Key%, UseErrorLevel
				hotkeys_created := 1
				; MsgBox, % Key "`n" Value
			}
			if (not IsLabel(Key)) {
				; MsgBox, % "No Label:`n" . Key " = " Value
			}
		}
	}
}
;====================================================================================================
INIT_LUPE:
{
	; follow := 0
	; dx := 7, dy := 26
	; dx := 10, dy := 17
	dx := 5, dy := 9

	lupe_output_window_name := "lupe_output_window_title"

	Gui, LUPE_: +AlwaysOnTop +Owner +Resize +ToolWindow ; window for the dock
	Gui, LUPE_: Show, NoActivate w%width% h%height% x300 y50, %lupe_output_window_name%

	WinGet, lupe_output_window_id, ID, %lupe_output_window_name%
	WinGet, image_source_window_id, ID

	; ToolTip, lupe_output_window_id: %lupe_output_window_id%`nimage_source_window_id: %image_source_window_id%

	; WinSet, Region, 0-0 w365 h365 E, %lupe_output_window_name%

	WinSet, Transparent, % 254*1, %lupe_output_window_name% ; exclude lupe window from source image processing

	hdd_frame := DllCall("GetDC", UInt, image_source_window_id)
	hdc_frame := DllCall("GetDC", UInt, lupe_output_window_id)

	; ToolTip, hdc_frame: %hdd_frame%

	hdc_buffer := DllCall("gdi32.dll\CreateCompatibleDC", UInt, hdc_frame) ; buffer
	hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt, hdc_frame, Int, A_ScreenWidth, Int, A_ScreenHeight)

	delay := delay < 10 ? 10 : delay
	antialiasing := antialiasing >= 1 ? 1 : 0

	SetWinDelay, %delay%

	gosub, MAGNIFICATION_PROCESSING
	return
}
MAGNIFICATION_PROCESSING:
{
	CoordMode, Mouse, Screen
	MouseGetPos, mx, my ; position of mouse
	WinGetPos, wx, wy, ww, wh, %lupe_output_window_name%

	; ToolTip, wx: %wx%`nwy: %wy%`nww: %ww%`nwh: %wh%`ndx: %dx%`ndy: %dy%`nzoom: %zoom%

	if (antialiasing) {
		DllCall("gdi32.dll\SetStretchBltMode", "UInt", hdc_frame, "Int", 4*antialiasing) ; Halftone better quality with stretch
	}

	DllCall("gdi32.dll\StretchBlt"
	,"UInt", hdc_frame
	, "Int", 0
	, "Int", 0
	, "Int", ww
	, "Int", wh
	,"UInt", hdd_frame
	, "Int", mx-(ww/2/zoom)+dx/zoom
	, "Int", my-(wh/2/zoom)+dy/zoom
	, "Int", ww/zoom
	, "Int", wh/zoom
	,"UInt", 0xCC0020) ; SRCCOPY

	if (follow) {
		WinMove, %lupe_output_window_name%,, mx-ww/2, my-wh/2
	}

	SetTimer, %A_ThisLabel%, %delay%
	return
}
CLEAR_MEMORY:
{
	DllCall("gdi32.dll\DeleteObject", UInt, hbm_buffer)
	DllCall("gdi32.dll\DeleteDC", UInt, hdc_frame)
	DllCall("gdi32.dll\DeleteDC", UInt, hdd_frame)
	DllCall("gdi32.dll\DeleteDC", UInt, hdc_buffer)
	return
}
CLOSE_APP:
LUPE_GuiClose:
HANDLE_EXIT:
{
	gosub, CLEAR_MEMORY
	ExitApp
}
TOGGLE_FOLLOW:
{
	follow := 1 - follow
	if (follow) {
		Gui, LUPE_: +E0x00000020
		Gui, LUPE_: -Resize
		Gui, LUPE_: -Caption
		Gui, LUPE_: +Border
		dx := 0, dy := 1
	}
	else {
		Gui, LUPE_: -E0x00000020
		Gui, LUPE_: +Resize
		Gui, LUPE_: +Caption
		Gui, LUPE_: +Border
		dx := 7, dy := 26
	}
	return
}
ZOOM_IN:
{
	zoom *= zoom_step
	zoom := zoom > zoom_max ? zoom_max : zoom
	return
}
ZOOM_OUT:
{
	zoom /= zoom_step
	zoom := zoom < zoom_min ? zoom_min : zoom
	return
}
/*
LUPE_GuiSize:
{
	WinGetPos,,, width, height, %lupe_output_window_name%

	; Params
	IniWrite("width", config_file, "Params", width)
	IniWrite("height", config_file, "Params", height)

	return
}
*/
;====================================================================================================