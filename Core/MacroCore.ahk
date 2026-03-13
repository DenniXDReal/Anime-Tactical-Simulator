StartMacro() {
    global Running, SessionStart, CurrentRaidStep, HasSummonedThisSession, RobloxTitle
    Running                 := true
    SessionStart            := A_TickCount
    CurrentRaidStep         := 0
    CurrentAVStep           := 0
    HasSummonedThisSession  := false
    UpdateSpeedScale()  ; calculate speed scalar from user speed setting
    UpdateSearchArea()  ; calculate search region from current Roblox window size

    ; AV and Rift are real-clock based — no cooldown restore needed
    LastRejoinTime  := A_TickCount  ; prevent hourly check firing immediately
    GuiStatus.Text  := "● Running"
    GuiStatus.Opt("c00FF99")

    ; ── Always rejoin on start to ensure clean server state ──
    GuiStatus.Text := "Rejoining server..."
    RejoinPS()

    ; Run summon immediately at start if enabled
    if (ModeSummoning)
        RunSummon()
    SetTimer(MainLoop, 150)
    SetTimer(CrashWatchdog, 5000)
}
StopMacro() {
    global Running, SummonHasRun, MacroLock, LastAVTime, LastRiftTime, CurrentRaidStep, CurrentAVStep, MacroPaused
    SummonHasRun    := false
    MacroLock       := false
    LastAVTime      := 0
    LastRiftTime    := 0
    Running         := false
    CurrentRaidStep := 0
    MacroPaused     := false
    GuiStatus.Text  := "● Stopped"
    GuiStatus.Opt("cFF3355")
    SetTimer(MainLoop, 0)
    SetTimer(CrashWatchdog, 0)
    ; Check for updates when macro stops — only if not already checked this session
    if (!UpdateAttempted)
        SetTimer(CheckForUpdates, -1000)
}
TogglePause() {
    global MacroPaused, Running, GuiStatus
    if (!Running)
        return
    MacroPaused := !MacroPaused
    if (MacroPaused) {
        GuiStatus.Text := "⏸ Paused"
        GuiStatus.Opt("cFFAA00")
    } else {
        GuiStatus.Text := "● Running"
        GuiStatus.Opt("c00FF99")
    }
}

UpdateRaidType() {
    global DdlRaidType, RaidType, GuiRaidType, ModeRaid
    types := ["Namex Planet", "Colosseum Kingdom", "Demon Forest", "Dungeon Town", "Reaper Society"]
    RaidType := types[DdlRaidType.Value]
    if (ModeRaid)
        GuiRaidType.Text := RaidType
}

KillAll() {
    global Running
    Running := false
    SetTimer(MainLoop, 0)
    for procName in ["TinyTask.exe", "tinytask.exe", "TINYTASK.EXE"] {
        while ProcessExist(procName)
            ProcessClose(procName)
    }
    Loop Files, A_ScriptDir "\*.exe" {
        try ProcessClose(A_LoopFileName)
    }
    ExitApp()
}
MainLoop() {
    global Running, CurrentRaidStep, CurrentAVStep, RaidStartTime, MacroLock
    global ModeAbandonVillage, ModeDoubleDungeon, ModeRift, ModeSummoning, ModeCustomMovement, ModeRaid
    global LastAVTime, LastRiftTime
    if (!Running)
        return
    if (MacroPaused) {
        GuiStatus.Text := "⏸ Paused — F4 to resume"
        return
    }
    if (MacroLock)
        return

    ; Safety timeout — force rejoin if DD takes longer than 30 minutes
    ; (large slot counts with long sequences can easily exceed 5 min)
    if (CurrentRaidStep > 0 && RaidStartTime > 0 && (A_TickCount - RaidStartTime > 1800000)) {
        ForceRejoin()
        return
    }

    ; Guard — at least one mode must be on
    anyOn := ModeAbandonVillage || ModeDoubleDungeon || ModeRift
              || ModeSummoning || ModeCustomMovement || ModeRaid
    if (!anyOn) {
        ModeAbandonVillage := true
        GuiStatus.Text := "⚠ No mode selected — defaulting to Abandon Village"
        return
    }

    MacroLock := true
    SetTimer(MainLoop, 0)

    now := A_TickCount

    ; ── Hourly rejoin check — restart game if 1hr has elapsed ──
    if (LastRejoinTime == 0 || (now - LastRejoinTime >= 3600000)) {
        GuiStatus.Text := "⏳ 1hr elapsed — restarting game..."
        RejoinPS()
        MacroLock := false
        SetTimer(MainLoop, 150)
        return
    }

    ; ── SCHEDULING ───────────────────────────────────────────────
    ; Summon  → once per session
    ; AV      → fires at real clock :00/:10/:20/:30/:40/:50
    ; Rift    → fires at real clock :00/:15/:30/:45
    ; DD / Raid / Custom → filler, run every cycle if enabled
    ;
    ; Priority order: Summon > Rift > AV > DD > Raid > Custom
    ; If both Rift and AV are due at the same time, Rift runs first

    ; 1. Summon — once per session
    if (Running && ModeSummoning)
        RunSummon()

    ; 2. Rift — fires at real clock :00/:15/:30/:45 (higher priority than AV)
    if (Running && ModeRift) {
        currMin := Integer(FormatTime(, "mm"))
        currSec := Integer(FormatTime(, "ss"))
        ; Due at exactly XX:00/15/30/45 — only within first 10s of that minute
        riftDue := (Mod(currMin, 15) == 0 && currSec < 10)
        ; Guard: don't re-trigger within same 15min window (840s = 14min debounce)
        if (riftDue && (LastRiftTime == 0 || (A_TickCount - LastRiftTime > 840000))) {
            RunRift()
            LastRiftTime := A_TickCount
            IniWrite(A_Now, IniFile, "Cooldowns", "LastRiftEpoch")
            UpdateUI()
        }

        ; Force-leave AV/DD/Raid if Rift window is <60s away and feature is enabled
        ; This fires even when riftDue is false — it's a pre-emptive warning/leave
        if (RiftForceLeave && !riftDue) {
            _secsLeft := RiftSecsUntilNext()
            if (_secsLeft > 0 && _secsLeft <= 60) {
                GuiStatus.Text := "Rift approaching in " _secsLeft "s — force leaving to lobby..."
                ReturnToLobby()
                WaitForRiftBoundary()
            }
        }
    }

    ; 3. AV — clock-based: fires at XX:00, XX:10, XX:20, XX:30, XX:40, XX:50
    if (Running && ModeAbandonVillage) {
        currMin := Integer(FormatTime(, "mm"))
        currSec := Integer(FormatTime(, "ss"))
        ; Only fire on a 10-min mark and not within 30s of the last run (debounce)
        avDue := (Mod(currMin, 10) == 0 && currSec < 30)
                 && (LastAVTime == 0 || (A_TickCount - LastAVTime > 30000))
        if (avDue) {
            RunDemonSlayer()
            LastAVTime := A_TickCount
            IniWrite(A_Now, IniFile, "Cooldowns", "LastAVEpoch")
            UpdateUI()
        }
    }


    ; 4. DD — filler, runs every cycle
    if (Running && ModeDoubleDungeon) {
        RunDoubleDungeon()
        UpdateUI()
    }

    ; 5. Raid — filler, runs every cycle
    if (Running && ModeRaid) {
        RunRaid()
        UpdateUI()
    }

    ; 6. Custom — filler, runs every cycle
    if (Running && ModeCustomMovement) {
        RunCustomOrDefault("Custom_Movement", (*) => 0)
        UpdateUI()
    }

    MacroLock := false
    SetTimer(MainLoop, 150)
}
; ================================================================
;   RAID MODES
; ================================================================
RunDynamicSlots(gmKey) {
    ; Runs all dynamically added slots for a gamemode in order
    ; Each slot fires when its trigger enemy count is detected on screen
    global CustomSeqs, SlotTriggers, GM_DD, GM_AV, GM_Rift, GM_Summon, GM_Custom
    global Running, StartX, StartY, EndX, EndY

    gmMap := Map("DD",GM_DD,"AV",GM_AV,"Rift",GM_Rift,"Raid","Summon",GM_Summon,"Custom",GM_Custom)
    if (!gmMap.Has(gmKey))
        return

    slots := gmMap[gmKey]
    ; Only run slots that are not in the base hardcoded set
    baseKeys := Map(
        "DD_EnterRaid",1,"DD_Step1",1,"DD_Step2",1,"DD_Step3",1,"DD_Step4",1,
        "DD_Step5",1,"DD_Step6",1,"DD_Step7",1,"DD_Step8",1,"DD_Step9",1,"DD_Step10",1,
        "AV_Entry",1,"AV_Step1",1,"Rift_Entry",1,"Rift_Custom",1,
        "Raid_Entry",1,"Raid_NamexPlanet",1,"Raid_ColosseumKingdom",1,
        "Raid_DemonForest",1,"Raid_DungeonTown",1,"Raid_ReaperSociety",1,
        "Summon_DungeonTown",1,"Summon_ReaperSociety",1,"Summon_SoulSociety",1,
        "Custom_Movement",1
    )

    for slot in slots {
        key := slot["key"]
        if (baseKeys.Has(key) || !CustomSeqs.Has(key))
            continue
        trigger := SlotTriggers.Has(key) ? SlotTriggers[key] : "—"
        ; Fire based on trigger
        if (trigger == "—" || trigger == "— (manual/always)") {
            GuiStatus.Text := "Running: " slot["label"]
            RunCustomOrDefault(key, (*) => 0)
        } else if (trigger == "After entry") {
            ; Already inside — run immediately
            GuiStatus.Text := "Running: " slot["label"]
            RunCustomOrDefault(key, (*) => 0)
        } else {
            ; Enemy count trigger — wait for it
            countStr := RegExReplace(trigger, "[^\d]", "")
            if (countStr == "")
                continue
            count := Integer(countStr)
            try textVar := "Text" count
            deadline := A_TickCount + 60000
            Loop {
                if (!Running)
                    return
                if (A_TickCount > deadline)
                    break
                if GetFindText().FindText(&fx, &fy, StartX, StartY, EndX, EndY, 0, 0, %textVar%) {
                    GuiStatus.Text := "Running: " slot["label"]
                    RunCustomOrDefault(key, (*) => 0)
                    break
                }
                Sleep(300)
            }
        }
    }
    BlockInput("Off")
}

