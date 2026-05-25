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
; --- 0x7A332D Vermelho Sangue
; --- 0xFF48E5 Rosa Claro

ColorToFind   := [0xFF48E5, 0xFF48E5] 
Variation     := 15
Sensibilidade := 0.5
SearchRadius  := 100
AimbotActive  := False

; --- AJUSTE DE FOCO (DISTÂNCIA DINÂMICA) ---
OffsetPerto   := 35
OffsetLonge   := 0

; Limite horizontal máximo para os lados (direito e esquerdo)
MaxLimiteX    := 20

; Limiar de distância para o script entender se está perto ou longe (em pixels)
DistanciaLimite := 25

Return

WheelUp::
    Send, c               
    AimbotActive := True
    SoundBeep, 1000, 150  
    SetTimer, MainLoop, 1
return

WheelDown::
    AimbotActive := False
    SoundBeep, 500, 150   
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

    ; CORRIGIDO: Removido o espaço de 'Cor Atual' para 'CorAtual'
    for Index, CorAtual in ColorToFind
    {
        PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %CorAtual%, Variation, Fast RGB

        if (ErrorLevel = 0)
        {
            ; --- CÁLCULO DINÂMICO DE DISTÂNCIA Y ---
            DistanciaY := Abs(FoundY - MidY)
            
            if (DistanciaY > DistanciaLimite)
                YOffset := OffsetPerto
            else
                YOffset := OffsetLonge

            ; --- CÁLCULO DE DISTÂNCIA X (COM TRAVA DE 20 PIXELS) ---
            DiferencaX := FoundX - MidX
            
            if (DiferencaX > MaxLimiteX)
                DiferencaX := MaxLimiteX
            else if (DiferencaX < -MaxLimiteX)
                DiferencaX := -MaxLimiteX

            ; --- MOVIMENTAÇÃO AGRESSIVA CORRIGIDA ---
            TargetX := DiferencaX * Sensibilidade
            TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
            
            DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
            
            break 
        }
    }
return

RemoveToolTip:
    ToolTip
return

; --- MINIMIZAR TUDO COM F12 ---
F12::
    Send, #d 
return