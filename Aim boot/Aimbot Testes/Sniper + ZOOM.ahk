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
Variation := 0 

; --- Ajustes de Calibração ---
Sensibilidade := 0.1
Deadzone := 2          
SearchRadius := 300    

AimbotActive := False
ModoZoom := False ; Nova variável para controlar o tipo de disparo
Return

; --- Atalhos ---

WheelDown::
    AimbotActive := True
    ModoZoom := False
    ToolTip, 🎯 PUXAR + SNIPER: ATIVO
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -1000
return

WheelUp:: ; --- NOVO MODO COM ZOOM ---
    AimbotActive := True
    ModoZoom := True
    ToolTip, 🔍 SNIPER + ZOOM: ATIVO
    SetTimer, AimTrackingLoop, 1
    SetTimer, RemoveToolTip, -1000
return

F8::
    AimbotActive := False
    ModoZoom := False
    ToolTip, ⚡ TROCA RÁPIDA: ATIVO (AUTO-OFF)
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
    ToolTip 
    ExitApp
return

; --- Loop de Movimento e Disparo ---

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
        DllCall("mouse_event", "UInt", 0x0001, "Int", MoveX, "Int", MoveY, "UInt", 0, "UPtr", 0)
        
        if (ModoZoom) {
            ; --- MACRO COM ZOOM (F8) ---
            Click, Right, Down
            Sleep, 80    
            Click, Down               
            Sleep, 30   
            Click, Up
            Click, Right, Up
        } else {
            ; --- MACRO SIMPLES (WheelDown) ---
            Click, Down
            Sleep, 30
            Click, Up
        }
        
        ; --- QUICK SWITCH (Comum a ambos) ---
        Sleep, 20    
        Send, {3 down}
        Sleep, 30
        Send, {3 up}
        Sleep, 15      
        Send, {1 down}
        Sleep, 30
        Send, {1 up}
        
        Sleep 700 ; Tempo de espera entre disparos
    }
}
return

RemoveToolTip:
    ToolTip
return

; Mantive seu atalho manual do LButton e MButton caso queira usar fora do bot
~lButton::
    Click, Down
    Sleep, 30
    Click, Up
    Sleep, 20
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