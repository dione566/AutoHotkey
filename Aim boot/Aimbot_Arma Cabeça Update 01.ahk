; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

GameWinTitle := "Point Blank"
ColorToFind := 0xff0000 
Variation := 5 ; Aumentado levemente para melhor detecção

; --- Ajustes de Calibração ---
Sensibilidade := 0.1
Deadzone := 2          ; Um pequeno valor evita tremedeira excessiva
SearchRadius := 150    ; Reduzi o raio para focar mais no centro da tela

AimbotActive := False
Return

; --- Atalhos ---

WheelDown::
    AimbotActive := True
    ToolTip, 🎯 GRUDE + TIRO ATIVADO
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -1000
return

WheelUp::
    AimbotActive := False
    ToolTip, ❌ DESATIVADO
    SetTimer, AimTrackingLoop, Off
    SetTimer, RemoveToolTip, -1000
return

; --- Atalhos ---

z::
    Suspend, Toggle ; Alterna o estado dos atalhos
    
    if (A_IsSuspended) 
    {
        ; --- Desativa os timers/loops aqui ---
        AimbotActive := False
        SetTimer, AimTrackingLoop, Off
        SetTimer, RemoveToolTip, Off ; Para garantir que não haja conflito
        
        ToolTip, ❌ SCRIPT: DESATIVADO
    } 
    else 
    {
        ToolTip, ✅ SCRIPT: ATIVO
    }
    
    SetTimer, RemoveToolTip, -2000
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

; --- Loop de Movimento e Tiro ---

AimTrackingLoop:
if !WinActive(GameWinTitle)
    return

CenterX := A_ScreenWidth / 2
CenterY := A_ScreenHeight / 2

X1 := CenterX - SearchRadius
Y1 := CenterY - SearchRadius
X2 := CenterX + SearchRadius
Y2 := CenterY + SearchRadius

PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, %ColorToFind%, %Variation%, Fast RGB

if (ErrorLevel = 0)
{
    DistX := FoundX - CenterX
    DistY := FoundY - CenterY

    if (Abs(DistX) > Deadzone || Abs(DistY) > Deadzone)
    {
        MoveX := DistX * Sensibilidade
        MoveY := DistY * Sensibilidade
        
        ; Movimenta a mira
        DllCall("mouse_event", "UInt", 0x0001, "Int", MoveX, "Int", MoveY, "UInt", 0, "UPtr", 0)
        
        ; --- FUNÇÃO DE TIRO ---
        ; Envia o clique (0x0002 = Aperta, 0x0004 = Solta)
        DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
        Sleep, 10 ; Pequena pausa para o jogo registrar o clique
        DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0)
    }
}
return

RemoveToolTip:
    ToolTip
return
