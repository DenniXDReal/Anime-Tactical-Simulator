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
