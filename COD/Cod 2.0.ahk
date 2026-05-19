; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1
Process, Priority,, High

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; --- Configurações de Ajuste ---
ColorToFind   := 0xc35846
Variation     := 7
Sensibilidade := 0.7
SearchRadius  := 40
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset       := 5
Return

; --- Atalhos de Controle ---

F5::
    AimbotActive := True
    ToolTip, 🎯 AUTO-AIM & FIRE: LIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, 1 
return

F6::
    AimbotActive := False
    ToolTip, ❌ AUTO-AIM & FIRE: DESLIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, Off 
return

F9::
    Suspend, Toggle 
    if (A_IsSuspended) 
        ToolTip, ❌ SCRIPT: DESATIVADO
    else 
        ToolTip, ✅ SCRIPT: ATIVO
    SetTimer, RemoveToolTip, -1000
return

~F7::
    Loop, 2 {
        Contagem := 3 - A_Index
        ToolTip, ⚠️ Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
    ExitApp
return

; --- Loop Principal ---

MainLoop:
    if (!AimbotActive) {
        if (GetKeyState("LButton"))
            Click, Up
        return
    }

    MidX := A_ScreenWidth / 2
    MidY := A_ScreenHeight / 2

    X1 := MidX - SearchRadius
    Y1 := MidY - SearchRadius
    X2 := MidX + SearchRadius
    Y2 := MidY + SearchRadius

    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB

    if (ErrorLevel = 0)
    {
        ; --- MOVIMENTAÇÃO AGRESSIVA ---
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
    }
return

RemoveToolTip:
    ToolTip
return

; =======================================================================
; --- Mapeamento do Mouse ---
; =======================================================================

WheelUp::Send g
WheelDown::Send {Ctrl}

; --- MINIMIZAR TUDO COM F12 ---
F12::
    Send, #d ; Envia o comando Win + D (Mostra a Área de Trabalho)
return