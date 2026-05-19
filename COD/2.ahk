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
MenuX := A_ScreenWidth - 220
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 
Gui, Color, 1A1A1A                            
Gui, Font, s9 cWhite Bold, Segoe UI           

; Seções do Menu (Estados)
Gui, Add, Text, w200 Center cFFA500, === PAINEL DE CONTROLE ===
Gui, Add, Text, w200 vStatusScript, SCRIPT: ✅ ATIVO
Gui, Add, Text, w200 vStatusAim, AIMBOT: ❌ DESLIGADO
Gui, Add, Text, w200 vStatusCor, COR: 0xc35846 (Var: 7)

Gui, Font, s8 cA0A0A0 Normal                 
Gui, Add, Text, w200, ---------------------------------------
Gui, Add, Text, w200, [F5] Ligar Auto-Aim
Gui, Add, Text, w200, [F6] Desligar Auto-Aim
Gui, Add, Text, w200, [F9] Suspender/Ativar Script
Gui, Add, Text, w200, [+] Aumentar Variação da Cor
Gui, Add, Text, w200, [-] Diminuir Variação da Cor
Gui, Add, Text, w200, [F12] Minimizar Tudo (Win+D)
Gui, Add, Text, w200, [Scroll Up/Down] G / Ctrl
Gui, Add, Text, w200, [F7] Encerrar Script
Gui, Add, Text, w200, ---------------------------------------

Gui, Show, x%MenuX% y%MenuY% w210 NoActivate

AtualizarMenu()
Return

; --- Função para Atualizar o Painel ---
AtualizarMenu() {
    global AimbotActive, ColorToFind, Variation
    
    ; Transforma o valor numérico da cor para o formato Hexadecimal de texto para exibir no menu
    HexColor := Format("0x{1:X}", ColorToFind)

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
    
    ; Atualiza a linha da Cor e Variação no Menu
    GuiControl, +cFFFFFF, StatusCor
    GuiControl,, StatusCor, COR: %HexColor% (Var: %Variation%)
}

; --- Atalhos de Controle ---

; Tecla Mais (Teclado Numérico ou Teclado Padrão)
+::
NumpadAdd::
    Variation += 1
    if (Variation > 255) ; Limite máximo que o Windows aceita
        Variation := 255
    AtualizarMenu()
return

; Tecla Menos (Teclado Numérico ou Teclado Padrão)
-::
NumpadSub::
    Variation -= 1
    if (Variation < 0) ; Limite mínimo
        Variation := 0
    AtualizarMenu()
return

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

    ; O script usa a variável %Variation% atualizada em tempo real aqui
    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB

    if (ErrorLevel = 0)
    {
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

F12::
    Send, #d 
return