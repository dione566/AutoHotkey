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
Sensibilidade := 1.5
SearchRadius  := 30
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 5

; --- Criação do Menu Flutuante Overlay ---
; Calcula a posição X para colar no canto direito (Largura da tela - largura do menu - margem)
MenuX := A_ScreenWidth - 210
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 ; Sempre no topo, sem bordas, sem aparecer na barra de tarefas, clique através (+E0x20 opcional)
Gui, Color, 1A1A1A                            ; Cor de fundo escura (Fundo Gamer/Clean)
Gui, Font, s9 cWhite Bold, Segoe UI           ; Fonte moderna branca

; Seções do Menu
Gui, Add, Text, w190 Center cFFA500, === PAINEL DE CONTROLE ===
Gui, Add, Text, w190 vStatusScript, SCRIPT: ✅ ATIVO
Gui, Add, Text, w190 vStatusAim, AIMBOT: ❌ DESLIGADO

Gui, Font, s8 cA0A0A0 Normal                 ; Fonte menor e cinza para os atalhos
Gui, Add, Text, w190, -------------------------------------
Gui, Add, Text, w190, [F5] Ligar Auto-Aim
Gui, Add, Text, w190, [F6] Desligar Auto-Aim
Gui, Add, Text, w190, [F9] Suspender/Ativar Script
Gui, Add, Text, w190, [F12] Minimizar Tudo (Win+D)
Gui, Add, Text, w190, [Scroll Up/Down] G / Ctrl
Gui, Add, Text, w190, [F7] Encerrar Script
Gui, Add, Text, w190, -------------------------------------

; Exibe a GUI na posição calculada sem roubar o foco da janela ativa
Gui, Show, x%MenuX% y%MenuY% w200 NoActivate

; Atualiza o estado inicial do menu
AtualizarMenu()
Return

; --- Função para Atualizar o Painel em Tempo Real ---
AtualizarMenu() {
    global AimbotActive
    
    if (A_IsSuspended) {
        GuiControl, +cFF4444, StatusScript
        GuiControl,, StatusScript, SCRIPT: ❌ SUSPENDIDO
        GuiControl, +c888888, StatusAim
        GuiControl,, StatusAim, AIMBOT: ⏸️ INATIVO
    } else {
        GuiControl, +c44FF44, StatusScript
        GuiControl,, StatusScript, SCRIPT: ✅ ATIVO
        
        if (AimbotActive) {
            GuiControl, +c44FF44, StatusAim
            GuiControl,, StatusAim, AIMBOT: 🎯 LIGADO
        } else {
            GuiControl, +cFF4444, StatusAim
            GuiControl,, StatusAim, AIMBOT: ❌ DESLIGADO
        }
    }
}

; --- Atalhos de Controle ---

F5::
    AimbotActive := True
    AtualizarMenu()
    SetTimer, MainLoop, 1 
return

F6::
    AimbotActive := False
    AtualizarMenu()
    SetTimer, MainLoop, Off 
return

F9::
    Suspend, Toggle 
    AtualizarMenu()
return

~F7::
    ; Altera o menu para mostrar a contagem regressiva
    GuiControl,, StatusScript, ⚠️ FECHANDO...
    GuiControl,, StatusAim, Aguarde...
    Loop, 2 {
        Contagem := 3 - A_Index
        GuiControl,, StatusAim, Encerrando em %Contagem%s...
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
    }
return

; =======================================================================
; --- Mapeamento do Mouse ---
; =======================================================================

WheelUp::Send g
WheelDown::Send {Ctrl}

; --- MINIMIZAR TUDO COM F12 ---
F12::
    Send, #d ; Envia o comando Win + D (Mostra a Área de Trabalho)
return