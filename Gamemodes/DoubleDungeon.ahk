RunDoubleDungeon() {
    ; CurrentRaidStep: 0 = not started, 1 = entered (waiting), 2+ = slot index into GM_DD
    global Running, CurrentRaidStep, DungeonRuns, RaidStartTime, EntryFailCount
    global SlotTriggers, GM_DD, CustomSeqs, StartX, StartY, EndX, EndY
    if (!Running)
        return

    slots := GM_DD  ; live reference — reflects any added/removed slots

    ; —— Not started: run entry slot then wait for first trigger ————————
    if (CurrentRaidStep == 0) {
        TravelToGamemode("DD")
        GuiStatus.Text := "Double Dungeon — Entering"
        RunCustomOrDefault(slots[1]["key"], (*) => 0)
        RaidStartTime   := A_TickCount
        CurrentRaidStep := 1  ; marks entry done, next = slot index 2

        ; Wait for slot 2 trigger to confirm we are inside
        if (slots.Length < 2) {
            ; Only entry slot exists — run complete
            DungeonRuns += 1
                    GuiStatus.Text := "● Done  [DD: " . DungeonRuns . "]"
            Sleep(5000)
            CaptureAndSend(false)
            ReturnToLobby()
            CurrentRaidStep := 0
            return
        }
        slot2    := slots[2]
        trig2    := SlotTriggers.Has(slot2["key"]) ? SlotTriggers[slot2["key"]] : slot2["trigger"]
        textVar2 := DDResolveTextVar(trig2)
        GuiStatus.Text := "Double Dungeon — Waiting to enter stage..."
        ftDD := GetFindText()
        EntryDeadline := A_TickCount + 90000
        Loop {
            if (!Running)
                return
            ; Direct Text12 check (12 enemies = original entry confirm method)
            if ftDD.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text12) {
                GuiStatus.Text := "Double Dungeon — Stage confirmed (12 enemies)"
                break
            }
            ; Difficulty text = confirmed inside (Nightmare / Hard / Medium / Easy)
            if (CheckDifficultyDetected()) {
                GuiStatus.Text := "Double Dungeon — Stage confirmed via difficulty"
                break
            }
            ; Specific trigger enemy count visible
            if (textVar2 != "") {
                try {
                    if ftDD.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar2%) {
                        GuiStatus.Text := "Double Dungeon — Stage confirmed (" trig2 ")"
                        break
                    }
                }
            }
            ; Any enemy count visible = we are inside
            if (DDAnyStageSeen(StartX, StartY, EndX, EndY)) {
                GuiStatus.Text := "Double Dungeon — Stage confirmed (enemies visible)"
                break
            }
            if (A_TickCount > EntryDeadline) {
                EntryFailCount += 1
                if (EntryFailCount >= 2) {
                    EntryFailCount := 0
                    GuiStatus.Text := "Double Dungeon — Entry failed twice — hard resetting..."
                    ForceRejoin()
                    return
                }
                GuiStatus.Text := "Double Dungeon — Timed out waiting for entry, restarting"
                CurrentRaidStep := 0
                return
            }
            Sleep(400)
        }
        return
    }

    ; —— CurrentRaidStep 1 = run slot 2 onward ———————————————
    ; Walk through all remaining slots sequentially (slot index 2 to end)
    ; CurrentRaidStep == 1 means we just entered; start from slot 2
    startIdx := (CurrentRaidStep == 1) ? 2 : CurrentRaidStep
    if (startIdx > slots.Length) {
        ; Somehow past the end — finish up
        DungeonRuns += 1
        GuiStatus.Text := "● Done  [DD: " . DungeonRuns . "]"
        Sleep(5000)
        CaptureAndSend(false)
        ReturnToLobby()
        CurrentRaidStep := 0
        return
    }

    Loop {
        if (!Running)
            return

        idx  := (CurrentRaidStep == 1) ? 2 : CurrentRaidStep
        if (idx > slots.Length)
            break

        slot    := slots[idx]
        key     := slot["key"]
        trigger := SlotTriggers.Has(key) ? SlotTriggers[key] : slot["trigger"]
        textVar := DDResolveTextVar(trigger)

        ; Always update status immediately so display never shows stale message
        GuiStatus.Text := "Double Dungeon — " slot["label"] " — waiting for " trigger "..."

        ; Wait for trigger only if we have a valid non-empty pattern
        if (textVar != "") {
            ; Verify the pattern variable is actually populated (e.g. Text3 may be empty placeholder)
            patternExists := false
            try {
                val := %textVar%
                patternExists := (val != "")
            }
            if (!patternExists) {
                GuiStatus.Text := "Double Dungeon — " slot["label"] " — no pattern for '" trigger "', skipping wait"
                Sleep(500)
            } else {
                ; Ensure Roblox is focused and search area is fresh before scanning
                if WinExist(RobloxTitle) {
                    WinActivate(RobloxTitle)
                    WinWaitActive(RobloxTitle, , 2)
                }
                UpdateSearchArea()

                ; Fused detection — single instance, direct check first then two-phase
                ft := GetFindText()

                ; Quick direct check — if count already visible, proceed immediately
                directFound := false
                try {
                    if ft.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar%)
                        directFound := true
                }
                if (!directFound) {
                    ; Phase 1: wait up to 15s for previous count to DISAPPEAR
                    clearDeadline := A_TickCount + 15000
                    Loop {
                        if (!Running)
                            return
                        if (A_TickCount > clearDeadline)
                            break
                        stillVisible := false
                        try {
                            if ft.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar%)
                                stillVisible := true
                        }
                        if (!stillVisible)
                            break
                        Sleep(100)
                    }

                    ; Phase 2: wait up to 30s for new count to appear and be stable
                    stepDeadline := A_TickCount + 30000
                    Loop {
                        if (!Running)
                            return
                        if (A_TickCount > stepDeadline) {
                            GuiStatus.Text := "Double Dungeon — " slot["label"] " — 30s passed, running anyway"
                            break
                        }
                        found := false
                        try {
                            if ft.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar%)
                                found := true
                        }
                        if (found) {
                            ; Stability check — confirm twice over 200ms
                            Sleep(100)
                            c1 := false, c2 := false
                            try {
                                if ft.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar%)
                                    c1 := true
                            }
                            Sleep(100)
                            try {
                                if ft.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, %textVar%)
                                    c2 := true
                            }
                            if (c1 && c2)
                                break
                        }
                        Sleep(100)
                    }
                }
                if (!Running)
                    return
            }
        }

        ; Run the sequence
        GuiStatus.Text := "Double Dungeon — Running " slot["label"]
        RunCustomOrDefault(key, (*) => 0)

        ; Pause: 2s flat between slots
        GuiStatus.Text := "Double Dungeon — " slot["label"] " done — next slot..."
        Sleep(2000)

        ; Advance
        CurrentRaidStep := idx + 1
        if (CurrentRaidStep > slots.Length)
            break
    }

    if (!Running)
        return

    ; All slots done — run complete
    DungeonRuns += 1
    CurrentRaidStep := 0
    GuiStatus.Text := "● Done  [DD: " . DungeonRuns . "]"
    Sleep(5000)
    CaptureAndSend(false)
    ReturnToLobby()
}

DDResolveTextVar(trigger) {
    if (trigger == "0 enemies")
        return "Text0"
    if (trigger == "—" || trigger == "— (manual/always)" || trigger == "" || trigger == "After entry")
        return ""
    ; Extract only the FIRST number in the trigger string (handles "10 enemies (2nd)" etc)
    if RegExMatch(trigger, "\d+", &m)
        return "Text" m[]
    return ""
}

; Returns true if any enemy count text (0-20) is visible on screen = we are inside a stage
DDAnyStageSeen(x1, y1, x2, y2) {
    global Text0, Text1, Text2, Text4, Text5, Text6, Text7, Text8, Text9, Text10, Text11, Text12
    for tv in [Text1, Text2, Text4, Text5, Text6, Text7, Text8, Text9, Text10, Text11, Text12, Text0] {
        if GetFindText().FindText(&fx, &fy, x1, y1, x2, y2, 0.15, 0.15, tv)
            return true
    }
    return false
}
; ================================================================
;   DOUBLE DUNGEON — MOVEMENT FUNCTIONS
; ================================================================
; ================================================================
;   RIFT MODE
; ================================================================
