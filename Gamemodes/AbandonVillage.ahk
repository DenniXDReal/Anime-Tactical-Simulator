RunDemonSlayer() {
    ; CurrentAVStep: 0 = not started, 1 = entered (waiting for stage), 2+ = slot index into GM_AV
    global Running, CurrentAVStep, DemonRuns, RaidStartTime, AVEntryFails, EntryFailCount
    global SlotTriggers, GM_AV, CustomSeqs, StartX, StartY, EndX, EndY
    if (!Running)
        return

    slots := GM_AV  ; live reference — reflects any added/removed slots

    ; —— Not started: travel to correct map then run entry slot ————————
    if (CurrentAVStep == 0) {
        TravelToGamemode("AV")
        GuiStatus.Text := "Abandon Village — Entering"
        RunCustomOrDefault(slots[1]["key"], (*) => 0)
        RaidStartTime  := A_TickCount
        CurrentAVStep  := 1

        if (slots.Length < 2) {
            DemonRuns += 1
            GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
            Sleep(5000)
            CaptureAndSend(false)
            ReturnToLobby()
            CurrentAVStep := 0
            return
        }

        GuiStatus.Text := "Abandon Village — Waiting for stage..."
        ftAV := GetFindText()
        EntryDeadline := A_TickCount + 90000
        Loop {
            if (!Running)
                return
            if (CheckDifficultyDetected()) {
                AVEntryFails   := 0
                EntryFailCount := 0
                GuiStatus.Text := "Abandon Village — Stage confirmed via difficulty"
                break
            }
            if ftAV.FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text2) {
                AVEntryFails   := 0
                EntryFailCount := 0
                GuiStatus.Text := "Abandon Village — Stage confirmed"
                break
            }
            if (A_TickCount > EntryDeadline) {
                if (CheckDifficultyDetected()) {
                    GuiStatus.Text := "Abandon Village — Difficulty detected, continuing..."
                    EntryFailCount := 0
                    break
                }
                AVEntryFails  += 1
                EntryFailCount += 1
                if (EntryFailCount >= 2) {
                    EntryFailCount := 0
                    CurrentAVStep  := 0
                    GuiStatus.Text := "Abandon Village — Entry failed twice — hard resetting..."
                    ForceRejoin()
                    return
                }
                GuiStatus.Text := "Abandon Village — Timed out, restarting cycle"
                CurrentAVStep := 0
                return
            }
            Sleep(500)
        }
        return
    }

    ; —— CurrentAVStep 1+ = walk through remaining slots ————————————
    startIdx := (CurrentAVStep == 1) ? 2 : CurrentAVStep
    if (startIdx > slots.Length) {
        DemonRuns += 1
        GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
        Sleep(5000)
        CaptureAndSend(false)
        ReturnToLobby()
        CurrentAVStep := 0
        return
    }

    ftAV := GetFindText()
    Loop {
        if (!Running)
            return

        idx  := (CurrentAVStep == 1) ? 2 : CurrentAVStep
        if (idx > slots.Length)
            break

        slot    := slots[idx]
        key     := slot["key"]
        trigger := SlotTriggers.Has(key) ? SlotTriggers[key] : slot["trigger"]

        GuiStatus.Text := "Abandon Village — " slot["label"] " — waiting for " trigger "..."

        ; Only wait if trigger is meaningful
        if (trigger != "" && trigger != "—" && trigger != "After entry") {
            winDeadline := A_TickCount + 300000
            Loop {
                if (!Running)
                    return
                if ftAV.FindText(&FoundX, &FoundY, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
                    Sleep(500)
                    if ftAV.FindText(&FoundX, &FoundY, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
                        DemonRuns += 1
                        GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
                        Sleep(5000)
                        CaptureAndSend(false)
                        ReturnToLobby()
                        CurrentAVStep := 0
                        return
                    }
                }
                if (A_TickCount > winDeadline) {
                    GuiStatus.Text := "Abandon Village — " slot["label"] " — timeout, running anyway"
                    break
                }
                Sleep(500)
            }
        }

        GuiStatus.Text := "Abandon Village — Running " slot["label"]
        RunCustomOrDefault(key, (*) => 0)
        Sleep(1000)

        ; Check win after each slot
        if ftAV.FindText(&FoundX, &FoundY, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
            Sleep(500)
            if ftAV.FindText(&FoundX, &FoundY, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
                DemonRuns += 1
                GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
                Sleep(5000)
                CaptureAndSend(false)
                ReturnToLobby()
                CurrentAVStep := 0
                return
            }
        }

        Sleep(2000)
        CurrentAVStep := idx + 1
        if (CurrentAVStep > slots.Length)
            break
    }

    if (!Running)
        return

    DemonRuns += 1
    CurrentAVStep := 0
    GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
    Sleep(5000)
    CaptureAndSend(false)
    ReturnToLobby()
}
