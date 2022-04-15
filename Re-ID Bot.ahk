; Written on Autohotkey Version: 1.1.32.00
; Auto-Run >>
	; Version Control
		Ver := "0.0.3", sName := "Re-ID Bot OCR", Name := sName " " A_Year "." Ver
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

		#Include <Gdip_All> 	; Used mainly for Tesseract
		#Include <Select> 		; Search field select
		#Include <FindGame> 	; Finds all game instances
		#Include <Compare> 		; Used for comparing found stats to chosen stats
		#Include <MultiOCR> 	; Wrapper for Windows OCR Engine and Tesseract
		#Include <Settings> 	; Generate / Load Settings
		#Include <GUIFunctions> ; Functions for controlling GUI
		#Include <ReloadScript> ; Reload script with params
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
			EBProp := "w170 Disabled center"
			BtnProp := "x+m yp-1 wp-130"
		; Gui Settings
			Gui, 1: -DPIScale +hwndbotid
			Gui, 1: Margin, 4, 4

		Gui, 1: Add, Tab3,, Identify|Settings

		Gui, 1: Tab, Identify ; All Identify tab controls

			; Identify, Reset & Search field - Position Display
				Gui, 1: Add, ListBox, Section r12 vidchoice Multi, % IDList
				Gui, 1: Add, Edit, Section x+m %EBProp% vIDInfo, Identify Button
				Gui, 1: Add, Button, %BtnProp% gFindID vFindIDB, Find
				Gui, 1: Add, Edit, xs %EBProp% vResInfo, Reset Button
				Gui, 1: Add, Button, %BtnProp% gFindRes vFindResB, Find
				Gui, 1: Add, Edit, xs %EBProp% vSFInfo, Search Field
				Gui, 1: Add, Button, %BtnProp% gSet vSetB, Set
				FieldController(Info) ; Updates positions

			; Multi, Single & Total
				Gui, 1: Add, Groupbox, Section xs y+-2 r1 w213
				Gui, 1: Font, c6D6D6D
				Gui, 1: Add, Text, xp+9 yp+13 w30, Mode:
				Gui, 1: Font
				Gui, 1: Add, Radio, % (Info.IDs.idmode=1?"Checked":"") " x+15 vidmode1", Multi
				Gui, 1: Add, Radio, % (Info.IDs.idmode=2?"Checked":"") " x+m vidmode2", Single
				Gui, 1: Add, Checkbox, % (Info.IDs.idmode=3?"Checked":"") " x+m vTCheck gTotalCheck", Total

			; Number of ID DDL
				Gui, 1: Add, Groupbox, Section xs y+6 r1 w83
				Gui, 1: Font, c6D6D6D
				Gui, 1: Add, Text, xp+9 yp+13 w30, ID's:
				Gui, 1: Font
				Gui, 1: Add, DDL, % "Choose" Info.IDs.count " x+1 yp-4 w30 vcount", 1|2|3|4|5|6|7

			; Reset Checkbox
				Gui, 1: Add, Groupbox, x+18 ys r1 w82
				Gui, 1: Add, Checkbox, % (Info.IDs.resetid=1?"Checked":"") " xp+11 yp+13 vresetid gResetChange", Reset ID

			; Change & Start Button
				Gui, 1: Add, Button, xs y+11 vChangeB gChange Disabled, Change
				Gui, 1: Add, Button, x+m wp vStartB gStart, Start

			Gosub, TotalCheck ; Enables/Disables Multi-ID & ID Count

			if (Info.Settings.savetype && Info.IDs.Types[1] != "") {
				TypeController(0)
				for _,curr in Info.IDs.Types
					GuiControl, 1:ChooseString, idchoice, % curr
				}

		Gui, 1: Tab, Settings ; All Settings tab controls

			; OCR Engines
				Gui, 1: Add, Radio, % (Info.Settings.ocrengine=1?"Checked":"") " vocrengine", Windows OCR Engine (Windows 10+)
				Gui, 1: Add, Radio, % (Info.Settings.ocrengine=2?"Checked":""), Tesseract

			; Checkboxes
				Gui, 1: Add, Checkbox, % (Info.Settings.savepos?"Checked":"") " Section vsavepos", Save Search-field Position
				Gui, 1: Add, Checkbox, % (Info.Settings.savetype?"Checked":"") " x+m wp vsavetype", Save selected ID-Types
				Gui, 1: Add, Checkbox, % (Info.Settings.showimg?"Checked":"") " Section xs y+m wp vshowimg", Show Image-Capture
				Gui, 1: Add, Checkbox, % (Info.Settings.fixstats?"Checked":"") " x+m wp vfixstats", Fix OCR Errors
				Gui, 1: Add, Checkbox, % (Info.Settings.alwaystop?"Checked":"") " Section xs y+m wp valwaystop", Always on top

			; Input fields
				Gui, 1: Add, Edit, Section xs y+m h17 vscreendelay, % Info.Settings.screendelay
				Gui, 1: Add, Text, x+m ys+3, ms delay after OCR failed to find information
				Gui, 1: Add, Edit, Section xs y+m h17 viddelay, % Info.Settings.iddelay
				Gui, 1: Add, Text, x+m ys+3, ms delay between Identifications

			; Apply & Reset Buttons
				Gui, 1: Add, Button, xs y+m gApply, Apply
				Gui, 1: Add, Button, x+m gReset, Reset

		Gui, 1: Tab ; Outside of Tab3
			Gui, 1: Add, Text, x4 w175 h0 voutputdisplay
			Gui, 1: Add, Picture, x+m w0 h0 vimagedisplay, % "HBITMAP:*" ()

		Gui, 1: Show, % (Info.GUI.X != "ERROR" || Info.GUI.Y != "ERROR" ? "x" . Info.GUI.X . " y" . Info.GUI.Y:""), % sName " " Ver

		if (Info.Settings.alwaystop)
			AlwaysOnTop(botid)

		SetControlDelay, % (Info.IDs.resetid ? "5":"-1")
		id := FindGame() ; Finds and sets target client
		gc := new MultiOCR(Info.Settings.ocrengine=1 ? "win10":"tess4", Info.Settings.savepos ? Info.Field:"", id ? id:"")
		gc.target := id

		if (idReload() && Info.Settings.savepos)
			Goto, Start
	return
	; <<<<<<<<<<<

; Hotkeys >>
	#If (WinActive("ahk_id " botid) || WinActive("ahk_id " gc.target))
		^f5::ReloadScript(!starttoggle ? "/idreload":"")
	#If
	^esc::
		Goto, GuiClose ; Ctrl + ESC = ExitApp
	; <<<<<<<<<<

; Labels >>
	Start:
		Gui, Submit, NoHide
		scrollcount := 0

		if (!guiw && Info.Settings.showimg) {
			Tick := A_TickCount
			gc.OCR()
			result := StrReplace(gc.result, "`n`n", "`r")
			GuiControl, 1:Move, outputdisplay, % "h" gc.h + 25
			GuiControl, 1:, outputdisplay, % result "`nTook " A_TickCount - Tick "ms"
			GuiControl, 1:Move, imagedisplay, % "w" gc.w " h" gc.h
			WinGetPos,,, guiw, guih, % "ahk_id" botid
			WinMove, % "ahk_id" botid,,,, % Max(gc.w + 14, guiw), % guih + gc.h - 2
			GuiControl, 1:, imagedisplay, % "HBITMAP:*" gc.hBitmap
			Gosub, ClearBitmaps
			}

		TypeController(0)
		Info.IDs.idmode := TCheck?3:idmode2?2:1
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
		GuiControl, % "1:" (starttoggle ? "Enabled":"Disabled"), SetB
		rx := Info.IDs.ResetButton.X, ry := Info.IDs.ResetButton.Y ; Reset Button Pos
		ix := Info.IDs.IDButton.X, iy := Info.IDs.IDButton.Y ; Identify Button Pos

		SetTimer, OCRTimer, -1 ; Starts IDing
		return
	OCRTimer:
		scrollcount++
		Attempt := 0
		CheckAgain:
		
		if (starttoggle) ; Exit if starttoggle is true
			Exit

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
				GuiControl, 1:, outputdisplay, % fixedresult "`nTook " A_TickCount - Tick "ms with " Attempt " attempt" (Attempt > 1 ? "s":"") ".`nTotal Scrolls: " scrollcount
				Gosub, ClearBitmaps
				if (Attempt > 400) {
					Gosub, OCREnd
					Msgbox % "Something broke and needs your attention."
					return
				}
				Sleep, % Info.Settings.screendelay
				Goto, CheckAgain
			}
		Compare(Info, result, found, fixedresult, gc)
		GuiControl, 1:, outputdisplay, % fixedresult "`nTook " A_TickCount - Tick "ms with " Attempt " attempt" (Attempt > 1 ? "s":"") ".`nTotal Scrolls: " scrollcount
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
		SetTimer, OCRTimer, -1
		return
	OCREnd:
		starttoggle := 1
		GuiControl, Enabled, SetB
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
		Goto, TotalCheck
		return
	FindID:
		KeyWait, LButton, Up
		Hotkey, LButton, Void, On
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
		gc.target := id, Info.IDs.IDButton.X := idx, Info.IDs.IDButton.Y := idy
		FieldController(Info)
		Return
	FindRes:
		KeyWait, LButton, Up
		Hotkey, LButton, Void, On
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
		Hotkey, LButton, Void, Off
		gc.target := id, Info.IDs.ResetButton.X := resx, Info.IDs.ResetButton.Y := resy
		FieldController(Info)
		Return
	Set:
		KeyWait, LButton, Up
		Hotkey, LButton, Void, On

		WinActivate, % "ahk_id " gc.target

		gc := "" ; Close previous ocr instance
		gc := new MultiOCR()
		gc.ocrt := Info.Settings.ocrengine=1 ? "win10":"tess4" ; Changes OCR Engine
		Info.Field.X := gc.x, Info.Field.Y := gc.y, Info.Field.W := gc.w, Info.Field.H := gc.h

		KeyWait, LButton, Up
		Hotkey, LButton, Void, Off

		FieldController(Info)
		WinActivate, % "ahk_id " botid
		void:
		return
	TotalCheck:
		Gui, Submit, NoHide
		GuiControl, % (TCheck ? "Disabled":"Enabled"), idmode1
		GuiControl, % (TCheck ? "Disabled":"Enabled"), count
		If (TCheck) {
			idmode := 3
			GuiControl,, idmode2, 1
		}
		Return
	Apply:
		Gui, Submit, NoHide
		Info.Settings.ocrengine 	:= ocrengine
		Info.Settings.savepos 		:= savepos
		Info.Settings.savetype 		:= savetype
		Info.Settings.showimg 		:= showimg
		Info.Settings.screendelay 	:= screendelay
		Info.Settings.iddelay 		:= iddelay
		Info.Settings.fixstats		:= fixstats
		Info.Settings.alwaystop		:= alwaystop

		AlwaysOnTop(botid, alwaystop)

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
