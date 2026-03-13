InitFolders() {
    global FolderCustom, FolderRaids, FolderSummon
    for folder in [FolderCustom, FolderRaids, FolderSummon] {
        if (!DirExist(folder))
            DirCreate(folder)
    }
    GenerateDefaultFiles()
}

GenerateDefaultFiles() {
    global FolderCustom, FolderRaids, FolderSummon

    hdr := "; ================================================================`n"
          . "; DenniXD ATS Macro V3.0.0 — Movement File (auto-generated)`n"
          . "; Edit steps freely. Reload via Settings > Movement Files.`n"
          . "; Format:  SlotKey|key|keyname|ms  /  |click|x|y|ms  /  |sleep|ms`n"
          . "; ================================================================`n`n"

    ; ── Custom/DoubleDungeon.txt ──────────────────────────────
    p := FolderCustom "\DoubleDungeon.txt"
    if (!FileExist(p)) {
        txt := hdr . "; === Double Dungeon ===`n"
        . "DD_EnterRaid|trigger|—`n"
        . "DD_EnterRaid|sleep|500`n"
        . "DD_EnterRaid|click|835|652|300`n"
        . "DD_EnterRaid|sleep|500`n"
        . "DD_EnterRaid|click|835|652|1000`n"
        . "DD_EnterRaid|key|s|3000`n"
        . "DD_EnterRaid|click|1117|626|2000`n`n"
        . "DD_Step1|trigger|12 enemies`n"
        . "DD_Step1|key|s|2563`n"
        . "DD_Step1|key|d|250`n`n"
        . "DD_Step2|trigger|10 enemies`n"
        . "DD_Step2|key|s|875`n"
        . "DD_Step2|key|a|344`n`n"
        . "DD_Step3|trigger|8 enemies`n"
        . "DD_Step3|key|s|2266`n"
        . "DD_Step3|key|d|218`n"
        . "DD_Step3|key|s|1000`n`n"
        . "DD_Step4|trigger|6 enemies`n"
        . "DD_Step4|key|s|563`n"
        . "DD_Step4|key|a|266`n`n"
        . "DD_Step5|trigger|5 enemies`n"
        . "DD_Step5|key|s|1500`n"
        . "DD_Step5|key|d|407`n"
        . "DD_Step5|key|s|1500`n`n"
        . "DD_Step6|trigger|4 enemies`n"
        . "DD_Step6|key|s|625`n"
        . "DD_Step6|key|a|320`n`n"
        . "DD_Step7|trigger|4 enemies`n"
        . "DD_Step7|key|w|4016`n"
        . "DD_Step7|key|a|5063`n"
        . "DD_Step7|key|s|2438`n"
        . "DD_Step7|key|a|1172`n"
        . "DD_Step7|key|d|453`n"
        . "DD_Step7|key|w|1500`n"
        . "DD_Step7|key|d|1469`n`n"
        . "DD_Step8|trigger|2 enemies`n"
        . "DD_Step8|key|d|8938`n"
        . "DD_Step8|key|s|3610`n"
        . "DD_Step8|key|d|2328`n"
        . "DD_Step8|key|a|188`n"
        . "DD_Step8|key|a|219`n"
        . "DD_Step8|key|w|1360`n"
        . "DD_Step8|key|a|1640`n"
        . "DD_Step8|key|a|172`n"
        . "DD_Step8|key|w|156`n`n"
        . "DD_Step9|trigger|1 enemy`n"
        . "DD_Step9|key|a|2641`n"
        . "DD_Step9|key|s|3032`n"
        . "DD_Step9|key|a|843`n`n"
        . "DD_Step10|trigger|0 enemies`n"
        . "DD_Step10|key|s|3578`n"
        . "DD_Step10|key|space|93`n"
        . "DD_Step10|key|space|344`n"
        . "DD_Step10|key|s|1141`n"
        . "DD_Step10|key|space|125`n"
        . "DD_Step10|key|space|422`n"
        . "DD_Step10|key|space|141`n"
        . "DD_Step10|key|space|297`n"
        . "DD_Step10|key|s|640`n"
        . "DD_Step10|key|d|359`n"
        . "DD_Step10|key|e|109`n"
        FileAppend(txt, p, "UTF-8")
    }

    ; ── Custom/AbandonVillage.txt ─────────────────────────────
    p := FolderCustom "\AbandonVillage.txt"
    if (!FileExist(p)) {
        txt := hdr . "; === Abandon Village ===`n"
        . "AV_Entry|trigger|—`n"
        . "AV_Entry|key|f|1000`n"
        . "AV_Entry|click|894|436|1000`n"
        . "AV_Entry|key|s|2000`n"
        . "AV_Entry|sleep|2000`n`n"
        . "AV_Step1|trigger|After entry`n"
        . "AV_Step1|key|s|578`n"
        . "AV_Step1|key|a|3516`n"
        . "AV_Step1|key|w|1968`n"
        FileAppend(txt, p, "UTF-8")
    }

    ; ── Custom/Rift.txt ───────────────────────────────────────
    p := FolderCustom "\Rift.txt"
    if (!FileExist(p)) {
        txt := hdr . "; === Rift ===`n"
        . "; Record your Rift entry in the editor and save here`n"
        . "Rift_Entry|trigger|—`n"
        . "Rift_Custom|trigger|—`n"
        FileAppend(txt, p, "UTF-8")
    }

    ; ── Raids — one file per map ──────────────────────────────
    raidEntry := "Raid_Entry|trigger|—`n"
        . "Raid_Entry|click|1230|446|63`n"
        . "Raid_Entry|click|1230|423|78`n"
        . "Raid_Entry|key|f|125`n"
        . "Raid_Entry|key|\|94`n"
        . "Raid_Entry|key|d|94`n"
        . "Raid_Entry|key|s|78`n"
        . "Raid_Entry|key|a|62`n"
        . "Raid_Entry|key|w|78`n"
        . "Raid_Entry|key|s|78`n"
        . "Raid_Entry|key|w|93`n"
        . "Raid_Entry|key|w|94`n"
        . "Raid_Entry|key|w|110`n"
        . "Raid_Entry|key|w|141`n"
        . "Raid_Entry|key|s|78`n"
        . "Raid_Entry|key|s|47`n"
        . "Raid_Entry|key|Enter|78`n"
        . "Raid_Entry|key|RShift|47`n"
        . "Raid_Entry|key|f|110`n"
        . "Raid_Entry|key|s|78`n"
        . "Raid_Entry|key|s|94`n"
        . "Raid_Entry|key|s|109`n"
        . "Raid_Entry|key|s|110`n"
        . "Raid_Entry|key|s|125`n"
        . "Raid_Entry|key|s|110`n"
        . "Raid_Entry|key|s|94`n"
        . "Raid_Entry|key|s|78`n"
        . "Raid_Entry|key|\|110`n"
        . "Raid_Entry|key|f|141`n"
        . "Raid_Entry|key|\|110`n"
        . "Raid_Entry|key|\|94`n"
        . "Raid_Entry|key|d|2297`n"
        . "Raid_Entry|key|w|1579`n"
        . "Raid_Entry|key|d|984`n`n"

    raidMaps := Map(
        "NamexPlanet",      "Raid_NamexPlanet",
        "ColosseumKingdom", "Raid_ColosseumKingdom",
        "DemonForest",      "Raid_DemonForest",
        "DungeonTown",      "Raid_DungeonTown",
        "ReaperSociety",    "Raid_ReaperSociety"
    )
    for fname, key in raidMaps {
        p := FolderRaids "\" fname ".txt"
        if (!FileExist(p)) {
            txt := hdr . "; === Raid: " fname " ===`n"
                . "; Raid_Entry runs automatically before this slot`n`n"
                . raidEntry
                . "; " key " — record your map sequence in the editor`n"
                . key "|trigger|—`n"
            FileAppend(txt, p, "UTF-8")
        }
    }

    ; ── Summon/DungeonTown.txt ────────────────────────────────
    p := FolderSummon "\DungeonTown.txt"
    if (!FileExist(p)) {
        txt := hdr . "; === Summon: Dungeon Town ===`n"
        . "Summon_DungeonTown|trigger|—`n"
        . "Summon_DungeonTown|click|1404|579|80`n"
        . "Summon_DungeonTown|click|1404|556|80`n"
        . "Summon_DungeonTown|key|f|94`n"
        . "Summon_DungeonTown|click|1276|582|80`n"
        . "Summon_DungeonTown|sleep|150`n"
        . "Summon_DungeonTown|click|1276|582|80`n"
        . "Summon_DungeonTown|sleep|150`n"
        . "Summon_DungeonTown|click|1276|582|80`n"
        . "Summon_DungeonTown|sleep|2000`n"
        . "Summon_DungeonTown|key|w|453`n"
        . "Summon_DungeonTown|key|d|937`n"
        . "Summon_DungeonTown|key|w|313`n"
        . "Summon_DungeonTown|key|r|172`n"
        FileAppend(txt, p, "UTF-8")
    }


    ; ── Summon/ReaperSociety.txt ──────────────────────────────────
    p := FolderSummon "\ReaperSociety.txt"
    if (!FileExist(p)) {
        txt := hdr . "; === Summon: Reaper Society ===`n"
        . "Summon_ReaperSociety|trigger|—`n"
        . "Summon_ReaperSociety|click|-112|77|78`n"
        . "Summon_ReaperSociety|click|1407|543|78`n"
        . "Summon_ReaperSociety|key|f|78`n"
        . "Summon_ReaperSociety|key|\|78`n"
        . "Summon_ReaperSociety|key|d|94`n"
        . "Summon_ReaperSociety|key|s|94`n"
        . "Summon_ReaperSociety|key|a|93`n"
        . "Summon_ReaperSociety|key|w|63`n"
        . "Summon_ReaperSociety|key|s|62`n"
        . "Summon_ReaperSociety|key|s|78`n"
        . "Summon_ReaperSociety|key|s|93`n"
        . "Summon_ReaperSociety|key|s|94`n"
        . "Summon_ReaperSociety|key|\|78`n"
        . "Summon_ReaperSociety|click|1309|573|78`n"
        . "Summon_ReaperSociety|key|s|860`n"
        . "Summon_ReaperSociety|key|d|547`n"
        . "Summon_ReaperSociety|key|w|359`n"
        . "Summon_ReaperSociety|key|r|141`n"
        . "Summon_ReaperSociety|key|\|109`n"
        . "Summon_ReaperSociety|key|f|125`n"
        . "Summon_ReaperSociety|key|s|78`n"
        . "Summon_ReaperSociety|key|d|110`n"
        . "Summon_ReaperSociety|key|w|93`n"
        . "Summon_ReaperSociety|key|s|79`n"
        . "Summon_ReaperSociety|key|a|47`n"
        . "Summon_ReaperSociety|key|s|78`n"
        . "Summon_ReaperSociety|key|d|109`n"
        . "Summon_ReaperSociety|key|s|63`n"
        . "Summon_ReaperSociety|key|s|78`n"
        . "Summon_ReaperSociety|key|s|63`n"
        . "Summon_ReaperSociety|key|w|78`n"
        . "Summon_ReaperSociety|key|w|78`n"
        . "Summon_ReaperSociety|key|d|78`n"
        . "Summon_ReaperSociety|key|w|47`n"
        . "Summon_ReaperSociety|key|s|62`n"
        . "Summon_ReaperSociety|key|s|63`n"
        . "Summon_ReaperSociety|key|\|94`n"
        . "Summon_ReaperSociety|key|f|94`n"
        . "Summon_ReaperSociety|key|\|94`n"
        . "Summon_ReaperSociety|key|\|93`n"
        FileAppend(txt, p, "UTF-8")
    }
}

LoadMovementFile(path) {
    ; Loads a single movement txt file into CustomSeqs + SlotTriggers
    ; Always clears existing keys from this file first to prevent step stacking
    global CustomSeqs, SlotTriggers
    if (!FileExist(path))
        return false

    ; First pass — collect all slot keys in this file so we can clear them
    keysInFile := Map()
    loop read path {
        line := Trim(A_LoopReadLine)
        if (line == "" || SubStr(line, 1, 1) == ";")
            continue
        parts := StrSplit(line, "|")
        if (parts.Length < 3)
            continue
        keysInFile[parts[1]] := true
    }
    ; Clear steps only — preserve any trigger overrides already loaded from Sequences.txt
    for k in keysInFile {
        CustomSeqs[k] := []
        ; Do NOT delete SlotTriggers here — Sequences.txt overrides take priority
    }

    ; Second pass — load fresh
    for line in StrSplit(FileRead(path), "`n", "`r") {
        line := Trim(line)
        if (line == "" || SubStr(line, 1, 1) == ";")
            continue
        parts := StrSplit(line, "|")
        if (parts.Length < 3)
            continue
        seqName := parts[1]
        t       := parts[2]
        if (t == "trigger") {
            SlotTriggers[seqName] := parts[3]
            continue
        }
        ; Auto-register slot into the correct GM array using full key name
        if (t == "key" || t == "click" || t == "sleep" || t == "triggerpoint") {
            gmArr     := GetGMSlotsForKey(seqName)
            alreadyIn := false
            for s in gmArr {
                if (s["key"] == seqName) {
                    alreadyIn := true
                    break
                }
            }
            if (!alreadyIn) {
                lbl := RegExReplace(seqName, "^[A-Za-z]+_", "")
                lbl := RegExReplace(lbl, "([A-Z])", " $1")
                lbl := Trim(lbl)
                if (lbl == "")
                    lbl := seqName
                gmArr.Push(Map("key", seqName, "label", lbl, "trigger", "—"))
            }
        }
        if (!CustomSeqs.Has(seqName))
            CustomSeqs[seqName] := []
        step := Map("type", t)
        if (t == "key") {
            step["key"] := parts[3]
            step["dur"] := Integer(parts[4])
        } else if (t == "click") {
            step["x"]   := Integer(parts[3])
            step["y"]   := Integer(parts[4])
            step["dur"] := (parts.Length >= 5) ? Integer(parts[5]) : 80
        } else if (t == "sleep") {
            step["dur"] := Integer(parts[3])
        } else if (t == "triggerpoint") {
            step["count"] := Integer(parts[3])
        }
        CustomSeqs[seqName].Push(step)
    }
    return true
}

LoadAllMovementFiles() {
    global FolderCustom, FolderRaids, FolderSummon, MovementFiles
    global CustomSeqs, SlotTriggers, RaidType

    ; Expected files — warn if missing
    expectedCustom := ["DoubleDungeon.txt", "AbandonVillage.txt", "Rift.txt"]
    expectedRaids  := ["NamexPlanet.txt", "ColosseumKingdom.txt", "DemonForest.txt", "DungeonTown.txt", "ReaperSociety.txt"]
    expectedSummon := ["DungeonTown.txt", "ReaperSociety.txt"]

    missing := []

    ; Load Custom folder
    for fname in expectedCustom {
        path := FolderCustom "\" fname
        if LoadMovementFile(path) {
            MovementFiles[fname] := path
        } else {
            missing.Push("Custom" fname)
        }
    }

    ; Load Raids folder
    for fname in expectedRaids {
        path := FolderRaids "\" fname
        if LoadMovementFile(path) {
            MovementFiles[fname] := path
        } else {
            missing.Push("Raids" fname)
        }
    }

    ; Load Summon folder
    for fname in expectedSummon {
        path := FolderSummon "\" fname
        if LoadMovementFile(path) {
            MovementFiles[fname] := path
        } else {
            missing.Push("Summon" fname)
        }
    }

    ; Warn about missing files
    if (missing.Length > 0) {
        warnMsg := "⚠ Missing movement files:`n"
        for f in missing
            warnMsg .= "  • " f "`n"
        warnMsg .= "`nThose gamemodes will use fallback (no movement).`nPlace files next to the macro and restart."
        MsgBox(warnMsg, "DenniXD ATS — Missing Files", "Icon! T10")
    }
}

; Reload a single folder on demand (called from Settings)
ReloadMovementFolder(folder) {
    global FolderCustom, FolderRaids, FolderSummon, CustomSeqs, SlotTriggers, MovementFiles
    loop files folder "\*.txt" {
        LoadMovementFile(A_LoopFileFullPath)
        MovementFiles[A_LoopFileName] := A_LoopFileFullPath
    }
    ; Re-apply trigger overrides from Sequences.txt so user config is not lost
    LoadSequences()
    GuiStatus.Text := "✔ Reloaded: " folder
}

LoadSequences() {
    global CustomSeqs, SeqFile, SlotTriggers, FolderCustom, FolderRaids, FolderSummon
    ; Note: CustomSeqs is NOT reset here — folder txt files are the source of truth for steps.
    ; We only reset SlotTriggers so Sequences.txt trigger overrides are re-applied cleanly.
    SlotTriggers := Map()
    if (!IsObject(CustomSeqs))
        CustomSeqs := Map()

    ; ── Scan all folder txt files first (Custom, Raids, Summon) ──
    filesToLoad := []
    for folder in [FolderCustom, FolderRaids, FolderSummon] {
        loop files folder "\*.txt" {
            filesToLoad.Push(A_LoopFileFullPath)
        }
    }
    ; Also load Sequences.txt on top (user overrides)
    if FileExist(SeqFile)
        filesToLoad.Push(SeqFile)

    for filePath in filesToLoad {
        if (!FileExist(filePath))
            continue
        for line in StrSplit(FileRead(filePath), "`n", "`r") {
        line := Trim(line)
        if (line == "" || SubStr(line, 1, 1) == ";")
            continue
        parts := StrSplit(line, "|")
        if (parts.Length < 3)
            continue
        seqName := parts[1]
        t       := parts[2]
        if (t == "trigger") {
            SlotTriggers[seqName] := parts[3]
            continue
        }
        if (t == "slotdef") {
            slotLabel := parts[3]
            gmKey     := (parts.Length >= 4) ? parts[4] : "Custom"
            gmArr     := GetGMSlots(gmKey)
            alreadyIn := false
            for s in gmArr {
                if (s["key"] == seqName) {
                    alreadyIn := true
                    break
                }
            }
            if (!alreadyIn)
                gmArr.Push(Map("key", seqName, "label", slotLabel, "trigger", "—"))
            continue
        }
        ; Auto-register slot into the correct GM array using full key name
        if (t == "key" || t == "click" || t == "sleep" || t == "triggerpoint") {
            gmArr     := GetGMSlotsForKey(seqName)
            alreadyIn := false
            for s in gmArr {
                if (s["key"] == seqName) {
                    alreadyIn := true
                    break
                }
            }
            if (!alreadyIn) {
                lbl := RegExReplace(seqName, "^[A-Za-z]+_", "")
                lbl := RegExReplace(lbl, "([A-Z])", " $1")
                lbl := Trim(lbl)
                if (lbl == "")
                    lbl := seqName
                gmArr.Push(Map("key", seqName, "label", lbl, "trigger", "—"))
            }
        }
        ; Load step into CustomSeqs (all keys, no skipping)
        if (!CustomSeqs.Has(seqName))
            CustomSeqs[seqName] := []
        step := Map("type", t)
        if (t == "key") {
            step["key"] := parts[3]
            step["dur"] := Integer(parts[4])
        } else if (t == "click") {
            step["x"]   := Integer(parts[3])
            step["y"]   := Integer(parts[4])
            step["dur"] := (parts.Length >= 5) ? Integer(parts[5]) : 80
        } else if (t == "sleep") {
            step["dur"] := Integer(parts[3])
        } else if (t == "triggerpoint") {
            step["count"] := Integer(parts[3])
        }
        CustomSeqs[seqName].Push(step)
        } ; end for line
    } ; end for filePath
}

SaveSequences() {
    global CustomSeqs, SeqFile, SlotTriggers, GM_DD, GM_AV, GM_Rift, GM_Summon, GM_Custom
    global GM_Raid_NamexPlanet, GM_Raid_ColosseumKingdom, GM_Raid_DemonForest, GM_Raid_DungeonTown, GM_Raid_ReaperSociety
    out := ""
    ; Save slot definitions for dynamically added slots (non-hardcoded)
    hardcoded := Map(
        "DD_EnterRaid",1,"DD_Step1",1,"DD_Step2",1,"DD_Step3",1,"DD_Step4",1,
        "DD_Step5",1,"DD_Step6",1,"DD_Step7",1,"DD_Step8",1,"DD_Step9",1,"DD_Step10",1,
        "AV_Entry",1,"AV_Step1",1,"Rift_Entry",1,"Rift_Custom",1,
        "Raid_NamexPlanet",1,"Raid_ColosseumKingdom",1,"Raid_DemonForest",1,
        "Raid_DungeonTown",1,"Raid_ReaperSociety",1,
        "Summon_DungeonTown",1,"Summon_ReaperSociety",1,"Summon_SoulSociety",1,
        "Custom_Movement",1
    )
    allGMs := Map("DD",GM_DD,"AV",GM_AV,"Rift",GM_Rift,"Summon",GM_Summon,"Custom",GM_Custom)
    for gmKey, gmSlots in allGMs {
        for slot in gmSlots {
            if (!hardcoded.Has(slot["key"]))
                out .= slot["key"] "|slotdef|" slot["label"] "|" gmKey "`n"
        }
    }
    ; Save trigger overrides
    for seqKey, trigger in SlotTriggers
        out .= seqKey "|trigger|" trigger "`n"
    ; Save steps — only for sequences NOT owned by a dedicated folder txt file
    ; DD_*, AV_*, Rift_*, Raid_*, Summon_* all live in their own txt files — skip them here
    ; to prevent double-loading when LoadSequences() reads both the folder file and Sequences.txt
    folderOwned := Map(
        "DD_",1, "AV_",1, "Rift_",1, "Raid_",1, "Summon_",1
    )
    for seqName, steps in CustomSeqs {
        isOwned := false
        for prefix in ["DD_","AV_","Rift_","Raid_","Summon_"] {
            if (SubStr(seqName, 1, StrLen(prefix)) == prefix) {
                isOwned := true
                break
            }
        }
        if (isOwned)
            continue
        for step in steps {
            t := step["type"]
            if (t == "key")
                out .= seqName "|key|" step["key"] "|" step["dur"] "`n"
            if (t == "click") {
                dur := step.Has("dur") ? step["dur"] : 80
                out .= seqName "|click|" step["x"] "|" step["y"] "|" dur "`n"
            }
            if (t == "sleep")
                out .= seqName "|sleep|" step["dur"] "`n"
            if (t == "triggerpoint")
                out .= seqName "|triggerpoint|" step["count"] "`n"
        }
    }
    try {
        FileDelete(SeqFile)
        FileAppend(out, SeqFile, "UTF-8")
    }
}

; ── Core rejoin: only re-opens PS link every 1hr, always runs ResetTravelUI inline ──
RejoinPS() {
    global PrivateServer, RobloxTitle, LastRejoinTime, Running, TextLoaded, ModeSummoning

    OneHour       := 3600000
    NeedsPSLaunch := AutoRejoinEnabled && (LastRejoinTime == 0 || (A_TickCount - LastRejoinTime >= OneHour))

    if (!NeedsPSLaunch) {
        Remaining := Round((OneHour - (A_TickCount - LastRejoinTime)) / 60000)
        GuiStatus.Text := "Skipping PS rejoin (" . Remaining . "m until next)"
        Sleep(1000)
    } else {
        ; 1. Kill existing Roblox
        GuiStatus.Text := "Closing Roblox..."
        for proc in ["RobloxPlayerBeta.exe", "RobloxPlayer.exe", "Roblox.exe"] {
            if ProcessExist(proc) {
                ProcessClose(proc)
                Sleep(500)
            }
        }
        Sleep(2000)

        ; 2. Always re-read PS link fresh from INI so changes take effect immediately
        PrivateServer := IniRead(IniFile, "Settings", "PSLink", "")
        if (EditPS.Value != PrivateServer)
            EditPS.Value := PrivateServer  ; sync UI field too

        GuiStatus.Text := "Launching private server..."
        if (PrivateServer == "") {
            GuiStatus.Text := "⚠ No PS link set — please add one in Settings"
            MacroLock := false
            SetTimer(MainLoop, 150)
            return
        }

        ; Resolve ro.blox.com shortlinks to proper roblox:// protocol before launching
        GuiStatus.Text := "Launching PS link..."

        launched := false
        Loop 3 {
            try {
                Run(PrivateServer)
                launched := true
                break
            } catch {
                GuiStatus.Text := "Launch attempt " . A_Index . " failed, retrying..."
                Sleep(2000)
            }
        }

        if (!launched) {
            GuiStatus.Text := "⚠ Failed to launch PS link after 3 attempts — check your link in Settings"
            MacroLock := false
            SetTimer(MainLoop, 150)
            return
        }
        LastRejoinTime := A_TickCount
        Sleep(5000)

        ; 3. Loop until Roblox window exists — retry with full relaunch if it never appears
        GuiStatus.Text := "Waiting for Roblox..."
        robloxWaitAttempt := 0
        robloxFound := false
        Loop {
            if (!Running)
                return
            reconnectDeadline := A_TickCount + 120000  ; 2 min per attempt
            Loop {
                if (!Running)
                    return
                if (A_TickCount > reconnectDeadline)
                    break
                SafeClick(490, 400)
                Sleep(5000)
                if WinExist(RobloxTitle) {
                    WinActivate(RobloxTitle)
                    Sleep(2000)
                    ; Close browser now that Roblox is detected
                    GuiStatus.Text := "Roblox detected — closing browser..."
                    for browserExe in ["ahk_exe chrome.exe", "ahk_exe firefox.exe", "ahk_exe msedge.exe", "ahk_exe opera.exe", "ahk_exe brave.exe"] {
                        if WinExist(browserExe) {
                            WinActivate(browserExe)
                            WinWaitActive(browserExe, , 2)
                            Send("^w")
                            Sleep(600)
                            if WinExist(browserExe) {
                                WinClose(browserExe)
                                Sleep(600)
                            }
                            if WinExist(browserExe) {
                                WinActivate(browserExe)
                                WinWaitActive(browserExe, , 2)
                                Send("!{F4}")
                                Sleep(400)
                            }
                            break
                        }
                    }
                    if WinExist(RobloxTitle) {
                        WinActivate(RobloxTitle)
                        WinWaitActive(RobloxTitle, , 3)
                    }
                    Sleep(500)
                    robloxFound := true
                    break
                }
            }
            if (robloxFound)
                break
            ; Roblox still not found — kill and relaunch
            robloxWaitAttempt += 1
            GuiStatus.Text := "Roblox not detected — killing and relaunching (attempt " robloxWaitAttempt ")..."
            for proc in ["RobloxPlayerBeta.exe", "RobloxPlayer.exe", "Roblox.exe"] {
                if ProcessExist(proc) {
                    ProcessClose(proc)
                    Sleep(500)
                }
            }
            Sleep(3000)
            PrivateServer := IniRead(IniFile, "Settings", "PSLink", PrivateServer)
            try {
                Run(PrivateServer)
            } catch {
                Sleep(2000)
                Run(PrivateServer)
            }
            Sleep(5000)
        }
    }

    ; 4. Wait for TextLoaded — confirms fully in game
    ; If load fails, kill Roblox and relaunch fully
    loadAttempt := 0
    loadSuccess := false
    Loop {
        if (!Running)
            return
        if (!WinExist(RobloxTitle)) {
            GuiStatus.Text := "Roblox not found before load check — relaunching..."
        } else {
            WinActivate(RobloxTitle)
            WinWaitActive(RobloxTitle, , 5)
            GuiStatus.Text := "Waiting for game to load... (attempt " (loadAttempt + 1) ")"
            loadDeadline := A_TickCount + 90000  ; 90s to load
            gameLoaded   := false
            Loop {
                if (!Running)
                    return
                if (A_TickCount > loadDeadline)
                    break
                try {
                    if GetFindText().FindText(&fx, &fy, 18, 526, 116, 616, 0, 0, TextLoaded) {
                        gameLoaded := true
                        GuiStatus.Text := "Game loaded — waiting 5s..."
                        break
                    }
                }
                Sleep(500)
            }
            if (gameLoaded) {
                loadSuccess := true
                break
            }
        }
        ; Load failed — kill Roblox and relaunch
        loadAttempt += 1
        GuiStatus.Text := "Load failed — killing Roblox and relaunching (attempt " loadAttempt ")..."
        for proc in ["RobloxPlayerBeta.exe", "RobloxPlayer.exe", "Roblox.exe"] {
            if ProcessExist(proc) {
                ProcessClose(proc)
                Sleep(500)
            }
        }
        Sleep(3000)
        PrivateServer := IniRead(IniFile, "Settings", "PSLink", PrivateServer)
        try {
            Run(PrivateServer)
        } catch {
            Sleep(2000)
            Run(PrivateServer)
        }
        ; Wait for Roblox window after relaunch
        Sleep(5000)
        recheckDeadline := A_TickCount + 120000
        Loop {
            if (!Running)
                return
            SafeClick(490, 400)
            Sleep(5000)
            if WinExist(RobloxTitle) {
                WinActivate(RobloxTitle)
                Sleep(2000)
                break
            }
            if (A_TickCount > recheckDeadline)
                break
        }
    }

    ; 5. Game loaded — directly start the correct gamemode
    if (loadSuccess) {
        Sleep(5000)
        if (WinExist(RobloxTitle)) {
            WinActivate(RobloxTitle)
            WinWaitActive(RobloxTitle, , 5)
            UpdateSearchArea()
        }
        LastRejoinTime := A_TickCount
        GuiStatus.Text := "Rejoin complete — starting gamemode..."
        Sleep(1000)
        if (ModeRift)
            RunRift()
        else if (ModeDoubleDungeon)
            RunDoubleDungeon()
        else
            RunDemonSlayer()
    }


    ; 6. Run summon after rejoin if enabled
    if (ModeSummoning)
        RunSummon()
}

; ══════════════════════════════════════════════════════════════════
;   SEQUENCE EDITOR
; ══════════════════════════════════════════════════════════════════

; ══════════════════════════════════════════════════════════════════
;   SEQUENCE EDITOR — Gamemode-based with enemy-count slots
; ══════════════════════════════════════════════════════════════════
global EditorGui       := ""
global EditorOpen      := false
; EditorRecording declared below at editor init
global EditorSteps     := []
global EditorRecording := false
global EditorGamemode  := "DD"
global EditorSlotKey   := "DD_EnterRaid"
global EditorLV        := ""
global EditorSlotLV    := ""
global EditorAppendMode  := false  ; true = append to existing steps, false = replace
global CustomFileName    := ""      ; name entered by user for saving custom gamemode file
global EditorSlotIdx     := 1       ; currently selected slot index
global TriggerOptions    := ["— (manual/always)", "0 enemies", "1 enemy", "2 enemies", "3 enemies", "4 enemies", "5 enemies", "6 enemies", "7 enemies", "8 enemies", "9 enemies", "10 enemies", "11 enemies", "12 enemies", "13 enemies", "14 enemies", "15 enemies", "16 enemies", "17 enemies", "18 enemies", "19 enemies", "20 enemies", "21 enemies", "22 enemies", "23 enemies", "24 enemies", "25 enemies", "26 enemies", "27 enemies", "28 enemies", "29 enemies", "30 enemies", "31 enemies", "32 enemies", "33 enemies", "34 enemies", "35 enemies", "After entry"]

; Gamemode slot definitions: key -> {label, trigger}
