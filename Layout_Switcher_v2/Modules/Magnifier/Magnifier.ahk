;====================================================================================================
; Screen Magnifier-by Holomind://autohotkey.com/board/topic/10660-screenmagnifier/?p=67011
;====================================================================================================

#SingleInstance, Ignore

G_App_Version := "1.0.00 [AHK v1.1.33.01 - July 13, 2020]"

OnExit, HANDLE_EXIT

; OS_MajorVersion := DllCall("GetVersion") & 0xFF                ; 10
; OS_MinorVersion := DllCall("GetVersion") >> 8 & 0xFF           ; 0
; OS_BuildNumber  := DllCall("GetVersion") >> 16 & 0xFFFF        ; 10532

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
BitBlt_operation := 0xCC0020
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
	negative := 1 - negative
	gosub, TOGGLE_NEGATIVE
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
	defaults.zoom_max := 4 ;32
	defaults.zoom_step := 2 ;^0.5
	defaults.follow := 1
	defaults.negative := 0
	defaults.width := 400
	defaults.height := 250 ;400/2 ;^0.5
	defaults.antialiasing := 0 ;1
	defaults.processing_delay := 15
	defaults.processing_mode := 3 ;(OS_MajorVersion > 6) ? 1 : 0 ; WIN_8+

	; HotKeys
	defaults.key_close_app := "Escape"
	defaults.key_toggle_follow := "LWin & X"  . " Up" ;"Space"
	defaults.key_toggle_negative := "LWin & N" . " Up"
	defaults.key_zoom_in := "WheelUp"
	defaults.key_zoom_out := "WheelDown"

	return
}
GET_SETTINGS:
{
	Critical, On
	
	; Params
	IniRead, zoom, %config_file%, Params, zoom, % defaults.zoom
	IniRead, zoom_min, %config_file%, Params, zoom_min, % defaults.zoom_min
	IniRead, zoom_max, %config_file%, Params, zoom_max, % defaults.zoom_max
	IniRead, zoom_step, %config_file%, Params, zoom_step, % defaults.zoom_step
	IniRead, follow, %config_file%, Params, follow, % defaults.follow
	IniRead, negative, %config_file%, Params, negative, % defaults.negative
	IniRead, width, %config_file%, Params, width, % defaults.width
	IniRead, height, %config_file%, Params, height, % defaults.height
	IniRead, antialiasing, %config_file%, Params, antialiasing, % defaults.antialiasing
	IniRead, delay, %config_file%, Params, processing_delay, % defaults.processing_delay
	IniRead, processing_mode, %config_file%, Params, processing_mode, % defaults.processing_mode

	; HotKeys
	IniRead, key_close_app, %config_file%, HotKeys, key_close_app, % defaults.key_close_app
	IniRead, key_toggle_follow, %config_file%, HotKeys, key_toggle_follow, % defaults.key_toggle_follow
	IniRead, key_toggle_negative, %config_file%, HotKeys, key_toggle_negative, % defaults.key_toggle_negative
	IniRead, key_zoom_in, %config_file%, HotKeys, key_zoom_in, % defaults.key_zoom_in
	IniRead, key_zoom_out, %config_file%, HotKeys, key_zoom_out, % defaults.key_zoom_out
	
	Critical, Off
	return
}
ASSIGN_HOTKEYS:
{
	Critical, On
	; HotKeys
	Get_Binds(config_file, "HotKeys", "key_")
	Critical, Off
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
	IniWrite("negative", config_file, "Params", negative)
	IniWrite("width", config_file, "Params", Round(width))
	IniWrite("height", config_file, "Params", Round(height))
	IniWrite("antialiasing", config_file, "Params", antialiasing)
	IniWrite("processing_delay", config_file, "Params", delay)
	IniWrite("processing_mode", config_file, "Params", processing_mode)

	; HotKeys
	IniWrite("key_close_app", config_file, "HotKeys", key_close_app)
	IniWrite("key_toggle_follow", config_file, "HotKeys", key_toggle_follow)
	IniWrite("key_toggle_negative", config_file, "HotKeys", key_toggle_negative)
	IniWrite("key_zoom_in", config_file, "HotKeys", key_zoom_in)
	IniWrite("key_zoom_out", config_file, "HotKeys", key_zoom_out)

	return
}
;====================================================================================================
Get_Binds(config_file, Section, Prefix := "")
{ ; функция получения назначений клавиш из файла настроек
	local
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
#Include Gdip_All.ahk ; https://autohotkey.com/boards/viewtopic.php?t=6517
;====================================================================================================
Gdip_BitmapFromHwnd2(hWnd, x=0, y=0, w=0, h=0) {
	if (!w || !h)
    WinGetPos,,, w,h, ahk_id %hWnd%
	hhdc := GetDCEx(hWnd, 3)
	chdc := CreateCompatibleDC()
	hbm := CreateDIBSection(w,h, chdc)
	obm := SelectObject(chdc, hbm)
	BitBlt(chdc, 0, 0, w, h, hhdc, x, y)
	ReleaseDC(hhdc)
	pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
	SelectObject(chdc, obm)
	DeleteObject(hbm)
	DeleteDC(hhdc)
	DeleteDC(chdc)
	return pBitmap
}
;====================================================================================================
INIT_LUPE:
{
	if (processing_mode == 3)
	{ ; GDIP magnifier - https://autohotkey.com/boards/viewtopic.php?t=28937#
		if (!pToken := Gdip_Startup()) {
			ExitApp
		}

		CoordMode, Mouse, Screen

		display_width  := width
		display_height := height
		capture_width  := display_width / zoom
		capture_height := display_height / zoom

		Gui, LUPE_: -Caption +E0x00080020 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs +hwndLUPE_ID
		Gui, LUPE_: Show, NA

		hbm := CreateDIBSection(display_width, display_height)
		hdc := CreateCompatibleDC()
		obm := SelectObject(hdc, hbm)
		G := Gdip_GraphicsFromHDC(hdc)
		Gdip_SetInterpolationMode(G, 7)
		pPen := Gdip_CreatePen(0xFF000000,1)
		; pBrush := Gdip_BrushCreateHatch(0xFFFFFFFF, 0xFF000000, 38) ; HatchStyleDiagonalBrick

		MouseGetPos, mX, mY, mWin
		tX := mX-display_width/2
		ty := mY-display_height/2

		GDIP_COLOR_MATRIX_INVERT := "-1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1"
		GDIP_COLOR_MATRIX_DEFAULT := ""
		GDIP_COLOR_MATRIX := GDIP_COLOR_MATRIX_DEFAULT
	}
	else if (processing_mode == 2)
	{ ; Magnification API and AutoHotkey - //autohotkey.com/board/topic/64060-magnification-api-and-autohotkey/?p=403936
		Gui, LUPE_: +AlwaysOnTop +Owner +Resize +ToolWindow +hwndLUPE_ID
		Gui, LUPE_: Show, NoActivate w%width% h%height% x300 y50
		WinSet, Transparent, 254, ahk_id %LUPE_ID%

		CoordMode, Mouse, Screen

		vSfx := (A_PtrSize=8) ? "Ptr" : ""
		hInstance := DllCall("GetWindowLong",vSfx, Ptr,LUPE_ID, Int,-6) ; GWL_HINSTANCE := -6
		DllCall("LoadLibrary", Str,"magnification.dll")
		DllCall("magnification.dll\MagInitialize")
		WS_CHILD := 0x40000000
		WS_VISIBLE := 0x10000000
		MS_SHOWMAGNIFIEDCURSOR := 0x1
		MS_INVERTCOLORS := 0x4
		vWinStyle := WS_CHILD | WS_VISIBLE
		gosub, DLL_CALCULATE_ZOOM
	}
	else
	{ ; Screen Magnifier by Holomind - ://autohotkey.com/board/topic/10660-screenmagnifier/?p=67011
		Gui, LUPE_: +AlwaysOnTop +Owner +Resize +ToolWindow +hwndLUPE_ID
		Gui, LUPE_: Show, NoActivate w%width% h%height% x300 y50
		WinSet, Transparent, 254, ahk_id %LUPE_ID%

		CoordMode, Mouse, Screen

		SRCCOPY := 0xCC0020
		SRCINVERT := 0x330008
		BitBlt_operation := SRCCOPY
		hdd_frame := DllCall("GetDC", UInt, 0)
		hdc_frame := DllCall("GetDC", UInt, LUPE_ID)
		; hdc_buffer := DllCall("gdi32.dll\CreateCompatibleDC", UInt, hdc_frame) ; buffer
		; hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt, hdc_frame, Int, A_ScreenWidth, Int, A_ScreenHeight)
		if (antialiasing) {
			DllCall("gdi32.dll\SetStretchBltMode", "UInt", hdc_frame, "Int", 4*antialiasing) ; Halftone better quality with stretch
		}
	}
	delay := delay < 10 ? 10 : delay
	antialiasing := antialiasing >= 1 ? 1 : 0
	SetWinDelay, %delay%
	gosub, MAGNIFICATION_PROCESSING
	return
}
DLL_CALCULATE_ZOOM:
{
	VarSetCapacity(MAGTRANSFORM, 36, 0)
	NumPut(zoom, MAGTRANSFORM, (1-1)*4, "Float")
	NumPut(zoom, MAGTRANSFORM, (5-1)*4, "Float")
	NumPut(1, MAGTRANSFORM, (9-1)*4, "Float")
	return
}
DLL_UPDATE_OUTPUT_IMAGE:
{
	WinGetPos, wx, wy, ww, wh, ahk_id %LUPE_ID%
	hCtl := DllCall("CreateWindowEx"
	, UInt, 0
	, Str, "Magnifier"
	, Str, "MagnifierWindow"
	, UInt, vWinStyle
	, Int, 0
	, Int, 0
	, Int, ww
	, Int, wh
	, Ptr, LUPE_ID
	, Ptr, 0
	, Ptr, hInstance
	, Ptr, 0
	, Ptr)
	return
}
MAGNIFICATION_PROCESSING:
{
	if (processing_mode == 3) {
		MouseGetPos, mX, mY, mWin
		WinGetPos, X, Y, W, H, ahk_id %mWin%
		pBitmap := Gdip_BitmapFromHwnd2(mWin, x1 := mX-X-capture_width/2, y1 := mY-Y-capture_height/2, capture_width, capture_height)
		G2 := Gdip_GraphicsFromImage(pBitmap)
		/*
		if (x1 < 0) {
			Gdip_FillRectangle(G2, pBrush, 0, 0, -x1, capture_height)
		}
		if (y1 < 0) {
			Gdip_FillRectangle(G2, pBrush, 0, 0, capture_width, -y1)
		}
		if (W < x1+capture_width) {
			Gdip_FillRectangle(G2, pBrush, -x1+W, 0, capture_width-x1+W, capture_height)
		}
		if (H < y1+capture_height) {
			Gdip_FillRectangle(G2, pBrush, 0, -y1+H, capture_width, capture_height-y1+H)
		}
		*/
		Gdip_DeleteGraphics(G2)
		; Gdip_DrawImage(G, pBitmap, 0, 0, display_width, display_height, 0, 0, capture_width, capture_height)
		Gdip_DrawImage(G, pBitmap, 0, 0, display_width, display_height, 0,0 , capture_width, capture_height, GDIP_COLOR_MATRIX)

		Gdip_DrawRectangle(G, pPen, 0, 0, display_width-1, display_height-1)

		tX := follow ? mX-display_width/2 : tX
		ty := follow ? mY-display_height/2 : tY

		UpdateLayeredWindow(LUPE_ID
		, hdc
		, tX ;mX-display_width/2
		, tY ;mY-display_height/2
		, display_width
		, display_height)

		Gdip_DisposeImage(pBitmap)
	}
	else if (processing_mode == 2) {
		MouseGetPos, mx, my ; position of mouse
		WinGetPos, wx, wy, ww, wh, ahk_id %LUPE_ID%
		DllCall("magnification.dll\MagSetWindowTransform"
		, Ptr, hCtl
		, Ptr, &MAGTRANSFORM)
		DllCall("magnification.dll\MagSetWindowSource"
		, Ptr, hCtl
		, Int, mx-(ww/2/zoom)+dx/zoom
		, Int, my-(wh/2/zoom)+dy/zoom
		, Int, ww
		, Int, wh)
	}
	else {
		MouseGetPos, mx, my ; position of mouse
		WinGetPos, wx, wy, ww, wh, ahk_id %LUPE_ID%
		DllCall("gdi32.dll\StretchBlt"
		,UInt, hdc_frame
		, Int, 0
		, Int, 0
		, Int, ww
		, Int, wh
		,UInt, hdd_frame
		, Int, mx-(ww/2/zoom)+dx/zoom
		, Int, my-(wh/2/zoom)+dy/zoom
		, Int, ww/zoom
		, Int, wh/zoom
		,UInt, BitBlt_operation)
	}
	if (follow) {
		WinMove, ahk_id %LUPE_ID%,, mx-ww/2, my-wh/2
	}
	SetTimer, %A_ThisLabel%, %delay%
	return
}
CLEAR_MEMORY:
{
	if (processing_mode == 3) {
		; Gdip_DeleteBrush(pBrush)
		Gdip_DeletePen(pPen)
		SelectObject(hdc, obm)
		DeleteObject(hbm)
		DeleteDC(hdc)
		Gdip_DeleteGraphics(G)
		;
		Gdip_Shutdown(pToken)
	}
	else if (processing_mode == 2) {
		DllCall("magnification.dll\MagUninitialize")
		Gui, LUPE_: Destroy
	}
	else {
		; DllCall("gdi32.dll\DeleteObject", UInt, hbm_buffer)
		DllCall("gdi32.dll\DeleteDC", UInt, hdc_frame)
		DllCall("gdi32.dll\DeleteDC", UInt, hdd_frame)
		; DllCall("gdi32.dll\DeleteDC", UInt, hdc_buffer)
		Gui, LUPE_: Destroy
	}
	return
}
CLOSE_APP:
LUPE_GuiClose:
HANDLE_EXIT:
{
	Critical, On
	gosub, CLEAR_MEMORY
	ExitApp
}
TOGGLE_FOLLOW:
{
	follow := 1 - follow
	gosub, SAVE_CONFIG_FILE
	if (processing_mode == 3) {
		return
	}
	if (processing_mode == 2) {
		if (follow) {
			Gui, LUPE_: +E0x00000020
			Gui, LUPE_: -Resize
			Gui, LUPE_: -Caption
			Gui, LUPE_: +Border
			dx := 0, dy := 0
		}
		else {
			Gui, LUPE_: -E0x00000020
			Gui, LUPE_: +Resize
			Gui, LUPE_: +Caption
			Gui, LUPE_: +Border
			dx := 0, dy := 12
		}
		gosub, DLL_UPDATE_OUTPUT_IMAGE
	}
	else {
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
	}
	return
}
TOGGLE_NEGATIVE:
{
	negative := 1 - negative
	gosub, SAVE_CONFIG_FILE
	if (processing_mode == 3) {
		GDIP_COLOR_MATRIX := negative ? GDIP_COLOR_MATRIX_INVERT : GDIP_COLOR_MATRIX_DEFAULT
	}
	if (processing_mode == 2) {
		if (negative) {
			vWinStyle := WS_CHILD | WS_VISIBLE | MS_INVERTCOLORS
		}
		else {
			vWinStyle := WS_CHILD | WS_VISIBLE
		}
		gosub, DLL_UPDATE_OUTPUT_IMAGE
	}
	else {
		if (negative) {
			BitBlt_operation := SRCINVERT
		}
		else {
			BitBlt_operation := SRCCOPY
		}
	}
	return
}
ZOOM_IN:
{
	zoom *= zoom_step
	zoom := zoom > zoom_max ? zoom_max : zoom
	gosub, SAVE_CONFIG_FILE
	; ToolTip, zoom: %zoom% (%zoom_step%)
	if (processing_mode == 3) {
		capture_width := display_width / zoom
		capture_height := display_height / zoom
	}
	else if (processing_mode == 2) {
		gosub, DLL_CALCULATE_ZOOM
	}
	return
}
ZOOM_OUT:
{
	zoom /= zoom_step
	zoom := zoom < zoom_min ? zoom_min : zoom
	gosub, SAVE_CONFIG_FILE
	; ToolTip, zoom: %zoom% (%zoom_step%)
	if (processing_mode == 3) {
		capture_width := display_width / zoom
		capture_height := display_height / zoom
	}
	else if (processing_mode == 2) {
		gosub, DLL_CALCULATE_ZOOM
	}
	return
}
/*
LUPE_GuiSize:
{
	WinGetPos,,, width, height, ahk_id %LUPE_ID%

	; Params
	IniWrite("width", config_file, "Params", width)
	IniWrite("height", config_file, "Params", height)

	return
}
*/
;====================================================================================================