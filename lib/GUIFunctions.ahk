TypeController(x) {
    global ChangeB, SetB, idchoice, idmode1, idmode2, idmode3, count
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idchoice
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), count
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idmode1
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idmode2
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), idmode3
    GuiControl, % "1:" (x ? "Enabled":"Disabled"), SetB
    GuiControl, % "1:" (!x ? "Enabled":"Disabled"), ChangeB
    }
FieldController(this) {
    global xbox, ybox, wbox, hbox
    GuiControl, 1:, xbox, % this.x
    GuiControl, 1:, ybox, % this.y
    GuiControl, 1:, wbox, % this.w
    GuiControl, 1:, hbox, % this.h
    }