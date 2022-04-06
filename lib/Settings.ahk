#Include <JSON>
If FileExist("Settings.json") {
    FileRead, tempjson, Settings.json
    Info := JSON.Load(tempjson), tempjson := ""
} Else
    Info := {GUI: {X: "ERROR", Y: "ERROR"}, Settings: {ocrengine: 2, savepos: 1, savetype: 1, showimg: 1, fixstats: 0, screendelay: 40, iddelay: 2685}, Field: {X: 0, Y: 0, W: 0, H: 0}, IDs: {Target: 0, IDButton: {X: 0, Y: 0}, ResetButton: {X: 0, Y: 0}, count: 3, idmode: 2, resetid: 1, Types: [], Minimums: []}}
if (!Info.IDs.Minimums[1])
    change := 1 ; Used for Labels>Start