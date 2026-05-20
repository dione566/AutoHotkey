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
Sensibilidade := 0.5
SearchRadius  := 60
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 10

; --- Configuração Inicial do Menu Flutuante ---
MenuX := A_ScreenWidth - 150  ; Posição X no canto direito
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 ; Sempre no topo, sem bordas, clique através
Gui, Color, 1A1A1A                            ; Fundo escuro discreto para o texto aparecer bem
Gui, Font, s10 Bold, Segoe UI                 ; Fonte moderna

; Adiciona o texto de status
Gui, Add, Text, x10 y5 w130 vStatusAim, AIMBOT: DESLIGADO

Return ; Pausa a execução inicial. O menu só vai aparecer quando for chamado.


; --- Função para Atualizar o Painel (Chame esta função sempre que ativar/desativar) ---
AtualizarMenu() {
    global AimbotActive
    global MenuX, MenuY
    
    ; Cancela o temporizador antigo (caso você aperte o botão várias vezes rápidas)
    SetTimer, EsconderMenu, Off
    
    if (A_IsSuspended) {
        GuiControl, +cFF4444, StatusAim
        GuiControl,, StatusAim, SCRIPT: SUSPENDIDO
    } else {
        if (AimbotActive) {
            GuiControl, +c44FF44, StatusAim
            GuiControl,, StatusAim, ON
        } else {
            GuiControl, +cFF4444, StatusAim
            GuiControl,, StatusAim, OFF
        }
    }
    
    ; Mostra a janelinha com o texto
    Gui, Show, x%MenuX% y%MenuY% w140 h30 NoActivate
    
    ; Define para esconder daqui a 1500 milissegundos (1.5 segundos)
    SetTimer, EsconderMenu, -1500
}

; --- Sub-rotina para esconder o texto ---
EsconderMenu:
    Gui, Hide
Return

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