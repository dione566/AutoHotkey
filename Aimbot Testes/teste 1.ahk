; --- Configurações Iniciais ---
#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1

GameWinTitle := "Point Blank"
ColorToFind := 0xff0000
Variation := 15

; --- Ajustes para Parar em Cima do Alvo (Calibração) ---
; Se ainda estiver passando do ponto, diminua o valor de Sensibilidade para 0.05
Sensibilidade := 0.15  
Smooth := 1            ; Mantido em 1 para resposta direta, a Sensibilidade fará o controle
Deadzone := 2          ; Se a mira estiver a 2 pixels do alvo, ela para de mover (evita tremer)
SearchRadius := 80     ; Raio menor evita que a mira puxe em coisas erradas no cenário

; --- Variáveis de Controle ---
AimbotActive := False

Return

; --- Atalhos ---

WheelDown::
    AimbotActive := True
    ToolTip, 🎯 GRUDE ATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 - 50
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -500
return

WheelUp::
    AimbotActive := False
    ToolTip, ❌ GRUDE DESATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 - 50
    SetTimer, AimTrackingLoop, Off
    SetTimer, RemoveToolTip, -500
return

z::Suspend
~F7::ExitApp

; --- Loop de Movimento Corrigido ---

AimTrackingLoop:
if !WinActive(GameWinTitle)
    return

; Define a área de busca ao redor do centro da tela
X1 := (A_ScreenWidth/2) - SearchRadius
Y1 := (A_ScreenHeight/2) - SearchRadius
X2 := (A_ScreenWidth/2) + SearchRadius
Y2 := (A_ScreenHeight/2) + SearchRadius

PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %ColorToFind%, %Variation%, Fast RGB

if (ErrorLevel = 0)
{
    ; Calcula a distância exata entre o centro da mira e o pixel vermelho
    DistX := FoundX - (A_ScreenWidth / 2)
    DistY := FoundY - (A_ScreenHeight / 2)

    ; Só move se a distância for maior que a Deadzone (zona morta)
    if (Abs(DistX) > Deadzone || Abs(DistY) > Deadzone)
    {
        ; Multiplicador baixo para não "dar chicotada" na mira
        MoveX := DistX * Sensibilidade
        MoveY := DistY * Sensibilidade
        
        ; Comando de movimento relativo
        DllCall("mouse_event", "UInt", 0x0001, "Int", MoveX, "Int", MoveY, "UInt", 0, "UPtr", 0)
    }
}
return

RemoveToolTip:
    ToolTip
return