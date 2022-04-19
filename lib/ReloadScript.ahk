idReload() {
    if !A_Args
        return

    for _,p in A_Args
        if (p = "/idreload")
            return 1
    }

if FileExist("tempreloadsettings.json") {
    FileRead, tempjson, tempreloadsettings.json
    FileDelete, tempreloadsettings.json
    ReloadInfo := JSON.Load(tempjson), tempjson := ""
} else
    ReloadInfo := {Scrolls: 0, Target: 0}

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