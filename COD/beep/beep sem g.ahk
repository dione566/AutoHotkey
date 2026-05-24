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
ColorToFind   := 0xB31890
Variation     := 15
Sensibilidade := 0.5
SearchRadius  := 100
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset       := 5  ; <--- QUANTIDADE DE PIXELS ABAIXO DO ALVO (Aumente se quiser que atire mais baixo)

Return

WheelUp::
    AimbotActive := True
    SoundBeep, 1000, 150  ; Som agudo (1000 Hz) por 150 milissegundos
    SetTimer, MainLoop, 1 
return

WheelDown::
    AimbotActive := False
    SoundBeep, 500, 150   ; Som mais grave (500 Hz) por 150 milissegundos
    SetTimer, MainLoop, Off 
return

F9::
    Suspend, Toggle 
    if (A_IsSuspended) 
    {
        ; Beep duplo grave indicando que o script inteiro foi desligado
        SoundBeep, 400, 100
        SoundBeep, 400, 100
    }
    else 
    {
        ; Beep agudo indicando que o script voltou a ficar ativo
        SoundBeep, 1200, 200
    }
return

~F7::
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