TravelToGamemode(gm := "AV") {
    global RobloxTitle, Running
    global TextTravelDemonForest, TextTravelDungeonTown, TextTravelReaperSociety
    global TextTeleportBtn, TravelBoundaryAbort
    global TextCardAV1, TextCardDD1
    local fx, fy, ft, destText, found

    if (!Running)
        return

    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }

    ; ── Pick target banner pattern ──
    if (gm == "AV")
        destText := TextTravelDemonForest
    else if (gm == "DD")
        destText := TextTravelDungeonTown
    else if (gm == "Rift")
        destText := TextTravelReaperSociety
    else
        destText := TextTravelDemonForest

    ; ── Boundary watcher: Rift only ──
    TravelBoundaryAbort := false
    if (gm == "Rift")
        SetTimer(TravelBoundaryWatcher, 500)

    ; ── Open travel menu: F \ S D S ──
    GuiStatus.Text := "Travel — opening map..."
    WinActivate(RobloxTitle)
    WinWaitActive(RobloxTitle, , 3)
    Sleep(200)
    BlockInput("On")
    SafeClick(500, 500), Sleep(200)
    Send("{f down}"), Sleep(110), Send("{f up}"), Sleep(200)
    Send("{\ down}"), Sleep(109), Send("{\ up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}"), Sleep(100)
    Send("{d down}"), Sleep(78),  Send("{d up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}")
    BlockInput("Off")
    WinActivate(RobloxTitle)
    WinWaitActive(RobloxTitle, , 3)
    Sleep(3000)  ; wait for TravelUI to fully render

    ; ── Scroll until card/banner detected, press S after each failed scan ──
    WinGetPos(&rbX, &rbY, &rbW, &rbH, RobloxTitle)
    rbX2 := rbX + rbW
    rbY2 := rbY + rbH
    found := false
    attempt := 0

    Loop 20 {
        attempt++
        if (TravelBoundaryAbort)
            break
        GuiStatus.Text := "Travel — scanning for " gm " (" attempt "/20)..."

        ; Fresh FindText instance each attempt — same as F10/F11 hotkeys
        ft := GetFindText()

        if (gm == "AV") {
            if (ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0, 0, TextCardAV1)
             || ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0.2, 0.2, TextCardAV1)
             || ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0.3, 0.3, TextCardAV1)) {
                found := true
                break
            }
        } else if (gm == "DD") {
            if (ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0, 0, TextCardDD1)
             || ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.2, 0.2, TextCardDD1)
             || ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.3, 0.3, TextCardDD1)) {
                found := true
                break
            }
        } else {
            if ft.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.15, 0.15, destText) {
                found := true
                break
            }
        }
        GuiStatus.Text := "Travel — not found, pressing S (" attempt "/20)..."
        WinActivate(RobloxTitle)
        Send("{s down}"), Sleep(94), Send("{s up}")
        Sleep(800)
    }

    if (gm == "Rift")
        SetTimer(TravelBoundaryWatcher, 0)

    if (TravelBoundaryAbort) {
        TravelBoundaryAbort := false
        return
    }

    TravelBoundaryAbort := false
    Sleep(200)

    ; ── Confirm ──
    BlockInput("Off")
    Sleep(200)

    if (gm == "Rift") {
        ; Rift — banner confirmed, close menu — RunRift() handles movement after this
        GuiStatus.Text := "Travel — Rift banner confirmed, closing menu..."
        Send("{\ down}"), Sleep(109), Send("{\ up}"), Sleep(100)
        Send("{f down}"), Sleep(110), Send("{f up}")
        Sleep(500)
        return  ; hand back to RunRift() to play imported movement
    } else {
        if (!found) {
            GuiStatus.Text := "Travel — banner not found after 20 attempts, aborting"
            return
        }

        ; ── Hide macro GUI so mouse clicks don't land on it ──
        global MyGui, MiniGui, MiniMode
        if (MiniMode)
            MiniGui.Hide()
        else
            MyGui.Hide()
        Sleep(100)

        ; AV/DD — card detected, click it to reveal Teleport button
        GuiStatus.Text := "Travel — clicking card at " fx "," fy "..."
        WinActivate(RobloxTitle)
        Sleep(100)
        MouseMove(fx, fy)
        Sleep(150)
        MouseClick("Left", fx, fy)
        Sleep(800)  ; wait for Teleport button to appear

        ; Now scan for Teleport button
        GuiStatus.Text := "Travel — scanning for Teleport button..."
        ft2 := GetFindText()
        teleportClicked := false
        Loop 15 {
            if ft2.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.3, 0.3, TextTeleportBtn) {
                GuiStatus.Text := "Travel — Teleport at " fx "," fy " — clicking..."
                WinActivate(RobloxTitle)
                Sleep(100)
                MouseMove(fx, fy)
                Sleep(150)
                MouseClick("Left", fx, fy)
                Sleep(200)
                MouseClick("Left", fx, fy)
                Sleep(300)
                ; Close travel UI with F after teleport click lands
                Send("{f down}"), Sleep(110), Send("{f up}")
                teleportClicked := true
                break
            }
            Sleep(300)
        }
        if (!teleportClicked)
            GuiStatus.Text := "Travel — Teleport btn not found"

        ; ── Restore macro GUI ──
        Sleep(200)
        if (MiniMode)
            MiniGui.Show("NoActivate")
        else
            MyGui.Show("NoActivate")
    }
    Sleep(500)
    GuiStatus.Text := "Travel done — " gm " — ready"
}


Execute_ResetTravelUI() {
    ; Opens the travel menu then immediately closes it with F.
    ; Scans to confirm the menu actually opened before closing — no blind key-mashing.
    global RobloxTitle, TextCardAV1, TextCardDD1, TextTravelLobby
    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }
    GuiStatus.Text := "ResetTravel — opening map..."
    BlockInput("On")
    SafeClick(500, 500), Sleep(200)
    Send("{f down}"), Sleep(110), Send("{f up}"), Sleep(200)
    Send("{\ down}"), Sleep(109), Send("{\ up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}"), Sleep(100)
    Send("{d down}"), Sleep(78),  Send("{d up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}")
    BlockInput("Off")
    Sleep(3000)  ; wait for TravelUI to render

    ; Scan to confirm menu opened — check for any known card
    WinGetPos(&rbX, &rbY, &rbW, &rbH, RobloxTitle)
    rbX2 := rbX + rbW
    rbY2 := rbY + rbH
    menuOpen := false
    Loop 10 {
        ft := GetFindText()
        if (ft.FindText(&fx, &fy, 812-300, 467-300, 812+300, 467+300, 0.3, 0.3, TextCardAV1)
         || ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.3, 0.3, TextCardDD1)
         || ft.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.3, 0.3, TextTravelLobby)) {
            menuOpen := true
            break
        }
        Sleep(400)
    }

    ; Close menu with F whether or not we confirmed it
    WinActivate(RobloxTitle)
    Send("{f down}"), Sleep(110), Send("{f up}")
    Sleep(500)
    GuiStatus.Text := menuOpen ? "ResetTravel — menu closed ✓" : "ResetTravel — menu may not have opened"
}

ReturnToLobby() {
    ; Opens travel menu, scans for Lobby banner scrolling W, clicks card → Teleport button.
    ; Uses same scan+scroll method as TravelToGamemode.
    global RobloxTitle, TextTravelLobby, TextTeleportBtn, MyGui, MiniGui, MiniMode
    local fx, fy, ft, found

    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }

    ; ── Open travel menu: F \ S D S ──
    GuiStatus.Text := "ReturnToLobby — opening map..."
    BlockInput("On")
    SafeClick(500, 500), Sleep(150)
    SafeClick(500, 500), Sleep(200)
    Send("{f down}"), Sleep(110), Send("{f up}"), Sleep(200)
    Send("{\ down}"), Sleep(109), Send("{\ up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}"), Sleep(100)
    Send("{d down}"), Sleep(78),  Send("{d up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}")
    BlockInput("Off")
    WinActivate(RobloxTitle)
    Sleep(3000)  ; wait for TravelUI to render

    WinGetPos(&rbX, &rbY, &rbW, &rbH, RobloxTitle)
    rbX2 := rbX + rbW
    rbY2 := rbY + rbH
    found := false
    attempt := 0

    ; Lobby banner is above the default scroll position — press W to scroll up
    Loop 20 {
        attempt++
        GuiStatus.Text := "ReturnToLobby — scanning for Lobby (" attempt "/20)..."
        ft := GetFindText()
        if (ft.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.15, 0.15, TextTravelLobby)
         || ft.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.3,  0.3,  TextTravelLobby)) {
            found := true
            break
        }
        GuiStatus.Text := "ReturnToLobby — not found, pressing W (" attempt "/20)..."
        WinActivate(RobloxTitle)
        Send("{w down}"), Sleep(94), Send("{w up}")
        Sleep(800)
    }

    if (!found) {
        GuiStatus.Text := "ReturnToLobby — Lobby card not found, closing menu"
        Send("{f down}"), Sleep(110), Send("{f up}")
        return
    }

    ; ── Hide macro GUI so mouse clicks don't land on it ──
    if (MiniMode)
        MiniGui.Hide()
    else
        MyGui.Hide()
    Sleep(100)

    ; ── Click the Lobby card to reveal Teleport button ──
    GuiStatus.Text := "ReturnToLobby — clicking Lobby card at " fx "," fy "..."
    WinActivate(RobloxTitle)
    Sleep(100)
    MouseMove(fx, fy)
    Sleep(150)
    MouseClick("Left", fx, fy)
    Sleep(800)  ; wait for Teleport button to appear

    ; ── Scan for Teleport button ──
    GuiStatus.Text := "ReturnToLobby — scanning for Teleport button..."
    ft2 := GetFindText()
    teleportClicked := false
    Loop 15 {
        if ft2.FindText(&fx, &fy, rbX, rbY, rbX2, rbY2, 0.3, 0.3, TextTeleportBtn) {
            GuiStatus.Text := "ReturnToLobby — Teleport at " fx "," fy " — clicking..."
            WinActivate(RobloxTitle)
            Sleep(100)
            MouseMove(fx, fy)
            Sleep(150)
            MouseClick("Left", fx, fy)
            Sleep(200)
            MouseClick("Left", fx, fy)
            Sleep(300)
            ; Close travel UI with F after teleport click lands
            Send("{f down}"), Sleep(110), Send("{f up}")
            teleportClicked := true
            break
        }
        Sleep(300)
    }
    if (!teleportClicked) {
        GuiStatus.Text := "ReturnToLobby — Teleport btn not found, closing menu"
        Send("{f down}"), Sleep(110), Send("{f up}")
    }

    ; ── Restore macro GUI ──
    Sleep(200)
    if (MiniMode)
        MiniGui.Show("NoActivate")
    else
        MyGui.Show("NoActivate")

    Sleep(500)
    GuiStatus.Text := "ReturnToLobby — done"
}

; ── Mode toggle — flips enabled state, updates button colour, WIP modes blocked ──
