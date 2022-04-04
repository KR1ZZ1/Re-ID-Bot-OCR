; Used for comparing found stats to chosen stats
#Include <FindString>
Compare(this, result, ByRef found := "", ByRef fixed := "", reocr := "") {
    unknownread:
    result := StrReplace(result, "+ g", "+ 9")
    result := StrReplace(result, "-")
    result := StrReplace(result, "+")
    result := StrReplace(result, "%")
    result := StrReplace(result, "0/0")
    resultarray := StrSplit(result, "`n", "`r")

    count := 0, found := 0, fixed := ""
    for arrcount,targetid in this.IDs.Types {
        total := 0, fixed := "" ; Needed for mode 3

        if (this.IDs.idmode = 2)
            count := 0

        for _,resultid in resultarray {
            if !resultid
                Continue ; Skip empty IDs

            currnum := 0
            for _,num in StrSplit(resultid, " ") { ; Finds Current ID's Number
                if num is not integer
                    Continue
                currnum := (currnum > num) ? currnum:num
                }

            currid := Trim(StrReplace(resultid, currnum)) ; Cleans Current ID Up
            currnum := (!currnum)?"UNKNOWN":currnum ; Checks if a number was found and replaces with 999 if not.

            if (this.Settings.fixstats)
                currid := FindString(currid) ; Correct OCR Errors
            
            if ((currnum = "UNKNOWN" || currid = -1) && reocr.ocrt = "win10") { ; Use Tesseract for weird ocr reads
                reocr.result := Vis2.OCR(reocr.Bitmap)
                goto, unknownread
                }

            currid := StrReplace(currid, "Critical", "Crit")
            currid := StrReplace(currid, "Healing", "Heal")

            StringLower, currnum, currnum, T
            fixed .= (fixed ? "`n":"") "+ " currnum " " currid ; Returns fixed string to "fixed" variable

            If currid in %targetid%
                {
                If (this.IDs.idmode < 3) ; Multi-ID & Single-ID
                    if (currnum >= this.IDs.Minimums[arrcount])
                        count++
                If (this.IDs.idmode = 3) { ; Single-ID (Total Minimum)
                    total += currnum
                    If (total >= this.IDs.Minimums[arrcount]) ; Total has exceeded minimum
                        found := 1
                    }
                }
            }

            if (this.IDs.idmode = 2)
                if (count >= this.IDs.count)
                    found := 1
        }

        if (this.IDs.idmode = 1)
            if (count >= this.IDs.count)
                found := 1
        return count
    }