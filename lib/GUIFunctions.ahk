TypeController(x) {
    global ChangeB, SetB, idchoice, idmode1, idmode2, TCheck, count
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idchoice
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), count
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idmode1
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idmode2
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), TCheck
    GuiControl, % "1:" (!x ? "Enabled":"Disabled"), ChangeB
    }
FieldController(this) {
    global SFInfo, ResInfo, IDInfo
    GuiControl, 1:, SFInfo, % "Search: x" this.Field.x " y" this.Field.y " w" this.Field.w " h" this.Field.h
    GuiControl, 1:, IDInfo, % "Identify: x" this.IDs.IDButton.x " y" this.IDs.IDButton.y
    GuiControl, 1:, ResInfo, % "Reset: x" this.IDs.ResetButton.x " y" this.IDs.ResetButton.y
    }
AlwaysOnTop(target, x := 1) {
    WinSet, AlwaysOnTop, % (x ? "On":"Off"), % "ahk_id " target
    }