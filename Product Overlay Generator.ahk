#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance Force
#Include Gdip_All.ahk

SelectedOutputFolder := ""

;Start Gdip
If !pToken := Gdip_Startup() {
    MsgBox, 16, Gdiplus Error, Gdiplus failed to start.
    ExitApp
}

Gui, Main: New
Gui, Main: Add, Picture, w428 h-1 x38 y10, %A_ScriptDir%\_assets\banner.png
Gui, Main: Add, Text, x150, All images are resized to 1280x1280 pixels.`n

Gui, Main: Add, Text, x10, Product Images:
Gui, Main: Add, Edit, yp x90 w320 hwndProductsPath,
SetEditCueBanner(ProductsPath, "Select (or Drag & Drop) the folder containing the product images...")
Gui, Main: Add, Button, yp x+5 gSelectProductsFolder, Select Folder...

Gui, Main: Add, Text, x10, Overlay Images:
Gui, Main: Add, Edit, +r1 yp x90 w320 hwndOverlaysPath
SetEditCueBanner(OverlaysPath, "Select the folder containing the overlay images...")
Gui, Main: Add, Button, yp x+5 gSelectOverlaysFolder, Select Folder...

Gui, Main: Add, Text, x10, Output Folder:
Gui, Main: Add, Edit, yp x90 w320 hwndOutputPath
SetEditCueBanner(OutputPath, "Select the output folder for the new images...")
Gui, Main: Add, Button, yp x+5 gSelectOutputFolder, Select Folder...

Gui, Main: Add, Text,, `r`n
Gui, Main: Font, s18
Gui, Main: Add, Button, yp+20 x27.5 vGenerateButton gGenerateImages w450 disabled, Generate
Gui, Main: Font, s2
Gui, Main: Add, Text,, `r`n

Gui, Main:Show,,Product Overlay Generator
WinWaitActive, Product Overlay Generator,, 3
ControlSetText, Edit2, %A_ScriptDir%\Overlays
ControlSetText, Edit3, %A_MyDocuments%

Gui, Processing: Add, Text, Border h100, `n`n`n Generating product overlay images... 
Gui, Processing: -Caption +AlwaysOnTop

ChangeButtonNames: 
IfWinNotExist, Done
	return  ; Keep waiting.
SetTimer, ChangeButtonNames, Off 
WinActivate 
ControlSetText, Button1, &Open Folder
return

SetEditCueBanner(HWND, Cue)
{
	Static EM_SETCUEBANNER := (0x1500 + 1)
	Return DllCall("User32.dll\SendMessageW", "Ptr", HWND, "Uint", EM_SETCUEBANNER, "Ptr", True, "WStr", Cue)
}

MainGuiDropFiles:
Loop Parse, A_GuiEvent, `n
{
	Loop, Files, %A_LoopField%, D
	{
		ControlSetText, Edit1, %A_LoopFileFullPath%
		GuiControl, Enable, Button4
	}
    return ; only first dropped file selected, others ignored
}
return ; in case the event been triggered with no files in list

SelectProductsFolder:
DownloadsPath := ComObjCreate("Shell.Application").NameSpace("shell:downloads").self.path
FileSelectFolder, SelectedProductsFolder, , 3, Select the folder containing your product/swatch images.
if SelectedProductsFolder = 
{
    ; The user didn't select anything.
}
else
{
    ControlSetText, Edit1, %SelectedProductsFolder%
	GuiControl, Enable, Button4
}
return

SelectOverlaysFolder:
FileSelectFolder, SelectedOverlaysFolder, , 3, Select the folder containing the images you'd like to overaly over the product images.
if SelectedOverlaysFolder = 
{
    ; The user didn't select anything.
}
else
{
    ControlSetText, Edit2, %SelectedOverlaysFolder%
}
return

SelectOutputFolder:
FileSelectFolder, SelectedOutputFolder, , 3, Select the output folder for the new images.
if SelectedOutputFolder = 
{
    ; The user didn't select anything.
}
else
{
    ControlSetText, Edit3, %SelectedOutputFolder%
}
return

GenerateImages:
Gui, Processing: Show, Center, Msgbox
ControlGetText, SelectedProductsFolder, Edit1
Loop, Files, %SelectedProductsFolder%\*.*, R
{
	swatch_name := SubStr(A_LoopFileName, 1, InStr(A_LoopFileName, ".",, -1) -1)
	swatch_image_resized := ResConImg(A_LoopFileFullPath, 1280, 1280,,,, false)

	ControlGetText, SelectedOutputFolder, Edit3
	FileCreateDir, %SelectedOutputFolder%\Product Overlay Generator\%swatch_name%

	ControlGetText, SelectedOverlaysFolder, Edit2
	Loop, Files, %SelectedOverlaysFolder%\*.*
	{
		overlay_image_resized := ResConImg(A_LoopFileFullPath, 1280, 1280,,,, false)
		output_path := SelectedOutputFolder "\Product Overlay Generator\" swatch_name "\" swatch_name " - " A_LoopFileName
		p_output_file := Gdip_CreateBitmap(1280, 1280)
		G := Gdip_GraphicsFromImage(p_output_file)
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetInterpolationMode(G, 7)

		; --- From gdip_all.ahk ---
		; Gdip_DrawImage(pGraphics, pBitmap, dx="", dy="", dw="", dh="", sx="", sy="", sw="", sh="", Matrix=1)
		; 
		; Function              Gdip_DrawImage
		; Description           This function draws a bitmap into the Graphics of another bitmap
		;
		; pGraphics             Pointer to the Graphics of a bitmap
		; pBitmap               Pointer to a bitmap to be drawn
		; dx                    x-coord of destination upper-left corner
		; dy                    y-coord of destination upper-left corner
		; dw                    width of destination image
		; dh                    height of destination image
		; sx                    x-coordinate of source upper-left corner
		; sy                    y-coordinate of source upper-left corner
		; sw                    width of source image
		; sh                    height of source image
		; Matrix                a matrix used to alter image attributes when drawing
		Gdip_DrawImage(G, swatch_image_resized,  0, 0, 1280, 1280, 0, 0, 1280, 1280)
		Gdip_DrawImage(G, overlay_image_resized, 0, 0, 1280, 1280, 0, 0, 1280, 1280)

		Gdip_SaveBitmapToFile(p_output_file, output_path)
	}
}
Sleep, 5000
Gui, Processing:Destroy
SetTimer, ChangeButtonNames, 50 
MsgBox, 0, Done, Generating overlay images complete.
IfMsgBox, OK 
	Run, %SelectedOutputFolder%\Product Overlay Generator
ExitApp

/*  ResConImg
 *    By kon
 *    Updated November 2, 2015
 *    http://ahkscript.org/boards/viewtopic.php?f=6&t=2505&p=13640#p13640
 *
 *  Resize and convert images. png, bmp, jpg, tiff, or gif.
 *
 *  Requires Gdip.ahk in your Lib folder or #Included. Gdip.ahk is available at:
 *      http://www.autohotkey.com/board/topic/29449-gdi-standard-library-145-by-tic/
 *     
 *  ResConImg( OriginalFile             ;- Path of the file to convert
 *           , NewWidth                 ;- Pixels (Blank = Original Width)
 *           , NewHeight                ;- Pixels (Blank = Original Height)
 *           , NewName                  ;- New file name (Blank = "Resized_" . OriginalFileName)
 *           , NewExt                   ;- New file extension can be png, bmp, jpg, tiff, or gif (Blank = Original extension)
 *           , NewDir                   ;- New directory (Blank = Original directory)
 *           , PreserveAspectRatio      ;- True/false (Blank = true)
 *           , BitDepth)                ;- 24/32 only applicable to bmp file extension (Blank = 24)
 */
ResConImg(OriginalFile, NewWidth:="", NewHeight:="", NewName:="", NewExt:="", NewDir:="", PreserveAspectRatio:=true, BitDepth:=24) {
    SplitPath, OriginalFile, SplitFileName, SplitDir, SplitExtension, SplitNameNoExt, SplitDrive
    pBitmapFile := Gdip_CreateBitmapFromFile(OriginalFile)                  ; Get the bitmap of the original file
    Width := Gdip_GetImageWidth(pBitmapFile)                                ; Original width
    Height := Gdip_GetImageHeight(pBitmapFile)                              ; Original height
    NewWidth := NewWidth ? NewWidth : Width
    NewHeight := NewHeight ? NewHeight : Height
    NewExt := NewExt ? NewExt : SplitExtension
    if SubStr(NewExt, 1, 1) != "."                                          ; Add the "." to the extension if required
        NewExt := "." NewExt
    NewPath := ((NewDir != "") ? NewDir : SplitDir)                         ; NewPath := Directory
            . "\" ((NewName != "") ? NewName : "Resized_" SplitNameNoExt)       ; \File name
            . NewExt                                                            ; .Extension
    if (PreserveAspectRatio) {                                              ; Recalcultate NewWidth/NewHeight if required
        if ((r1 := Width / NewWidth) > (r2 := Height / NewHeight))          ; NewWidth/NewHeight will be treated as max width/height
            NewHeight := Height / r1
        else
            NewWidth := Width / r2
    }
    pBitmap := Gdip_CreateBitmap(NewWidth, NewHeight                        ; Create a new bitmap
    , (SubStr(NewExt, -2) = "bmp" && BitDepth = 24) ? 0x21808 : 0x26200A)   ; .bmp files use a bit depth of 24 by default
    G := Gdip_GraphicsFromImage(pBitmap)                                    ; Get a pointer to the graphics of the bitmap
    Gdip_SetSmoothingMode(G, 4)                                             ; Quality settings
    Gdip_SetInterpolationMode(G, 7)
    Gdip_DrawImage(G, pBitmapFile, 0, 0, NewWidth, NewHeight)               ; Draw the original image onto the new bitmap
    Gdip_DisposeImage(pBitmapFile)                                          ; Delete the bitmap of the original image
    ;Gdip_SaveBitmapToFile(pBitmap, NewPath)                                 ; Save the new bitmap to file
    ;Gdip_DisposeImage(pBitmap)                                              ; Delete the new bitmap
    Gdip_DeleteGraphics(G)                                                  ; The graphics may now be deleted
    return pBitmap
}
return

MainGuiClose:
ExitApp