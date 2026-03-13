; ── Main window creation ──────────────────────────────────────────
global MyGui := Gui("+AlwaysOnTop -Caption +Border", "DenniXD ATS Macro V3.0.0")
MyGui.BackColor := "0D0D0D"

OnMessage(0x0201, WM_LBUTTONDOWN)
WM_LBUTTONDOWN(wParam, lParam, msg, hwnd) {
    global MyGui
    ; Only drag if the click is directly on the GUI window itself (not a control)
    if (hwnd == MyGui.Hwnd)
        PostMessage(0xA1, 2,,, MyGui.Hwnd)
}

; ── Accent bar (top) ─────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x0 y0 w430 h3 Background7B2FFF", "")   ; purple accent strip

; ── Title row ────────────────────────────────────────────────────
MyGui.SetFont("s13 cFFFFFF Bold", "Segoe UI")
MyGui.AddText("x16 y14 w300", "DenniXD ATS MACRO")
MyGui.SetFont("s8 c555555 Norm", "Segoe UI")
MyGui.AddText("x16 y32 w300", "V3.0.0  ·  Double Dungeon + Abandon Village")

; Close [ X ]
MyGui.SetFont("s10 cFF4455 Bold", "Segoe UI")
MyGui.AddText("x404 y10 w22 h22 Center", "✕").OnEvent("Click", (*) => ExitApp())
MyGui.SetFont("s10 c888888 Norm", "Segoe UI")
MyGui.AddText("x378 y10 w22 h22 Center", "⊟").OnEvent("Click", (*) => ToggleMiniMode())

; ── Status pill ──────────────────────────────────────────────────
MyGui.SetFont("s9 cAAAAAA Norm", "Segoe UI")
MyGui.AddText("x16 y58 w60", "STATUS")
MyGui.SetFont("s10 c00FF99 Bold", "Segoe UI")
global GuiStatus := MyGui.AddText("x80 y56 w270", "● Idle")

; ── Divider ──────────────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x16 y76 w348 h1 Background222222", "")

; ── Stat cards (3-column grid x2 rows + live timer) ──────────────
; Card bg: 181818 | label: 888888 | value: FFFFFF
CardW := 108, CardH := 52
CardX1 := 16, CardX2 := 132, CardX3 := 248
CardY1 := 84, CardY2 := 144

; Card 1 — Abandon Village
MyGui.AddText("x" CardX1 " y" CardY1 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX1+6) " y" (CardY1+6) " w" (CardW-12), "ABANDON VILLAGE")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiDemon := MyGui.AddText("x" (CardX1+6) " y" (CardY1+22) " w" (CardW-12), "0")

; Card 2 — Double Dungeon
MyGui.AddText("x" CardX2 " y" CardY1 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX2+6) " y" (CardY1+6) " w" (CardW-12), "DOUBLE DUNGEON")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiDungeon := MyGui.AddText("x" (CardX2+6) " y" (CardY1+22) " w" (CardW-12), "0")

; Card 3 — Rift
MyGui.AddText("x" CardX3 " y" CardY1 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX3+6) " y" (CardY1+6) " w" (CardW-12), "RIFT")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiRift := MyGui.AddText("x" (CardX3+6) " y" (CardY1+22) " w" (CardW-12), "0")

; Card 4 — Custom (label updates when file loaded)
MyGui.AddText("x" CardX1 " y" CardY2 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
global GuiCustomLabel := MyGui.AddText("x" (CardX1+6) " y" (CardY2+6) " w" (CardW-12), "CUSTOM")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiCustom := MyGui.AddText("x" (CardX1+6) " y" (CardY2+22) " w" (CardW-12), "0")

; Card 5 — Rejoined
MyGui.AddText("x" CardX2 " y" CardY2 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX2+6) " y" (CardY2+6) " w" (CardW-12), "REJOINED")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiRejoin := MyGui.AddText("x" (CardX2+6) " y" (CardY2+22) " w" (CardW-12), "0")

; Card 6 — Uptime
MyGui.AddText("x" CardX3 " y" CardY2 " w" CardW " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX3+6) " y" (CardY2+6) " w" (CardW-12), "UPTIME")
MyGui.SetFont("s11 cFFFFFF Bold", "Segoe UI")
global GuiUptime := MyGui.AddText("x" (CardX3+6) " y" (CardY2+22) " w" (CardW-12), "0h 0m 0s")

; Row 3 — Raid card (full width)
CardY3 := 204
MyGui.AddText("x" CardX1 " y" CardY3 " w" (CardW*3+16) " h" CardH " Background181818 Border", "")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x" (CardX1+6) " y" (CardY3+6) " w70", "RAID RUNS")
MyGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
global GuiRaid := MyGui.AddText("x" (CardX1+6) " y" (CardY3+22) " w50", "0")
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")
MyGui.AddText("x90 y" (CardY3+6) " w70", "MAP")
MyGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
global GuiRaidType := MyGui.AddText("x90 y" (CardY3+22) " w240", "—")

; ── Live timer bar ────────────────────────────────────────────────
MyGui.SetFont("s7 c888888 Norm", "Segoe UI")

; ── Divider ──────────────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x16 y276 w348 h1 Background222222", "")

; ── Farm Mode Selector ───────────────────────────────────────────
MyGui.AddText("x16 y284 w348", "FARM MODES")
; Row of 4 toggle buttons — active = purple, inactive = dark grey
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global ChkModeAV   := MyGui.AddCheckbox("x16 y298 w172 Checked", "Abandon Village")
ChkModeAV.OnEvent("Click", (*) => ToggleMode("AbandonVillage"))
global ChkModeDD   := MyGui.AddCheckbox("x196 yp+0 w172 Checked", "Double Dungeon")
ChkModeDD.OnEvent("Click", (*) => ToggleMode("DoubleDungeon"))
global ChkModeRift := MyGui.AddCheckbox("x16 yp+22 w172", "Rift")
ChkModeRift.OnEvent("Click", (*) => ToggleMode("Rift"))
global ChkModeSum  := MyGui.AddCheckbox("x196 yp+0 w172", "Summoning")
ChkModeSum.OnEvent("Click", (*) => ToggleMode("Summoning"))
global ChkModeCustom := MyGui.AddCheckbox("x16 yp+22 w172", "Custom Movement")
ChkModeCustom.OnEvent("Click", (*) => ToggleMode("CustomMovement"))
; Raid toggle + type dropdown
global ChkModeRaid := MyGui.AddCheckbox("x196 yp+0 w172", "Raid")
ChkModeRaid.OnEvent("Click", (*) => ToggleMode("Raid"))
MyGui.SetFont("s8 c888888 Norm", "Segoe UI")
MyGui.AddText("x16 yp+24 w80", "Raid Type:")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global DdlRaidType := MyGui.AddDropDownList("x96 yp-3 w252", ["Namex Planet", "Colosseum Kingdom", "Demon Forest", "Dungeon Town", "Reaper Society"])
DdlRaidType.Value := 1
DdlRaidType.OnEvent("Change", (*) => UpdateRaidType())
MyGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")

; (Summon map checkboxes are in the Settings panel)

; ── Divider ──────────────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x16 y310 w348 h1 Background222222", "")

; ── Action buttons ───────────────────────────────────────────────
; START — green accent
MyGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
global BtnStart := MyGui.AddButton("x16 y412 w78 h32 Background00CC66", "▶  START  F1")
BtnStart.OnEvent("Click", (*) => StartMacro())

; STOP — red accent
global BtnStop := MyGui.AddButton("x100 y412 w78 h32 BackgroundFF3355", "■  STOP  F2")
BtnStop.OnEvent("Click", (*) => StopMacro())

; SETTINGS — muted
MyGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
global BtnSettings := MyGui.AddButton("x184 y412 w78 h32 Background333333", "⚙ SETTINGS")
BtnSettings.Opt("cFFFFFF")
BtnSettings.OnEvent("Click", ToggleSettings)
global BtnEditor := MyGui.AddButton("x268 y412 w72 h32 Background2A1A4A", "📝 EDIT")
BtnEditor.Opt("cFFFFFF")
BtnEditor.OnEvent("Click", (*) => OpenSequenceEditor())
global BtnDiscord := MyGui.AddButton("x346 y412 w78 h32 Background5865F2", "🎮 Discord")
BtnDiscord.Opt("cFFFFFF")
BtnDiscord.OnEvent("Click", (*) => Run("https://discord.gg/qZxDkR4eZS"))

; ── Divider ──────────────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x16 y452 w348 h1 Background222222", "")

; ── Hotkey hint + help button ────────────────────────────────────
MyGui.SetFont("s8 c444444 Norm", "Segoe UI")
MyGui.AddText("x16 y458 w318 Center", "F1 Start  ·  F2 Stop  ·  F3 Kill  ·  F4 Pause  ·  F5 Reset")
MyGui.SetFont("s8 Bold", "Segoe UI")
global BtnMainHelp := MyGui.AddButton("x340 y452 w74 h22 Background1A1A2A", "❓ HELP")
BtnMainHelp.Opt("cAAAAFF")
BtnMainHelp.OnEvent("Click", (*) => ShowMainHelp())


; ── Settings panel (hidden) ──────────────────────────────────────
; ── Summon Map Section (in settings) ─────────────────────────────

MyGui.Show("w430 h474")

; ================================================================
;   MINI MODE OVERLAY  —  compact top-right widget
; ================================================================
global MiniGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "ATS Mini")
MiniGui.BackColor := "0D0D0D"
MiniGui.SetFont("s7 cFFFFFF Norm", "Segoe UI")

; Drag support
OnMessage(0x0201, WM_LBUTTONDOWN_Mini)
WM_LBUTTONDOWN_Mini(wParam, lParam, msg, hwnd) {
    global MiniGui
    if (hwnd == MiniGui.Hwnd)
        PostMessage(0xA1, 2,,, MiniGui.Hwnd)
}

; Purple accent top bar
MiniGui.AddText("x0 y0 w280 h2 Background7B2FFF", "")

; Title + status row
MiniGui.SetFont("s7 c7B2FFF Bold", "Segoe UI")
MiniGui.AddText("x8 y6 w100", "ATS MACRO")
MiniGui.SetFont("s7 c00FF99 Bold", "Segoe UI")
global MiniStatus := MiniGui.AddText("x90 y6 w140", "● Idle")

; Expand + Close buttons (top right)
MiniGui.SetFont("s7 c888888 Norm", "Segoe UI")
MiniGui.AddText("x232 y4 w18 h16 Center", "⊞").OnEvent("Click", (*) => ToggleMiniMode())
MiniGui.SetFont("s7 cFF4455 Bold", "Segoe UI")
MiniGui.AddText("x252 y4 w18 h16 Center", "✕").OnEvent("Click", (*) => ExitApp())

; Divider
MiniGui.SetFont("s6", "Segoe UI")
MiniGui.AddText("x0 y20 w280 h1 Background222222", "")

; Stat row 1: AV | DD | Rift | Raid
MiniGui.SetFont("s6 c888888 Norm", "Segoe UI")
MiniGui.AddText("x8  y24 w56", "AV")
MiniGui.AddText("x72 y24 w56", "DD")
MiniGui.AddText("x136 y24 w56", "RIFT")
MiniGui.AddText("x200 y24 w68", "RAID")
MiniGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
global MiniAV    := MiniGui.AddText("x8  y33 w56", "0")
global MiniDD    := MiniGui.AddText("x72 y33 w56", "0")
global MiniRift  := MiniGui.AddText("x136 y33 w56", "0")
global MiniRaid  := MiniGui.AddText("x200 y33 w68", "0")

; Divider
MiniGui.SetFont("s6", "Segoe UI")
MiniGui.AddText("x0 y48 w280 h1 Background1A1A1A", "")

; Stat row 2: Rejoined | Uptime
MiniGui.SetFont("s6 c888888 Norm", "Segoe UI")
MiniGui.AddText("x8  y52 w100", "REJOINED")
MiniGui.AddText("x116 y52 w152", "UPTIME")
MiniGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
global MiniRejoin := MiniGui.AddText("x8  y61 w100", "0")
MiniGui.SetFont("s8 cFFFFFF Bold", "Segoe UI")
global MiniUptime := MiniGui.AddText("x116 y61 w152", "0h 0m 0s")

; Divider
MiniGui.SetFont("s6", "Segoe UI")
MiniGui.AddText("x0 y76 w280 h1 Background222222", "")

; Buttons: START | STOP | QUIT
MiniGui.SetFont("s7 c0D0D0D Bold", "Segoe UI")
global MiniBtnStart := MiniGui.AddButton("x8  y80 w80 h22 Background00CC66", "▶ START")
global MiniBtnStop  := MiniGui.AddButton("x96 y80 w80 h22 BackgroundFF3355", "■ STOP")
global MiniBtnQuit  := MiniGui.AddButton("x184 y80 w80 h22 Background333333", "QUIT")
MiniBtnStart.Opt("cFFFFFF")
MiniBtnStop.Opt("cFFFFFF")
MiniBtnQuit.Opt("cFFFFFF")
MiniBtnStart.OnEvent("Click", (*) => StartMacro())
MiniBtnStop.OnEvent("Click",  (*) => StopMacro())
MiniBtnQuit.OnEvent("Click",  (*) => ExitApp())

; ── Settings Popup GUI ────────────────────────────────────────────
global SettingsGui := Gui("+AlwaysOnTop +ToolWindow", "ATS Settings")
SettingsGui.BackColor := "0D0D0D"
SettingsGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")

SettingsGui.SetFont("s9 cFFFFFF Bold", "Segoe UI")
SettingsGui.AddText("x16 y14 w280", "⚙  SETTINGS")
SettingsGui.SetFont("s8 Bold", "Segoe UI")
global BtnSettingsHelp := SettingsGui.AddButton("x300 y10 w104 h24 Background1A1A2A", "❓ HOW IT WORKS")
BtnSettingsHelp.Opt("cAAAAFF")
BtnSettingsHelp.OnEvent("Click", (*) => ShowSettingsHelp())

SettingsGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
SettingsGui.AddText("x16 y70 w388 cAAAAAA", "DISCORD WEBHOOK URL")
global EditWeb := SettingsGui.AddEdit("x16 y58 w388 h26 Background1A1A1A", DiscordWebhook)

global ChkWebhook := SettingsGui.AddCheckbox("x16 y88 w388 cFFFFFF Checked", "Enable Discord Webhook")
ChkWebhook.OnEvent("Click", (*) => (WebhookEnabled := ChkWebhook.Value ? true : false))

SettingsGui.AddText("x16 y116 w388 cAAAAAA", "ROBLOX PRIVATE SERVER LINK")
global EditPS := SettingsGui.AddEdit("x16 y132 w388 h26 Background1A1A1A", PrivateServer)

global ChkAutoRejoin := SettingsGui.AddCheckbox("x16 y166 w388 cFFFFFF Checked", "Auto-Rejoin PS Server every 1 hour")
ChkAutoRejoin.OnEvent("Click", (*) => (AutoRejoinEnabled := ChkAutoRejoin.Value ? true : false))

SettingsGui.AddText("x16 y184 w388 cAAAAAA", "SPEED SCALING")
SettingsGui.AddText("x16 y200 w180 c888888", "Creator Speed (default)")
SettingsGui.AddText("x214 y200 w180 c888888", "Your Speed")
global EditCreatorSpeed := SettingsGui.AddEdit("x16 y216 w180 h26 Background1A1A1A", CreatorSpeed)
global EditSpeed        := SettingsGui.AddEdit("x214 y216 w180 h26 Background1A1A1A", UserSpeed)
global LblSpeedScale := SettingsGui.AddText("x16 y248 w388 c555555", "Scale = " CreatorSpeed " ÷ " UserSpeed " = " Round(CreatorSpeed / UserSpeed, 2) "x")

SettingsGui.AddText("x16 y280 w388 cAAAAAA", "UI ACCENT COLOR (HEX)")
global EditCol := SettingsGui.AddEdit("x16 y296 w110 h26 Background1A1A1A", CustomColor)

SettingsGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
SettingsGui.AddText("x16 y336 w388 cAAAAAA", "TOOLS")
global BtnTestSS      := SettingsGui.AddButton("x16 y352 w194 h30 Background333333", "📸  Test Screenshot")
BtnTestSS.OnEvent("Click", (*) => CaptureAndSend(true))
global BtnDebug       := SettingsGui.AddButton("x208 y352 w194 h30 Background333333", "🔍  Toggle Debug")
BtnDebug.OnEvent("Click", ToggleDebugBox)
global BtnTestJoin    := SettingsGui.AddButton("x16 y388 w194 h30 Background1A3A2A", "🔗  Test Join PS")
BtnTestJoin.OnEvent("Click", (*) => TestJoinPS())
global BtnTestWebhook := SettingsGui.AddButton("x208 y388 w194 h30 Background1A1A3A", "📡  Test Webhook")
BtnTestWebhook.OnEvent("Click", (*) => CaptureAndSend(true))

SettingsGui.AddText("x16 y434 w388 cAAAAAA", "MOVEMENT FILES")
global BtnLoadSeqFile := SettingsGui.AddButton("x16 y450 w388 h30 Background1A2A1A", "📂  Load Custom Sequence File")
BtnLoadSeqFile.OnEvent("Click", (*) => LoadCustomSeqFile())
global LblSeqFile     := SettingsGui.AddText("x16 y486 w388 c888888", "No custom file loaded")
global BtnReloadCustom := SettingsGui.AddButton("x16 y508 w116 h28 Background1A2A1A", "🔄 Custom")
BtnReloadCustom.OnEvent("Click", (*) => ReloadMovementFolder(FolderCustom))
global BtnReloadRaids  := SettingsGui.AddButton("x140 y508 w116 h28 Background1A1A2A", "🔄 Raids")
BtnReloadRaids.OnEvent("Click", (*) => ReloadMovementFolder(FolderRaids))
global BtnReloadSummon := SettingsGui.AddButton("x264 y508 w132 h28 Background2A1A1A", "🔄 Summon")
BtnReloadSummon.OnEvent("Click", (*) => ReloadMovementFolder(FolderSummon))

SettingsGui.AddText("x16 y550 w388 cAAAAAA", "RIFT LOBBY MOVEMENT")
global LblRiftImport := SettingsGui.AddText("x16 y568 w260 c888888", "No file imported")
global BtnRiftImport := SettingsGui.AddButton("x284 y564 w112 h28 Background1A2A2A", "📂 Import")
BtnRiftImport.OnEvent("Click", (*) => ImportRiftMovement())
global ChkRiftForceLeave := SettingsGui.AddCheckbox("x16 y594 w388 cFFFFFF", "Force leave AV/DD/Raid 1min before Rift window")
ChkRiftForceLeave.OnEvent("Click", (*) => (RiftForceLeave := ChkRiftForceLeave.Value ? true : false))

SettingsGui.AddText("x16 y634 w388 cAAAAAA", "SUMMON MAP")
global DdlSummonMap    := SettingsGui.AddDropDownList("x16 y650 w260", ["Dungeon Town", "Reaper Society", "Map 3", "Map 4", "Map 5"])
global ChkSummonActive := SettingsGui.AddCheckbox("x16 y684 w388 cFFFFFF", "Enable Summon Each Run")

SettingsGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
global BtnSave        := SettingsGui.AddButton("x16 y722 w194 h34 Background7B2FFF", "SAVE & APPLY")
global BtnUpdate      := SettingsGui.AddButton("x208 y722 w194 h34 Background2A2A2A", "🔄 Check Updates")
global BtnForceUpdate := SettingsGui.AddButton("x16 y762 w388 h26 Background3A1A1A", "⚠ Force Update (re-download everything)")
BtnSave.OnEvent("Click", SaveSettings)
BtnUpdate.OnEvent("Click", (*) => CheckForUpdates(false))
BtnForceUpdate.OnEvent("Click", (*) => CheckForUpdates(true))
SettingsGui.OnEvent("Close", (*) => SettingsGui.Hide())
DdlSummonMap.OnEvent("Change", UpdateSummonMap)
DdlSummonMap.Value := 1
ChkSummonActive.OnEvent("Click", (*) => UpdateSummonActive())
ChkAutoRejoin.Value := AutoRejoinEnabled ? 1 : 0
    ChkWebhook.Value       := WebhookEnabled ? 1 : 0
    ChkRiftForceLeave.Value := RiftForceLeave ? 1 : 0
if (RiftLobbyImportPath != "") {
    SplitPath(RiftLobbyImportPath, &_fname)
    LblRiftImport.Text := "Loaded: " _fname
}

