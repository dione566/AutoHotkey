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
Sensibilidade := 0.5
SearchRadius  := 100
AimbotActive  := False

; --- AJUSTE DE FOCO (DISTÂNCIA DINÂMICA) ---
; Mantido conforme solicitado
OffsetPerto   := 35
OffsetLonge   := 0

; Limite horizontal máximo para os lados (direito e esquerdo)
MaxLimiteX    := 20

; Limiar de distância para o script entender se está perto ou longe (em pixels)
DistanciaLimite := 25

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
        ; --- CÁLCULO DINÂMICO DE DISTÂNCIA Y ---
        DistanciaY := Abs(FoundY - MidY)
        
        if (DistanciaY > DistanciaLimite)
            YOffset := OffsetPerto
        else
            YOffset := OffsetLonge

        ; --- CÁLCULO DE DISTÂNCIA X (COM TRAVA DE 20 PIXELS) ---
        DiferencaX := FoundX - MidX
        
        ; Se a distância para a direita/esquerda for maior que o limite, trava em 20 ou -20
        if (DiferencaX > MaxLimiteX)
            DiferencaX := MaxLimiteX
        else if (DiferencaX < -MaxLimiteX)
            DiferencaX := -MaxLimiteX

        ; --- MOVIMENTAÇÃO AGRESSIVA CORRIGIDA ---
        TargetX := DiferencaX * Sensibilidade
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

; =========================================================================
; --- NOVO CODIGO: CONTROLE DE RECUO (NO-RECOIL) AO SEGURAR LBUTTON ---
; =========================================================================

~LButton::
    ; Enquanto você estiver segurando o botão esquerdo do mouse...
    while GetKeyState("LButton", "P")
    {
        ; SÓ FUNCIONA SE O SCRIPT ESTIVER ATIVADO VIA WHEELUP (AimbotActive)
        ; E SE NÃO ESTIVER PAUSADO PELO F9 (A_IsSuspended)
        if (!AimbotActive || A_IsSuspended)
            break

        Click, down
        Sleep, 10  ; Tempo que o clique fica segurado (em milissegundos)
        Click, up
        Sleep, 15  ; Intervalo entre um clique e outro (ajuste conforme a arma)
		
        Sleep, 1 ; Atraso entre as repetições
    }
return