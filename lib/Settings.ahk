#Include <JSON>
If FileExist("Settings.json") {
    FileRead, tempjson, Settings.json
    Info := JSON.Load(tempjson), tempjson := ""
} Else
    Info := {GUI: {X: "ERROR", Y: "ERROR"}, Settings: {ocrengine: 2, savepos: 1, savetype: 1, showimg: 1, fixstats: 0, alwaystop: 0, screendelay: 40, iddelay: 2685}, Field: {X: 0, Y: 0, W: 0, H: 0}, IDs: {Target: 0, IDButton: {X: 0, Y: 0}, ResetButton: {X: 0, Y: 0}, count: 3, idmode: 2, resetid: 1, Types: [], Minimums: []}}
if (!Info.IDs.Minimums[1])
    change := 1 ; Used for Labels>Start

if FileExist("tempreloadsettings.json") {
    FileRead, tempjson, tempreloadsettings.json
    FileDelete, tempreloadsettings.json
    ReloadInfo := JSON.Load(tempjson), tempjson := ""
} else
    ReloadInfo := {Scrolls: 0, Target: 0}

idReload() {
    if !A_Args
        return

    for _,p in A_Args
        if (p = "/idreload")
            return 1
    }
ReloadScript(param := "", reloadsettings := "") {
    static file := "tempreloadsettings.json"

    if (param && IsObject(reloadsettings)) { ; Reloading script during IDing
		newdump := JSON.Dump(reloadsettings)
		If FileExist(file)
			FileDelete, % file
		FileAppend, % newdump, % file
        }

    CmdLine := ( A_IsCompiled ? "" : """"  A_AhkPath """" ) A_Space ( """" A_ScriptFullpath """"  ) A_Space ( param ? param : "")
    Run, %CmdLine%, %A_ScriptDir%, UseErrorLevel
    ExitApp
    }