ImportRiftMovement() {
    global RiftLobbyImportPath, LblRiftImport, SeqFile, FolderCustom, IniFile
    chosen := FileSelect(3,, "Select Rift Lobby Movement File", "Text Files (*.txt)")
    if (chosen == "")
        return
    ; Copy file into Custom folder as Rift.txt
    destPath := FolderCustom "\Rift.txt"
    FileCopy(chosen, destPath, 1)
    RiftLobbyImportPath := destPath
    SplitPath(chosen, &fname)
    LblRiftImport.Text := "Loaded: " fname
    ; Save the source path to INI so it persists across restarts
    IniWrite(chosen, IniFile, "Settings", "RiftImportPath")
    LoadSequences()
    MsgBox("Rift movement imported!`n" fname, "Rift Import", "Icon!")
}

; ── Rift timer helper — returns seconds until next XX:00/15/30/45 boundary ──
; Runs on a 300ms timer during Rift entry — stops movement if lobby UI detected
; Runs on 500ms timer during TravelToGamemode — force-closes menu with F if boundary hits
TravelBoundaryWatcher() {
    global TravelBoundaryAbort, RobloxTitle
    currMin := Integer(FormatTime(, "mm"))
    currSec := Integer(FormatTime(, "ss"))
    if (Mod(currMin, 15) == 0 && currSec <= 3) {
        TravelBoundaryAbort := true
        ; Force close travel UI
        if WinExist(RobloxTitle) {
            WinActivate(RobloxTitle)
            Send("{f down}"), Sleep(110), Send("{f up}")
        }
        SetTimer(TravelBoundaryWatcher, 0)
    }
}

RiftCheckLobbyDuringEntry() {
    global Running, RiftLobbyDetected, TextRiftLobby
    if (!Running || RiftLobbyDetected)
        return
    try {
        if GetFindText().FindText(&fx, &fy, 563, 179, 719, 238, 0.15, 0.15, TextRiftLobby) {
            RiftLobbyDetected := true
            GuiStatus.Text := "Rift — Lobby detected! Stopping entry movement..."
            Send("{w up}{a up}{s up}{d up}")
        }
    }
}

RiftSecsUntilNext() {
    sec := Integer(FormatTime(, "ss"))
    mn  := Integer(FormatTime(, "mm"))
    ; seconds into current 15-min window
    secsIntoWindow := (Mod(mn, 15) * 60) + sec
    return (900 - secsIntoWindow)  ; 900 = 15*60
}

; ── Mini mode toggle ──────────────────────────────────────────
ToggleMiniMode() {
    global MiniMode, MiniGui, MyGui
    MiniMode := !MiniMode
    if (MiniMode) {
        MyGui.Hide()
        ; Position top-right of primary monitor
        monRight  := SysGet(78)   ; SM_CXVIRTUALSCREEN width fallback
        monRight  := SysGet(16)   ; SM_CXFULLSCREEN
        MiniGui.Show("x" (monRight - 290) " y4 w280 h106 NoActivate")
    } else {
        MiniGui.Hide()
        MyGui.Show()
    }
}

; ── Rift: are we within the danger zone? (XX:14/29/44/59 = last second before boundary) ──
RiftInDangerZone() {
    sec := Integer(FormatTime(, "ss"))
    mn  := Integer(FormatTime(, "mm"))
    secsLeft := RiftSecsUntilNext()
    ; Danger = <=1s before boundary (XX:59, XX:14, XX:29, XX:44 with sec >= 59)
    ; Or more practically: if next boundary <2s away stop launching
    return (secsLeft <= 2)
}

; ── Rift: is it exactly a boundary second? XX:00 / XX:15 / XX:30 / XX:45 ──
RiftAtBoundary() {
    sec := Integer(FormatTime(, "ss"))
    mn  := Integer(FormatTime(, "mm"))
    return (sec == 0 && Mod(mn, 15) == 0)
}

; ── Rift boundary wait helpers ──
WaitForRiftBoundary() {
    global Running
    Loop {
        if (!Running)
            return
        mn  := Integer(FormatTime(, "mm"))
        sec := Integer(FormatTime(, "ss"))
        if (Mod(mn, 15) == 0 && sec < 10)
            return
        Sleep(200)
    }
}

WaitForRiftBoundaryAndRetry() {
    global Running
    GuiStatus.Text := "Rift — Waiting for next cycle..."
    WaitForRiftBoundary()
    if Running
        RunRift()
}

RunRift() {
    global Running, RiftRuns, RaidStartTime, CurrentRaidStep, TextRiftLobby, RiftLobbyDetected
    global TextNightmare, TextMedium, TextEasy, TextHard, TextAVActive, StartX, StartY, EndX, EndY
    global Text0, Text1, Text2, Text4, Text5, Text6, Text7, Text8, Text9
    global ModeAbandonVillage, ModeDoubleDungeon
    GuiStatus.Text := "Rift — Starting"
    RaidStartTime  := A_TickCount
    ft             := GetFindText()

    ; ── Phase 0: Check if we are about to hit a boundary (XX:14/29/44/59) ──
    ; If next boundary is within 2s, hold off until it passes, then force-enter
    secsLeft := RiftSecsUntilNext()
    if (secsLeft <= 2) {
        GuiStatus.Text := "Rift — Waiting for boundary to pass..."
        ; Wait until we cross XX:00/15/30/45
        Loop {
            if (!Running)
                return
            if (RiftAtBoundary() || RiftSecsUntilNext() > 5)
                break
            Sleep(200)
        }
        Sleep(500)
        GuiStatus.Text := "Rift — Boundary passed, force-entering..."
    }

    ; ── Phase 1: Travel — open map, scroll to Reaper Society banner, confirm, close menu ──
    TravelToGamemode("Rift")

    ; ── Phase 2: Verify clock is still within XX:00/15/30/45 window before playing movement ──
    ; TravelToGamemode can take time — if we've drifted past the window, abort
    _mn  := Integer(FormatTime(, "mm"))
    _sec := Integer(FormatTime(, "ss"))
    if !(Mod(_mn, 15) == 0 || (Mod(_mn, 15) == 1 && _sec < 10)) {
        GuiStatus.Text := "Rift — Clock window missed after travel, aborting"
        return
    }

    ; ── Phase 2: Banner confirmed — play imported movement (Rift_Custom) to walk to lobby ──
    ; Continuously check for lobby detection — stop movement if entered
    ; Also stop if clock hits XX:01/16/31/46 (lobby window closed)
    GuiStatus.Text := "Rift — Banner confirmed, playing movement to lobby..."
    RiftLobbyDetected := false
    lobbyEntered := false

    SetTimer(RiftCheckLobbyDuringEntry, 300)
    RunCustomOrDefault("Rift_Custom", (*) => 0)
    SetTimer(RiftCheckLobbyDuringEntry, 0)

    ; After movement finishes — check if lobby was entered
    if (RiftLobbyDetected)
        lobbyEntered := true

    ; If movement done but lobby not yet detected — keep checking until :01/:16/:31/:46
    if (!lobbyEntered) {
        GuiStatus.Text := "Rift — Movement done, waiting for lobby..."
        Loop {
            if (!Running)
                return
            currMin := Integer(FormatTime(, "mm"))
            currSec := Integer(FormatTime(, "ss"))
            if (Mod(currMin, 15) == 1 && currSec < 10) {
                GuiStatus.Text := "Rift — XX:01/16/31/46 hit — lobby window closed"
                break
            }
            if (RiftLobbyDetected) {
                lobbyEntered := true
                break
            }
            Sleep(300)
        }
    }

    ; ── Phase 3: Lobby not entered in time — hand off or wait for next cycle ──
    if (!lobbyEntered) {
        GuiStatus.Text := "Rift — Missed this cycle"
        if (ModeAbandonVillage || ModeDoubleDungeon) {
            GuiStatus.Text := "Rift — Handing off to AV/DD..."
            ReturnToLobby()
            return
        } else {
            WaitForRiftBoundaryAndRetry()
            return
        }
    }

    ; ── Phase 4: In lobby — wait for game start OR timeout at XX:01/16/31/46 ──
    GuiStatus.Text := "Rift — In lobby! Waiting for game start..."
    gameStarted := false
    Loop {
        if (!Running)
            return
        currMin := Integer(FormatTime(, "mm"))
        currSec := Integer(FormatTime(, "ss"))
        if (Mod(currMin, 15) == 1 && currSec < 10) {
            GuiStatus.Text := "Rift — XX:01/16/31/46 hit — lobby window closed"
            break
        }
        try {
            if ft.FindText(&fx, &fy, 563, 179, 719, 238, 0.15, 0.15, TextNightmare) {
                gameStarted := true
                break
            }
        }
        Sleep(300)
    }

    ; ── If timed out without game start ──
    if (!gameStarted) {
        GuiStatus.Text := "Rift — Missed this cycle"
        if (ModeAbandonVillage || ModeDoubleDungeon) {
            GuiStatus.Text := "Rift — Handing off to AV/DD..."
            ReturnToLobby()
            return
        } else {
            WaitForRiftBoundaryAndRetry()
            return
        }
    }

    ; ── Phase 5: Game confirmed — run Rift stage sequence ──
    GuiStatus.Text := "Rift — In game! Running stage sequence..."
    RunCustomOrDefault("Rift_Custom", (*) => 0)

    ; ── Phase 4: Watch for win condition (same as AV) OR boundary hit ──
    ; Win = TextAVActive detected (completion screen)
    ; Boundary = next XX:00/15/30/45 hit — force leave
    GuiStatus.Text := "Rift — Watching for completion or boundary..."
    ftRift := GetFindText()
    riftDone := false
    Loop {
        if (!Running)
            return

        ; ── Win condition check (same method as AV) ──
        if ftRift.FindText(&fx, &fy, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
            Sleep(1000)
            if ftRift.FindText(&fx, &fy, 860, 341, 1055, 391, 0.15, 0.15, TextAVActive) {
                riftDone := true
                break
            }
        }

        ; ── Boundary check — stop 2s before XX:00/15/30/45 ──
        if (RiftSecsUntilNext() <= 2) {
            GuiStatus.Text := "Rift — Boundary approaching — force leaving..."
            break
        }

        ; Safety timeout 14.5 min
        if (A_TickCount - RaidStartTime > 870000) {
            GuiStatus.Text := "Rift — Safety timeout, wrapping up..."
            break
        }

        Sleep(500)
    }

    ; ── Phase 5: Wrap up ──
    if (riftDone) {
        GuiStatus.Text := "Rift — Run complete!"
    } else {
        ; Wait for exact boundary before leaving
        GuiStatus.Text := "Rift — Waiting for boundary..."
        Loop {
            if (!Running)
                return
            if (RiftAtBoundary())
                break
            Sleep(200)
        }
    }

    ReturnToLobby()
    Sleep(1000)
    RiftRuns += 1
    GuiStatus.Text := "Rift — Done [" RiftRuns "]"
    CaptureAndSend(false)

    ; Travel back to ReaperSociety for next cycle
    TravelToGamemode("Rift")
}


