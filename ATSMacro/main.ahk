#Requires AutoHotkey v2.0
#SingleInstance Force
#Include FindText.ahk
; Force event-level input so Roblox receives all clicks and keypresses
SendMode("Event")

; Clean up any leftover tmp files from a previously failed update
if FileExist(A_ScriptDir "\main.ahk.tmp")
    FileDelete(A_ScriptDir "\main.ahk.tmp")
if FileExist(A_ScriptDir "\~updater.bat")
    FileDelete(A_ScriptDir "\~updater.bat")

; Check for updates on launch — macro not running yet so safe to update
SetTimer(CheckForUpdates, -1500)
SetDefaultMouseSpeed(0)
CoordMode("Mouse", "Screen")
; ================================================================
;   DenniXD ATS MACRO V2.3.6 — Combined Double Dungeon + Abandon Village
; ================================================================
; ---------------- INITIALIZE FILES ----------------
InitFiles() {
    iniPath := A_ScriptDir "\Settings.ini"
    seqPath := A_ScriptDir "\Sequences.txt"
    ; Create Settings.ini with defaults if missing
    if (!FileExist(iniPath)) {
        FileAppend("[Settings]`nWebhook=`nPSLink=`nUIColor=1A1A1A`nUserSpeed=33`nCreatorSpeed=33`n", iniPath, "UTF-8")
    }
    ; Create empty Sequences.txt if missing
    if (!FileExist(seqPath)) {
        FileAppend("; DenniXD ATS Macro V2.3.6 - Sequences`n; Auto-generated on first run`n", seqPath, "UTF-8")
    }
}
InitFiles()

; ---------------- INITIALIZE SETTINGS ----------------
global IniFile        := A_ScriptDir "\Settings.ini"
global DiscordWebhook := IniRead(IniFile, "Settings", "Webhook", "")
global MacroVersion      := "2.3.6"
global CreatorSpeed      := 33      ; macro creator's in-game speed (do not change)
global UserSpeed         := 33      ; user's in-game speed (set in Settings)
global SpeedScale        := 1.0     ; calculated as CreatorSpeed / UserSpeed
global UpdateAttempted   := false  ; prevents re-checking every cycle
global RepoOwner      := "DenniXDReal"
global RepoName       := "Anime-Tactical-Simulator"
global RawBase        := "https://raw.githubusercontent.com/" . RepoOwner . "/" . RepoName . "/main/ATSMacro/"
global PrivateServer  := IniRead(IniFile, "Settings", "PSLink",  "")
global UserSpeed      := Integer(IniRead(IniFile, "Settings", "UserSpeed", "33"))
global CreatorSpeed   := Integer(IniRead(IniFile, "Settings", "CreatorSpeed", "33"))
global CustomColor    := IniRead(IniFile, "Settings", "UIColor", "1A1A1A")
global Running         := false
global DemonRuns       := 0
global DungeonRuns     := 0
global RejoinCount     := 0
global SessionStart    := A_TickCount
global RaidStartTime   := 0
global HasRunSpecial   := false
global AVEntryFails    := 0
global SettingsVisible := false
global DebugVisible    := false
global RobloxTitle     := "Roblox"
global CurrentRaidStep := 0
global LastRejoinTime  := 0   ; tracks last time PS link was opened (ms)
; ── Farm mode toggles (true = enabled) ──
global ModeAbandonVillage := true    ; Abandon Village (ex Demon Slayer)
global ModeDoubleDungeon  := true    ; Double Dungeon
global ModeRift           := false   ; Rift
global RiftRuns           := 0
global RaidRuns           := 0
global ModeRaid           := false
global RaidType           := "Normal"
global CustomRuns         := 0        ; runs of user-loaded custom macro
global CustomRunName      := "CUSTOM"  ; display name from loaded file
global MacroPaused        := false     ; F4 pause toggle
global MacroLock          := false     ; prevents mode overlap
global LastAVTime         := 0          ; last time AV ran (ms)
global LastRiftTime       := 0          ; last time Rift ran (ms)
global AVIntervalMs       := 600000     ; AV runs every 10 min
global RiftIntervalMs     := 900000     ; Rift runs every 15 min
global LiveTimerActive    := false     ; live countdown timer running
global CrashCheckActive   := false     ; crash watchdog active
global ModeSummoning      := false   ; Summoning
global SummonHasRun       := false   ; runs only once per macro session
; ── Summoning settings ──
global SummonMaps             := ["Dungeon Town", "Reaper Society", "Map 3", "Map 4", "Map 5"]
global SummonMap              := "Dungeon Town"  ; currently selected map
global HasSummonedThisSession := false
; ── Custom Movement ──
global ModeCustomMovement := false   ; Custom Movement (user-defined sequences)
global SeqFile            := A_ScriptDir "\Sequences.txt"
global SeqFileCustom      := ""  ; path to a user-loaded custom seq file
global FolderCustom       := A_ScriptDir "\Custom"
global FolderRaids        := A_ScriptDir "\Raids"
global FolderSummon       := A_ScriptDir "\Summon"
global MovementFiles      := Map()  ; tracks which movement files are loaded
; Loaded custom sequences — keyed by sequence name
; e.g. CustomSeqs["DD_Step1"] := [{type:"key",key:"s",dur:500}, ...]
global CustomSeqs         := Map()
; Search Area Coordinates (for FindText enemy-count overlay)
; Search area — calculated dynamically from Roblox window at runtime
; These are set by UpdateSearchArea() on start and after every rejoin
global StartX := 600, StartY := 30, EndX := 850, EndY := 120
; ---------------- FINDTEXT CODES (Enemy Count Detection) ----------------
global Text35 := "|<>DF4744-323232$71.0000000000000000T07y00000003zUzy0000000DzVzw0000000zz3zs0000001wz7zU0000003kSD0000000030wS000000000TtzU00000001zXzk00000003y7zk00000007yDzk00000007yTTU00000000w0D0000000S1s0S0000000w3k0w0000001wDbXs0000001zzDzk0000003zwTz00000003zkTw00000001y0Dk000000000000000000000000000000000000000000000000001"
global Text34 := "|<>E14A47-323232$71.0000000000000000000000000007k1Uk0000000zs7Xs0000003zsD7k000000DzkSDU000000TDlwT0000000w7Xsy0000000kD7Vw00000007yD3s0000000Tsy7k0000000zVwDU0000001zXzz00000001zbzy00000000DDzw0000007USTzs000000D0w07k000000T3s0DU000000Tzk0T0000000zz00y0000000zw00s0000000TU01k000000000000000000000000000000000000001"
global Text33 := "|<>E14B48-0.90$71.0000000000000001A04k0000000Dy0zs0000000zy3zs0000003zwDzk0000007nwTDk000000D1sw7U000000A3kkD00000000zU3y00000003y0Ds0000000Ds0zU0000000Ts1zU0000000Ts1zU00000003k0D0000001s7bUS0000003kDD0w0000007kyT3s0000007zwTzk0000007zkTz000000000000000000000000000000000000000000000000000000000000000000000000001"
global Text32 := "|<>E65452-323232$71.000000000000000000000000000000000000000T01s00000003zUDw0000000DzUzw0000000zz3zw0000001wzDrs0000003kST3s00000030ww3k0000000Dts7U0000001zXkT00000003y01y00000007y07s00000007y0TU00000000w3y0000000S1sDs0000000w3kz00000001wDXy00000001zzDzy0000003zwTzw0000003zkzzs0000001y0zzU000000000000000000000000001"
global Text31 := "|<>E5514F-323232$71.0000000000000000000000000003s0400000000Tw0y00000001zw3w00000007zsDs0000000Dbszk0000000S3nzU0000000M7bz000000001zDy00000000DwBw00000000Tk3s00000000zk7k00000000zkDU000000007UT00000003kD0y00000007US1w0000000DVw3s0000000Dzs7k0000000TzUDU0000000Ty0C00000000Dk0Q0000000000000000000000000000000000000001"
global Text30 := "|<>DD4441-323232$71.0000000000000007k0T00000000zs3z00000003zsDz0000000Dzkzz0000000TDlzz0000000w7Xky0000000kDDUw00000007yS1s0000000Tsw3k0000000zVs7U0000001zXkD00000001zbUS00000000DD0w0000007UST1s000000D0wS7k000000T3syTU000000Tzlzy0000000zz1zw0000000zw1zk0000000TU1y0000000000000000000000000000000000000000000000000001"
global Text29 := "|<>DD4441-323232$71.0000000000000000000000000000000000000000w07k00000007y0zs0000000Ty3zs0000001zy7zk0000007zwT7k000000DVww7U000000S1tsD0000000w3nsy0000001sDbzw00000000z7zs00000003w7zk0000000Ds3zU0000001zU0S00000007w01w0000000zk07s0000001z01zU0000007zzDy0000000DzyTs0000000TzwzU0000000Tzls0000000000000000000000000001"
global Text28 := "|<>DF4744-323232$71.000000000000000000000000000000000000000D01w00000001zU7y00000007zUTy0000000TzVzy0000001zz3tw0000003sT7Vs0000007USD3k000000D0wTDU000000S3szy00000000Dkzw00000000z3zw00000003wDzs0000000TsT3s0000001z0w7k000000Ds1sDU000000Tk3sS0000001zznzw0000003zzbzk0000007zz7z00000007zw3w0000000000000000000000000001"
global Text27 := "|<>E34D4B-323232$71.0000S0Tz00000003z1zz0000000Dz3zy0000000zz7zw0000003zyDzs0000007ky07k000000D0w0T0000000S1s0y0000000w7k3s00000000TUDk00000001y0T000000007s1w00000000zU3s00000003y0DU0000000Tk0T00000000zU0w00000003zzVs00000007zz3k0000000Dzy7U0000000DzsC0000000000000000000000000000000000000000000000000000000000000001"
global Text26 := "|<>DD4441-323232$71.0000000000000000000000000000S00300000003z01z0000000Dz0Dy0000000zz0zw0000003zy3zk0000007ky7k0000000D0wT00000000S1sw00000000w7nt000000000Tbzk00000001yDzk00000007wTzU0000000zkyDU0000003y1sD0000000Ts3kS0000000zU7lw0000003zzbzs0000007zzDzU000000DzyDy0000000Dzs7k000000000000000000000000000000000000001"
global Text25 := "|<>DB413D-323232$71.00000000000000000D07z00000001zUTz00000007zUzy0000000TzVzw0000001zz3zk0000003sT7U00000007UST00000000D0wzk0000000S3tzs00000000Dnzs00000000z7zs00000003yDjk0000000Ts07U0000001z00D0000000Dw00S0000000Tk3lw0000001zzrzs0000003zzjzU0000007zzDy00000007zw7s00000000000000000000000000000000000000000000000001"
global Text24 := "|<>E14A47-323232$71.00007U1Uk0000000zk7Xs0000003zkD7k000000DzkSDU000000zzVwT0000001wDXsy0000003kD7Vw0000007USD3s000000D1wy7k00000007twDU0000000TXzz00000001y7zy0000000DsDzw0000000zUTzs0000007w007k000000Ds00DU000000zzs0T0000001zzk0y0000003zzU0s0000003zy01k00000000000000000000000000000000000000000000000000000000000001"
global Text23 := "|<>DB413D-323232$71.0000000000000000000000000000w03s00000007y0Tw0000000Ty1zw0000001zy7zs0000007zwDbs000000DVwS3k000000S1sM7U000000w3k3z0000001sDUDw00000000z0Tk00000003w0zk0000000Ds0zk0000001zU07U0000007w3kD0000000zk7US0000001z0Dlw0000007zzDzs000000DzyTzU000000TzwTy0000000TzkDk000000000000000000000000000000000000001"
global Text22 := "|<>DB413D-323232$71.0000000000000003k0D00000000Ts1zU0000001zs7zU0000007zsTzU000000Tzlzz0000000y7nsT0000001s7bUS0000003kDD0w0000007UyS3s00000003w0Dk0000000Dk0z00000000zU3y00000007y0Ts0000000Tk1z00000003z0Dw00000007w0Tk0000000Tzxzzk000000zzvzzU000001zzrzz0000001zz7zw000000000000000000000000000000000000000000000000001"
global Text21 := "|<>DD4441-323232$71.0000000000000000000000000000S00U00000003z07k0000000Dz0TU0000000zz1z00000003zy7y00000007kyTw0000000D0wzs0000000S1tzk0000000w7ljU00000000TUT000000001y0y000000007w1w00000000zk3s00000003y07k0000000Ts0DU0000000zU0T00000003zzUy00000007zz1w0000000Dzy3s0000000Dzs3U000000000000000000000000000000000000001"
global Text20 := "|<>DB413D-323232$71.000000000000000000000000000000000000000000000000001s07k0000000Dw0zk0000000zw3zk0000003zwDzk000000DzsTzk000000T3swDU000000w3nsD0000001s7bUS0000003kTD0w00000001yS1s00000007sw3k0000000Tls7U0000003z3kD0000000Ds7kS0000001zU7Vw0000003y0Dbs000000DzyTzU000000TzwTz0000000zzsTw0000000zzUTU0000000000000001"
global Text19 := "|<>DD4441-323232$71.00000000000000000E3s000000003sTw00000000Dlzw00000000zXzs00000003zDXs0000000DyS3k0000000Tww7U0000000ztwT00000000rnzy00000000DXzw00000000T3zs00000000y1zk00000001w0D000000003s0y000000007k3w00000000DUzk00000000T7z000000000yDw000000001wTk000000001kw0000000000000000000000000000000000000000000000000001"
global Text18 := "|<>E14B48-323232$71.000000000000000000000000000081w000000001w7y000000007sTy00000000Tlzy00000001zXtw00000007z7Vs0000000DyD3k0000000TwTDU0000000Pszy000000007kzw00000000DXzw00000000T7zs00000000yT3s00000001ww7k00000003tsDU00000007nsS00000000DXzw00000000T7zk00000000S7z000000000s3w0000000000000000000000000000000000000001"
global Text17 := "|<>E65452-323232$71.00000000000000000000000000000000000000000ETz000000003tzz00000000Dnzy00000000zbzw00000003zDzs0000000Dy07k0000000Tw0T00000000zs0y00000000rk3s00000000DUDk00000000T0T000000000y1w000000001w3s000000003sDU000000007kT000000000DUw000000000T1s000000000y3k000000000s7U000000001kC0000000000000000000000000001"
global Text16 := "|<>D83A36-323232$71.0000000000000000M07000000003s1z00000000DkDy00000000zUzw00000003z3zk0000000Dy7k00000000TwT000000000zsw000000000rnv000000000Dbzk00000000TDzk00000000yTzk00000001wyDU00000003tsD000000007nkS00000000Dblw00000000T7zs00000000yDzU00000001wDy000000001k7k0000000000000000000000000000000000000000000000000001"
global Text15 := "|<>E65452-323232$71.000000000000000000000000000083z000000001wTz000000007szy00000000Tlzw00000001zXzk00000007z7U00000000DyD000000000Twzk00000000Ptzs000000007nzs00000000Dbzs00000000T7jk00000000y07U00000001w0D000000003s0S000000007nlw00000000Dbzs00000000TDzU00000000QDy000000000s7k0000000000000000000000000000000000000001"
global Text14 := "|<>E14A47-323232$71.000000000000000000000000000010MA00000000DVsy00000000z3lw00000003y7Xs0000000DwT7k0000000zsyDU0000001zlsT00000003zXky00000003TDVw00000000yT3s00000001wzzk00000003tzzU00000007nzz00000000Dbzy00000000T01w00000000y03s00000001w07k00000003s0DU00000003k0C00000000700Q000000000000000000000000000000000000001"
global Text13 := "|<>E4514E-323232$71.000000000000000000000000000000000000000040T000000000y3zU00000003wDzU0000000Dszz00000000zlwz00000003zXkS00000007z30w0000000Dy0Ds0000000Bw1zU00000003s3y000000007k7y00000000DU7y00000000T00w00000000yS1s00000001ww3k00000003twDU00000007lzz00000000DXzw00000000D3zk00000000Q1y0000000000000000000000000001"
global Text11 := "|<>E4514E-323232$71.00000000000000000E0U000000003s7k00000000DkTU00000000zVz000000003z7y00000000DyTw00000000Twzs00000000ztzk00000000rljU00000000DUT000000000T0y000000000y1w000000001w3s000000003s7k000000007kDU00000000DUT000000000T0y000000000y1w000000000w1s000000001k3U000000000000000000000000000000000000000000000000001"
global Text7  := "|<>DF4744-323232$71.00000000000000000Tz0000000001zz0000000003zz0000000007zw000000000Dzs00000000007k0000000000T00000000000y00000000003s0000000000Dk0000000000T00000000001w00000000003s0000000000DU0000000000T00000000000w00000000001s00000000003k00000000007U0000000000C00000000000000000000000000000000000000000000000000001"
global Text12 := "|<>E34D4B-323232$71.000000000000000000000000000000000000000080w000000001w7y000000007sTy00000000Tlzy00000001zbzw00000007zDVw0000000DyS1s0000000Tww3k0000000PtsDU00000007k0z00000000DU3w00000000T0Dk00000000y1z000000001w7w000000003szU000000007lz000000000Dbzz00000000TDzy00000000STzw00000000sTzk000000000000000000000000001"
global Text10 := "|<>E14A47-323232$71.0000000000000000000000000000107U00000000DUzk00000000z3zk00000003yDzk0000000DwTjU0000000zswDU0000001znsD00000003zbUS00000003TD0w00000000yS1s00000001ww3k00000003ts7U00000007nkD00000000DbkS00000000T7Vw00000000yDbs00000001wTzU00000003sTz000000003kTw0000000070TU000000000000000000000000000000000000001"
global Text8  := "|<>DD4441-323232$71.000000000000000003s0000000000Dw0000000000zw0000000003zw0000000007ns000000000D3k000000000S7U000000000yT0000000001zw0000000001zs0000000007zs000000000Tzk000000000y7k000000001sDU000000003kT0000000007kw0000000007zs000000000DzU000000000Dy00000000007s0000000000000000000000000000000000000000000000000001"
global Text6  := "|<>D83A36-323232$71.000000000000000000000000000000000000000003U0000000000zU0000000007z0000000000Ty0000000001zs0000000003s0000000000DU0000000000S00000000001xU0000000003zs0000000007zs000000000Dzs000000000T7k000000000w7U000000001sD0000000003sy0000000003zw0000000007zk0000000007z00000000003s00000000000000000000000000001"
global Text5  := "|<>E34D4B-323232$71.00000000000000000000000000000000000000000zk0000000007zk000000000DzU000000000Tz0000000000zw0000000001s00000000003k0000000000Dw0000000000Ty0000000000zy0000000001zy0000000001vw00000000001s00000000003k00000000007U000000000wT0000000001zy0000000003zs0000000003zU0000000001w00000000000000000000000000001"
global Text4  := "|<>E5514E-323232$71.00000000000000000U80000000003lw0000000007Xs000000000D7k000000000yDU000000001wT0000000003ky0000000007Vw000000000T3s000000000y7k000000001zzU000000003zz0000000007zy000000000Dzw00000000003s00000000007k0000000000DU0000000000T00000000000Q00000000000s0000000000000000000000000000000000000000000000000001"
global Text2  := "|<>DD4441-323232$71.00000000000000000000000000000D00000000001zU0000000007zU000000000TzU000000001zz0000000003sT0000000007US000000000D0w000000000S3s0000000000Dk0000000000z00000000003y0000000000Ts0000000001z0000000000Dw0000000000Tk0000000001zzk000000003zzU000000007zz0000000007zw0000000000000000000000000000000000000001"
global Text1  := "|<>DF4744-323232$71.00000000000000000000000000000000000000000000000000000100000000000DU0000000000z00000000003y0000000000Dw0000000000zs0000000001zk0000000003zU0000000003T00000000000y00000000001w00000000003s00000000007k0000000000DU0000000000T00000000000y00000000001w00000000003s00000000003k0000000000700000000000000001"
global TextAVActive  := "|<>3F3F3F-0.90$71.000000000000000000000000000000000000Dzs0000003U0zzk000000701zzU000000C003U0000000Q0070400821ks00C7yDwsCDtk00QDwzvkwznU00sTnznlvvr001ks7bXbb7i003VkCD7jDzQ0073UQS7wTws00C70zwDkw1s00QC1zsDVzns00sQ1zkS1zbk01ks1vUQ1z7U00000000000000000000000000000000000000000000000000000000000000000000000000000000001"
global TextNightmare := "|<>FFB447-323232$141.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000E000U000000000000000000D000S0000000000000003s1tw003s01k000000000000T0DD000T00S0000000000003w1sE003s03k000000000000TkD0000T00S0000000000003z1s0003s03k000000000000TsD70SQTS1zstsS0DC7D0zU3zVtsDzXzwDzDzbs3ztzwTy0TyDDXzwTzlztzzzUzzDzbzs3vttwTzXzyDzDzzwDztzszT0TDDDblwTbsS1yzjXwzDUDVs3tztww7XsT3kDXsyT3tw1wD0T7zDbUwT1sS1wT7nkTDUDzs3sTtww7XsD3kDXsyS3tw1zz0T1zDblwT1sS1wT7nsTDUDU03sDtwTzXsD3sDXsyTztw1w00T0zDXzwT1sTtwT7lzzDU7zk3s3tsDzXkD1zDXsy7ztw0zz0S0DD0ywS1s7tsC3UTzD03zs1k0ks07Vk60C71kQ0kks07w0000000w000000000000000000000ADU000000000000000000001zs000000000000000000000Tz0000000000000000000000zU00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
global TextMedium    := "|<>FFBC4C-323232$141.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000620000000000000000000001ts0000000000000DU0S0000DDU0000000000001w07k0001ts0000000000000Dk1y0000D200000000000001z0Tk0001s00000000000000Dw3y0000D000000000000001zkzkDs1tssQ3lnkw0000000DyDy7zUTzD7USTzDk0000001zvzlzy7ztwy3nzzz0000000DjzSDrlzzDbkSTzzs0000001wznnsSDbtwy3nxzT0000000DbwST3nsTDbkST7lw0000001wT3nzyS3twy3nsyDU000000DVsSTznkTDbkST7lw0000001w43ns0T3twS7nsyDU000000DU0ST01zzD3zyT7lw0000001s03lyQDztsTznky7U000000D00S7zkzzD1zyS7kw0000000s03kTy3zss7vlkQ70000000200A0z024604AA10E0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
global TextEasy      := "|<>FFD258-323232$141.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000zw000000000000000000000Tzs000000000000000000007zz000000000000000000000zzs000000000000000000007zz000000000000000000000y00000000000000000000007k00wsDsQ1k0000000000000y00DzXzrUT00000000000007zs3zwTwy3k0000000000000zz0zzXV3ky00000000000007zsDnwQ0T7U0000000000000zz1sDXw1sw00000000000007k0D1wTwDj00000000000000w01sDVzkzs00000000000003U0DVw1y3z00000000000000S00yTU1kTk00000000000003zz7zwQS1w0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
global TextHard      := "|<>FFC752-323232$141.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000M00000000000000000000007U0000000000007U7U000000w0000000000000y0w0000007U0000000000007k7k000000w0000000000000y0y0000007U0000000000007k7k000000w0000000000000y0y1tkts7bU0000000000007k7kTzDzVzw0000000000000zzy7ztzwTzU0000000000007zzlzzDz7zw0000000000000zzyTbtw0yTU0000000000007zzXsTDUDVw0000000000000y0wS3ts1s7U0000000000007k7XkTD0D1w0000000000000w0wT3ts1wDU0000000000007U7VxzD07nw0000000000000w0wDzts0zzU0000000000003U7Uzz703zw0000000000000Q0Q3xks0DrU0000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004"
global TextLoaded := "|<>FBFFFB-323232$71.0000000000000000000000000000000000000000000003U0Tzk000000700zzU000000C003U0000000Q00700000000s00C7wDwsCDlk00QDsztkQznU00sTnznlvnr001ks77XXb3i003VkC77iDyQ0073UQC7wTss00C70ww7ks1k00QC0zsDUzns00sQ0zkC1zbk01UM0l080y3U00000000000000000000000000000000000000000000000000000000000000000000000000000000001"
global Text0  := "|<>D83A37-323232$71.00000000000000000000000000000T00000000003z0000000000Dz0000000000zz0000000001zz0000000003ky000000000DUw000000000S1s000000000w3k000000001s7U000000003kD0000000007US000000000D0w000000000T1s000000000y7k000000000yTU000000001zy0000000001zw0000000001zk0000000001y00000000000000000000000000000000000000001"
; ================================================================
;   GUI SETUP  —  Modern dark card layout
; ================================================================
MyGui := Gui("+AlwaysOnTop -Caption +Border", "DenniXD ATS Macro V2.3.6")
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
MyGui.AddText("x16 y32 w300", "V2.3.6  ·  Double Dungeon + Abandon Village")

; Close [ X ]
MyGui.SetFont("s10 cFF4455 Bold", "Segoe UI")
MyGui.AddText("x404 y10 w22 h22 Center", "✕").OnEvent("Click", (*) => ExitApp())

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
MyGui.AddText("x16 y262 w60", "NEXT IN:")
MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global GuiLiveTimer := MyGui.AddText("x80 y260 w280", "—")

; ── Divider ──────────────────────────────────────────────────────
MyGui.SetFont("s7", "Segoe UI")
MyGui.AddText("x16 y276 w348 h1 Background222222", "")

; ── Farm Mode Selector ───────────────────────────────────────────
MyGui.SetFont("s8 cAAAAAA Norm", "Segoe UI")
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

; ── Hotkey hint ──────────────────────────────────────────────────
MyGui.SetFont("s8 c444444 Norm", "Segoe UI")
MyGui.AddText("x16 y458 w398 Center", "F1 Start  ·  F2 Stop  ·  F3 Kill  ·  F4 Pause  ·  F5 Reset")


; ── Settings panel (hidden) ──────────────────────────────────────
MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global TextWeb := MyGui.AddText("x16 y480 w348 Hidden", "DISCORD WEBHOOK URL")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global EditWeb := MyGui.AddEdit("x16 yp+16 w348 h24 Hidden Background1A1A1A", DiscordWebhook)

MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global TextPS  := MyGui.AddText("x16 yp+32 w348 Hidden", "ROBLOX PRIVATE SERVER LINK")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global EditPS  := MyGui.AddEdit("x16 yp+16 w348 h24 Hidden Background1A1A1A", PrivateServer)

MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global TextSpeedHeader := MyGui.AddText("x16 yp+32 w348 Hidden", "SPEED SCALING")
MyGui.SetFont("s8 cAAAAAA Norm", "Segoe UI")
global TextCreatorSpeed := MyGui.AddText("x16 yp+14 w160 Hidden", "Creator Speed (default)")
global TextUserSpeed    := MyGui.AddText("x196 yp w160 Hidden", "Your Speed")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global EditCreatorSpeed := MyGui.AddEdit("x16 yp+16 w160 h24 Hidden Background1A1A1A", CreatorSpeed)
global EditSpeed        := MyGui.AddEdit("x196 yp w160 h24 Hidden Background1A1A1A", UserSpeed)
MyGui.SetFont("s8 cAAAAAA Norm", "Segoe UI")
MyGui.AddText("x16 yp+28 w348 Hidden", "Scale = Creator ÷ Your Speed  (33÷30 = 1.10x slower)")

MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global TextCol := MyGui.AddText("x16 yp+32 w348 Hidden", "UI ACCENT COLOR (HEX)")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global EditCol := MyGui.AddEdit("x16 yp+16 w100 h24 Hidden Background1A1A1A", CustomColor)

MyGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
global BtnTestSS := MyGui.AddButton("x16 yp+36 w168 h28 Background333333 Hidden", "📸  Test Screenshot")
BtnTestSS.OnEvent("Click", (*) => CaptureAndSend(true))
global BtnDebug  := MyGui.AddButton("x192 yp+0 w172 h28 Background333333 Hidden", "🔍  Toggle Debug")
BtnDebug.OnEvent("Click", ToggleDebugBox)
global BtnTestJoin    := MyGui.AddButton("x16 yp+36 w168 h28 Background1A3A2A Hidden", "🔗  Test Join PS")
BtnTestJoin.OnEvent("Click", (*) => TestJoinPS())
global BtnTestWebhook := MyGui.AddButton("x192 yp+0 w172 h28 Background1A1A3A Hidden", "📡  Test Webhook")
BtnTestWebhook.OnEvent("Click", (*) => CaptureAndSend(true))
global BtnLoadSeqFile := MyGui.AddButton("x16 yp+36 w398 h28 Background1A2A1A Hidden", "📂  Load Custom Sequence File")
BtnLoadSeqFile.OnEvent("Click", (*) => LoadCustomSeqFile())
global LblSeqFile := MyGui.AddText("x16 yp+30 w348 c888888 Hidden", "No custom file loaded")
; Movement folder reload buttons
MyGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
global LblMovFiles := MyGui.AddText("x16 yp+28 w348 Hidden", "MOVEMENT FILES")
MyGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
global BtnReloadCustom := MyGui.AddButton("x16 yp+16 w110 h26 Background1A2A1A Hidden", "🔄 Custom")
BtnReloadCustom.OnEvent("Click", (*) => ReloadMovementFolder(FolderCustom))
global BtnReloadRaids := MyGui.AddButton("x134 yp+0 w110 h26 Background1A1A2A Hidden", "🔄 Raids")
BtnReloadRaids.OnEvent("Click", (*) => ReloadMovementFolder(FolderRaids))
global BtnReloadSummon := MyGui.AddButton("x252 yp+0 w112 h26 Background2A1A1A Hidden", "🔄 Summon")
BtnReloadSummon.OnEvent("Click", (*) => ReloadMovementFolder(FolderSummon))
global BtnSave   := MyGui.AddButton("x16 yp+36 w168 h30 Background7B2FFF Hidden", "SAVE & APPLY")
global BtnUpdate      := MyGui.AddButton("xp+176 yp w172 h30 Background2A2A2A Hidden", "🔄 Check Updates")
global BtnForceUpdate := MyGui.AddButton("x16 yp+36 w348 h24 Background3A1A1A Hidden", "⚠ Force Update (re-download everything)")
BtnSave.OnEvent("Click", SaveSettings)
BtnUpdate.OnEvent("Click", (*) => (Running ? MsgBox("Stop the macro before checking for updates.", "Update", 48) : CheckForUpdates()))
BtnForceUpdate.OnEvent("Click", (*) => (Running ? MsgBox("Stop the macro before force updating.", "Update", 48) : CheckForUpdates(true)))

; ── Summon Map Section (in settings) ─────────────────────────────
MyGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
global LblSummonSec := MyGui.AddText("x16 yp+40 w348 Hidden", "SUMMON MAP")
MyGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
global DdlSummonMap := MyGui.AddDropDownList("x16 yp+16 w348 Hidden", ["Dungeon Town", "Reaper Society", "Map 3", "Map 4", "Map 5"])
DdlSummonMap.OnEvent("Change", UpdateSummonMap)
DdlSummonMap.Value := 1
global ChkSummonActive := MyGui.AddCheckbox("x16 yp+28 w348 Hidden", "Enable Summon Each Run")
ChkSummonActive.OnEvent("Click", (*) => UpdateSummonActive())

MyGui.Show("w430 h474")
LoadSequences()  ; load Sequences.txt (editor-saved sequences)
InitFolders()    ; create folders if missing
LoadAllMovementFiles()  ; load movements from Custom/Raids/Summon folders

; Debug overlay GUI
DebugGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
DebugGui.BackColor := "Red"
; ================================================================
;   HOTKEYS
; ================================================================
F1:: StartMacro()
F2:: StopMacro()
F3:: KillAll()
F4:: TogglePause()
F5:: Execute_ResetTravelUI()
; ================================================================
;   CORE LOGIC
; ================================================================


StartMacro() {
    global Running, SessionStart, CurrentRaidStep, HasSummonedThisSession, RobloxTitle
    Running                 := true
    SessionStart            := A_TickCount
    CurrentRaidStep         := 0
    HasSummonedThisSession  := false
    UpdateSpeedScale()  ; calculate speed scalar from user speed setting
    UpdateSearchArea()  ; calculate search region from current Roblox window size

    ; Restore cooldown timestamps from INI so restarts respect real cooldowns
    savedAV   := Integer(IniRead(IniFile, "Cooldowns", "LastAVTime",   "0"))
    savedRift := Integer(IniRead(IniFile, "Cooldowns", "LastRiftTime", "0"))
    now       := A_TickCount
    ; Only restore if the saved time is recent (within 2x the interval)
    ; A_TickCount resets on reboot so we store real-world epoch via A_Now
    savedAVEpoch   := IniRead(IniFile, "Cooldowns", "LastAVEpoch",   "0")
    savedRiftEpoch := IniRead(IniFile, "Cooldowns", "LastRiftEpoch", "0")
    if (savedAVEpoch != "0") {
        elapsedSinceAV := DateDiff(A_Now, savedAVEpoch, "Seconds") * 1000
        LastAVTime := (elapsedSinceAV < AVIntervalMs) ? (now - elapsedSinceAV) : 0
    }
    if (savedRiftEpoch != "0") {
        elapsedSinceRift := DateDiff(A_Now, savedRiftEpoch, "Seconds") * 1000
        LastRiftTime := (elapsedSinceRift < RiftIntervalMs) ? (now - elapsedSinceRift) : 0
    }
    GuiStatus.Text  := "● Running"
    GuiStatus.Opt("c00FF99")

    ; ── Always rejoin on start to ensure clean server state ──
    GuiStatus.Text := "Rejoining server..."
    RejoinPS()

    ; Run summon immediately at start if enabled
    if (ModeSummoning)
        RunSummon()
    SetTimer(MainLoop, 150)
    SetTimer(LiveTimerTick, 1000)
    SetTimer(CrashWatchdog, 5000)
}
StopMacro() {
    global Running, SummonHasRun, MacroLock, LastAVTime, LastRiftTime, CurrentRaidStep, MacroPaused
    SummonHasRun    := false
    MacroLock       := false
    ; Persist cooldown timestamps so they survive macro stop/start
    IniWrite(LastAVTime,   IniFile, "Cooldowns", "LastAVTime")
    IniWrite(LastRiftTime, IniFile, "Cooldowns", "LastRiftTime")
    LastAVTime      := 0
    LastRiftTime    := 0
    Running         := false
    CurrentRaidStep := 0
    MacroPaused     := false
    GuiStatus.Text  := "● Stopped"
    GuiStatus.Opt("cFF3355")
    SetTimer(MainLoop, 0)
    SetTimer(LiveTimerTick, 0)
    SetTimer(CrashWatchdog, 0)
    GuiLiveTimer.Text := "—"
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
    global Running, CurrentRaidStep, RaidStartTime, MacroLock
    global ModeAbandonVillage, ModeDoubleDungeon, ModeRift, ModeSummoning, ModeCustomMovement, ModeRaid
    global LastAVTime, LastRiftTime, AVIntervalMs, RiftIntervalMs
    if (!Running)
        return
    if (MacroPaused) {
        GuiStatus.Text := "⏸ Paused — F4 to resume"
        return
    }
    if (MacroLock)
        return

    ; Safety timeout — force rejoin if DD takes longer than 5 minutes
    if (CurrentRaidStep > 0 && RaidStartTime > 0 && (A_TickCount - RaidStartTime > 300000)) {
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
    ; AV      → timed every 10 min (AVIntervalMs = 600000ms)
    ; Rift    → timed every RiftIntervalMs (default 15 min)
    ; DD / Raid / Custom → filler, run every cycle if enabled
    ;
    ; Full order when all on: Summon > AV > Rift > DD > Raid > Custom
    ; If AV/Rift off → DD/Raid/Custom just loop continuously

    ; 1. Summon — once per session
    if (Running && ModeSummoning)
        RunSummon()

    ; 2. AV — only when interval elapsed
    if (Running && ModeAbandonVillage) {
        now   := A_TickCount
        avDue := (LastAVTime == 0 || (now - LastAVTime >= AVIntervalMs))
        if (avDue) {
            RunDemonSlayer()
            LastAVTime := A_TickCount  ; set AFTER run completes
            IniWrite(A_Now, IniFile, "Cooldowns", "LastAVEpoch")
            UpdateUI()
        } else {
            remaining := Round((AVIntervalMs - (now - LastAVTime)) / 1000)
            m := remaining // 60
            s := Mod(remaining, 60)
            GuiStatus.Text := "AV in " . m . "m " . s . "s"
        }
    }

    ; 3. Rift — only when interval elapsed
    if (Running && ModeRift) {
        now      := A_TickCount
        riftDue  := (LastRiftTime == 0 || (now - LastRiftTime >= RiftIntervalMs))
        if (riftDue) {
            RunRift()
            LastRiftTime := A_TickCount  ; set AFTER run completes
            IniWrite(A_Now, IniFile, "Cooldowns", "LastRiftEpoch")
            UpdateUI()
        } else {
            remaining := Round((RiftIntervalMs - (now - LastRiftTime)) / 1000)
            m := remaining // 60
            s := Mod(remaining, 60)
            GuiStatus.Text := "Rift in " . m . "m " . s . "s"
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
        "AV_Entry",1,"AV_Step1",1,"Rift_Custom",1,
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

RunDemonSlayer() {
    global Running, DemonRuns, RaidStartTime, AVEntryFails
    GuiStatus.Text := "Abandon Village — Entering"
    RunCustomOrDefault("AV_Entry",      (*) => 0)
    RaidStartTime := A_TickCount
    ; ── Entry check: wait up to 90s for Text2 (2 enemies = stage loaded) ──
    ; Just keep polling — do NOT re-run entry sequence as it resets position
    GuiStatus.Text := "Abandon Village — Waiting for enemies..."
    EntryDeadline := A_TickCount + 90000  ; 90s total wait
    Loop {
        if (!Running)
            return
        if (A_TickCount > EntryDeadline) {
            ; Before giving up — check if difficulty text is visible (confirms in stage)
            if (CheckDifficultyDetected()) {
                GuiStatus.Text := "Abandon Village — Difficulty detected, continuing..."
                break
            }
            AVEntryFails += 1
            GuiStatus.Text := "Abandon Village — Timed out, no stage detected — restarting cycle"
            return
        }
        ; Also check difficulty mid-poll as faster confirmation
        if (CheckDifficultyDetected()) {
            AVEntryFails := 0
            GuiStatus.Text := "Abandon Village — Stage confirmed via difficulty"
            break
        }
        if GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text2) {
            AVEntryFails  := 0
            GuiStatus.Text := "Abandon Village — Stage confirmed"
            break
        }
        Sleep(1000)
    }
    ; Text2 already confirmed — run Step1 immediately
    GuiStatus.Text := "Abandon Village — Step 1"
    RunCustomOrDefault("AV_Step1",      (*) => 0)
    ; ── Wait for completion ──
    ; Step 1: Confirm TextAVActive is visible (stage is running)
    GuiStatus.Text := "Abandon Village — Waiting for stage to activate..."
    AVActiveDeadline := A_TickCount + 60000
    Loop {
        if (!Running)
            return
        if (A_TickCount > AVActiveDeadline) {
            GuiStatus.Text := "Abandon Village — Stage never activated, returning..."
            CaptureAndSend(false)
            ReturnToLobby()
            return
        }
        if GetFindText().FindText(&FoundX, &FoundY, 27, 577, 127, 627, 0.15, 0.15, TextAVActive) {
            GuiStatus.Text := "Abandon Village — Stage active, running..."
            break
        }
        Sleep(500)
    }

    ; Step 2: Watch for TextLoaded (end screen) = win condition
    ; TextLoaded appears at 27,577->127,627 same as rejoin game load detection
    CompletionDeadline := A_TickCount + 300000  ; 5 min max safety
    Loop {
        if (!Running)
            return
        if (A_TickCount > CompletionDeadline) {
            GuiStatus.Text := "Abandon Village — Timeout, returning to lobby..."
            CaptureAndSend(false)
            ReturnToLobby()
            return
        }
        ; Win condition: end screen detected = stage cleared
        if GetFindText().FindText(&FoundX, &FoundY, 27, 577, 127, 627, 0, 0, TextLoaded) {
            Sleep(1000)
            ; Double check its still there
            if GetFindText().FindText(&FoundX, &FoundY, 27, 577, 127, 627, 0, 0, TextLoaded) {
                DemonRuns += 1
                GuiStatus.Text := "● Done  [AV: " . DemonRuns . "]"
                Sleep(5000)
                CaptureAndSend(false)
                ReturnToLobby()
                return
            }
        }
        Sleep(1000)
    }
}
RunDoubleDungeon() {
    global Running, CurrentRaidStep, DungeonRuns, RaidStartTime
    if (!Running)
        return
    ; ── Step 0: Enter the raid ──────────────────────────────────
    if (CurrentRaidStep == 0) {
        GuiStatus.Text := "Double Dungeon — Entering"
        RunCustomOrDefault("DD_EnterRaid",  (*) => 0)
        RaidStartTime   := A_TickCount
        CurrentRaidStep := 0.5
        ; ── Entry confirmation: wait up to 90s for 12 enemies ───
        ; Just keep polling — do NOT re-run entry as it resets position
        GuiStatus.Text := "Double Dungeon — Waiting for enemies..."
        EntryDeadline := A_TickCount + 90000
        Loop {
            if (!Running)
                return
            if (A_TickCount > EntryDeadline) {
                ; Before giving up — check if difficulty text is visible (confirms in stage)
                if (CheckDifficultyDetected()) {
                    GuiStatus.Text := "Double Dungeon — Difficulty detected, continuing..."
                    break
                }
                GuiStatus.Text := "Double Dungeon — Timed out, no stage detected — restarting cycle"
                CurrentRaidStep := 0
                return
            }
            ; Also check difficulty mid-poll as faster confirmation
            if (CheckDifficultyDetected()) {
                GuiStatus.Text := "Double Dungeon — Stage confirmed via difficulty"
                break
            }
            if GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text12) {
                GuiStatus.Text := "Double Dungeon — Stage confirmed (12 enemies)"
                break
            }
            Sleep(500)
        }
        return
    }
    ; ── Step 0.5: Confirmed inside — run Step 1 ─────────────────
    if (CurrentRaidStep == 0.5) {
        if GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text12) {
            RunCustomOrDefault("DD_Step1",      (*) => 0)
            CurrentRaidStep := 2
            Sleep(2913)   ; Step 1 total: 2563+100+250
        } else {
            GuiStatus.Text := "Double Dungeon — Waiting for enemies..."
        }
        return
    }
    ; ── Step 2 → 10: Enemy-count driven progression ─────────────
    if (CurrentRaidStep == 2 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text10)) {
        RunCustomOrDefault("DD_Step2",      (*) => 0)
        CurrentRaidStep := 3
        Sleep(1319)   ; Step 2 total: 875+100+344
    }
    else if (CurrentRaidStep == 3 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text8)) {
        RunCustomOrDefault("DD_Step3",      (*) => 0)
        CurrentRaidStep := 4
        Sleep(3684)   ; Step 3 total: 2266+100+218+100+1000
    }
    else if (CurrentRaidStep == 4 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text6)) {
        RunCustomOrDefault("DD_Step4",      (*) => 0)
        CurrentRaidStep := 5
        Sleep(929)    ; Step 4 total: 563+100+266
    }
    else if (CurrentRaidStep == 5 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text4)) {
        RunCustomOrDefault("DD_Step5",      (*) => 0)
        CurrentRaidStep := 6
        Sleep(3607)   ; Step 5 total: 1500+100+407+100+1500
    }
    else if (CurrentRaidStep == 6 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text2)) {
        RunCustomOrDefault("DD_Step6",      (*) => 0)
        CurrentRaidStep := 7
        Sleep(1025)   ; Step 6 total: 625+100+300
    }
    else if (CurrentRaidStep == 7 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text10)) {
        RunCustomOrDefault("DD_Step7",      (*) => 0)
        CurrentRaidStep := 8
        Sleep(16711)  ; Step 7 total: 4016+100+5063+100+2438+100+1172+100+453+100+1500+100+1469
    }
    else if (CurrentRaidStep == 8 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text5)) {
        RunCustomOrDefault("DD_Step8",      (*) => 0)
        CurrentRaidStep := 9
        Sleep(19511)  ; Step 8 total: 8938+100+3610+100+2328+100+188+100+219+100+1360+100+1640+100+172+100+156
    }
    else if (CurrentRaidStep == 9 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text1)) {
        RunCustomOrDefault("DD_Step9",      (*) => 0)
        CurrentRaidStep := 10
        Sleep(6716)   ; Step 9 total: 2641+100+3032+100+843
    }
    else if (CurrentRaidStep == 10 && GetFindText().FindText(&FoundX, &FoundY, StartX, StartY, EndX, EndY, 0.15, 0.15, Text0)) {
        RunCustomOrDefault("DD_Step10",     (*) => 0)
        DungeonRuns += 1
        CurrentRaidStep := 0
        GuiStatus.Text := "● Done  [DD: " . DungeonRuns . "]"
        Sleep(5000)
        CaptureAndSend(false)
        ReturnToLobby()
        return
    }
    GuiStatus.Text := "Double Dungeon (Step " . CurrentRaidStep . ")"
}
; ================================================================
;   DOUBLE DUNGEON — MOVEMENT FUNCTIONS
; ================================================================
; ================================================================
;   RIFT MODE
; ================================================================
RunRift() {
    global Running, RiftRuns, RaidStartTime, CurrentRaidStep
    GuiStatus.Text := "Rift — Starting"
    RaidStartTime  := A_TickCount

    ; Run custom Rift sequence if recorded
    RunCustomOrDefault("Rift_Custom",   (*) => 0)

    ; ── Time check: wrap up every 15 mins ──
    Loop {
        if (!Running)
            return
        currMin := Integer(FormatTime(, "mm"))
        ; Fire at XX:00, XX:15, XX:30, XX:45
        if (Mod(currMin, 15) == 0) {
            GuiStatus.Text := "Rift — 15min window complete, wrapping up..."
            break
        }
        ; Safety timeout 14 min 30s
        if (A_TickCount - RaidStartTime > 870000) {
            GuiStatus.Text := "Rift — Safety timeout, wrapping up..."
            break
        }
        Sleep(5000)
    }

    RiftRuns += 1
    GuiStatus.Text := "Rift — Run complete [" RiftRuns "]"
    Sleep(5000)
    CaptureAndSend(false)
    ReturnToLobby()
}




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
        ; Fallback — use a wide area covering the full top of the screen
        StartX := 0
        StartY := 0
        EndX   := A_ScreenWidth
        EndY   := Round(A_ScreenHeight * 0.25)
        return
    }
    WinGetPos(&wx, &wy, &ww, &wh, RobloxTitle)
    ; Cast a wide net — full width, top 25% of window
    ; Better to scan more area than to miss the enemy count UI
    StartX := wx
    StartY := wy
    EndX   := wx + ww
    EndY   := wy + Round(wh * 0.25)
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
    total := 0
    for step in steps {
        if (step.Has("dur"))
            total += step["dur"]
    }
    return total
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
Execute_ReturnToLobby() {
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 2)
    }
    BlockInput("On")
    SafeClick(1564, 827), Sleep(100)
    Loop 11 {
        SafeClick(1564, 804), Sleep(80)
    }
    Send("{f down}"), Sleep(63), Send("{f up}")
    SafeClick(1234, 597), Sleep(100)
    SafeClick(1234, 597)
    BlockInput("Off")
}

Execute_ResetTravelUI() {
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }
    SafeClick(1296, 572), Sleep(100), SafeClick(1296, 572), Sleep(5000)
    Send("{\ down}"),  Sleep(94),  Send("{\ up}")
    Send("{f down}"),  Sleep(110), Send("{f up}")
    Send("{s down}"),  Sleep(94),  Send("{s up}")
    Send("{d down}"),  Sleep(78),  Send("{d up}")
    Send("{s down}"),  Sleep(78),  Send("{s up}")
    Send("{s down}"),  Sleep(78),  Send("{s up}")
    Send("{s down}"),  Sleep(78),  Send("{s up}")
    Send("{s down}"),  Sleep(94),  Send("{s up}")
    Send("{s down}"),  Sleep(93),  Send("{s up}")
    Send("{s down}"),  Sleep(93),  Send("{s up}")
    Send("{s down}"),  Sleep(109), Send("{s up}")
    Send("{s down}"),  Sleep(109), Send("{s up}")
    Send("{s down}"),  Sleep(93),  Send("{s up}")
    Send("{s down}"),  Sleep(94),  Send("{s up}")
    Send("{\ down}"),  Sleep(110), Send("{\ up}")
    Send("{f down}"),  Sleep(110), Send("{f up}")
    BlockInput("On")
    SafeClick(1296, 572)
    Sleep(80)
    SafeClick(1296, 572)
    BlockInput("Off")
    Sleep(3000)
}

ReturnToLobby() {
    global CurrentRaidStep, RaidStartTime, RobloxTitle, Running
    CurrentRaidStep := 0
    RaidStartTime   := 0
    if (!Running)
        return
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }
    GuiStatus.Text := "Returning to lobby..."
    Execute_ReturnToLobby()
    ; Wait for lobby to load before next cycle
    Sleep(3000)
    GuiStatus.Text := "Back in lobby — ready for next cycle"
    ; MainLoop timer re-arms itself — cycle continues automatically
}

; ── Mode toggle — flips enabled state, updates button colour, WIP modes blocked ──
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
    global SettingsVisible
    SettingsVisible := !SettingsVisible
    for ctrl in [TextWeb, EditWeb, TextPS, EditPS, TextSpeedHeader, TextCreatorSpeed, TextUserSpeed, EditCreatorSpeed, EditSpeed, TextCol, EditCol, BtnSave, BtnUpdate, BtnForceUpdate, BtnTestSS, BtnDebug, BtnTestJoin, BtnTestWebhook, BtnLoadSeqFile, LblSeqFile, LblMovFiles, BtnReloadCustom, BtnReloadRaids, BtnReloadSummon, LblSummonSec, DdlSummonMap, ChkSummonActive] {
        ctrl.Visible := SettingsVisible
    }
    MyGui.Show(SettingsVisible ? "h960" : "h474")
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
    CreatorSpeed       := Integer(EditCreatorSpeed.Value) > 0 ? Integer(EditCreatorSpeed.Value) : 33
    UserSpeed          := Integer(EditSpeed.Value) > 0 ? Integer(EditSpeed.Value) : 33
    EditCreatorSpeed.Value := CreatorSpeed
    EditSpeed.Value        := UserSpeed
    UpdateSpeedScale()
    CustomColor     := EditCol.Value
    MyGui.BackColor := CustomColor
    IniWrite(DiscordWebhook, IniFile, "Settings", "Webhook")
    IniWrite(PrivateServer,  IniFile, "Settings", "PSLink")
    IniWrite(CreatorSpeed,   IniFile, "Settings", "CreatorSpeed")
    IniWrite(UserSpeed,      IniFile, "Settings", "UserSpeed")
    IniWrite(CustomColor,    IniFile, "Settings", "UIColor")
    ToggleSettings()
}
ResetStats(*) {
    global DemonRuns, DungeonRuns, RejoinCount, CurrentRaidStep, SessionStart
    if (MsgBox("Reset all stats?", "Confirm", "YesNo") == "Yes") {
        DemonRuns       := 0
        DungeonRuns     := 0
        RejoinCount     := 0
        CurrentRaidStep := 0
        SessionStart    := A_TickCount
        UpdateUI()
    }
}
LiveTimerTick() {
    global Running, MacroPaused
    if (!Running || MacroPaused)
        return
    ; Show seconds until next XX:X5 window
    currMin := Integer(FormatTime(, "mm"))
    currSec := Integer(FormatTime(, "ss"))
    minInBlock := Mod(currMin, 10)
    if (minInBlock < 5) {
        secsLeft := (5 - minInBlock) * 60 - currSec
        UpdateLiveTimer("AV→DD", secsLeft)
    } else {
        secsLeft := (15 - minInBlock) * 60 - currSec
        UpdateLiveTimer("DD→AV", secsLeft)
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
}

UpdateLiveTimer(label, secondsLeft) {
    global GuiLiveTimer
    if (secondsLeft <= 0) {
        GuiLiveTimer.Text := "—"
        return
    }
    m := secondsLeft // 60
    s := Mod(secondsLeft, 60)
    GuiLiveTimer.Text := label . " in " . m . "m " . s . "s"
}
CaptureAndSend(IsManualTest := false) {
    global RobloxTitle, DemonRuns, DungeonRuns, RejoinCount, SessionStart, MacroPaused
    if (EditWeb.Value == "" || !WinExist(RobloxTitle))
        return
    WinActivate(RobloxTitle)
    Sleep(1000)
    MiniCap  := A_ScriptDir "\MiniCap\MiniCap.exe"
    SSPath   := A_ScriptDir "\ss.png"
    JsonPath := A_ScriptDir "\payload.json"
    RunWait('"' MiniCap '" -captureactivewin -save "' SSPath '" -exit', , "Hide")
    Elapsed  := A_TickCount - SessionStart
    h := Elapsed // 3600000
    m := Mod(Elapsed, 3600000) // 60000
    s := Mod(Elapsed, 60000)   // 1000
    Duration := h . "h " . m . "m " . s . "s"
    global RiftRuns, RaidRuns, RaidType, CustomRuns, CustomRunName
    currStatus := MacroPaused ? "⏸ Paused" : "● Running"
    Payload := '{"embeds": [{"title": "DenniXD ATS Macro V2.3.6","color": 8323327,'
             . '"image": {"url": "attachment://ss.png"},'
             . '"fields": ['
             . '{"name": "🗡 Abandon Village",  "value": "' . DemonRuns   . ' runs", "inline": true},'
             . '{"name": "⚔ Double Dungeon",   "value": "' . DungeonRuns . ' runs", "inline": true},'
             . '{"name": "🌀 Rift",            "value": "' . RiftRuns    . ' runs", "inline": true},'
             . '{"name": "💥 Raid (' . RaidType . ')", "value": "' . RaidRuns . ' runs", "inline": true},'
             . '{"name": "🎮 ' . CustomRunName . '", "value": "' . CustomRuns . ' runs", "inline": true},'
             . '{"name": "🔄 Rejoined",        "value": "' . RejoinCount . ' times", "inline": true},'
             . '{"name": "⏱ Uptime",          "value": "' . Duration    . '", "inline": true},'
             . '{"name": "📊 Status",          "value": "' . currStatus  . '", "inline": true}'
             . '],"footer": {"text": "DenniXD ATS V2.3.6  ·  ' . FormatTime(, "HH:mm:ss") . '"}}]}'
    try {
        FileOpen(JsonPath, "w", "UTF-8").Write(Payload)
        RunWait('curl.exe -s -F "payload_json=<' JsonPath '" -F "file=@' SSPath '" "' EditWeb.Value '"', , "Hide")
    }
    SetTimer(() => CleanupFiles(SSPath, JsonPath), -3000)
}
CleanupFiles(ss, js) {
    if FileExist(ss)
        FileDelete(ss)
    if FileExist(js)
        FileDelete(js)
}
ForceRejoin() {
    global PrivateServer, RejoinCount, CurrentRaidStep, RaidStartTime
    if (PrivateServer == "")
        return
    CurrentRaidStep := 0
    RaidStartTime   := 0
    RejoinPS()
    RejoinCount += 1
    UpdateUI()
}
; ── Reset Travel UI — inline keystrokes replacing resettravelui.exe ──


UpdateSummonMap(ctrl, *) {
    global SummonMap, SummonMaps
    SummonMap := SummonMaps[ctrl.Value]
}

UpdateSummonActive() {
    global ModeSummoning, ChkSummonActive
    ModeSummoning := ChkSummonActive.Value ? true : false
}

; ── Summoning — fires once at start and after every rejoin ──
Execute_Summon(mapName) {
    key := "Summon_" StrReplace(mapName, " ", "")
    RunCustomOrDefault(key, (*) => 0)
}

RunSummon() {
    global ModeSummoning, SummonMap, SummonHasRun
    if (!ModeSummoning || SummonHasRun)
        return
    SummonHasRun := true
    GuiStatus.Text := "Summoning on " . SummonMap . "..."
    Execute_Summon(SummonMap)
    GuiStatus.Text := "Summoning complete"
    Sleep(500)
}




; ══════════════════════════════════════════════════════════════════
;   SEQUENCE PERSISTENCE  (simple CSV-style flat file)
;   Format per line:  SeqName|type|key|dur  or  SeqName|click|x|y|dur
; ══════════════════════════════════════════════════════════════════
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
          . "; DenniXD ATS Macro V2.3.6 — Movement File (auto-generated)`n"
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
    ; Clear those keys before reloading
    for k in keysInFile {
        CustomSeqs[k] := []
        if SlotTriggers.Has(k)
            SlotTriggers.Delete(k)
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
    GuiStatus.Text := "✔ Reloaded: " folder
}

LoadSequences() {
    global CustomSeqs, SeqFile, SlotTriggers
    CustomSeqs   := Map()
    SlotTriggers := Map()
    if (!FileExist(SeqFile))
        return
    ; Movement file prefixes — these are loaded from txt files, skip them here
    movPrefixes := ["DD_", "AV_", "Rift_", "Raid_", "Summon_", "Custom_"]
    for line in StrSplit(FileRead(SeqFile), "`n", "`r") {
        line := Trim(line)
        if (line == "" || SubStr(line, 1, 1) == ";")
            continue
        parts := StrSplit(line, "|")
        if (parts.Length < 3)
            continue
        seqName := parts[1]
        ; Skip keys that belong to movement files — they load from txt folders
        isMovKey := false
        for pfx in movPrefixes {
            if (SubStr(seqName, 1, StrLen(pfx)) == pfx) {
                isMovKey := true
                break
            }
        }
        if (isMovKey)
            continue
        t := parts[2]
        if (t == "trigger") {
            SlotTriggers[seqName] := parts[3]
            continue
        }
        if (!CustomSeqs.Has(seqName))
            CustomSeqs[seqName] := []
        step := Map("type", t)
        if (t == "key") {
            step["key"] := parts[3]
            step["dur"] := Integer(parts[4])
        }
        if (t == "click") {
            step["x"]   := Integer(parts[3])
            step["y"]   := Integer(parts[4])
            step["dur"] := (parts.Length >= 5) ? Integer(parts[5]) : 80
        }
        if (t == "sleep") {
            step["dur"] := Integer(parts[3])
        }
        CustomSeqs[seqName].Push(step)
    }
}

SaveSequences() {
    global CustomSeqs, SeqFile, SlotTriggers
    out := ""
    ; Save trigger overrides
    for seqKey, trigger in SlotTriggers
        out .= seqKey "|trigger|" trigger "`n"
    ; Save steps
    for seqName, steps in CustomSeqs {
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
    NeedsPSLaunch := (LastRejoinTime == 0 || (A_TickCount - LastRejoinTime >= OneHour))

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

        ; 3. Loop until Roblox window exists — click away any popups every 5s
        GuiStatus.Text := "Waiting for Roblox..."
        reconnectDeadline := A_TickCount + 120000  ; 2 min max
        Loop {
            if (!Running)
                return
            if (A_TickCount > reconnectDeadline) {
                GuiStatus.Text := "Rejoin timed out — retrying launch..."
                PrivateServer := IniRead(IniFile, "Settings", "PSLink", PrivateServer)
                try {
                    Run(PrivateServer)
                } catch {
                    Sleep(2000)
                    Run(PrivateServer)
                }
                reconnectDeadline := A_TickCount + 120000
            }
            ; Dismiss any popup dialogs (e.g. "Open Roblox?" browser prompt)
            SafeClick(490, 400)
            Sleep(5000)
            if WinExist(RobloxTitle) {
                WinActivate(RobloxTitle)
                Sleep(2000)
                ; Close browser now that Roblox is detected
                GuiStatus.Text := "Roblox detected — closing browser..."
                for browserExe in ["ahk_exe chrome.exe", "ahk_exe firefox.exe", "ahk_exe msedge.exe", "ahk_exe opera.exe", "ahk_exe brave.exe"] {
                    if WinExist(browserExe) {
                        WinClose(browserExe)
                        Sleep(600)
                        ; Force kill if still open (e.g. "close tabs?" prompt)
                        if WinExist(browserExe) {
                            WinActivate(browserExe)
                            WinWaitActive(browserExe, , 2)
                            Send("!{F4}")
                            Sleep(400)
                        }
                        break
                    }
                }
                ; Bring Roblox back to front after browser close
                if WinExist(RobloxTitle) {
                    WinActivate(RobloxTitle)
                    WinWaitActive(RobloxTitle, , 3)
                }
                Sleep(500)
                break
            }
        }
    }

    ; 4. Wait for TextLoaded — confirms fully in game
    if (WinExist(RobloxTitle)) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 5)
        GuiStatus.Text := "Waiting for game to load..."
        loadDeadline := A_TickCount + 60000
        gameLoaded   := false
        Loop {
            if (!Running)
                break
            if (A_TickCount > loadDeadline) {
                GuiStatus.Text := "Load timeout — skipping ResetTravelUI"
                break
            }
            try {
                if GetFindText().FindText(&fx, &fy, 27, 577, 127, 627, 0, 0, TextLoaded) {
                    gameLoaded := true
                    GuiStatus.Text := "Game loaded — waiting 5s..."
                    break
                }
            }
            Sleep(500)
        }
        ; 5. ResetTravelUI once fully loaded
        if (gameLoaded) {
            Sleep(5000)
            if (WinExist(RobloxTitle)) {
                WinActivate(RobloxTitle)
                WinWaitActive(RobloxTitle, , 5)
                UpdateSearchArea()  ; recalculate for potentially new window size
                GuiStatus.Text := "Running ResetTravelUI..."
                Execute_ResetTravelUI()
                Sleep(1000)
            }
        }
    } else {
        GuiStatus.Text := "Roblox not found — skipping ResetTravelUI"
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
global SlotTriggers      := Map()   ; key -> custom trigger string, saved to Sequences.txt
global TriggerOptions    := ["— (manual/always)", "0 enemies", "1 enemy", "2 enemies", "4 enemies", "5 enemies", "6 enemies", "7 enemies", "8 enemies", "10 enemies", "11 enemies", "12 enemies", "13 enemies", "14 enemies", "15 enemies", "16 enemies", "17 enemies", "18 enemies", "19 enemies", "20 enemies", "21 enemies", "22 enemies", "23 enemies", "24 enemies", "25 enemies", "26 enemies", "27 enemies", "28 enemies", "29 enemies", "30 enemies", "31 enemies", "32 enemies", "33 enemies", "34 enemies", "35 enemies", "After entry"]

; Gamemode slot definitions: key -> {label, trigger}
global GM_DD := [
    Map("key","DD_EnterRaid","label","Enter Raid",  "trigger","—"),
    Map("key","DD_Step1",    "label","Step 1",      "trigger","12 enemies"),
    Map("key","DD_Step2",    "label","Step 2",      "trigger","10 enemies"),
    Map("key","DD_Step3",    "label","Step 3",      "trigger","8 enemies"),
    Map("key","DD_Step4",    "label","Step 4",      "trigger","6 enemies"),
    Map("key","DD_Step5",    "label","Step 5",      "trigger","4 enemies"),
    Map("key","DD_Step6",    "label","Step 6",      "trigger","2 enemies"),
    Map("key","DD_Step7",    "label","Step 7",      "trigger","10 enemies (2nd)"),
    Map("key","DD_Step8",    "label","Step 8",      "trigger","5 enemies"),
    Map("key","DD_Step9",    "label","Step 9",      "trigger","1 enemy"),
    Map("key","DD_Step10",   "label","Step 10",     "trigger","0 enemies")
]
global GM_AV := [
    Map("key","AV_Entry", "label","Entry",  "trigger","—"),
    Map("key","AV_Step1", "label","Step 1", "trigger","After entry")
]
global GM_Rift := [
    Map("key","Rift_Custom","label","Custom","trigger","—")
]
global GM_Raid_NamexPlanet := [
    Map("key","Raid_NamexPlanet", "label","Namex Planet (Raid)", "trigger","—")
]
global GM_Raid_ColosseumKingdom := [
    Map("key","Raid_ColosseumKingdom", "label","Colosseum Kingdom (Raid)", "trigger","—")
]
global GM_Raid_DemonForest := [
    Map("key","Raid_DemonForest", "label","Demon Forest (Raid)", "trigger","—")
]
global GM_Raid_DungeonTown := [
    Map("key","Raid_DungeonTown", "label","Dungeon Town (Raid)", "trigger","—")
]
global GM_Raid_ReaperSociety := [
    Map("key","Raid_ReaperSociety", "label","Reaper Society (Raid)", "trigger","—")
]
global GM_Custom := [
    Map("key","Custom_Movement","label","Movement","trigger","—")
]
global GM_Summon := [
    Map("key","Summon_DungeonTown",   "label","Dungeon Town",   "trigger","—"),
    Map("key","Summon_ReaperSociety", "label","Reaper Society", "trigger","—"),
    Map("key","Summon_SoulSociety",   "label","Soul Society",   "trigger","—"),
    Map("key","Summon_Map4",          "label","Map 4",          "trigger","—"),
    Map("key","Summon_Map5",          "label","Map 5",          "trigger","—")
]

GetGMSlots(gm) {
    global GM_DD, GM_AV, GM_Rift, GM_Custom, GM_Summon
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

OpenSequenceEditor() {
    global EditorGui, EditorOpen, EditorGamemode, EditorSlotKey, EditorLV, EditorSlotLV

    if (EditorOpen) {
        EditorGui.Show()
        return
    }

    EditorGamemode := "DD"
    EditorSlotKey  := "DD_EnterRaid"

    EditorGui := Gui("+AlwaysOnTop -MaximizeBox", "Gamemode Editor — DenniXD ATS V2.3.6")
    EditorGui.BackColor := "111111"
    EditorGui.OnEvent("Close", (*) => CloseSequenceEditor())

    ; ── Header ──
    EditorGui.SetFont("s11 c7B2FFF Bold", "Segoe UI")
    EditorGui.AddText("x16 y12 w560", "🎮  GAMEMODE EDITOR")
    EditorGui.SetFont("s8 c666666 Norm", "Segoe UI")
    EditorGui.AddText("x16 y34 w560", "Select a gamemode → pick a slot → record steps → save.")

    ; ── Gamemode selector ──
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x16 y58 w80", "GAMEMODE:")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global DdlEditorGM := EditorGui.AddDropDownList("x100 y55 w180", ["Double Dungeon","Abandon Village","Rift","Namex Planet (Raid)","Colosseum Kingdom (Raid)","Demon Forest (Raid)","Dungeon Town (Raid)","Reaper Society (Raid)","Summon","Custom"])
    DdlEditorGM.Value := 1
    DdlEditorGM.OnEvent("Change", OnEditorGMChange)

    ; ── Status bar ──
    EditorGui.SetFont("s8 Norm", "Segoe UI")
    global LblEditorStatus := EditorGui.AddText("x16 y82 w564 h18 Background0A0A0A", "  ● Idle — select a slot then press F8 to record")
    LblEditorStatus.Opt("c00FF99")

    ; ── LEFT: Slot list ──
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x16 y108 w180", "SLOTS")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditorSlotLV := EditorGui.AddListView("x16 y124 w180 h220 Background1A1A1A cFFFFFF -LV0x10 -Multi", ["Slot","Trigger"])
    EditorSlotLV.ModifyCol(1, 90)
    EditorSlotLV.ModifyCol(2, 82)
    EditorSlotLV.OnEvent("Click", OnSlotSelect)

    ; ── Slot name field + Add/Delete slot buttons ──
    EditorGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
    global EditNewSlotName := EditorGui.AddEdit("x16 y350 w116 h24 Background1A1A1A", "Step Name")
    EditorGui.SetFont("s7 c0D0D0D Bold", "Segoe UI")
    global BtnAddSlot := EditorGui.AddButton("x136 y349 w60 h26 Background00AA44", "➕ ADD")
    BtnAddSlot.OnEvent("Click", (*) => AddCustomSlot())
    global BtnDelSlot := EditorGui.AddButton("x16 y379 w180 h24 Background662222", "🗑 DELETE SLOT")
    BtnDelSlot.Opt("cFFFFFF")
    BtnDelSlot.OnEvent("Click", (*) => DeleteCustomSlot())

    ; ── Trigger dropdown ──
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x16 y410 w180", "TRIGGER:")
    EditorGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
    global DdlTrigger := EditorGui.AddDropDownList("x16 y426 w180", ["— (manual/always)", "0 enemies", "1 enemy", "2 enemies", "4 enemies", "5 enemies", "6 enemies", "7 enemies", "8 enemies", "10 enemies", "11 enemies", "12 enemies", "13 enemies", "14 enemies", "15 enemies", "16 enemies", "17 enemies", "18 enemies", "19 enemies", "20 enemies", "21 enemies", "22 enemies", "23 enemies", "24 enemies", "25 enemies", "26 enemies", "27 enemies", "28 enemies", "29 enemies", "30 enemies", "31 enemies", "32 enemies", "33 enemies", "34 enemies", "35 enemies", "After entry"])
    DdlTrigger.Value := 1
    DdlTrigger.OnEvent("Change", OnTriggerChange)

    ; ── RIGHT: Step list ──
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x208 y108 w372", "STEPS  (drag to reorder)")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditorLV := EditorGui.AddListView("x208 y124 w372 h300 Background1A1A1A cFFFFFF -LV0x10", ["#","Type","Key / Coords","ms"])
    EditorLV.ModifyCol(1, 30)
    EditorLV.ModifyCol(2, 55)
    EditorLV.ModifyCol(3, 165)
    EditorLV.ModifyCol(4, 60)
    EditorLV.OnEvent("ItemFocus", OnStepFocus)

    ; ── Buttons ──
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    ; Row 1 — Record controls
    global BtnEdRecord := EditorGui.AddButton("x16 y478 w128 h30 Background00CC66", "⏺ RECORD  F8")
    BtnEdRecord.OnEvent("Click", (*) => StartEditorRecording(false))
    global BtnEdAppend := EditorGui.AddButton("x152 y478 w128 h30 Background226622", "➕ APPEND  F7")
    BtnEdAppend.Opt("cFFFFFF")
    BtnEdAppend.OnEvent("Click", (*) => StartEditorRecording(true))
    global BtnEdStop := EditorGui.AddButton("x288 y478 w120 h30 BackgroundFF3355", "⏹ STOP  F9")
    BtnEdStop.OnEvent("Click", (*) => StopEditorRecording())
    global BtnEdPlay := EditorGui.AddButton("x416 y478 w130 h30 Background334466", "▶ PLAY")
    BtnEdPlay.Opt("cFFFFFF")
    BtnEdPlay.OnEvent("Click", (*) => PlayEditorSteps())
    ; Row 2 — Step management
    global BtnEdMoveUp := EditorGui.AddButton("x16 y516 w100 h28 Background333333", "▲ MOVE UP")
    BtnEdMoveUp.Opt("cFFFFFF")
    BtnEdMoveUp.OnEvent("Click", (*) => MoveStep(-1))
    global BtnEdMoveDn := EditorGui.AddButton("x124 y516 w100 h28 Background333333", "▼ MOVE DN")
    BtnEdMoveDn.Opt("cFFFFFF")
    BtnEdMoveDn.OnEvent("Click", (*) => MoveStep(1))
    global BtnEdAddStep := EditorGui.AddButton("x232 y516 w76 h28 Background1A3A4A", "➕ ADD")
    BtnEdAddStep.Opt("cFFFFFF")
    BtnEdAddStep.OnEvent("Click", (*) => AddStepManual())
    global BtnEdDelRow := EditorGui.AddButton("x316 y516 w80 h28 Background662222", "🗑 DELETE")
    BtnEdDelRow.Opt("cFFFFFF")
    BtnEdDelRow.OnEvent("Click", (*) => DeleteSelectedStep())
    global BtnEdClear := EditorGui.AddButton("x396 y516 w150 h28 Background333333", "✖ CLEAR ALL")
    BtnEdClear.Opt("cFFFFFF")
    BtnEdClear.OnEvent("Click", (*) => ClearEditorSteps())
    ; Row 3 — Trigger point insert
    EditorGui.SetFont("s8 cAAAAAA Bold", "Segoe UI")
    EditorGui.AddText("x16 y552 w100", "TRIGGER POINT:")
    EditorGui.SetFont("s8 cFFFFFF Norm", "Segoe UI")
    global DdlTriggerPoint := EditorGui.AddDropDownList("x120 y549 w230", ["0 enemies","1 enemy","2 enemies","3 enemies","4 enemies","5 enemies","6 enemies","7 enemies","8 enemies","9 enemies","10 enemies","11 enemies","12 enemies","13 enemies","14 enemies","15 enemies","16 enemies","17 enemies","18 enemies","19 enemies","20 enemies","After entry"])
    DdlTriggerPoint.Value := 1
    EditorGui.SetFont("s8 c0D0D0D Bold", "Segoe UI")
    global BtnInsertTrigger := EditorGui.AddButton("x358 y548 w188 h26 BackgroundFFAA00", "⚡ INSERT TRIGGER POINT")
    BtnInsertTrigger.OnEvent("Click", (*) => InsertTriggerPoint())
    ; Row 4 — Save slot
    global BtnEdSave := EditorGui.AddButton("x16 y582 w530 h32 Background7B2FFF", "💾  SAVE SLOT SEQUENCE")
    BtnEdSave.Opt("cFFFFFF")
    BtnEdSave.OnEvent("Click", (*) => SaveEditorSequence())

    ; Row 4 — Save as custom file (Custom gamemode only)
    EditorGui.SetFont("s8 c7B2FFF Bold", "Segoe UI")
    global LblSaveFile := EditorGui.AddText("x16 y624 w530 Hidden", "── SAVE CUSTOM MACRO AS FILE ─────────────────────────────────────────")
    EditorGui.SetFont("s9 cFFFFFF Norm", "Segoe UI")
    global EditFileName := EditorGui.AddEdit("x16 y642 w380 h28 Background1A1A1A Hidden", "MyCustomMacro")
    EditorGui.SetFont("s8 c888888 Norm", "Segoe UI")
    EditorGui.AddText("x400 y647 w50 Hidden", ".txt")
    EditorGui.SetFont("s9 c0D0D0D Bold", "Segoe UI")
    global BtnSaveFile := EditorGui.AddButton("x456 y640 w90 h30 Background00AA44 Hidden", "💾 SAVE FILE")
    BtnSaveFile.Opt("cFFFFFF")
    BtnSaveFile.OnEvent("Click", (*) => SaveCustomMacroFile())

    EditorGui.SetFont("s7 c444444 Norm", "Segoe UI")
    EditorGui.AddText("x16 y678 w530 Center", "F8 = Record (replace)   ·   F7 = Append   ·   F9 = Stop   ·   Custom Movement must be ON")

    EditorGui.Show("w580 h700")
    EditorOpen := true

    RefreshSlotLV()
    SelectSlot(1)
}

CloseSequenceEditor() {
    global EditorOpen, EditorRecording
    EditorOpen      := false
    EditorRecording := false
}

OnEditorGMChange(ctrl, *) {
    global EditorGamemode, LblSaveFile, EditFileName, BtnSaveFile
    global EditorSteps, EditorSlotKey, EditorFocusedRow
    gms := ["DD","AV","Rift","Raid_NamexPlanet","Raid_ColosseumKingdom","Raid_DemonForest","Raid_DungeonTown","Raid_ReaperSociety","Summon","Custom"]
    EditorGamemode   := gms[ctrl.Value]
    EditorSteps      := []
    EditorSlotKey    := ""
    EditorFocusedRow := 0
    isCustom := (EditorGamemode == "Custom")
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
    LblEditorStatus.Text := msg
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
        SetEditorStatus("  ➕ APPENDING — new steps will be added to end... F9 to stop", "c22FF22")
    else
        SetEditorStatus("  ⏺ RECORDING — existing steps cleared, recording fresh... F9 to stop", "cFF3355")
    RefreshEditorLV()
}

StopEditorRecording() {
    global EditorRecording
    if (!EditorRecording)
        return
    EditorRecording := false
    SetEditorStatus("  ⏹ Stopped — review steps, reorder if needed, then Save", "cFFAA00")
}

F7:: {
    global EditorOpen
    if (EditorOpen)
        StartEditorRecording(true)
}
F8:: {
    global EditorOpen
    if (EditorOpen)
        StartEditorRecording(false)
}
F9:: {
    global EditorOpen
    if (EditorOpen)
        StopEditorRecording()
}

~*a:: EditorCaptureKey("a")
~*d:: EditorCaptureKey("d")
~*w:: EditorCaptureKey("w")
~*s:: EditorCaptureKey("s")
~*f:: EditorCaptureKey("f")
~*e:: EditorCaptureKey("e")
~*r:: EditorCaptureKey("r")
~*Space:: EditorCaptureKey("Space")
~*Enter:: EditorCaptureKey("Enter")
~*\:: EditorCaptureKey("\")
~*LButton:: EditorCaptureMouse()

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

EditorCaptureMouse() {
    global EditorRecording, EditorOpen
    if (!IsSet(EditorRecording) || !EditorRecording || !EditorOpen)
        return
    MouseGetPos(&mx, &my, &mWin)
    edWin := WinExist("Gamemode Editor — DenniXD ATS V2.3.6")
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

InsertTriggerPoint() {
    global EditorSteps, EditorFocusedRow, DdlTriggerPoint, EditorSlotKey
    if (EditorSlotKey == "") {
        MsgBox("Select a slot first.", "Editor", "Icon!")
        return
    }
    ; Parse enemy count from dropdown selection
    selected := DdlTriggerPoint.Text
    if (selected == "After entry") {
        count := -1
    } else {
        count := Integer(RegExReplace(selected, "[^\d]", ""))
    }
    step := Map("type", "triggerpoint", "count", count)
    ; Insert after focused row, or append if nothing focused
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
    SetEditorStatus("  ⚡ Trigger point inserted: wait for " selected, "cFFAA00")
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
    out := "; DenniXD ATS V2.3.6 — saved from editor`n`n"
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

