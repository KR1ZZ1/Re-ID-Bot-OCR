; Original code by Teadrinker on Autohotkey.com
; Modified by KR1ZZ1
Select(ByRef coords, Button := "LButton") {
	OldCoord := A_CoordModeMouse
	CoordMode, Mouse, Client

	Gui, New, +hwndhGUI +Alwaysontop -Caption +LastFound +ToolWindow +E0x20 -DPIScale
	WinSet, Transparent, 130
	Gui, Color, FF0000

	KeyWait, % Button, Up
	Hotkey, % Button, VoidTrash, On
	ReplaceSystemCursors("IDC_CROSS")
	While !GetKeyState(Button, "P") {
		MouseGetPos, x, y, id
		if (ox != x || oy != y) {
			ox := x, oy := y
			CoordMode, Mouse, Screen
			MouseGetPos, startmousex, startmousey
			CoordMode, Mouse, Client
			ToolTip, % "Start selecting Area by holding down " Button 
			}
		}
	ToolTip
	While GetKeyState(Button, "P") {
		MouseGetPos, x, y
		if (nx != x || ny != y) {
			nx := x, ny := y
			CoordMode, Mouse, Screen
			MouseGetPos, mousex, mousey
			CoordMode, Mouse, Client

			gx := startMouseX < mouseX ? startMouseX : mouseX
			gy := startMouseY < mouseY ? startMouseY : mouseY
			gw := Abs(mouseX - startMouseX)
			gh := Abs(mouseY - startMouseY)

			try Gui, %hGUi%: Show, x%gx% y%gy% w%gw% h%gh% NA
			}
		}
	Gui, %hGUI%: Destroy
	ReplaceSystemCursors("")

	x := ox < nx ? ox : nx
	y := oy < ny ? oy : ny
	w := Abs(nx - ox)
	h := Abs(ny - oy)

	coords := {}
	coords.x := x
	coords.y := y
	coords.w := w
	coords.h := h
	coords.target := id

	Hotkey, % Button, Void, Off
	CoordMode, Mouse, % OldCoord

	VoidTrash:
	return
	}
ReplaceSystemCursors(IDC = "") {
	static IMAGE_CURSOR := 2, SPI_SETCURSORS := 0x57
							, exitFunc := Func("ReplaceSystemCursors").Bind("")
							, SysCursors := { IDC_APPSTARTING: 32650
							, IDC_ARROW      : 32512
							, IDC_CROSS      : 32515
							, IDC_HAND       : 32649
							, IDC_HELP       : 32651
							, IDC_IBEAM      : 32513
							, IDC_NO         : 32648
							, IDC_SIZEALL    : 32646
							, IDC_SIZENESW   : 32643
							, IDC_SIZENWSE   : 32642
							, IDC_SIZEWE     : 32644
							, IDC_SIZENS     : 32645 
							, IDC_UPARROW    : 32516
							, IDC_WAIT       : 32514 }
	if !IDC {
		DllCall("SystemParametersInfo", UInt, SPI_SETCURSORS, UInt, 0, UInt, 0, UInt, 0)
		OnExit(exitFunc, 0)
	}
	else
	{
		hCursor := DllCall("LoadCursor", Ptr, 0, UInt, SysCursors[IDC], Ptr)
		for k, v in SysCursors  {
			hCopy := DllCall("CopyImage", Ptr, hCursor, UInt, IMAGE_CURSOR, Int, 0, Int, 0, UInt, 0, Ptr)
			DllCall("SetSystemCursor", Ptr, hCopy, UInt, v)
		}
		OnExit(exitFunc)
	}
	} 