idReload() {
    if !A_Args
        return

    for _,p in A_Args
        if (p = "/idreload")
            return 1
    }
ReloadScript(param := "") {
    CmdLine := ( A_IsCompiled ? "" : """"  A_AhkPath """" ) A_Space ( """" A_ScriptFullpath """"  ) A_Space ( param ? param : "")
    Run, %CmdLine%, %A_ScriptDir%, UseErrorLevel
    ExitApp
    }