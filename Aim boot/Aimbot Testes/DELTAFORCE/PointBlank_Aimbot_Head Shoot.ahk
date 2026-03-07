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
ColorToFind   := 0xff0000
Variation     := 0
Sensibilidade := 0.1
SearchRadius  := 200
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset       := 20  ; <--- QUANTIDADE DE PIXELS ABAIXO DO ALVO (Aumente se quiser que atire mais baixo)

Return

; --- Atalhos de Controle ---

F5::
    AimbotActive := True
    ToolTip, 🎯 AUTO-AIM & FIRE: LIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, 1 
return

F6::
    AimbotActive := False
    ToolTip, ❌ AUTO-AIM & FIRE: DESLIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, Off 
return

F9::
    Suspend, Toggle 
    if (A_IsSuspended) 
        ToolTip, ❌ SCRIPT: DESATIVADO
    else 
        ToolTip, ✅ SCRIPT: ATIVO
    SetTimer, RemoveToolTip, -1000
return

~F7::
    Loop, 2 {
        Contagem := 3 - A_Index
        ToolTip, ⚠️ Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
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
        ; --- MOVIMENTAÇÃO AGRESSIVA ---
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := ((FoundY + YOffset) - MidY) * Sensibilidade
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)

; Fire Loop: Só atira se o pixel for encontrado
        Click, Down
        Random, RandSleep, 20, 45 ; Aumentado para parecer mais humano
        Sleep, %RandSleep%
        Click, Up
    }
return

RemoveToolTip:
    ToolTip
return

; --- Mapeamento do Mouse ---

WheelUp::Send, 4
WheelDown::Send, z
MButton::Send, f

#SingleInstance Force

; 📌 Mensagem de inicialização
ToolTip, Minimizar - PB (F12), 0, 0
return

; --- Atalho Minimizar - PB (F12) ---
F12::
    ; 1. Comando para minimizar tudo e mostrar a Área de Trabalho
    ComObjCreate("Shell.Application").MinimizeAll
    
    ; Pequena pausa para o sistema processar a limpeza da tela
    Sleep, 800

    ; 2. Tentar focar na janela do Point Blank
    if WinExist("ahk_exe PointBlank.exe")
    {
        WinActivate, ahk_exe PointBlank.exe
        ToolTip, Point Blank Ativado!, 0, 0
    }
    else
    {
        ToolTip, Área de Trabalho Ativa (Jogo não encontrado), 0, 0
    }
    
    ; Faz o ToolTip sumir após 3 segundos
    SetTimer, RemoverToolTip, 3000
return

RemoverToolTip:
    ToolTip
    SetTimer, RemoverToolTip, Off
    ToolTip, Minimizar - PB (F12), 0, 0
return