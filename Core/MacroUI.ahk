ToggleMode(mode) {
    global ModeAbandonVillage, ModeDoubleDungeon, ModeRift, ModeSummoning, ModeCustomMovement, ModeRaid
    global ChkModeAV, ChkModeDD, ChkModeRift, ChkModeSum, ChkModeCustom, ChkModeRaid

    ; Toggle the requested mode
    if (mode == "AbandonVillage")
        ModeAbandonVillage := !ModeAbandonVillage
    else if (mode == "DoubleDungeon")
        ModeDoubleDungeon := !ModeDoubleDungeon
    else if (mode == "Rift")
        ModeRift := !ModeRift
    else if (mode == "Summoning")
        ModeSummoning := !ModeSummoning
    else if (mode == "CustomMovement")
        ModeCustomMovement := !ModeCustomMovement
    else if (mode == "Raid")
        ModeRaid := !ModeRaid

    ; Check if at least one mode is on
    anyOn := ModeAbandonVillage || ModeDoubleDungeon || ModeRift
              || ModeSummoning || ModeCustomMovement || ModeRaid
    if (!anyOn) {
        ; Re-enable the one that was just turned off
        MsgBox("At least one mode must be enabled.", "Mode Selector", "Icon!")
        if (mode == "AbandonVillage") {
            ModeAbandonVillage := true
        } else if (mode == "DoubleDungeon") {
            ModeDoubleDungeon := true
        } else if (mode == "Rift") {
            ModeRift := true
        } else if (mode == "Summoning") {
            ModeSummoning := true
        } else if (mode == "CustomMovement") {
            ModeCustomMovement := true
        } else if (mode == "Raid") {
            ModeRaid := true
        }
    }

    ; Sync all checkboxes
    ChkModeAV.Value     := ModeAbandonVillage ? 1 : 0
    ChkModeDD.Value     := ModeDoubleDungeon  ? 1 : 0
    ChkModeRift.Value   := ModeRift           ? 1 : 0
    ChkModeSum.Value    := ModeSummoning      ? 1 : 0
    ChkModeCustom.Value := ModeCustomMovement ? 1 : 0
    ChkModeRaid.Value   := ModeRaid           ? 1 : 0
}

; Runs full RejoinPS() as a manual test — resets LastRejoinTime so PS link always opens
TestJoinPS() {
    global LastRejoinTime, PrivateServer
    if (PrivateServer == "") {
        MsgBox("No Private Server link set.`nPlease add it in Settings first.", "Test Join PS", "Icon!")
        return
    }
    LastRejoinTime := 0   ; force PS link to open regardless of 1hr timer
    GuiStatus.Text := "Test Join PS — starting..."
    RejoinPS()
    GuiStatus.Text := "● Test Join PS complete"
}

ToggleSettings(*) {
    if WinExist("ATS Settings") {
        SettingsGui.Hide()
    } else {
        ; Centre popup relative to main GUI
        MyGui.GetPos(&mx, &my, &mw)
        SettingsGui.Show("x" . (mx - 420 - 10) . " y" . my . " w420 h760")
    }
}
ToggleDebugBox(*) {
    global DebugVisible
    DebugVisible := !DebugVisible
    if (DebugVisible) {
        W := EndX - StartX, H := EndY - StartY
        DebugGui.Show("x" StartX " y" StartY " w" W " h" H " NoActivate")
        WinSetTransparent(100, DebugGui)
    } else {
        DebugGui.Hide()
    }
}
LoadCustomSeqFile() {
    global SeqFile, SeqFileCustom, LblSeqFile
    chosen := FileSelect(3,, "Select Sequence File", "Text Files (*.txt)")
    if (chosen == "")
        return
    SeqFileCustom := chosen
    SeqFile       := chosen
    ; Extract filename without path/ext as display name
    SplitPath(chosen, &fname)
    CustomRunName := RegExReplace(fname, "\.txt$", "")
    if (StrLen(CustomRunName) > 12)
        CustomRunName := SubStr(CustomRunName, 1, 12)
    CustomRunName := StrUpper(CustomRunName)
    GuiCustomLabel.Text := CustomRunName
    LblSeqFile.Text := "Loaded: " fname
    LoadSequences()
    MsgBox("Sequence file loaded!`n" fname, "Custom Sequence File", "Icon!")
}

SaveSettings(*) {
    global DiscordWebhook, PrivateServer, CustomColor
    DiscordWebhook  := EditWeb.Value
    PrivateServer   := EditPS.Value
    CreatorSpeed       := Integer(EditCreatorSpeed.Value) > 0 ? Integer(EditCreatorSpeed.Value) : 32
    UserSpeed          := Integer(EditSpeed.Value) > 0 ? Integer(EditSpeed.Value) : 32
    EditCreatorSpeed.Value := CreatorSpeed
    EditSpeed.Value        := UserSpeed
    UpdateSpeedScale()
    LblSpeedScale.Text := "Scale = " CreatorSpeed " ÷ " UserSpeed " = " Round(CreatorSpeed / UserSpeed, 2) "x"
    CustomColor     := EditCol.Value
    MyGui.BackColor := CustomColor
    try {
        IniWrite(DiscordWebhook,                    IniFile, "Settings", "Webhook")
        IniWrite(PrivateServer,                     IniFile, "Settings", "PSLink")
        IniWrite(AutoRejoinEnabled ? "1" : "0",     IniFile, "Settings", "AutoRejoin")
        IniWrite(WebhookEnabled ? "1" : "0",        IniFile, "Settings", "WebhookEnabled")
        IniWrite(RiftForceLeave ? "1" : "0",        IniFile, "Settings", "RiftForceLeave")
        IniWrite(CreatorSpeed,                      IniFile, "Settings", "CreatorSpeed")
        IniWrite(UserSpeed,                         IniFile, "Settings", "UserSpeed")
        IniWrite(CustomColor,                       IniFile, "Settings", "UIColor")
        SettingsGui.Hide()
        MsgBox("Settings saved!", "ATS Macro", "Iconi T1.5")
    } catch as e {
        MsgBox("Failed to save settings: " e.Message "`n`nMake sure the macro folder is not read-only.", "Save Error", "Iconx")
    }
}
ResetStats(*) {
    global DemonRuns, DungeonRuns, RejoinCount, CurrentRaidStep, SessionStart
    if (MsgBox("Reset all stats?", "Confirm", "YesNo") == "Yes") {
        DemonRuns       := 0
        DungeonRuns     := 0
            EntryFailCount      := 0
        RejoinCount     := 0
        CurrentRaidStep := 0
        SessionStart    := A_TickCount
        UpdateUI()
    }
}


CrashWatchdog() {
    global Running, RobloxTitle, MacroPaused
    if (!Running || MacroPaused)
        return
    if (!RobloxRunning()) {
        GuiStatus.Text := "⚠ Crash detected — rejoining..."
        GuiStatus.Opt("cFF4400")
        Sleep(2000)
        RejoinPS()
    }
}

UpdateUI() {
    global DemonRuns, DungeonRuns, RiftRuns, RaidRuns, RaidType, CustomRuns, CustomRunName, RejoinCount, SessionStart, ModeRaid
    e := A_TickCount - SessionStart
    GuiDemon.Text       := DemonRuns
    GuiDungeon.Text     := DungeonRuns
    GuiRift.Text        := RiftRuns
    GuiRaid.Text        := RaidRuns
    GuiRaidType.Text    := ModeRaid ? RaidType : "—"
    GuiCustom.Text      := CustomRuns
    GuiCustomLabel.Text := CustomRunName
    GuiRejoin.Text      := RejoinCount
    GuiUptime.Text      := (e // 3600000) . "h " . (Mod(e, 3600000) // 60000) . "m " . (Mod(e, 60000) // 1000) . "s"
    ; Sync mini overlay
    if (MiniMode) {
        MiniStatus.Text  := GuiStatus.Text
        MiniAV.Text      := DemonRuns
        MiniDD.Text      := DungeonRuns
        MiniRift.Text    := RiftRuns
        MiniRaid.Text    := RaidRuns
        MiniRejoin.Text  := RejoinCount
        MiniUptime.Text  := (e // 3600000) . "h " . (Mod(e, 3600000) // 60000) . "m " . (Mod(e, 60000) // 1000) . "s"
    }
}

