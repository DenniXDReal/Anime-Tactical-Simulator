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
                Send("{\ down}"), Sleep(109), Send("{\ up}")
                break
            }
        } else if (gm == "DD") {
            if (ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0, 0, TextCardDD1)
             || ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.2, 0.2, TextCardDD1)
             || ft.FindText(&fx, &fy, 869-300, 709-300, 869+300, 709+300, 0.3, 0.3, TextCardDD1)) {
                found := true
                Send("{\ down}"), Sleep(109), Send("{\ up}")
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
        Send("{f down}"), Sleep(110), Send("{f up}")
        Sleep(500)
        return  ; hand back to RunRift() to play imported movement
    } else {
        if (!found) {
            GuiStatus.Text := "Travel — banner not found after 20 attempts, aborting"
            return
        }
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
                ; Press \ to close any open overlay before clicking Teleport
                Send("{\\ down}"), Sleep(109), Send("{\\ up}")
                Sleep(150)
                MouseMove(fx, fy)
                Sleep(150)
                MouseClick("Left", fx, fy)
                Sleep(200)
                MouseClick("Left", fx, fy)
                teleportClicked := true
                break
            }
            Sleep(300)
        }
        if (!teleportClicked)
            GuiStatus.Text := "Travel — Teleport btn not found"
    }
    Sleep(500)
    GuiStatus.Text := "Travel done — " gm " — ready"
}


ReturnToLobby() {
    global RobloxTitle, Running
    if (!Running)
        return

    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }

    GuiStatus.Text := "Returning to Lobby..."
    Send("{f down}"), Sleep(110), Send("{f up}"), Sleep(200)

    Sleep(3000) ; Wait for UI to render

    ; Logic to click the Lobby/Home button (using your coordinates from the original)
    BlockInput("On")
    SafeClick(1237, 601) 
    Sleep(500)
    BlockInput("Off")
    
    GuiStatus.Text := "Lobby return initiated"
}

Execute_ResetTravelUI() {
    global RobloxTitle, Running
    if (!Running)
        return

    if WinExist(RobloxTitle) {
        WinActivate(RobloxTitle)
        WinWaitActive(RobloxTitle, , 3)
    }

    GuiStatus.Text := "Resetting Travel UI..."

    BlockInput("On")
    ; Standard opening sequence
    SafeClick(500, 500), Sleep(200)
    Send("{f down}"), Sleep(110), Send("{f up}"), Sleep(200)
    Send("{\ down}"), Sleep(109), Send("{\ up}"), Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}"),  Sleep(100)
    Send("{d down}"), Sleep(78),  Send("{d up}"),  Sleep(100)
    Send("{s down}"), Sleep(94),  Send("{s up}")
    
    ; Perform a quick scroll reset (W tapping) to ensure list is at the top
    Loop 5 {
        Send("{w down}"), Sleep(80), Send("{w up}")
        Sleep(100)
    }
    
    ; Close the menu to finalize the "Reset"
    Send("{f down}"), Sleep(110), Send("{f up}")
    BlockInput("Off")

    GuiStatus.Text := "Travel UI Reset complete"
    Sleep(1000)
}

; ── Mode toggle — flips enabled state, updates button colour, WIP modes blocked ──
