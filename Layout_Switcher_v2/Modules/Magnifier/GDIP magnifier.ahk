
#LTrim
#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Mouse

#Include Gdip_All.ahk ;C:\Portable\AutoHotkey\Lib\Gdip.ahk ;; https://autohotkey.com/boards/viewtopic.php?t=6517

if (!pToken := Gdip_Startup())
  ExitApp

activation_key := "CapsLock"

zoom_step := 1.1

display_width  := 300
display_height := 200

capture_width  := display_width
capture_height := display_height

Hotkey, %activation_key%, zoom
OnExit, Exit
return

#if (GetKeyState(activation_key, "P"))

WheelUp::capture_width /= zoom_step, capture_height /= zoom_step
WheelDown::capture_width *= zoom_step, capture_height *= zoom_step

zoom:
  Gui, -Caption +E0x00080020 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs
  Gui, Show, NA
  hwnd := WinExist()
  hbm := CreateDIBSection(display_width, display_height)
  hdc := CreateCompatibleDC()
  obm := SelectObject(hdc, hbm)
  G := Gdip_GraphicsFromHDC(hdc)
  Gdip_SetInterpolationMode(G, 7)
  pPen := Gdip_CreatePen(0xFF000000,1)
  pBrush := Gdip_BrushCreateHatch(0xFFFFFFFF, 0xFF000000, 38) ;; HatchStyleDiagonalBrick
  Loop
  {
    MouseGetPos, mX, mY, mWin
    WinGetPos, X, Y, W, H, ahk_id %mWin%
    pBitmap := Gdip_BitmapFromHwnd2(mWin, x1 := mX-X-capture_width/2, y1 := mY-Y-capture_height/2, capture_width, capture_height)
    G2 := Gdip_GraphicsFromImage(pBitmap)
    if (x1 < 0)
      Gdip_FillRectangle(G2, pBrush, 0, 0, -x1, capture_height)
    if (y1 < 0)
      Gdip_FillRectangle(G2, pBrush, 0, 0, capture_width, -y1)
    if (W < x1+capture_width)
      Gdip_FillRectangle(G2, pBrush, -x1+W, 0, capture_width-x1+W, capture_height)
    if (H < y1+capture_height)
      Gdip_FillRectangle(G2, pBrush, 0, -y1+H, capture_width, capture_height-y1+H)
    Gdip_DeleteGraphics(G2)
    Gdip_DrawImage(G, pBitmap, 0, 0, display_width, display_height, 0, 0, capture_width, capture_height)
    Gdip_DrawRectangle(G, pPen, 0, 0, display_width-1, display_height-1)
    UpdateLayeredWindow(hwnd, hdc, mX-display_width/2, mY-display_height/2, display_width, display_height)
    Gdip_DisposeImage(pBitmap)
  }
  Until (!GetKeyState(activation_key, "P"))
  Gdip_DeleteBrush(pBrush)
  Gdip_DeletePen(pPen)
  SelectObject(hdc, obm)
  DeleteObject(hbm)
  DeleteDC(hdc)
  Gdip_DeleteGraphics(G)
  Gui, Destroy
return

Exit:
  Gdip_Shutdown(pToken)
  ExitApp
Return

Gdip_BitmapFromHwnd2(hWnd, x=0,y=0, w=0,h=0) {
  if (!w || !h)
    WinGetPos,,, w,h, ahk_id %hWnd%
  hhdc := GetDCEx(hWnd, 3)
  chdc := CreateCompatibleDC()
  hbm := CreateDIBSection(w,h, chdc)
  obm := SelectObject(chdc, hbm)
  BitBlt(chdc, 0,0, w,h, hhdc, x,y)
  ReleaseDC(hhdc)
  pBitmap := Gdip_CreateBitmapFromHBITMAP(hbm)
  SelectObject(chdc, obm)
  DeleteObject(hbm)
  DeleteDC(hhdc)
  DeleteDC(chdc)
  return pBitmap
}
