CaptureAndSend(IsManualTest := false) {
    global RobloxTitle, DemonRuns, DungeonRuns, RejoinCount, SessionStart, MacroPaused, WebhookEnabled
    if (!IsManualTest && !WebhookEnabled)
        return
    if (EditWeb.Value == "" || !WinExist(RobloxTitle))
        return
    WinActivate(RobloxTitle)
    Sleep(1000)
    MiniCap  := A_ScriptDir "\MiniCap\MiniCap.exe"
    SSPath   := A_ScriptDir "\ss.png"
    JsonPath := A_ScriptDir "\payload.json"
    RunWait('"' MiniCap '" -captureactivewin -save "' SSPath '" -exit', , "Hide")
    Elapsed  := A_TickCount - SessionStart
    h := Elapsed // 3600000
    m := Mod(Elapsed, 3600000) // 60000
    s := Mod(Elapsed, 60000)   // 1000
    Duration := h . "h " . m . "m " . s . "s"
    global RiftRuns, RaidRuns, RaidType, CustomRuns, CustomRunName
    currStatus := MacroPaused ? "⏸ Paused" : "● Running"
    Payload := '{"embeds": [{"title": "DenniXD ATS Macro V3.0.0","color": 8323327,'
             . '"image": {"url": "attachment://ss.png"},'
             . '"fields": ['
             . '{"name": "🗡 Abandon Village",  "value": "' . DemonRuns   . ' runs", "inline": true},'
             . '{"name": "⚔ Double Dungeon",   "value": "' . DungeonRuns . ' runs", "inline": true},'
             . '{"name": "🌀 Rift",            "value": "' . RiftRuns    . ' runs", "inline": true},'
             . '{"name": "💥 Raid (' . RaidType . ')", "value": "' . RaidRuns . ' runs", "inline": true},'
             . '{"name": "🎮 ' . CustomRunName . '", "value": "' . CustomRuns . ' runs", "inline": true},'
             . '{"name": "🔄 Rejoined",        "value": "' . RejoinCount . ' times", "inline": true},'
             . '{"name": "⏱ Uptime",          "value": "' . Duration    . '", "inline": true},'
             . '{"name": "📊 Status",          "value": "' . currStatus  . '", "inline": true}'
             . '],"footer": {"text": "DenniXD ATS V3.0.0  ·  ' . FormatTime(, "HH:mm:ss") . '"}}]}'
    try {
        FileOpen(JsonPath, "w", "UTF-8").Write(Payload)
        RunWait('curl.exe -s -F "payload_json=<' JsonPath '" -F "file=@' SSPath '" "' EditWeb.Value '"', , "Hide")
    }
    SetTimer(() => CleanupFiles(SSPath, JsonPath), -3000)
}
CleanupFiles(ss, js) {
    if FileExist(ss)
        FileDelete(ss)
    if FileExist(js)
        FileDelete(js)
}
ForceRejoin() {
    global PrivateServer, RejoinCount, CurrentRaidStep, RaidStartTime
    if (PrivateServer == "")
        return
    CurrentRaidStep := 0
    RaidStartTime   := 0
    RejoinPS()
    RejoinCount += 1
    UpdateUI()
}
; ── Reset Travel UI — inline keystrokes replacing resettravelui.exe ──


UpdateSummonMap(ctrl, *) {
    global SummonMap, SummonMaps
    SummonMap := SummonMaps[ctrl.Value]
}

UpdateSummonActive() {
    global ModeSummoning, ChkSummonActive
    ModeSummoning := ChkSummonActive.Value ? true : false
}

; ── Summoning — fires once at start and after every rejoin ──
Execute_Summon(mapName) {
    key := "Summon_" StrReplace(mapName, " ", "")
    RunCustomOrDefault(key, (*) => 0)
}

