; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScreenDir%
SendMode Input
SetBatchLines -1

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

GameWinTitle := "Point Blank"
ColorToFind := 0xff0000 
Variation := 0 ; Ajustado para uma detecção mais equilibrada

; --- Ajustes de Busca ---
SearchRadius := 300   ; Raio de busca em volta do centro da tela
AimbotActive := False
Return

; --- Atalhos ---

WheelDown::
    AimbotActive := True
    ToolTip, 🎯 AIMBOT SNIPER: ATIVO
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -1000
return

WheelUp::
    AimbotActive := False
    ToolTip, ⚡ TROCA RÁPIDA: ATIVO
    SetTimer, AimTrackingLoop, Off
    SetTimer, RemoveToolTip, -1000
return

z::
    Suspend, Toggle 
    if (A_IsSuspended) 
    {
        AimbotActive := False
        SetTimer, AimTrackingLoop, Off
        ToolTip, ❌ SCRIPT: DESATIVADO
    } 
    else 
    {
        ToolTip, ✅ SCRIPT: ATIVO
    }
    SetTimer, RemoveToolTip, -1000
return

~F7::
    Loop, 2 {
        Contagem := 3 - A_Index
        ToolTip, ⚠️ Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
    ToolTip ; Limpa o tooltip antes de fechar
    ExitApp
return

; --- Loop de Detecção e Tiro (Sem Movimento) ---

AimTrackingLoop:
if !WinActive(GameWinTitle)
    return

CenterX := A_ScreenWidth / 2
CenterY := A_ScreenHeight / 2

X1 := CenterX - SearchRadius
Y1 := CenterY - SearchRadius
X2 := CenterX + SearchRadius
Y2 := CenterY + SearchRadius

; Procura a cor na região central
PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %ColorToFind%, %Variation%, Fast RGB

if (ErrorLevel = 0)
{
    ; Se achou a cor, ele executa a sequência de tiro e troca rápida
    ; MAS NÃO TEM MAIS O DLLCALL DE MOVIMENTO AQUI
    
    Click, Down           ; 1. Atira
    Sleep, 30             
    Click, Up             
    
    Sleep, 20             

    Send, {3 down}        ; 2. Puxa a Faca
    Sleep, 30
    Send, {3 up}
    
    Sleep, 15             

    Send, {1 down}        ; 3. Volta para a Sniper
    Sleep, 30
    Send, {1 up}
    
    ; Tempo de espera para não "bugar" a animação da arma
    Sleep 600
}
return

RemoveToolTip:
    ToolTip
return

; Mantém o Quick Shot manual no botão esquerdo também
~LButton::
    Sleep, 30
    Send, {3 down}
    Sleep, 30
    Send, {3 up}
    Sleep, 15
    Send, {1 down}
    Sleep, 30
    Send, {1 up}
return

#if
~*MButton::LButton