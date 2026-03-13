RunRaid() {
    global Running, RaidRuns, RaidType, RaidStartTime
    GuiStatus.Text := "Raid (" RaidType ") — Entering"
    RaidStartTime  := A_TickCount
    RunCustomOrDefault("Raid_Entry", (*) => 0)
    ; Pick slot based on selected map
    raidKeyMap := Map(
        "Namex Planet",      "Raid_NamexPlanet",
        "Colosseum Kingdom", "Raid_ColosseumKingdom",
        "Demon Forest",      "Raid_DemonForest",
        "Dungeon Town",      "Raid_DungeonTown",
        "Reaper Society",    "Raid_ReaperSociety"
    )
    raidSeqKey := raidKeyMap.Has(RaidType) ? raidKeyMap[RaidType] : "Raid_NamexPlanet"
    RunCustomOrDefault(raidSeqKey,      (*) => 0)
    ; Wait for completion or timeout (20 min max for raids)
    Deadline := A_TickCount + 1200000
    Loop {
        if (!Running)
            return
        if (A_TickCount > Deadline) {
            GuiStatus.Text := "Raid — Timeout, returning..."
            break
        }
        Sleep(5000)
    }
    RaidRuns += 1
    GuiStatus.Text := "Raid — Complete [" RaidRuns "]"
    Sleep(5000)
    CaptureAndSend(false)
    ReturnToLobby()
}


; ── Patch: RunDemonSlayer and RunDoubleDungeon to do webhook + ReturnToLobby ──

; ── Custom sequence dispatcher ──────────────────────────────────
; If a custom sequence exists for seqName, runs it; otherwise calls defaultFn
; Parses a Roblox PS URL and returns a direct roblox-player:// URI
; Supports formats:
;   https://www.roblox.com/games/PLACEID/name?privateServerLinkCode=CODE
;   https://www.roblox.com/share?code=CODE&type=Server
ParsePSLink(url) {
    ; Convert roblox.com/share?code=XXX&type=Server
    ; → roblox://navigation/share_links?code=XXX&type=Server
    ; This is the official Roblox deep link format that bypasses the browser entirely
    if (InStr(url, "roblox.com/share")) {
        RegExMatch(url, "code=([a-f0-9]+)", &mCode)
        RegExMatch(url, "type=(\w+)", &mType)
        if (mCode) {
            linkType := mType ? mType[1] : "Server"
            return "roblox://navigation/share_links?code=" . mCode[1] . "&type=" . linkType
        }
    }

    ; roblox.com/games/PLACEID?privateServerLinkCode=XXX — return as-is, works fine
    ; roblox:// links — return as-is
    ; ro.blox.com — return as-is, Windows hands to Roblox launcher
    return url
}

; Scans region 883,51,1037,86 for any difficulty text (Nightmare/Medium/Easy/Hard)
; Returns true if any detected — confirms player is inside a stage
CheckDifficultyDetected() {
    global TextNightmare, TextMedium, TextEasy, TextHard
    x1 := 883, y1 := 51, x2 := 1037, y2 := 86
    if GetFindText().FindText(&fx, &fy, x1, y1, x2, y2, 0.15, 0.15, TextNightmare)
        return true
    if GetFindText().FindText(&fx, &fy, x1, y1, x2, y2, 0.15, 0.15, TextMedium)
        return true
    if GetFindText().FindText(&fx, &fy, x1, y1, x2, y2, 0.15, 0.15, TextEasy)
        return true
    if GetFindText().FindText(&fx, &fy, x1, y1, x2, y2, 0.15, 0.15, TextHard)
        return true
    return false
}

