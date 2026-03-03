; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1

; ESSENCIAL PARA TELA CHEIA/JANELA:
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

GameWinTitle := "Point Blank"
ColorToFind := 0xff0000 ; Vermelho (Certifique-se que o inimigo tem essa cor exata)
Variation := 0

; --- Ajustes de Calibração ---
Sensibilidade := 0.1
Deadzone := 0         
SearchRadius := 300     

AimbotActive := False
Return

; --- Atalhos ---

WheelDown::
    AimbotActive := True
    ToolTip, 🎯 GRUDE ATIVADO
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -500
return

WheelUp::
    AimbotActive := False
    ToolTip, ❌ GRUDE DESATIVADO
    SetTimer, AimTrackingLoop, Off
    SetTimer, RemoveToolTip, -500
return

z::Suspend
~F7::ExitApp

; --- Loop de Movimento ---

AimTrackingLoop:
; Se o jogo não estiver focado, ele não tenta puxar a mira
if !WinActive(GameWinTitle)
    return

; Define o centro da tela dinamicamente
CenterX := A_ScreenWidth / 2
CenterY := A_ScreenHeight / 2

X1 := CenterX - SearchRadius
Y1 := CenterY - SearchRadius
X2 := CenterX + SearchRadius
Y2 := CenterY + SearchRadius

; Busca o Pixel
PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %ColorToFind%, %Variation%, Fast RGB

if (ErrorLevel = 0)
{
    ; Calcula a distância
    DistX := FoundX - CenterX
    DistY := FoundY - CenterY

    if (Abs(DistX) > Deadzone || Abs(DistY) > Deadzone)
    {
        ; Movimento relativo via DLL (mais rápido e ignora aceleração do Windows)
        MoveX := DistX * Sensibilidade
        MoveY := DistY * Sensibilidade
        
        DllCall("mouse_event", "UInt", 0x0001, "Int", MoveX, "Int", MoveY, "UInt", 0, "UPtr", 0)
    }
}
return

RemoveToolTip:
    ToolTip
return