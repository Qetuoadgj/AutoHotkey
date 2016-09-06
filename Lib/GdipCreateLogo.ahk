GdipCreateLogo(logoFile, logoURL, logoSize, logoAlpha := 1, IconNumber=1, IconSize="")
{
  ; logoFile = %A_ScriptDir%\Images\%SCRIPT_NAME%.png
  ; logoURL := "https://upload.wikimedia.org/wikipedia/en/thumb/d/d0/Chrome_Logo.svg/64px-Chrome_Logo.svg.png"
  ; logoSize := 64
  ; logoAlpha := 0.95

  If (logoFile != "") {
    ; Uncomment if Gdip.ahk is not in your standard library
    ; #Include, Gdip.ahk

    ; Start gdi+
    If !pToken := Gdip_Startup()
    {
      MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
      ExitApp
    }
    OnExit, Exit

    ; Create a layered window (+E0x80000 : must be used for UpdateLayeredWindow to work!) that is always on top (+AlwaysOnTop), has no taskbar entry or caption
    Gui, Logo_: +AlwaysOnTop -Caption +ToolWindow +LastFound +OwnDialogs +Owner +E0x80000 +hwndlogoHwnd

    ; Show the window
    Gui, Logo_: Show, NA

    ; If the image we want to work with does not exist on disk, then download it...
    If !FileExist(logoFile) {
      SplitPath, logoFile, , logoDir
      IfNotExist, logoDir
      {
        FileCreateDir,% logoDir
      }
      UrlDownloadToFile, %logoURL%, %logoFile%
    }

    ; Get a bitmap from the image
    logoBitmap := Gdip_CreateBitmapFromFile(logoFile, IconNumber=1, IconSize="")

    ; Check to ensure we actually got a bitmap from the file, in case the file was corrupt or some other error occured
    If !logoBitmap
    {
      MsgBox, 48, File loading error!, Could not load the image specified
      ExitApp
    }

    ; Get the width and height of the bitmap we have just created from the file
    ; This will be the dimensions that the file is
    Gdip_GetImageDimensions(logoBitmap, logoWidth, logoHeight) ;logoWidth := Gdip_GetImageWidth(logoBitmap), logoHeight := Gdip_GetImageHeight(logoBitmap)
    logoScale := logoSize / logoHeight
    logoWidth := logoWidth * logoScale
    logoHeight := logoHeight * logoScale
    logoY := 64 ; + 20 ;128 ;A_ScreenHeight * 0.1
    logoX := A_ScreenWidth - logoWidth - 64 ;A_ScreenWidth - logoY*2 - logoWidth

    ; Create a gdi bitmap with width and height of what we are going to draw into it. This is the entire drawing area for everything
    ; We are creating this "canvas" at half the size of the actual image
    ; We are halving it because we want the image to show in a gui on the screen at half its dimensions
    hbm := CreateDIBSection(logoWidth, logoHeight)

    ; Get a device context compatible with the screen
    hdc := CreateCompatibleDC()

    ; Select the bitmap into the device context
    obm := SelectObject(hdc, hbm)

    ; Get a pointer to the graphics of the bitmap, for use with drawing functions
    G := Gdip_GraphicsFromHDC(hdc)

    ; We do not need SmoothingMode as we did in previous examples for drawing an image
    ; Instead we must set InterpolationMode. This specifies how a file will be resized (the quality of the resize)
    ; Interpolation mode has been set to HighQualityBicubic = 7
    Gdip_SetInterpolationMode(G, 7)

    ; DrawImage will draw the bitmap we took from the file into the graphics of the bitmap we created
    ; We are wanting to draw the entire image, but at half its size
    ; Coordinates are therefore taken from (0,0) of the source bitmap and also into the destination bitmap
    ; The source height and width are specified, and also the destination width and height (half the original)
    ; Gdip_DrawImage(pGraphics, pBitmap, dx, dy, dw, dh, sx, sy, sw, sh, Matrix)
    ; d is for destination and s is for source. We will not talk about the matrix yet (this is for changing colours when drawing)
    Gdip_DrawImage(G, logoBitmap, 0, 0, logoWidth, logoHeight)

    ; Update the specified window we have created (logoHwnd) with a handle to our bitmap (hdc), specifying the x,y,w,h we want it positioned on our screen
    ; So this will position our gui at (0,0) with the Width and Height specified earlier (half of the original image)
    logoAlpha := floor(255*logoAlpha)
    logoAlpha > 255 ? logoAlpha := 255 : logoAlpha < 0 ? logoAlpha := 0
    UpdateLayeredWindow(logoHwnd, hdc, logoX, logoY, logoWidth, logoHeight, logoAlpha)

    ; Select the object back into the hdc
    SelectObject(hdc, obm)

    ; Now the bitmap may be deleted
    DeleteObject(hbm)

    ; Also the device context related to the bitmap may be deleted
    DeleteDC(hdc)

    ; The graphics may now be deleted
    Gdip_DeleteGraphics(G)

    ; The bitmap we made from the image may be deleted
    Gdip_DisposeImage(logoBitmap)

    OnMessage(0x201, "WM_LBUTTONDOWN")
  }
}
; ------------------ FUNCTIONS ------------------
WM_LBUTTONDOWN()
{
  PostMessage, 0xA1, 2
}
; ------------------ IMPORTANT! ------------------
Logo_GuiContextMenu:
{
  Menu, Tray, Show
  Return
}
Exit:
{
  ; gdi+ may now be shutdown on exiting the program
  Gdip_Shutdown(pToken)
  ExitApp
  Return
}
