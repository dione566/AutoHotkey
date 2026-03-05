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
ColorToFind   := 0x440d10
Variation     := 0
Sensibilidade := 0.8        
SearchRadius  := 130        
AimbotActive  := False

Return

; --- Atalhos ---

F5::
    AimbotActive := True
    ToolTip, 🎯 AUTO-AIM & FIRE: LIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, 1 ; Inicia o loop automático
return

F6::
    AimbotActive := False
    ToolTip, ❌ AUTO-AIM & FIRE: DESLIGADO
    SetTimer, RemoveToolTip, -1000
    SetTimer, MainLoop, Off ; Para o loop
return

F9::
    Suspend, Toggle ; Alterna o estado dos atalhos
    
    if (A_IsSuspended) 
    {       
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

; --- Loop de Verificação ---

MainLoop:
    if (!AimbotActive)
        return

    ; 1. Define o centro da tela
    MidX := A_ScreenWidth / 2
    MidY := A_ScreenHeight / 2

    ; 2. Define a área de busca
    X1 := MidX - SearchRadius
    Y1 := MidY - SearchRadius
    X2 := MidX + SearchRadius
    Y2 := MidY + SearchRadius

    ; 3. Procura o Pixel
    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB

    if (ErrorLevel = 0)
    {
        ; --- CÁLCULO DE MOVIMENTO ---
        TargetX := (FoundX - MidX) * Sensibilidade
        TargetY := (FoundY - MidY) * Sensibilidade

        ; Move o mouse para o alvo
        DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)

        ; --- AUTO-FIRE (DISPARO AUTOMÁTICO) ---
        ; Envia um clique instantâneo
    Click, Down           ; 1. Aperta o gatilho (Atira)
    Sleep, 30             ; Espera o tiro sair
    Click, Up             ; Solta o gatilho
	
    }
return

RemoveToolTip:
    ToolTip
return

; --- Script de Mapeamento do Mouse v2 ---
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Rolar para cima (WheelUp) pressiona a tecla 4
WheelUp::
Send, 4
return

; Rolar para baixo (WheelDown) pressiona a tecla z
WheelDown::
Send, z
return

; Clicar com o botão do meio (MButton) pressiona a tecla f
MButton::
Send, f
return