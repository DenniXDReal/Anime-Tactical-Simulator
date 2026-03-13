#Requires AutoHotkey v2.0
#SingleInstance Force

; ================================================================
;   DenniXD ATS MACRO V3.0.0
;   Entry point — all logic lives in subfiles below.
;   DO NOT add game logic here. Edit the relevant Lib/Core/Gamemodes file.
; ================================================================

; ── External library (FindText image-search engine) ──
#Include FindText.ahk

; ── Settings, globals, all FindText detection patterns ──
#Include Lib\Globals.ahk

; ── GUI construction (main window, mini overlay, settings panel) ──
#Include Lib\GUI.ahk

; ── Discord webhook, screenshot, rejoin ──
#Include Lib\Webhook.ahk

; ── File I/O: load/save movement files, sequences, folders ──
#Include Lib\FileSystem.ahk

; ── Gamemode editor (GUI + all editor logic) ──
#Include Lib\Editor.ahk

; ── Engine: Start/Stop/Pause/MainLoop/RunDynamicSlots ──
#Include Core\MacroCore.ahk

; ── Shared utilities: SafeClick, PlaySequence, CalcDuration, speed scale ──
#Include Core\Utils.ahk

; ── Travel system: TravelToGamemode, ResetTravelUI, ReturnToLobby ──
#Include Core\Travel.ahk

; ── UI helpers: ToggleMode, ToggleSettings, UpdateUI, SaveSettings ──
#Include Core\MacroUI.ahk

; ── Gamemodes ──
#Include Gamemodes\AbandonVillage.ahk
#Include Gamemodes\DoubleDungeon.ahk
#Include Gamemodes\Rift.ahk
#Include Gamemodes\Raid.ahk
#Include Gamemodes\Summon.ahk

; ── Runtime startup (runs after all files are loaded) ──
SendMode("Event")
SetDefaultMouseSpeed(0)
CoordMode("Mouse", "Screen")

; Clean up leftover tmp files from a failed update
if FileExist(A_ScriptDir "\main.ahk.tmp")
    FileDelete(A_ScriptDir "\main.ahk.tmp")
if FileExist(A_ScriptDir "\~updater.bat")
    FileDelete(A_ScriptDir "\~updater.bat")

InitFiles()
SetTimer(CheckForUpdates, -1500)
InitFolders()
LoadAllMovementFiles()
LoadSequences()

; ── Debug overlay (transparent click-through overlay) ──
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
F7:: (EditorOpen ? StartEditorRecording(true)  : 0)
F8:: (EditorOpen ? StartEditorRecording(false) : 0)
F9:: (EditorOpen ? StopEditorRecording()       : 0)

; ── Debug: F10 = test DD detection, F11 = test AV detection ──
F10:: {
    global TextCardDD1
    ft := GetFindText()
    if ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0,   0,   TextCardDD1)
        MsgBox("DD FOUND (tol=0) at "   fx "," fy)
    else if ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.2, 0.2, TextCardDD1)
        MsgBox("DD FOUND (tol=0.2) at " fx "," fy)
    else if ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.3, 0.3, TextCardDD1)
        MsgBox("DD FOUND (tol=0.3) at " fx "," fy)
    else
        MsgBox("DD NOT FOUND`nPattern length: " StrLen(TextCardDD1))
}

F11:: {
    global TextCardAV1
    ft := GetFindText()
    if ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0,   0,   TextCardAV1)
        MsgBox("AV FOUND (tol=0) at "   fx "," fy)
    else if ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0.2, 0.2, TextCardAV1)
        MsgBox("AV FOUND (tol=0.2) at " fx "," fy)
    else if ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0.3, 0.3, TextCardAV1)
        MsgBox("AV FOUND (tol=0.3) at " fx "," fy)
    else
        MsgBox("AV NOT FOUND`nPattern length: " StrLen(TextCardAV1))
}

; ── Editor key capture hotkeys (only active while editor is open) ──
~*a::      EditorCaptureKey("a")
~*d::      EditorCaptureKey("d")
~*w::      EditorCaptureKey("w")
~*s::      EditorCaptureKey("s")
~*f::      EditorCaptureKey("f")
~*e::      EditorCaptureKey("e")
~*r::      EditorCaptureKey("r")
~*q::      EditorCaptureQ()
~*Space::  EditorCaptureKey("Space")
~*Enter::  EditorCaptureKey("Enter")
~*\::      EditorCaptureKey("\")
~*LButton:: EditorCaptureMouse()
