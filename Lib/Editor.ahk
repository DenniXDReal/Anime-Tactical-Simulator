GetGMSlots(gm) {
    global GM_DD, GM_AV, GM_Rift, GM_Custom, GM_Summon
    global GM_Raid_NamexPlanet, GM_Raid_ColosseumKingdom, GM_Raid_DemonForest
    global GM_Raid_DungeonTown, GM_Raid_ReaperSociety
    if (gm == "DD")
        return GM_DD
    if (gm == "AV")
        return GM_AV
    if (gm == "Rift")
        return GM_Rift
    if (gm == "Raid_NamexPlanet")
        return GM_Raid_NamexPlanet
    if (gm == "Raid_ColosseumKingdom")
        return GM_Raid_ColosseumKingdom
    if (gm == "Raid_DemonForest")
        return GM_Raid_DemonForest
    if (gm == "Raid_DungeonTown")
        return GM_Raid_DungeonTown
    if (gm == "Raid_ReaperSociety")
        return GM_Raid_ReaperSociety
    if (gm == "Summon")
        return GM_Summon
    return GM_Custom
}

; Resolves the correct GM slot array directly from a full slot key name.
; e.g. "Raid_DungeonTown" -> GM_Raid_DungeonTown, "Summon_ReaperSociety" -> GM_Summon
; Used by LoadMovementFile and LoadSequences so Raid/Summon slots register correctly.
GetGMSlotsForKey(seqName) {
    global GM_DD, GM_AV, GM_Rift, GM_Custom, GM_Summon
    global GM_Raid_NamexPlanet, GM_Raid_ColosseumKingdom, GM_Raid_DemonForest
    global GM_Raid_DungeonTown, GM_Raid_ReaperSociety
    if (SubStr(seqName, 1, 3) == "DD_")
        return GM_DD
    if (SubStr(seqName, 1, 3) == "AV_")
        return GM_AV
    if (SubStr(seqName, 1, 5) == "Rift_")
        return GM_Rift
    if (SubStr(seqName, 1, 7) == "Custom_")
        return GM_Custom
    if (SubStr(seqName, 1, 7) == "Summon_")
        return GM_Summon
    if (SubStr(seqName, 1, 5) == "Raid_") {
        if InStr(seqName, "NamexPlanet")
            return GM_Raid_NamexPlanet
        if InStr(seqName, "ColosseumKingdom")
            return GM_Raid_ColosseumKingdom
        if InStr(seqName, "DemonForest")
            return GM_Raid_DemonForest
        if InStr(seqName, "DungeonTown")
            return GM_Raid_DungeonTown
        if InStr(seqName, "ReaperSociety")
            return GM_Raid_ReaperSociety
        return GM_Raid_NamexPlanet  ; fallback for Raid_Entry
    }
    return GM_Custom
}

OpenSequenceEditor() {
    global EditorGui, EditorOpen, EditorGamemode, EditorSlotKey, EditorLV, EditorSlotLV

    if (EditorOpen) {
        EditorGui.Show()
        return
    }

    EditorGamemode := "DD"
    EditorSlotKey  := "DD_EnterRaid"

    EditorGui := Gui("+AlwaysOnTop -MaximizeBox", "Gamemode Editor — DenniXD ATS V3.0.0")
    EditorGui.BackColor := "111111"
    EditorGui.OnEvent("Close", (*) => CloseSequenceEditor())

    ; ══ HEADER ══════════════════════════════════════════════════════
    EditorGui.SetFont("s12 c7B2FFF Bold", "Segoe UI")
    EditorGui.AddText("x16 y12 w480", "🎮  GAMEMODE EDITOR")
    EditorGui.SetFont("s8 c555555 Norm", "Segoe UI")
    global BtnEdHelp := EditorGui.AddButton("x636 y10 w84 h26 Background1A1A2A", "❓ HOW TO USE")
    BtnEdHelp.Opt("cAAAAFF")
    BtnEdHelp.OnEvent("Click", (*) => ShowEditorHelp())

    ; ══ STATUS BAR (large, prominent) ════════════════════════════════
    EditorGui.SetFont("s9 Bold", "Segoe UI")
    global LblEditorStatus := EditorGui.AddText("x16 y42 w704 h24 Background0D0D0D", "  ● STEP 1 — Choose a gamemode below, then pick a slot on the left")
    LblEditorStatus.Opt("c00FF99")

    ; ══ STEP 1 — GAMEMODE SELECTOR ═══════════════════════════════════
    EditorGui.SetFont("s8 cFFAA00 Bold", "Segoe UI")
    EditorGui.AddText("x16 y78 w30", "① ")
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x34 y78 w120", "PICK GAMEMODE:")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global DdlEditorGM := EditorGui.AddDropDownList("x160 y75 w200", ["Double Dungeon","Abandon Village","Rift","Namex Planet (Raid)","Colosseum Kingdom (Raid)","Demon Forest (Raid)","Dungeon Town (Raid)","Reaper Society (Raid)","Summon","Custom"])
    DdlEditorGM.Value := 1
    DdlEditorGM.OnEvent("Change", OnEditorGMChange)
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x370 y80 w360", "← Each gamemode has slots — each slot is one phase of movement")

    ; ══ MAIN LAYOUT — LEFT (slots) + RIGHT (steps) ═══════════════════
    ; ── LEFT PANEL ──
    EditorGui.SetFont("s8 cFFAA00 Bold", "Segoe UI")
    EditorGui.AddText("x16 y106 w20", "②")
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x34 y106 w160", "PICK A SLOT TO EDIT:")
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x16 y120 w196", "A slot = one movement phase (e.g. entry, wave 1...)")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditorSlotLV := EditorGui.AddListView("x16 y136 w196 h200 Background1A1A1A cFFFFFF -LV0x10 -Multi", ["Slot","Trigger"])
    EditorSlotLV.ModifyCol(1, 108)
    EditorSlotLV.ModifyCol(2, 80)
    EditorSlotLV.OnEvent("Click", OnSlotSelect)

    ; Slot add/delete
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x16 y340 w196", "Custom slots only — built-in slots can't be deleted:")
    EditorGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
    global EditNewSlotName := EditorGui.AddEdit("x16 y356 w120 h24 Background1A1A1A", "SlotName")
    EditorGui.SetFont("s7 c0D0D0D Bold", "Segoe UI")
    global BtnAddSlot := EditorGui.AddButton("x140 y355 w72 h26 Background00AA44", "➕ ADD")
    BtnAddSlot.OnEvent("Click", (*) => AddCustomSlot())
    global BtnDelSlot := EditorGui.AddButton("x16 y385 w196 h24 Background662222", "🗑 DELETE SELECTED SLOT")
    BtnDelSlot.Opt("cFFFFFF")
    BtnDelSlot.OnEvent("Click", (*) => DeleteCustomSlot())

    ; Slot trigger
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x16 y418 w196", "SLOT TRIGGER:")
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x16 y432 w196", "When should this slot's steps run?")
    EditorGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
    global DdlTrigger := EditorGui.AddDropDownList("x16 y448 w196", ["— (manual/always)", "0 enemies", "1 enemy", "2 enemies", "3 enemies", "4 enemies", "5 enemies", "6 enemies", "7 enemies", "8 enemies", "9 enemies", "10 enemies", "11 enemies", "12 enemies", "13 enemies", "14 enemies", "15 enemies", "16 enemies", "17 enemies", "18 enemies", "19 enemies", "20 enemies", "21 enemies", "22 enemies", "23 enemies", "24 enemies", "25 enemies", "26 enemies", "27 enemies", "28 enemies", "29 enemies", "30 enemies", "31 enemies", "32 enemies", "33 enemies", "34 enemies", "35 enemies", "After entry"])
    DdlTrigger.Value := 1
    DdlTrigger.OnEvent("Change", OnTriggerChange)

    ; ── RIGHT PANEL ──
    EditorGui.SetFont("s8 cFFAA00 Bold", "Segoe UI")
    EditorGui.AddText("x224 y106 w20", "③")
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x242 y106 w480", "RECORD OR EDIT STEPS:")
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x224 y120 w496", "Steps = keypresses your character makes. Click RECORD, play ingame, click STOP.")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditorLV := EditorGui.AddListView("x224 y136 w496 h310 Background1A1A1A cFFFFFF -LV0x10", ["#","Type","Key / Coords","ms"])
    EditorLV.ModifyCol(1, 32)
    EditorLV.ModifyCol(2, 58)
    EditorLV.ModifyCol(3, 230)
    EditorLV.ModifyCol(4, 64)
    EditorLV.OnEvent("ItemFocus", OnStepFocus)

    ; ── Record controls row ──
    EditorGui.SetFont("s8 cFFAA00 Bold", "Segoe UI")
    EditorGui.AddText("x224 y454 w20", "④")
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x242 y454 w480", "RECORD CONTROLS:")
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    global BtnEdRecord := EditorGui.AddButton("x224 y470 w150 h32 Background00CC66", "⏺ RECORD  F8")
    BtnEdRecord.OnEvent("Click", (*) => StartEditorRecording(false))
    global BtnEdAppend := EditorGui.AddButton("x382 y470 w148 h32 Background1A4A1A", "➕ APPEND  F7")
    BtnEdAppend.Opt("cFFFFFF")
    BtnEdAppend.OnEvent("Click", (*) => StartEditorRecording(true))
    global BtnEdStop := EditorGui.AddButton("x538 y470 w100 h32 BackgroundFF3355", "⏹ STOP  F9")
    BtnEdStop.OnEvent("Click", (*) => StopEditorRecording())
    global BtnEdPlay := EditorGui.AddButton("x646 y470 w74 h32 Background1A2A4A", "▶ PLAY")
    BtnEdPlay.Opt("cFFFFFF")
    BtnEdPlay.OnEvent("Click", (*) => PlayEditorSteps())
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x224 y506 w496", "RECORD = clears existing steps and records fresh  ·  APPEND = adds to end  ·  STOP = stop recording")

    ; ── Step edit row ──
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x224 y524 w496", "EDIT STEPS:")
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    global BtnEdMoveUp := EditorGui.AddButton("x224 y540 w110 h28 Background2A2A2A", "▲ MOVE UP")
    BtnEdMoveUp.Opt("cFFFFFF")
    BtnEdMoveUp.OnEvent("Click", (*) => MoveStep(-1))
    global BtnEdMoveDn := EditorGui.AddButton("x342 y540 w110 h28 Background2A2A2A", "▼ MOVE DOWN")
    BtnEdMoveDn.Opt("cFFFFFF")
    BtnEdMoveDn.OnEvent("Click", (*) => MoveStep(1))
    global BtnEdAddStep := EditorGui.AddButton("x460 y540 w90 h28 Background1A3A4A", "➕ ADD STEP")
    BtnEdAddStep.Opt("cFFFFFF")
    BtnEdAddStep.OnEvent("Click", (*) => AddStepManual())
    global BtnEdDelRow := EditorGui.AddButton("x558 y540 w80 h28 Background662222", "🗑 DELETE")
    BtnEdDelRow.Opt("cFFFFFF")
    BtnEdDelRow.OnEvent("Click", (*) => DeleteSelectedStep())
    global BtnEdClear := EditorGui.AddButton("x646 y540 w74 h28 Background3A1A1A", "✖ CLEAR")
    BtnEdClear.Opt("cFFFFFF")
    BtnEdClear.OnEvent("Click", (*) => ClearEditorSteps())

    ; ══ STEP 5 — SAVE ════════════════════════════════════════════════
    EditorGui.SetFont("s8 cFFAA00 Bold", "Segoe UI")
    EditorGui.AddText("x16 y578 w20", "⑤")
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    global BtnEdSave := EditorGui.AddButton("x36 y574 w684 h34 Background7B2FFF", "💾  SAVE SLOT SEQUENCE  (saves to memory — macro will use these steps)")
    BtnEdSave.Opt("cFFFFFF")
    BtnEdSave.OnEvent("Click", (*) => SaveEditorSequence())

    ; ── Save as custom file (Custom/Rift/DD only) ──
    EditorGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
    global LblSaveFile := EditorGui.AddText("x16 y622 w704 Hidden", "── SAVE AS FILE  (exports this macro so others can import it) ───────────────────────────────────────────")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditFileName := EditorGui.AddEdit("x16 y640 w520 h28 Background1A1A1A Hidden", "MyCustomMacro")
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x532 y645 w30 Hidden", ".txt")
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    global BtnSaveFile := EditorGui.AddButton("x566 y638 w154 h32 Background00AA44 Hidden", "💾 SAVE AS FILE")
    BtnSaveFile.Opt("cFFFFFF")
    BtnSaveFile.OnEvent("Click", (*) => SaveCustomMacroFile())

    EditorGui.Show("w740 h690")
    EditorOpen := true

    RefreshSlotLV()
    SelectSlot(1)
}

CloseSequenceEditor() {
    global EditorOpen, EditorRecording
    EditorOpen      := false
    EditorRecording := false
}

ShowEditorHelp() {
    HelpGui := Gui("+AlwaysOnTop", "How To Use The Editor")
    HelpGui.BackColor := "0D0D0D"
    HelpGui.SetFont("s11 c7B2FFF Bold", "Segoe UI")
    HelpGui.AddText("x16 y12 w560", "🎮  HOW TO MAKE A CUSTOM MACRO")
    HelpGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    HelpGui.AddText("x16 y38 w560", "Follow these 5 steps every time:")
    HelpGui.SetFont("s8 c555555 Norm", "Segoe UI")
    HelpGui.AddText("x16 y56 w560", "────────────────────────────────────────────────────────────────")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y70 w560", "① Pick a Gamemode")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y88 w560", "Choose which gamemode you want to customise from the dropdown at the top.")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y110 w560", "② Pick a Slot")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y128 w560", "A slot is a phase of movement. E.g. 'Entry' = how you enter the dungeon,")
    HelpGui.AddText("x16 y144 w560", "'Step1' = what you do during wave 1. Click the slot name on the left.")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y166 w560", "③ Record Your Steps")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y184 w560", "Click RECORD (or press F8), then switch to Roblox and press your movement keys.")
    HelpGui.AddText("x16 y200 w560", "Every key you hold will be timed. Press Q to add a 500ms pause. Click STOP (F9) when done.")
    HelpGui.SetFont("s8 c888888 Norm", "Segoe UI")
    HelpGui.AddText("x16 y216 w560", "Recordable keys: W A S D  Space  Q(pause)  Left click  — avoid F1/F2/F3/F4")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y238 w560", "④ Review & Reorder")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y256 w560", "Check the steps list on the right. Select a row and use MOVE UP / MOVE DOWN")
    HelpGui.AddText("x16 y272 w560", "to reorder. Use DELETE to remove a bad step. PLAY to test it ingame.")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y294 w560", "⑤ Save")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y312 w560", "Click SAVE SLOT SEQUENCE. This saves to memory — the macro will use your")
    HelpGui.AddText("x16 y328 w560", "steps next run. To share your macro, use SAVE AS FILE to export a .txt file.")
    HelpGui.SetFont("s8 c555555 Norm", "Segoe UI")
    HelpGui.AddText("x16 y348 w560", "────────────────────────────────────────────────────────────────")
    HelpGui.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    HelpGui.AddText("x16 y362 w560", "What is a Trigger?")
    HelpGui.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    HelpGui.AddText("x16 y380 w560", "The trigger tells the macro WHEN to run that slot's steps. '0 enemies' means")
    HelpGui.AddText("x16 y396 w560", "run when no enemies are left. 'After entry' means run right after entering.")
    HelpGui.AddText("x16 y412 w560", "'— (manual/always)' means always run it, no condition check.")
    HelpGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    BtnClose := HelpGui.AddButton("x16 y500 w560 h32 Background7B2FFF", "Got it — close")
    BtnClose.Opt("cFFFFFF")
    BtnClose.OnEvent("Click", (*) => HelpGui.Destroy())
    HelpGui.OnEvent("Close", (*) => HelpGui.Destroy())
    HelpGui.Show("w592 h548")
}

ShowMainHelp() {
    H := Gui("+AlwaysOnTop", "Main UI — How To Use")
    H.BackColor := "0D0D0D"
    H.SetFont("s11 c7B2FFF Bold", "Segoe UI")
    H.AddText("x16 y12 w520", "🎮  MAIN UI GUIDE")
    H.SetFont("s8 c555555 Norm", "Segoe UI")
    H.AddText("x16 y32 w520", "────────────────────────────────────────────────────────────────")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y46 w520", "▶ START / ■ STOP  (or F1 / F2)")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y64 w520", "Starts or stops the macro. The macro will only farm the modes you have ticked.")
    H.AddText("x16 y80 w520", "Make sure Roblox is open and your character is in-game before starting.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y102 w520", "Farm Mode Checkboxes")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y120 w520", "Tick which gamemodes you want the macro to farm:")
    H.AddText("x16 y136 w520", "  • Abandon Village — farms AV every cycle")
    H.AddText("x16 y151 w520", "  • Double Dungeon — farms DD every cycle")
    H.AddText("x16 y166 w520", "  • Rift — joins Rift at :00/:15/:30/:45 each hour")
    H.AddText("x16 y181 w520", "  • Raid — joins the selected raid type on cooldown")
    H.AddText("x16 y196 w520", "  • Custom Movement — runs a user-loaded movement file")
    H.AddText("x16 y211 w520", "  • Summoning — summons on each run using the configured map")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y233 w520", "Stat Cards")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y251 w520", "Shows how many runs of each mode have completed this session,")
    H.AddText("x16 y266 w520", "how many times the macro has rejoined your server, and total uptime.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y288 w520", "Hotkeys")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y306 w520", "  F1 = Start   F2 = Stop   F3 = Kill script   F4 = Pause/Resume   F5 = Reset counts")
    H.AddText("x16 y321 w520", "  F10/F11 = Debug detection tests (DD / AV card scan)")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y343 w520", "⚙ Settings button")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y361 w520", "Opens the settings panel. Set your webhook, private server link,")
    H.AddText("x16 y376 w520", "speed, and more. Click 'HOW IT WORKS' in settings for a full guide.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y398 w520", "📝 EDIT button")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y416 w520", "Opens the Gamemode Editor — use this to record custom movement")
    H.AddText("x16 y431 w520", "steps for any gamemode. Click ❓ in the editor for a full guide.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y453 w520", "⊟ Mini Mode button  (top-right of window)")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y471 w520", "Collapses the macro to a small overlay so it stays out of the way")
    H.AddText("x16 y486 w520", "while you play. Click it again to restore the full window.")

    H.SetFont("s8 c555555 Norm", "Segoe UI")
    H.AddText("x16 y506 w520", "────────────────────────────────────────────────────────────────")
    H.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    BtnC := H.AddButton("x16 y520 w520 h32 Background7B2FFF", "Got it — close")
    BtnC.Opt("cFFFFFF")
    BtnC.OnEvent("Click", (*) => H.Destroy())
    H.OnEvent("Close", (*) => H.Destroy())
    H.Show("w552 h568")
}

ShowSettingsHelp() {
    H := Gui("+AlwaysOnTop", "Settings — How It Works")
    H.BackColor := "0D0D0D"
    H.SetFont("s11 c7B2FFF Bold", "Segoe UI")
    H.AddText("x16 y12 w520", "⚙  SETTINGS GUIDE")
    H.SetFont("s8 c555555 Norm", "Segoe UI")
    H.AddText("x16 y32 w520", "────────────────────────────────────────────────────────────────")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y46 w520", "Discord Webhook URL")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y64 w520", "Paste a Discord webhook URL here to get run notifications and screenshots")
    H.AddText("x16 y79 w520", "sent to your Discord channel. Tick 'Enable' to turn notifications on.")
    H.SetFont("s8 c888888 Norm", "Segoe UI")
    H.AddText("x16 y94 w520", "How to get one: Discord server → channel settings → Integrations → Webhooks → New")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y116 w520", "Roblox Private Server Link")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y134 w520", "Paste the URL of your ATS private server. The macro uses this to auto-rejoin")
    H.AddText("x16 y149 w520", "every hour so you don't get kicked. Tick 'Auto-Rejoin' to enable.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y171 w520", "Speed Scaling")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y189 w520", "If your character's movement speed is different from the macro creator's speed,")
    H.AddText("x16 y204 w520", "enter your speed here. The macro scales all movement timings automatically.")
    H.SetFont("s8 c888888 Norm", "Segoe UI")
    H.AddText("x16 y219 w520", "Default speed is 32. Check your in-game stats for your current speed.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y241 w520", "UI Accent Color")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y259 w520", "Enter a 6-digit hex color code (e.g. 7B2FFF) to change the accent color")
    H.AddText("x16 y274 w520", "of the macro UI. Save & Apply to see the change.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y296 w520", "Tools")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y314 w520", "  📸 Test Screenshot — takes a screenshot and sends it to your webhook")
    H.AddText("x16 y329 w520", "  🔍 Toggle Debug — shows a live debug overlay with detection info")
    H.AddText("x16 y344 w520", "  🔗 Test Join PS — opens your private server link to test it works")
    H.AddText("x16 y359 w520", "  📡 Test Webhook — sends a test message to your Discord webhook")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y381 w520", "Movement Files")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y399 w520", "Load a custom .txt sequence file for Custom Movement mode. Use the")
    H.AddText("x16 y414 w520", "🔄 reload buttons to reload movement folders after adding new files.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y436 w520", "Rift Lobby Movement")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y454 w520", "Import a movement file (.txt) that walks your character to the Rift lobby")
    H.AddText("x16 y469 w520", "after teleporting in. 'Force leave' makes the macro exit the current")
    H.AddText("x16 y484 w520", "gamemode 1 minute before the Rift window opens so it's ready in time.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y506 w520", "Summon Map")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y524 w520", "Choose which map to summon on, and tick 'Enable Summon Each Run'")
    H.AddText("x16 y539 w520", "to automatically summon at the start of each macro cycle.")

    H.SetFont("s9 cFFAA00 Bold", "Segoe UI")
    H.AddText("x16 y561 w520", "SAVE & APPLY")
    H.SetFont("s8 cCCCCCC Norm", "Segoe UI")
    H.AddText("x16 y579 w520", "Always click this after making changes — settings are not saved until you do.")

    H.SetFont("s8 c555555 Norm", "Segoe UI")
    H.AddText("x16 y599 w520", "────────────────────────────────────────────────────────────────")
    H.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    BtnC := H.AddButton("x16 y613 w520 h32 Background7B2FFF", "Got it — close")
    BtnC.Opt("cFFFFFF")
    BtnC.OnEvent("Click", (*) => H.Destroy())
    H.OnEvent("Close", (*) => H.Destroy())
    H.Show("w552 h661")
}

OnEditorGMChange(ctrl, *) {
    global EditorGamemode, LblSaveFile, EditFileName, BtnSaveFile
    global EditorSteps, EditorSlotKey, EditorFocusedRow
    gms := ["DD","AV","Rift","Raid_NamexPlanet","Raid_ColosseumKingdom","Raid_DemonForest","Raid_DungeonTown","Raid_ReaperSociety","Summon","Custom"]
    EditorGamemode   := gms[ctrl.Value]
    EditorSteps      := []
    EditorSlotKey    := ""
    EditorFocusedRow := 0
    isCustom := (EditorGamemode == "Custom" || EditorGamemode == "Rift" || EditorGamemode == "DD")
    LblSaveFile.Visible  := isCustom
    EditFileName.Visible := isCustom
    BtnSaveFile.Visible  := isCustom
    RefreshSlotLV()
    SelectSlot(1)
}

RefreshSlotLV() {
    global EditorSlotLV, EditorGamemode, CustomSeqs, SlotTriggers, GM_DD, GM_AV, GM_Rift, GM_Summon, GM_Custom
    slots := GetGMSlots(EditorGamemode)
    EditorSlotLV.Delete()
    for slot in slots {
        trigger := SlotTriggers.Has(slot["key"]) ? SlotTriggers[slot["key"]] : slot["trigger"]
        if (CustomSeqs.Has(slot["key"])) {
            dur := CalcSeqDuration(CustomSeqs[slot["key"]])
            label := slot["label"] " (" Round(dur/1000, 1) "s)"
        } else {
            label := slot["label"]
        }
        EditorSlotLV.Add("", label, trigger)
    }
}

SelectSlot(idx) {
    global EditorSlotLV, EditorSlotKey, EditorSteps, EditorGamemode, CustomSeqs
    global EditorSlotIdx, SlotTriggers, DdlTrigger, TriggerOptions, EditorFocusedRow
    global GM_DD, GM_AV, GM_Rift, GM_Summon, GM_Custom
    slots := GetGMSlots(EditorGamemode)
    if (idx < 1 || idx > slots.Length)
        return
    EditorSlotIdx := idx
    EditorSlotLV.Modify(idx, "Select Focus")
    EditorSlotKey    := slots[idx]["key"]
    EditorSteps      := []
    EditorFocusedRow := 0
    if (CustomSeqs.Has(EditorSlotKey))
        EditorSteps := CustomSeqs[EditorSlotKey].Clone()
    RefreshEditorLV()
    ; Sync trigger dropdown to saved value or default
    activeTrigger := SlotTriggers.Has(EditorSlotKey) ? SlotTriggers[EditorSlotKey] : slots[idx]["trigger"]
    DdlTrigger.Value := 1
    Loop TriggerOptions.Length {
        if (TriggerOptions[A_Index] == activeTrigger) {
            DdlTrigger.Value := A_Index
            break
        }
    }
    SetEditorStatus("  ● Slot: " slots[idx]["label"] " — trigger: " activeTrigger "  | F8 to record", "c00AAFF")
}

OnSlotSelect(ctrl, *) {
    row := ctrl.GetNext(0, "F")
    if (row > 0)
        SelectSlot(row)
}

AddCustomSlot() {
    global EditNewSlotName, EditorGamemode, EditorSlotLV, CustomSeqs, SlotTriggers
    name := Trim(EditNewSlotName.Value)
    if (name == "" || name == "Step Name") {
        MsgBox("Enter a slot name first.", "Editor", "Icon!")
        return
    }
    ; Build key from gamemode prefix + name (strip spaces)
    prefix := Map("DD","DD_","AV","AV_","Rift","Rift_","Raid","Raid_","Summon","Summon_","Custom","Custom_")
    pfx    := prefix.Has(EditorGamemode) ? prefix[EditorGamemode] : "Custom_"
    key    := pfx . StrReplace(name, " ", "")

    ; Check not already existing
    slots := GetGMSlots(EditorGamemode)
    for s in slots {
        if (s["key"] == key) {
            MsgBox("Slot '" name "' already exists.", "Editor", "Icon!")
            return
        }
    }

    ; Add to the active GM slot array
    newSlot := Map("key", key, "label", name, "trigger", "—")
    slots.Push(newSlot)
    CustomSeqs[key]   := []
    SlotTriggers[key] := "—"

    RefreshSlotLV()
    ; Select the new slot
    SelectSlot(slots.Length)
    SetEditorStatus("  ✔ Slot '" name "' added — record steps and save", "c00FF99")
}

DeleteCustomSlot() {
    global EditorSlotIdx, EditorGamemode, EditorSlotKey, CustomSeqs, SlotTriggers
    slots := GetGMSlots(EditorGamemode)
    if (EditorSlotIdx < 1 || EditorSlotIdx > slots.Length)
        return
    label := slots[EditorSlotIdx]["label"]
    if (MsgBox("Delete slot '" label "'? Steps will be lost.", "Confirm", "YesNo") != "Yes")
        return
    ; Remove from CustomSeqs + SlotTriggers
    CustomSeqs.Delete(EditorSlotKey)
    if SlotTriggers.Has(EditorSlotKey)
        SlotTriggers.Delete(EditorSlotKey)
    ; Remove from GM array
    slots.RemoveAt(EditorSlotIdx)
    RefreshSlotLV()
    newIdx := Min(EditorSlotIdx, slots.Length)
    if (newIdx > 0)
        SelectSlot(newIdx)
    else {
        EditorSlotKey := ""
        EditorSlotIdx := 0
    }
    SetEditorStatus("  🗑 Slot '" label "' deleted", "cFF3355")
}

OnTriggerChange(ctrl, *) {
    global SlotTriggers, EditorSlotKey, TriggerOptions, EditorGamemode, EditorSlotIdx
    chosen := TriggerOptions[ctrl.Value]
    SlotTriggers[EditorSlotKey] := chosen
    ; Update the slot list display
    EditorSlotLV.Modify(EditorSlotIdx, "", , chosen)
    SetEditorStatus("  ✔ Trigger set to: " chosen " for " EditorSlotKey, "c00FF99")
}

global EditorFocusedRow := 0
OnStepFocus(ctrl, rowNum, *) {
    global EditorFocusedRow
    EditorFocusedRow := rowNum
}

MoveStep(dir) {
    global EditorSteps, EditorFocusedRow
    row := EditorFocusedRow
    if (row < 1 || row > EditorSteps.Length)
        return
    newRow := row + dir
    if (newRow < 1 || newRow > EditorSteps.Length)
        return
    ; Swap
    tmp               := EditorSteps[row]
    EditorSteps[row]  := EditorSteps[newRow]
    EditorSteps[newRow] := tmp
    EditorFocusedRow  := newRow
    RefreshEditorLV()
    EditorLV.Modify(newRow, "Select Focus")
}

SetEditorStatus(msg, color) {
    global LblEditorStatus
    LblEditorStatus.Text := "  " msg
    LblEditorStatus.Opt(color)
}

StartEditorRecording(appendMode := false) {
    global EditorRecording, EditorSteps, EditorAppendMode
    if (EditorRecording)
        return
    EditorAppendMode := appendMode
    if (!appendMode)
        EditorSteps := []
    EditorRecording := true
    if (appendMode)
        SetEditorStatus("➕ STEP 3 — APPENDING — switch to Roblox and press keys... press F9 to stop", "c22FF22")
    else
        SetEditorStatus("⏺ STEP 3 — RECORDING — switch to Roblox and press your movement keys... F9 to stop", "cFF5555")
    RefreshEditorLV()
}

StopEditorRecording() {
    global EditorRecording
    if (!EditorRecording)
        return
    EditorRecording := false
    SetEditorStatus("⏹ STEP 4 — Recording stopped — review steps on the right, reorder if needed, then click SAVE", "cFFAA00")
}


EditorCaptureKey(keyName) {
    global EditorRecording, EditorSteps, EditorOpen
    if (!IsSet(EditorRecording) || !EditorRecording || !EditorOpen)
        return
    t := A_TickCount
    KeyWait(keyName)
    dur := A_TickCount - t
    if (dur < 10)
        dur := 50
    EditorSteps.Push(Map("type","key","key",keyName,"dur",dur))
    RefreshEditorLV()
}

EditorCaptureQ() {
    global EditorRecording, EditorSteps, EditorOpen
    if (!IsSet(EditorRecording) || !EditorRecording || !EditorOpen)
        return
    ; Q = record a 500ms sleep step for spacing
    EditorSteps.Push(Map("type","sleep","dur",500))
    RefreshEditorLV()
}

EditorCaptureMouse() {
    global EditorRecording, EditorOpen
    if (!IsSet(EditorRecording) || !EditorRecording || !EditorOpen)
        return
    MouseGetPos(&mx, &my, &mWin)
    edWin := WinExist("Gamemode Editor — DenniXD ATS V3.0.0")
    if (edWin && mWin == edWin)
        return
    EditorSteps.Push(Map("type","click","x",mx,"y",my,"dur",80))
    RefreshEditorLV()
}

RefreshEditorLV() {
    global EditorLV, EditorSteps
    if (!IsObject(EditorLV))
        return
    EditorLV.Delete()
    for i, step in EditorSteps {
        t := step["type"]
        if (t == "key")
            EditorLV.Add("", i, "Key", step["key"], step["dur"])
        else if (t == "click")
            EditorLV.Add("", i, "Click", step["x"] "," step["y"], step.Has("dur") ? step["dur"] : 80)
        else if (t == "sleep")
            EditorLV.Add("", i, "Sleep", "—", step["dur"])
        else if (t == "triggerpoint")
            EditorLV.Add("Col4", i, "⚡ WAIT", step["count"] " enemies", "—")
    }
    ; Show total duration as summary row
    if (EditorSteps.Length > 0) {
        total := CalcSeqDuration(EditorSteps)
        EditorLV.Add("", "—", "TOTAL", "cooldown =", total " ms")
    }
}

PlayEditorSteps() {
    global EditorSteps, RobloxTitle, SpeedScale
    if (EditorSteps.Length == 0) {
        MsgBox("No steps to play.", "Editor", "Icon!")
        return
    }
    ; Activate Roblox first
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }
    BlockInput("On")
    for step in EditorSteps {
        if (step["type"] == "key") {
            scaledDur := Max(10, Round(step["dur"] * SpeedScale))
            Send("{" step["key"] " down}"), Sleep(scaledDur), Send("{" step["key"] " up}")
        } else if (step["type"] == "click") {
            MouseMove(step["x"], step["y"])
            MouseMove(1, 0,, "R")
            MouseClick("Left", -1, 0,,,, "R")
            Sleep(50)
            if (step.Has("dur") && step["dur"] > 0)
                Sleep(Round(step["dur"] * SpeedScale))
        } else if (step["type"] == "sleep") {
            Sleep(Max(10, Round(step["dur"] * SpeedScale)))
        }
    }
    BlockInput("Off")
}

AddStepManual() {
    global EditorSteps
    ; Popup GUI to add a step
    AddGui := Gui("+AlwaysOnTop", "Add Step")
    AddGui.BackColor := "1A1A1A"
    AddGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    AddGui.AddText("x16 y14 w200", "Step Type:")
    DdlType := AddGui.AddDropDownList("x16 y30 w200", ["Key Press", "Mouse Click", "Sleep"])
    DdlType.Value := 1
    AddGui.AddText("x16 y62 w80", "Key / X:")
    EditA := AddGui.AddEdit("x100 y59 w116 h24 Background111111", "s")
    AddGui.AddText("x16 y92 w80", "Y (click):")
    EditB := AddGui.AddEdit("x100 y89 w116 h24 Background111111", "0")
    AddGui.AddText("x16 y122 w80", "Duration ms:")
    EditC := AddGui.AddEdit("x100 y119 w116 h24 Background111111", "500")
    AddGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    BtnAdd := AddGui.AddButton("x16 y152 w200 h28 Background7B2FFF", "ADD STEP")
    BtnAdd.Opt("cFFFFFF")
    BtnAdd.OnEvent("Click", (*) => DoAddStep(DdlType, EditA, EditB, EditC, AddGui))
    AddGui.Show("w232 h194")
}

DoAddStep(DdlType, EditA, EditB, EditC, AddGui) {
    global EditorSteps, EditorFocusedRow
    t := DdlType.Value
    if (t == 1) {  ; Key
        step := Map("type","key","key",EditA.Value,"dur",Integer(EditC.Value))
    } else if (t == 2) {  ; Click
        step := Map("type","click","x",Integer(EditA.Value),"y",Integer(EditB.Value),"dur",Integer(EditC.Value))
    } else {  ; Sleep
        step := Map("type","sleep","dur",Integer(EditC.Value))
    }
    ; Insert after focused row or append at end
    insertAt := EditorFocusedRow
    if (insertAt > 0 && insertAt <= EditorSteps.Length) {
        EditorSteps.InsertAt(insertAt + 1, step)
        EditorFocusedRow := insertAt + 1
    } else {
        EditorSteps.Push(step)
        EditorFocusedRow := EditorSteps.Length
    }
    RefreshEditorLV()
    EditorLV.Modify(EditorFocusedRow, "Select Focus")
    AddGui.Destroy()
}

DeleteSelectedStep() {
    global EditorSteps, EditorFocusedRow
    row := EditorFocusedRow
    if (row < 1 || row > EditorSteps.Length) {
        MsgBox("No step selected.", "Editor", "Icon!")
        return
    }
    EditorSteps.RemoveAt(row)
    EditorFocusedRow := Min(row, EditorSteps.Length)
    RefreshEditorLV()
    if (EditorFocusedRow > 0)
        EditorLV.Modify(EditorFocusedRow, "Select Focus")
}

ClearEditorSteps() {
    global EditorSteps
    if (MsgBox("Clear ALL steps for this slot?", "Confirm", "YesNo") == "Yes") {
        EditorSteps := []
        RefreshEditorLV()
    }
}

SaveCustomMacroFile() {
    global CustomSeqs, SlotTriggers, EditFileName, CustomRunName, GuiCustomLabel
    fname := Trim(EditFileName.Value)
    if (fname == "") {
        MsgBox("Please enter a file name.", "Save Custom Macro", "Icon!")
        return
    }
    ; Sanitise — remove invalid chars
    fname := RegExReplace(fname, "[\/:*?" Chr(34) "<>|]", "")
    if (fname == "") {
        MsgBox("Invalid file name.", "Save Custom Macro", "Icon!")
        return
    }
    savePath := FolderCustom "\" fname ".txt"
    ; Build output — only Custom_ keys
    out := "; Custom Macro: " fname "`n"
    for seqKey, trigger in SlotTriggers {
        if InStr(seqKey, "Custom_")
            out .= seqKey "|trigger|" trigger "`n"
    }
    for seqName, steps in CustomSeqs {
        if !InStr(seqName, "Custom_")
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
        }
    }
    try {
        if FileExist(savePath)
            FileDelete(savePath)
        FileAppend(out, savePath, "UTF-8")
    }
    ; Update display name
    CustomRunName       := StrUpper(SubStr(fname, 1, 12))
    GuiCustomLabel.Text := CustomRunName
    SetEditorStatus("  ✔ Saved as " fname ".txt — use 📂 Load in Settings to activate", "c00FF99")
    MsgBox("Saved to:`n" savePath "`n`nReload via Settings > 🔄 Custom to activate.", "Saved!", "Icon!")
}

SaveEditorSequence() {
    global EditorSteps, EditorSlotKey, CustomSeqs, SlotTriggers
    global EditorGamemode, FolderCustom, FolderRaids, FolderSummon
    global GM_DD, GM_AV, GM_Rift, GM_Summon, GM_Custom
    if (EditorSteps.Length == 0) {
        MsgBox("No steps to save.", "Editor", "Icon!")
        return
    }
    ; Save edited steps into memory
    CustomSeqs[EditorSlotKey] := EditorSteps.Clone()
    SaveSequences()
    RefreshSlotLV()

    ; Write ALL slots for this gamemode back to the file (not just the one slot)
    if (EditorGamemode == "Summon") {
        ; Each summon slot has its own file
        fname := StrReplace(EditorSlotKey, "Summon_", "") . ".txt"
        SaveMovementFileSlots(FolderSummon "\" fname, [EditorSlotKey])
    } else if (InStr(EditorGamemode, "Raid_") == 1) {
        ; Each raid map has its own file
        fname := StrReplace(EditorGamemode, "Raid_", "") . ".txt"
        SaveMovementFileSlots(FolderRaids "\" fname, [EditorSlotKey])
    } else if (EditorGamemode == "DD") {
        ; All DD slots share one file — save them all
        keys := []
        for slot in GM_DD
            keys.Push(slot["key"])
        SaveMovementFileSlots(FolderCustom "\DoubleDungeon.txt", keys)
    } else if (EditorGamemode == "AV") {
        keys := []
        for slot in GM_AV
            keys.Push(slot["key"])
        SaveMovementFileSlots(FolderCustom "\AbandonVillage.txt", keys)
    } else if (EditorGamemode == "Rift") {
        keys := []
        for slot in GM_Rift
            keys.Push(slot["key"])
        SaveMovementFileSlots(FolderCustom "\Rift.txt", keys)
    }

    SetEditorStatus("  ✔ Saved " EditorSteps.Length " steps → " EditorSlotKey, "c00FF99")
}

; Writes multiple slot keys into one file (preserves all slots)
SaveMovementFileSlots(path, keys) {
    global CustomSeqs, SlotTriggers
    out := "; DenniXD ATS V3.0.0 — saved from editor`n`n"
    for slotKey in keys {
        if (!CustomSeqs.Has(slotKey))
            continue
        trigger := SlotTriggers.Has(slotKey) ? SlotTriggers[slotKey] : "—"
        out .= slotKey "|trigger|" trigger "`n"
        for step in CustomSeqs[slotKey] {
            t := step["type"]
            if (t == "key")
                out .= slotKey "|key|" step["key"] "|" step["dur"] "`n"
            else if (t == "click")
                out .= slotKey "|click|" step["x"] "|" step["y"] "|" step["dur"] "`n"
            else if (t == "sleep")
                out .= slotKey "|sleep|" step["dur"] "`n"
            else if (t == "triggerpoint")
                out .= slotKey "|triggerpoint|" step["count"] "`n"
        }
        out .= "`n"
    }
    if FileExist(path)
        FileDelete(path)
    FileAppend(out, path, "UTF-8")
}

; Legacy single-slot save (kept for custom macro file saves)
SaveMovementFile(path, slotKey) {
    SaveMovementFileSlots(path, [slotKey])
}

