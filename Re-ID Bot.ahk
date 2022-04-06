; Written on Autohotkey Version: 1.1.32.00
; Auto-Run >>
	; Version Control
		Ver := "0.0.2", sName := "Re-ID Bot OCR", Name := sName " " A_Year "." Ver
	; Default startup parameters
		#SingleInstance, Off
		#Persistent
		SetWorkingDir % A_ScriptDir
		FileEncoding, UTF-8
		CoordMode, Mouse, Client
		CoordMode, Pixel, Client
		; Optimization
			#NoEnv
			#KeyHistory 0
			Process, Priority,, H
			SetBatchLines -1
			ListLines Off
	; Remove Tray Icon
		; #NoTrayIcon <- (May trigger a false-positive malware detection) so use below lines instead
		Menu, Tray, NoStandard
		Menu, Tray, NoIcon
	; Includes
		#Include <RunAsTask> ; Auto-run as admin (May trigger a false-positive malware detection).
		RunAsTask() ; Auto-elevates script to admin

		#Include <Gdip_All> ; Used mainly for Tesseract
		#Include <Select> ; Search field select
		#Include <FindGame> ; Finds all game instances
		#Include <Compare> ; Used for comparing found stats to chosen stats
		#Include <MultiOCR> ; Wrapper for Windows OCR Engine and Tesseract
		#Include <Settings> ; Generate / Load Settings
		#Include <GUIFunctions> ; Functions for controlling GUI
	; OCR Setup
		If !pToken := Gdip_Startup() {
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
			}
	; GUI
		; Gui Vars
			If (!Info.Settings.savepos)
				Info.Field.X := Info.Field.Y := Info.Field.W := Info.Field.H := 0
			starttoggle := 1
			IDList := "Accuracy|Evasion|Heal Effect|Crit Heal Chance|Crit Damage|Crit Defense|Crit Chance|Crit Dodge|Attack|Defense|Health|Mana|Block Rate|Block Strength|Physical Mastery|Physical Resistance|Physical Attack|Physical Defense|Earth Mastery|Earth Resistance|Earth Attack|Earth Defense|Water Mastery|Water Resistance|Water Attack|Water Defense|Fire Mastery|Fire Resistance|Fire Attack|Fire Defense|Wind Mastery|Wind Resistance|Wind Attack|Wind Defense|Light Mastery|Light Resistance|Light Attack|Light Defense|Dark Mastery|Dark Resistance|Dark Attack|Dark Defense"
			CheckList = +,Accuracy,Evasion,Heal Effect,Crit Heal Chance,Crit Damage,Crit Defense,Crit Chance,Crit Dodge,Attack,Defense,Health,Mana,Block Rate,Block Strength,Physical Mastery,Physical Resistance,Physical Attack,Physical Defense,Earth Mastery,Earth Resistance,Earth Attack,Earth Defense,Water Mastery,Water Resistance,Water Attack,Water Defense,Fire Mastery,Fire Resistance,Fire Attack,Fire Defense,Wind Mastery,Wind Resistance,Wind Attack,Wind Defense,Light Mastery,Light Resistance,Light Attack,Light Defense,Dark Mastery,Dark Resistance,Dark Attack,Dark Defense
		; Gui Settings
			Gui, 1: Margin, 3 3
			Gui, 1: -DPIScale +hwndbotid

		Gui, 1: Add, Tab3,, Identify|Settings

		Gui, 1: Tab, Identify
			Gui, 1: Add, ListBox, Section r5 vidchoice Multi, % IDList
			Gui, 1: Add, Text, Section x+m yp+3, X:
			Gui, 1: Add, Edit, % "x+m yp-3 Disabled vxbox", 0000
			Gui, 1: Add, Text, x+m yp+3, Y:
			Gui, 1: Add, Edit, % "x+m yp-3 Disabled vybox", 0000
			Gui, 1: Add, Text, x+m yp+3, W:
			Gui, 1: Add, Edit, % "x+m yp-3 Disabled vwbox", 0000
			Gui, 1: Add, Text, x+m yp+3, H:
			Gui, 1: Add, Edit, % "x+m yp-3 Disabled vhbox", 0000
			FieldController(Info.Field)
			Gui, 1: Add, Button, x+m yp-1 gSet vSetB, Find
			Gui, 1: Add, Radio, % (Info.IDs.idmode=1?"Checked":"") " xs vidmode1", Multi-ID
			Gui, 1: Add, Radio, % (Info.IDs.idmode=2?"Checked":"") " x+m vidmode2", Single-ID
			Gui, 1: Add, Radio, % (Info.IDs.idmode=3?"Checked":"") " x+m vidmode3", Single-ID (Total Minimum)
			Gui, 1: Add, DDL, % "Choose" Info.IDs.count " xs w30 vcount", 1|2|3|4|5|6|7|8
			Gui, 1: Add, Checkbox, % (Info.IDs.resetid=1?"Checked":"") " x+m yp+4 vresetid gResetChange", Reset ID
			Gui, 1: Add, Button, yp-5 x+m vChangeB gChange Disabled, Change
			Gui, 1: Add, Button, x+m vStartB gStart, Start
			if (Info.Settings.savetype && Info.IDs.Types[1] != "") {
				TypeController(0)
				for _,curr in Info.IDs.Types
					GuiControl, 1:ChooseString, idchoice, % curr
				}

		Gui, 1: Tab, Settings
			Gui, 1: Add, Radio, % (Info.Settings.ocrengine=1?"Checked":"") " vocrengine", Windows OCR Engine (Windows 10+)
			Gui, 1: Add, Radio, % (Info.Settings.ocrengine=2?"Checked":""), Tesseract
			Gui, 1: Add, Checkbox, % (Info.Settings.savepos?"Checked":"") " vsavepos", Save Search-field Position
			Gui, 1: Add, Checkbox, % (Info.Settings.savetype?"Checked":"") " x+m vsavetype", Save selected ID-Types
			Gui, 1: Add, Checkbox, % (Info.Settings.showimg?"Checked":"") " Section x8 y+m vshowimg", Show Image-Capture
			Gui, 1: Add, Checkbox, % (Info.Settings.fixstats?"Checked":"") " x+m vfixstats", Fix OCR Errors
			Gui, 1: Add, Edit, Section x8 y+m h17 vscreendelay, % Info.Settings.screendelay
			Gui, 1: Add, Text, x+m ys+3, ms delay after OCR failed to find information
			Gui, 1: Add, Edit, Section x8 y+m h17 viddelay, % Info.Settings.iddelay
			Gui, 1: Add, Text, x+m ys+3, ms delay between Identifications
			Gui, 1: Add, Button, x7 y+m gApply, Apply
			Gui, 1: Add, Button, x+m gReset, Reset

		Gui, 1: Tab ; Outside of Tab3
			Gui, 1: Add, Text, x4 w175 h0 voutputdisplay
			Gui, 1: Add, Picture, x+m w0 h0 vimagedisplay, % "HBITMAP:*" ()

		Gui, 1: Show, % (Info.GUI.X != "ERROR" || Info.GUI.Y != "ERROR" ? "x" . Info.GUI.X . " y" . Info.GUI.Y:""), % sName

		SetControlDelay, % (Info.IDs.resetid ? "5":"-1")
		id := FindGame() ; Finds and sets target client
		gc := new MultiOCR(Info.Settings.ocrengine=1 ? "win10":"tess4", Info.Settings.savepos ? Info.Field:"", id ? id:"")
		gc.target := id
	return
	; <<<<<<<<<<<

; Hotkeys >>
	^esc::
		Goto, GuiClose ; Ctrl + ESC = ExitApp
	; <<<<<<<<<<

; Labels >>
	Start:
		Gui, Submit, NoHide

		if (!guiw && Info.Settings.showimg) {
			Tick := A_TickCount
			gc.OCR()
			result := StrReplace(gc.result, "`n`n", "`r")
			GuiControl, 1:Move, outputdisplay, % "h" gc.h
			GuiControl, 1:, outputdisplay, % result "`nTook " A_TickCount - Tick "ms"
			GuiControl, 1:Move, imagedisplay, % "w" gc.w " h" gc.h
			WinGetPos,,, guiw, guih, % "ahk_id" botid
			WinMove, % "ahk_id" botid,,,, % Max(gc.w + 14, guiw), % guih + gc.h - 2
			GuiControl, 1:, imagedisplay, % "HBITMAP:*" gc.hBitmap
			Gosub, ClearBitmaps
			}

		TypeController(0)
		Info.IDs.idmode := idmode1?1:idmode2?2:3
		Info.IDs.count := count
		Info.IDs.resetid := resetid

		If (starttoggle && change) {
			Choices := StrSplit(idchoice, "|"), Minimums := []
			for num,curr in Choices {
				InputBox, cm, % curr, % "Minimum accepted number for " curr
				If ErrorLevel
					Exit
				Minimums.Push(cm)
				}
			Info.IDs.Minimums := Minimums
			Info.IDs.Types := Choices
			change := 0
			}
		GuiControl,, StartB, % ((starttoggle:=!starttoggle) ? "Start":"Stop")
		rx := Info.IDs.ResetButton.X, ry := Info.IDs.ResetButton.Y ; Reset Button Pos
		ix := Info.IDs.IDButton.X, iy := Info.IDs.IDButton.Y ; Identify Button Pos
		SetTimer, OCRTimer, % !starttoggle ? 2000:"Off"
		return
	OCRTimer:
		Attempt := 0
		CheckAgain:
		Attempt++
		Tick := A_TickCount
		gc.OCR()

		if (Info.Settings.showimg) { ; If user wants images displayed
			GuiControl, 1:, imagedisplay, % "HBITMAP:*" gc.hBitmap
			}
		result := ""
		for _,curr in StrSplit(gc.result, "`n", "`r") {
			if !curr
				Continue
			result .= curr "`n"
			}
		if result not contains %CheckList%
			{ ; Checks if any id's / "+" is present in screen capture. If not the screenshot happened too soon.
				GuiControl, 1:, outputdisplay, % fixedresult "`nTook " A_TickCount - Tick "ms with " Attempt " attempt" (Attempt > 1 ? "s":"") "."
				Gosub, ClearBitmaps
				if (Attempt > 400) {
					Gosub, OCREnd
					Msgbox % "Something broke and needs your attention."
					return
				}
				Sleep, % Info.Settings.screendelay
				goto, CheckAgain
			}
		Compare(Info, result, found, fixedresult, gc)
		GuiControl, 1:, outputdisplay, % fixedresult "`nTook " A_TickCount - Tick "ms with " Attempt " attempt" (Attempt > 1 ? "s":"") "."
		Gosub, ClearBitmaps
		if (found) { ; Found ID, stop re-iding
			Gosub, OCREnd
			Msgbox % "ID Found`n" fixedresult
			return
			}
		if (resetid)
			Loop, 5 ; Attempt reset 5 times in a row to make it more reliable
				ControlClick,, % "ahk_id " gc.target,, Left, 1, NA x%rx% y%ry%
		ControlClick,, % "ahk_id " gc.target,, Left, 1, NA x%ix% y%iy%
		Sleep, % Info.Settings.iddelay
		return
	OCREnd:
		SetTimer, OCRTimer, Off
		starttoggle := 1
		GuiControl,, StartB, % "Start"
		return
	ClearBitmaps: ; Prevents Memory leaks
		DllCall("DeleteObject", "Ptr", gc.hBitmap) ; Clearing hbitmap from memory
        Gdip_DisposeImage(gc.Bitmap)
		gc.Bitmap := "", gc.hBitmap := "" ; Clearing variable content after (h)bitmap has been used.
		return
	ResetChange:
		Gui, Submit, NoHide
		Info.IDs.resetid := resetid
		SetControlDelay, % (Info.IDs.resetid ? "5":"-1")
		return
	Change:
		change := 1
		If !starttoggle
			Gosub, Start
		Info.IDs.Types := []
		Info.IDs.Minimums := []
		TypeController(1)
		return
	Set:
		Hotkey, LButton, Void, On
		KeyWait, LButton, Up
		While !GetKeyState("LButton", "P") {
			MouseGetPos, resx, resy, id
			WinActivate, % "ahk_id " id
			if (ox != resx || oy != resy) {
				ox := resx, oy := resy
				ToolTip, Left click Reset Button.
				}
			}
		ToolTip
		KeyWait, LButton, Up
		While !GetKeyState("LButton", "P") {
			MouseGetPos, idx, idy, id
			WinActivate, % "ahk_id " id
			if (ox != idx || oy != idy) {
				ox := idx, oy := idy
				ToolTip, Left click Identify Button.
				}
			}
		ToolTip
		KeyWait, LButton, Up
		Hotkey, LButton, Void, Off
		Info.IDs.IDButton.X := idx, Info.IDs.IDButton.Y := idy, Info.IDs.ResetButton.X := resx, Info.IDs.ResetButton.Y := resy
		gc := "" ; Close previous ocr instance
		gc := new MultiOCR()
		gc.ocrt := Info.Settings.ocrengine=1 ? "win10":"tess4" ; Changes OCR Engine
		gc.target := id, Info.Field.X := gc.x, Info.Field.Y := gc.y, Info.Field.W := gc.w, Info.Field.H := gc.h

		FieldController(Info.Field)
		WinActivate, % "ahk_id " botid
		void:
		return
	Apply:
		Gui, Submit, NoHide
		Info.Settings.ocrengine 	:= ocrengine
		Info.Settings.savepos 		:= savepos
		Info.Settings.savetype 		:= savetype
		Info.Settings.showimg 		:= showimg
		Info.Settings.screendelay 	:= screendelay
		Info.Settings.iddelay 		:= iddelay
		Info.Settings.fixstats		:= fixstats

		; Apply settings without restart
		gc.ocrt := Info.Settings.ocrengine=1 ? "win10":"tess4" ; Changes OCR Engine
		return
	Reset:
		FileDelete, Settings.json
		Reload
		ExitApp ; Some reloads happened to open new instance without closing current
	GuiClose:
		GuiEscape:
			WinGetPos, cx, cy,,, % "ahk_id" botid
			Info.GUI.X := cx, Info.GUI.Y := cy
			newdump := JSON.Dump(Info)
			If FileExist("Settings.json")
				FileDelete, Settings.json
			FileAppend, % newdump, Settings.json
			Gdip_Shutdown(pToken)
			ReplaceSystemCursors("") ; Recover Cursor on unexpected exit during search area select.
			ExitApp
	; <<<<<<<<<
