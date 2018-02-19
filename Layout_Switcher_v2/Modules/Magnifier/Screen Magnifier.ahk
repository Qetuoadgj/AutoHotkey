;=================================================================================
; Autohotkey script "Screen Magnifier" -  //autohotkey.com/board/topic/10660-screenmagnifier/?p=456256
;=================================================================================
#SingleInstance ignore
Process, Priority, , High
OnExit handle_exit
hotkey, Space,  toggle_follow
hotkey, Escape, GuiClose
hotkey, F18,    GuiClose
; Init variables
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


; Init zoom window

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
  if(antialias != 0)
      DllCall("gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 4*antialias)


Gosub, Repaint
return
;=================================================================================
; Input events

WheelUp::       ; zoom in
  if zoom < 4
      zoom *= %ZOOMFX%
return

WheelDown::     ; zoom out
  if zoom > %ZOOMFX%
      zoom /= %ZOOMFX%
return


+WheelDown::    ; larger
  wwD =  32
  whD =  32
  Gosub, Repaint
return

+WheelUp::      ; smaller
  wwD = -32
  whD = -32
  Gosub, Repaint
return

;=================================================================================
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
   DllCall("gdi32.dll\DeleteDC"    , UInt,hdc_frame )
   DllCall("gdi32.dll\DeleteDC"    , UInt,hdd_frame )
Process, Priority, , Normal
ExitApp

;=================================================================================