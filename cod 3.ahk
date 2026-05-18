#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)
SendMode("Input")
; v2 gerencia a velocidade de linhas de forma diferente, SetBatchLines não é mais necessário

ProcessSetPriority("High")

CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; --- Configurações de Ajuste ---
global Color1        := 0xE76C67 ; Vermelho Puro
global Color2        := 0xE76C67 ; Vermelho-Coral
global Variation     := 10        ; Tolerância de variação de cor
global Sensibilidade := 0.5
global SearchRadius  := 80
global AimbotActive  := false

; --- AJUSTE DE FOCO (OFFSET) ---
global YOffset       := 15 ; <--- QUANTIDADE DE PIXELS ABAIXO DO ALVO

return

; --- Atalhos de Controle ---

F5:: {
    global AimbotActive := true
    ToolTip("🎯 AUTO-AIM: LIGADO")
    SetTimer(RemoveToolTip, -1000)
    SetTimer(MainLoop, 1)
}

F6:: {
    global AimbotActive := false
    ToolTip("❌ AUTO-AIM: DESLIGADO")
    SetTimer(RemoveToolTip, -1000)
    SetTimer(MainLoop, 0) ; Desliga o timer
}

F9:: {
    Suspend(-1) ; Alterna o estado de suspensão (Toggle)
    if (A_IsSuspended)
        ToolTip("❌ SCRIPT: DESATIVADO")
    else
        ToolTip("✅ SCRIPT: ATIVO")
    SetTimer(RemoveToolTip, -1000)
}

~F7:: {
    loop 2 {
        Contagem := 3 - A_Index
        ToolTip("⚠️ Encerrando em " Contagem " segundos...")
        Sleep(1000)
    }
    ExitApp()
}

; --- Loop Principal ---

MainLoop() {
    if (!AimbotActive) {
        return
    }

    MidX := A_ScreenWidth / 2
    MidY := A_ScreenHeight / 2

    X1 := MidX - SearchRadius
    Y1 := MidY - SearchRadius
    X2 := MidX + SearchRadius
    Y2 := MidY + SearchRadius

    FoundX := 0
    FoundY := 0

    ; 1º Passo: Procura pela Color1. No v2, o modo padrão já é RGB se usado com "Fast"
    HasFound := PixelSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, Color1, Variation)

    ; 2º Passo: Se NÃO achar a Color1, procura pela Color2
    if (!HasFound) {
        HasFound := PixelSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, Color2, Variation)
    }

    ; Se qualquer uma das duas for encontrada (Retorna true no v2)
    if (HasFound) {
        ; --- MOVIMENTAÇÃO ---
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
        
        ; DllCall atualizado com a sintaxe correta do v2 (Move a mira até o alvo)
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
    }
}

RemoveToolTip() {
    ToolTip()
}

; --- Mapeamento do Mouse ---

WheelUp::Send("{Ctrl}")
WheelDown::Send("g")

; --- MINIMIZAR TUDO COM F12 ---
F12:: {
    Send("#d")
}