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
ColorToFind   := 0xFF48E5
Variation     := 15
Sensibilidade := 0.4
SearchRadius  := 100
AimbotActive  := False

; --- AJUSTE DE FOCO (DISTÂNCIA DINÂMICA) ---
; Definição dos offsets que você pediu
OffsetPerto   := 35
OffsetLonge   := 0

; Limiar de distância para o script entender se está perto ou longe (em pixels)
; Se o inimigo estiver a mais de 25 pixels de distância vertical do centro, o script considera "Perto"
DistanciaLimite := 25 

Return

WheelUp::
    AimbotActive := True
    SoundBeep, 1000, 150  ; Som agudo (1000 Hz) por 150 milissegundos
    SetTimer, MainLoop, 1 
    ; Define o atraso do clique (50ms segurando a tecla G)
    SetKeyDelay, 0, 50
    
    ; Executa o clique imediatamente na ativação
    GoSub, EnviarTeclaG
    
    ; Ativa o temporizador para repetir a cada 9000000 milissegundos (9000 segundos)
    SetTimer, EnviarTeclaG, 9000
return

WheelDown::
    AimbotActive := False
    SoundBeep, 500, 150   ; Som mais grave (500 Hz) por 150 milissegundos
    SetTimer, MainLoop, Off 
    ; Desliga o temporizador
    SetTimer, EnviarTeclaG, Off
return

; --- Sub-rotina que executa o envio do G ---
EnviarTeclaG:
    SendEvent, g
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
        ; --- CÁLCULO DINÂMICO DE DISTÂNCIA ---
        ; Calcula a distância absoluta do pixel encontrado até o centro Y da tela
        DistanciaY := Abs(FoundY - MidY)
        
        ; Se a distância for maior que o limite, o inimigo ocupa mais espaço na tela (está perto)
        if (DistanciaY > DistanciaLimite)
            YOffset := OffsetPerto
        else
            YOffset := OffsetLonge

        ; --- MOVIMENTAÇÃO AGRESSIVA ---
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
    }
return

RemoveToolTip:
    ToolTip
return

; --- MINIMIZAR TUDO COM F12 ---
F12::
    Send, #d 
return