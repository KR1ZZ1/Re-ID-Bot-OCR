#Include <Modified_Vis2>
#Include <w10ocr>
Class MultiOCR {
    __New(ocrtype := "win10", area := "", id := "") {
        if (id)
            this.target := id
        if (area.h)
            this.x := area.x, this.y := area.y, this.w := area.w, this.h := area.h, this.ssWH()
        else
            this.getTarget(area)
        this.ocrt := ocrtype
        }
    ; Get Target / XYWH >
        getTarget(area := "") {
            if !area.h {						
                area := []
                Select(area)
                }
            this.x := area.x
            this.y := area.y
            this.w := area.w
            this.h := area.h
            this.target := area.target
            this.ssWH()
            return
            }
        ssWH() {
            VarSetCapacity(RECT, 16, 0)
            DllCall("user32\GetClientRect", Ptr,this.target, Ptr,&RECT)
            DllCall("user32\ClientToScreen", Ptr,this.target, Ptr,&RECT)
            this.CX := NumGet(&RECT, 0, "Int")
            this.CY := NumGet(&RECT, 4, "Int")
            this.CW := NumGet(&RECT, 8, "Int")
            this.CH := NumGet(&RECT, 12, "Int")
            }
    ; ===================
    ; Bitmap >
        getSS() {
            this.ss()
            pOld := Gdip_CreateBitmapFromHBitmap(this.hbm)
            DllCall("DeleteObject", "Ptr", this.hbm)

            Width := Gdip_GetImageWidth(pOld), Height := Gdip_GetImageHeight(pOld)
            If (!this.x || !this.y || !this.w || !this.h)
                this.x := this.y := 0, this.w := Width, this.h := Height

            ; Inverted colors
            pNew := Gdip_CreateBitmap(this.w, this.h), G1 := Gdip_GraphicsFromImage(pNew)
            Gdip_DrawImage(G1, pOld, 0, 0, this.w, this.h, this.x, this.y, this.w, this.h, "-1|0|0|0|0|0|-1|0|0|0|0|0|-1|0|0|0|0|0|1|0|1|1|1|0|1")
            Gdip_DisposeImage(pOld)
            Gdip_DeleteGraphics(G1)

            ; GRAYSCALE
            this.Bitmap := Gdip_CreateBitmap(this.w, this.h), G2 := Gdip_GraphicsFromImage(this.Bitmap)
            Gdip_DrawImage(G2, pNew, 0, 0, this.w, this.h, 0, 0, this.w, this.h, "0.299|0.299|0.299|0|0|0.587|0.587|0.587|0|0|0.114|0.114|0.114|0|0|0|0|0|1|0|0|0|0|0|1")
            Gdip_DisposeImage(pNew)
            Gdip_DeleteGraphics(G2)
            
            this.hBitmap := Gdip_CreateHBITMAPFromBitmap(this.Bitmap) ; !!!!!!! DllCall("DeleteObject", "Ptr", this.hBitmap) ;!!!!!!! Call after done using hBitmap!!!!

            /* Call these after finishing OCR! 

                DllCall("DeleteObject", "Ptr", this.hBitmap)
                Gdip_DisposeImage(this.Bitmap)
                
            */
            }
        ss(bNC:=False) {
            VarSetCapacity(_VAR_RECT, 16, 0)
            DllCall((bNC ? "GetWindowRect" : "GetClientRect"), "Ptr",this.target, "Ptr",&_VAR_RECT)
            tW := NumGet(_VAR_RECT,  8, "Int") - NumGet(_VAR_RECT, 0, "Int")
            tH := NumGet(_VAR_RECT, 12, "Int") - NumGet(_VAR_RECT, 4, "Int")
            hdcs := DllCall("GetDCEx", "Ptr",this.target, "Ptr",0, "UInt",bNC|0x02, "Ptr")
            hdcd := DllCall("CreateCompatibleDC", "Ptr",hdcs, "Ptr")
            this.hbm := DllCall("CreateCompatibleBitmap","Ptr",hdcs,"Int",this.CW,"Int",this.CH,"Ptr")
            obm := DllCall("SelectObject","Ptr",hdcd,"Ptr",this.hbm,"Ptr")
            DllCall("SetStretchBltMode","Ptr",hdcd,"Int",0x04)
            DllCall("SetBrushOrgEx","Ptr",hdcd,"Int",0,"Int",0,"Ptr",0)
            DllCall("StretchBlt","Ptr",hdcd,"Int",0,"Int",0,"Int",this.CW,"Int",this.CH,"Ptr",hdcs,"Int",0,"Int",0,"Int",tW,"Int",tH,"UInt",0x00CC0020)
            DllCall("ReleaseDC","Ptr",hdcs)
            DllCall("DeleteObject","Ptr",obm)
            DllCall("DeleteDC","Ptr",hdcd)
            VarSetCapacity(_VAR_RECT, 0)
            }
    ; ========
    ; OCR >
        OCR() {
            this.getSS()
            If (this.ocrt = "tess4")
                this.result := Vis2.OCR(this.Bitmap)
            Else If (this.ocrt = "tess3")
                this.result := Vis2.OCR(this.Bitmap,,,1)
            Else {
                pIRandomAccessStream := HBitmapToRandomAccessStream(this.hBitmap)
                ; DllCall("DeleteObject", "Ptr", this.hBitmap)
                this.result := w10ocr(pIRandomAccessStream, "en")
                DllCall("DeleteObject", "Ptr", pIRandomAccessStream)
            }

            ; Gdip_SetBitmapToClipboard(this.Bitmap) ; Uncomment for Testing / Debug purposes 

            ; After ocr
            ; DllCall("DeleteObject", "Ptr", this.hBitmap)
            Gdip_DisposeImage(this.Bitmap)
            return this.result
            }
    ; =====
    }