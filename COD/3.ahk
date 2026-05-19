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
Sensibilidade := 1.0
SearchRadius  := 50
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 10

; --- Criação do Indicador (Bolinha no Canto Superior Direito) ---
TamanhoBolinha := 16 ; Tamanho em pixels (largura e altura)
BolinhaX := A_ScreenWidth - TamanhoBolinha - 20 ; 20 pixels de distância da borda direita
BolinhaY := 20                                  ; 20 pixels de distância do topo da tela

; Cria uma janela GUI redonda, sem bordas e sempre no topo
Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Color, FF4444 ; Começa vermelha (Desativado)
Gui, Show, x%BolinhaX% y%BolinhaY% w%TamanhoBolinha% h%TamanhoBolinha% NoActivate

; Transforma o quadrado da GUI em um círculo perfeito
WinSet, Region, 0-0 w%TamanhoBolinha% h%TamanhoBolinha% E, A
Return

; --- Atalhos de Controle ---

; F5 liga e desliga (Toggle)
F5::
    AimbotActive := !AimbotActive ; Inverte o estado atual
    
    if (AimbotActive) {
        Gui, Color, 44FF44 ; Muda para Verde
        SetTimer, MainLoop, 1
    } else {
        Gui, Color, FF4444 ; Muda para Vermelho
        SetTimer, MainLoop, Off
    }
return

F9::
    Suspend, Toggle 
    if (A_IsSuspended) {
        Gui, Color, 888888 ; Cinza se o script inteiro for suspenso
    } else {
        if (AimbotActive)
            Gui, Color, 44FF44
        else
            Gui, Color, FF4444
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
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
    }
return

; =======================================================================
; --- Mapeamento do Mouse e Extras ---
; =======================================================================

WheelUp::Send g
WheelDown::Send {Ctrl}

F12::
    Send, #d 
return