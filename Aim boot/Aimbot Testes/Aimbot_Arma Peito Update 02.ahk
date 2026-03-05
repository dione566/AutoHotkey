; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; --- AJUSTES DE CALIBRAÇÃO (Altere aqui) ---
GameWinTitle    := "Point Blank"
ColorToFind     := 0xff0000  ; Vermelho Puro (RGB)
Variation       := 0         ; Tolerância de cor (aumente se não estiver detectando)
Sensibilidade   := 0.3      ; Velocidade do movimento (0.1 a 0.3 recomendado)
Deadzone        := 2         ; Evita tremedeira em alvos muito próximos
SearchRadius    := 300       ; Tamanho da área de busca no centro da tela

; --- AJUSTE DE ALTURA (AQUI ESTÁ O SEGREDO) ---
; Aumente este valor para a mira descer MAIS em relação ao pixel colorido.
; Exemplo: 20 pixels abaixo da cor detectada.
OffsetVertical  := 25 

AimbotActive := False
Return

; --- Atalhos de Ativação ---

WheelDown::
    AimbotActive := True
    ToolTip, 🎯 GRUDE ATIVADO (ALVO: ABAIXO DA COR)
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -1000
return

WheelUp::
    AimbotActive := False
    ToolTip, ❌ DESATIVADO
    SetTimer, AimTrackingLoop, Off
    SetTimer, RemoveToolTip, -1000
return

z::
    Suspend, Toggle
    if (A_IsSuspended) 
    {
        AimbotActive := False
        SetTimer, AimTrackingLoop, Off
        ToolTip, ❌ SCRIPT: PAUSADO
    } 
    else 
    {
        ToolTip, ✅ SCRIPT: PRONTO
    }
    SetTimer, RemoveToolTip, -2000
return

~F7::
    ToolTip, ⚠️ Encerrando Script...
    Sleep, 1000
    ExitApp
return

; --- Loop de Movimento e Tiro ---

AimTrackingLoop:
; Verifica se o jogo é a janela ativa
if !WinActive(GameWinTitle)
    return

; Define o centro da tela
CenterX := A_ScreenWidth / 2
CenterY := A_ScreenHeight / 2

; Define a área de busca baseada no SearchRadius
X1 := CenterX - SearchRadius
Y1 := CenterY - SearchRadius
X2 := CenterX + SearchRadius
Y2 := CenterY + SearchRadius

; Procura o Pixel
PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %ColorToFind%, %Variation%, Fast RGB

if (ErrorLevel = 0)
{
    ; --- LÓGICA DE COMPENSAÇÃO ---
    ; Em vez de ir direto no FoundY, nós somamos o OffsetVertical
    TargetX := FoundX
    TargetY := FoundY + OffsetVertical 

    ; Calcula a distância do centro até o novo alvo (abaixo do pixel)
    DistX := TargetX - CenterX
    DistY := TargetY - CenterY

    ; Verifica se a distância sai da zona morta (Deadzone)
    if (Abs(DistX) > Deadzone || Abs(DistY) > Deadzone)
    {
        ; Aplica a sensibilidade para suavizar o movimento
        MoveX := DistX * Sensibilidade
        MoveY := DistY * Sensibilidade
        
        ; Movimenta a mira (0x0001 = MOUSEEVENTF_MOVE)
        DllCall("mouse_event", "UInt", 0x0001, "Int", MoveX, "Int", MoveY, "UInt", 0, "UPtr", 0)
        
        ; --- FUNÇÃO DE TIRO AUTOMÁTICO ---
        ; Pressiona (0x0002) e Solta (0x0004)
        DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        Sleep, 10 
        DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    }
}
return

RemoveToolTip:
    ToolTip
return