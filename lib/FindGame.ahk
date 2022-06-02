#Include <WTSEnumProcesses>
FindGame(target := "") {
	clientcount := 0, list := []
	Loop, Parse, % WTSEnumProcesses(), `n
		{
		If A_LoopField Contains pvegame.exe,pvpgame.exe,DeveloperClient.exe,DH_Developer.exe,pem.exe
			{
			clientcount++, list[clientcount] := A_LoopField
			currentid := WinExist("ahk_pid" StrSplit(A_LoopField, "`t")[1])
			if (target = currentid)
				Return target
			}
		}
	If (clientcount < 1)
		Return 0
	If (clientcount = 1)
		id := WinExist("ahk_pid" StrSplit(list[1], "`t")[1])
	If (clientcount > 1) {
		for _,c in list {
			cid := StrSplit(c, "`t")[1]
			WinActivate, % "ahk_pid" cid
			MsgBox, 4, Target Client, Is this the right game client to identify on?
			IfMsgBox, Yes
				{
				id := WinExist("ahk_pid" cid)
				Break
				}
			}
		if !id {
			Msgbox, 16,, No game client found.
			Return 0
			}
		}
	Return id
	}