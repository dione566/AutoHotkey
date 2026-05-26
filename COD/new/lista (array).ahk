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
; Criamos uma lista (array) contendo as duas cores e suas variações
Cores := [ {Cor: 0xFF48E5, Var: 15}
         , {Cor: 0x6F3430, Var: 4} ]

Sensibilidade := 0.5
SearchRadius  := 75
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 15  ; <--- QUANTIDADE DE PIXELS ABAIXO DO ALVO

Return

WheelUp::
    AimbotActive := True
    SetTimer, MainLoop, 1
return

WheelDown::
    AimbotActive := False
    SetTimer, MainLoop, Off
return

F8::
    Suspend, Toggle 
    if (A_IsSuspended) 
    {
        SoundBeep, 400, 100
        SoundBeep, 400, 100
    }
    else 
    {
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

    ; O "for" vai percorrer cada cor configurada na lista lá em cima
    for Index, Alvo in Cores
    {
        PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, Alvo.Cor, Alvo.Var, Fast RGB

        if (ErrorLevel = 0)
        {
            ; --- MOVIMENTAÇÃO AGRESSIVA ---
            TargetX := (FoundX - MidX) * Sensibilidade
            TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
            DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
            
            break ; Se encontrar a primeira cor, quebra o "for" para mover o mouse imediatamente
        }
    }
return

RemoveToolTip:
    ToolTip
return