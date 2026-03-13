UpdateSpeedScale() {
    global CreatorSpeed, UserSpeed, SpeedScale
    if (UserSpeed <= 0)
        UserSpeed := CreatorSpeed
    SpeedScale := CreatorSpeed / UserSpeed
}

UpdateSearchArea() {
    ; Recalculates the enemy count search region relative to the Roblox window
    global StartX, StartY, EndX, EndY, RobloxTitle
    if !WinExist(RobloxTitle) {
        StartX := 0
        StartY := 0
        EndX   := A_ScreenWidth
        EndY   := Round(A_ScreenHeight * 0.25)
        return
    }
    ; Fixed enemy count scan area (absolute coords)
    StartX := 656
    StartY := 46
    EndX   := 778
    EndY   := 88
}


; ================================================================
;   AUTO UPDATER  (ARX-style — GitHub Releases API)
; ================================================================
CheckForUpdates(force := false) {
    global MacroVersion, RepoOwner, RepoName, RawBase

    global UpdateAttempted
    if (UpdateAttempted && !force)
        return
    UpdateAttempted := true

    GuiStatus.Text := "Checking for updates..."

    ; ── Query GitHub Releases API (no curl needed — uses COM) ──
    url  := "https://api.github.com/repos/" . RepoOwner . "/" . RepoName . "/releases/latest"
    http := ComObject("MSXML2.XMLHTTP")
    try {
        http.Open("GET", url, false)
        http.setRequestHeader("User-Agent", "AHK-Macro-Updater")
        http.Send()
    } catch as e {
        GuiStatus.Text := "⚠ Update check failed — " . e.Message
        return
    }

    if (http.Status != 200) {
        GuiStatus.Text := "⚠ Update check failed (HTTP " . http.Status . ") — is repo public?"
        return
    }

    ; ── Parse tag_name from JSON response ──
    response      := http.responseText
    latestVersion := ""
    if RegExMatch(response, '"tag_name"\s*:\s*"v?([^"]+)"', &m)
        latestVersion := m[1]

    if (latestVersion == "") {
        GuiStatus.Text := "⚠ Could not parse version from GitHub — no releases published yet?"
        return
    }

    ; ── Compare versions ──
    cmp := VerCompare(MacroVersion, latestVersion)

    if (cmp == 0 && !force) {
        GuiStatus.Text := "✔ Up to date (V" . MacroVersion . ")"
        return
    }
    if (cmp > 0) {
        GuiStatus.Text := "⚠ Local version (V" . MacroVersion . ") is newer than release (V" . latestVersion . ")"
        return
    }

    if (force && cmp == 0)
        GuiStatus.Text := "Force updating V" . MacroVersion . "..."
    else
        GuiStatus.Text := "Update V" . MacroVersion . " → V" . latestVersion . " — downloading..."

    ; ── Download files.txt from repo to know what to update ──
    filesUrl := RawBase . "files.txt"
    http2    := ComObject("MSXML2.XMLHTTP")
    try {
        http2.Open("GET", filesUrl, false)
        http2.setRequestHeader("User-Agent", "AHK-Macro-Updater")
        http2.Send()
    } catch {
        GuiStatus.Text := "⚠ Could not fetch files.txt from repo"
        return
    }

    updatedCount := 0
    failedFiles  := ""

    if (http2.Status == 200) {
        fileList := http2.responseText
        Loop Parse, fileList, "`n", "`r" {
            fileName := Trim(A_LoopField)
            if (fileName == "")
                continue

            fileUrl   := RawBase . fileName
            localPath := A_ScriptDir . "\" . StrReplace(fileName, "/", "\")
            SplitPath(localPath, , &localDir)

            if (localDir != "" && !DirExist(localDir))
                DirCreate(localDir)

            ; Download via COM
            http3 := ComObject("MSXML2.XMLHTTP")
            try {
                http3.Open("GET", fileUrl, false)
                http3.setRequestHeader("User-Agent", "AHK-Macro-Updater")
                http3.Send()
            } catch {
                failedFiles .= fileName . "`n"
                continue
            }

            if (http3.Status != 200) {
                failedFiles .= fileName . " (HTTP " . http3.Status . ")`n"
                continue
            }

            ; Write file
            try {
                f := FileOpen(localPath, "w", "UTF-8")
                f.Write(http3.responseText)
                f.Close()
                updatedCount += 1
            } catch {
                failedFiles .= fileName . " (write error)`n"
            }
        }
    }

    ; ── Download main.ahk last and self-replace ──
    mainUrl  := RawBase . "main.ahk"
    http4    := ComObject("MSXML2.XMLHTTP")
    try {
        http4.Open("GET", mainUrl, false)
        http4.setRequestHeader("User-Agent", "AHK-Macro-Updater")
        http4.Send()
    } catch {
        GuiStatus.Text := "⚠ Could not download main.ahk"
        return
    }

    if (http4.Status != 200) {
        GuiStatus.Text := "⚠ main.ahk download failed (HTTP " . http4.Status . ")"
        return
    }

    mainContent := http4.responseText

    ; Validate it's actually AHK code not a 404 page
    if (!InStr(mainContent, "#Include") && !InStr(mainContent, "global ") && !InStr(mainContent, "; DenniXD")) {
        GuiStatus.Text := "⚠ Downloaded main.ahk looks invalid — keeping current"
        return
    }

    ; Write to temp file
    mainTmp := A_ScriptDir . "\main.ahk.tmp"
    try {
        f := FileOpen(mainTmp, "w", "UTF-8")
        f.Write(mainContent)
        f.Close()
    } catch as e {
        GuiStatus.Text := "⚠ Could not write main.ahk.tmp: " . e.Message
        return
    }

    ; Back up current script
    bakPath := A_ScriptDir . "\main_backup_V" . MacroVersion . ".ahk"
    FileCopy(A_ScriptFullPath, bakPath, 1)

    ; Replace via bat + restart
    batPath    := A_ScriptDir . "\~updater.bat"
    batContent := "@echo off`r`n"
                . "timeout /t 2 /nobreak >nul`r`n"
                . "move /y `"" . mainTmp . "`" `"" . A_ScriptFullPath . "`"`r`n"
                . "if exist `"" . bakPath . "`" del /f /q `"" . bakPath . "`"`r`n"
                . "start `"`" `"" . A_ScriptFullPath . "`"`r`n"
                . "del `"%~f0`"`r`n"
    try {
        f := FileOpen(batPath, "w")
        f.Write(batContent)
        f.Close()
    } catch as e {
        GuiStatus.Text := "⚠ Could not write updater.bat: " . e.Message
        return
    }

    if (failedFiles != "")
        MsgBox("Update V" . latestVersion . " ready!`n`nSome files failed:`n" . failedFiles . "`nMacro will restart now.", "Auto Updater", 48)
    else
        MsgBox("Update V" . latestVersion . " ready! (" . updatedCount . " files updated)`nMacro will restart now.", "Auto Updater", 64)

    Run(batPath)
    ExitApp()
}


; ARX-style FindText singleton — reuses same object for better performance
GetFindText() {
    static obj := FindText()
    return obj
}

RobloxRunning() {
    return ProcessExist("RobloxPlayerBeta.exe") || ProcessExist("RobloxPlayer.exe") || ProcessExist("Roblox.exe")
}

RunCustomOrDefault(seqName, defaultFn) {
    global CustomSeqs
    if (CustomSeqs.Has(seqName) && CustomSeqs[seqName].Length > 0) {
        PlaySequence(CustomSeqs[seqName])
        return
    }
    defaultFn()
}

; Returns total duration of a sequence in ms
CalcSeqDuration(steps) {
    global SpeedScale
    total := 0
    for step in steps {
        if (step.Has("dur"))
            total += step["dur"]
    }
    ; Apply speed scaling so post-step pauses match actual playback time
    return Round(total * SpeedScale)
}

; Plays a sequence array [{type,key,dur,x,y}, ...]
PlaySequence(steps) {
    global Running, StartX, StartY, EndX, EndY, RobloxTitle
    if (!Running || steps.Length == 0)
        return
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }
    BlockInput("On")
    for step in steps {
        if (!Running) {
            BlockInput("Off")
            return
        }
        if (step["type"] == "key") {
            scaledDur := Max(10, Round(step["dur"] * SpeedScale))
            Send("{" step["key"] " down}"), Sleep(scaledDur), Send("{" step["key"] " up}")
        } else if (step["type"] == "click") {
            ; ARX FixClick method — nudge + relative click for 100% hit rate
            MouseMove(step["x"], step["y"])
            MouseMove(1, 0,, "R")
            MouseClick("Left", -1, 0,,,, "R")
            Sleep(50)
            if (step.Has("dur") && step["dur"] > 0)
                Sleep(Round(step["dur"] * SpeedScale))
        } else if (step["type"] == "sleep") {
            Sleep(Max(10, Round(step["dur"] * SpeedScale)))
        } else if (step["type"] == "triggerpoint") {
            ; Wait until enemy count matches before continuing
            targetCount := step["count"]  ; e.g. 8
            deadline    := A_TickCount + 120000  ; 2 min max wait
            GuiStatus.Text := "Waiting for trigger: " targetCount " enemies..."
            Loop {
                if (!Running)
                    return
                if (A_TickCount > deadline)
                    break  ; timeout — continue anyway
                ; Use FindText to detect enemy count
                textVar := "Text" targetCount
                try {
                    if GetFindText().FindText(&fx, &fy, StartX, StartY, EndX, EndY, 0, 0, %textVar%) {
                        Sleep(200)
                        break
                    }
                }
                Sleep(300)
            }
        }
    }
}


; ================================================================
;   DEMON SLAYER — MOVEMENT FUNCTIONS
; ================================================================


; ================================================================
;   UTILITIES
; ================================================================
; Reliable double-click helper — activates Roblox, moves mouse, clicks twice
; FixClick — 100% click method ported from Anime Rangers X macro
; 1) Move to target  2) Nudge 1px relative  3) Click at -1,0 relative
; The nudge+relative trick guarantees Roblox registers every click
SafeClick(x, y, LR := "Left") {
    MouseMove(x, y)
    MouseMove(1, 0,, "R")
    MouseClick(LR, -1, 0,,,, "R")
    Sleep(50)
}

RobloxClick(x, y) {
    BlockInput("On")
    SafeClick(x, y)
    BlockInput("Off")
}
; Returns to lobby and resets raid state so Double Dungeon can start fresh
; ── TravelToGamemode — scan-based navigation, presses S/W until target map is highlighted ──
; Futureproof: never relies on fixed counts — keeps pressing until FindText confirms the map
; gm param: "AV" → DemonForest | "DD" → DungeonTown | "Rift" → ReaperSociety
