; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1
Process, Priority,, High

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; --- Configurações de Ajuste (Calibradas para a sua Imagem) ---
ColorToFind   := 0xE24031   ; Cor exata do centro do círculo no seu Paint
Variation     := 15         ; Aumentado para ignorar o serrilhado/ruído dos pixels
Sensibilidade := 0.4        ; Movimento firme e suave sem passar direto
SearchRadius  := 150        ; Área de busca maior para encontrar o círculo mais fácil
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 0         ; Zerado para testar o centro exato no Paint

; --- Configuração Inicial do Menu Flutuante ---
MenuX := A_ScreenWidth - 150  
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 
Gui, Color, 1A1A1A                            
Gui, Font, s10 Bold, Segoe UI                 

Gui, Add, Text, x10 y5 w130 vStatusAim, AIMBOT: OFF
Return 

; --- Função para Atualizar o Painel ---
AtualizarMenu() {
    global AimbotActive
    global MenuX, MenuY
    
    SetTimer, EsconderMenu, Off
    
    if (A_IsSuspended) {
        GuiControl, +cFF4444, StatusAim
        GuiControl,, StatusAim, SUSPENDIDO
    } else {
        if (AimbotActive) {
            GuiControl, +c44FF44, StatusAim
            GuiControl,, StatusAim, AIMBOT: ON
        } else {
            GuiControl, +cFF4444, StatusAim
            GuiControl,, StatusAim, AIMBOT: OFF
        }
    }
    
    Gui, Show, x%MenuX% y%MenuY% w140 h30 NoActivate
    SetTimer, EsconderMenu, -1500
}

EsconderMenu:
    Gui, Hide
Return

; --- Atalhos de Controle ---

; F5 Liga e Desliga
F5::
    AimbotActive := !AimbotActive 
    AtualizarMenu()
    if (AimbotActive)
        SetTimer, MainLoop, 1 
    else
        SetTimer, MainLoop, Off
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
    if (!AimbotActive)
        return

    ; Define o centro da sua tela atual (1280x720)
    MidX := A_ScreenWidth / 2
    MidY := A_ScreenHeight / 2

    ; Cria o quadrado de busca ao redor do centro da tela
    X1 := MidX - SearchRadius
    Y1 := MidY - SearchRadius
    X2 := MidX + SearchRadius
    Y2 := MidY + SearchRadius

    ; Procura a cor na tela usando RGB
    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB

    if (ErrorLevel = 0)
    {
        ; Calcula a distância do centro até o pixel encontrado
        DistX := FoundX - MidX
        DistY := (FoundY + YOffset) - MidY

        ; Aplica a sensibilidade para gerar o deslocamento relativo
        TargetX := DistX * Sensibilidade
        TargetY := DistY * Sensibilidade
        
        ; Envia o movimento relativo para o mouse
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
    Send, #d 
return