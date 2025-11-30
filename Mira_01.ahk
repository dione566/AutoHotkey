#NoEnv
#SingleInstance Force

; RECOMENDAÇÃO: Rode este script como Administrador (clique direito > Executar como administrador)

; === CONFIGURAÇÕES GERAIS ===
CorTransparente := "FF00FF" ; Magenta puro (HEX)
CorInicial := "Green"

; Variaveis para IDs das Janelas (Handles)
DotGuiHwnd := ""
CrossGuiHwnd := ""

; Status inicial: Começa com a mira de Ponto visível
MiraAtual := "Dot" ; Pode ser "Dot" ou "Cross"
ToggleVisibilidade := false ; Falso = Escondido, Verdadeiro = Visível

; === CONFIGURAÇÕES DO PONTO (DOT) ===
TamanhoPonto := 5          ; Tamanho do ponto (Largura e Altura)

; === CONFIGURAÇÕES DA CRUZ (+) ===
TamanhoCruz := 10          ; Comprimento total da cruz
EspessuraLinha := 2        ; Espessura das linhas da cruz

; === CONFIGURAÇÕES DO TIMER (FORÇA A VISIBILIDADE) ===
SetTimer, ForcarVisibilidade, 500 

; ==================================
; === CRIAÇÃO DA MIRA TIPO PONTO (GUI 1) ===
; ==================================
; Cálculo da Posição da GUI do Ponto
SysGet, Monitor_W, 78 
SysGet, Monitor_H, 79 
DotGui_W := TamanhoPonto + 4 
DotGui_H := TamanhoPonto + 4
DotGui_X := (Monitor_W / 2) - (DotGui_W / 2)
DotGui_Y := (Monitor_H / 2) - (DotGui_H / 2)
Ponto_X := (DotGui_W / 2) - (TamanhoPonto / 2)
Ponto_Y := (DotGui_H / 2) - (TamanhoPonto / 2)

Gui, 1: -Caption 
Gui, 1: +ToolWindow 
Gui, 1: +AlwaysOnTop 
Gui, 1: Color, %CorTransparente%

; O PONTO: Controle Progress
Gui, 1: Add, Progress, x%Ponto_X% y%Ponto_Y% w%TamanhoPonto% h%TamanhoPonto% Background%CorInicial% -Theme vDOT_CONTROL

; Exibe a GUI do Ponto e armazena o Handle (escondida por padrão)
Gui, 1: Show, x%DotGui_X% y%DotGui_Y% w%DotGui_W% h%DotGui_H% Hide NoActivate, DotGUI
DotGuiHwnd := WinExist("DotGUI")
WinSet, TransColor, %CorTransparente% 255, ahk_id %DotGuiHwnd%
WinSet, ExStyle, +0x20, ahk_id %DotGuiHwnd% 


; ==================================
; === CRIAÇÃO DA MIRA TIPO CRUZ (GUI 2) ===
; ==================================
; Cálculo da Posição da GUI da Cruz
CrossGui_W := TamanhoCruz + (EspessuraLinha * 2) 
CrossGui_H := TamanhoCruz + (EspessuraLinha * 2)
CrossGui_X := (Monitor_W / 2) - (CrossGui_W / 2)
CrossGui_Y := (Monitor_H / 2) - (CrossGui_H / 2)

LinhaHorizontal_X := (CrossGui_W - TamanhoCruz) / 2
LinhaHorizontal_Y := (CrossGui_H / 2) - (EspessuraLinha / 2)
LinhaVertical_X := (CrossGui_W / 2) - (EspessuraLinha / 2)
LinhaVertical_Y := (CrossGui_H - TamanhoCruz) / 2

Gui, 2: -Caption 
Gui, 2: +ToolWindow 
Gui, 2: +AlwaysOnTop 
Gui, 2: Color, %CorTransparente%

; Linha Horizontal do "+"
Gui, 2: Add, Progress, x%LinhaHorizontal_X% y%LinhaHorizontal_Y% w%TamanhoCruz% h%EspessuraLinha% Background%CorInicial% -Theme vH_LINE

; Linha Vertical do "+"
Gui, 2: Add, Progress, x%LinhaVertical_X% y%LinhaVertical_Y% w%EspessuraLinha% h%TamanhoCruz% Background%CorInicial% -Theme vV_LINE

; Exibe a GUI da Cruz e armazena o Handle (escondida por padrão)
Gui, 2: Show, x%CrossGui_X% y%CrossGui_Y% w%CrossGui_W% h%CrossGui_H% Hide NoActivate, CrossGUI
CrossGuiHwnd := WinExist("CrossGUI")
WinSet, TransColor, %CorTransparente% 255, ahk_id %CrossGuiHwnd%
WinSet, ExStyle, +0x20, ahk_id %CrossGuiHwnd% 

; Esconde a Cruz no início, já que a mira DOT é a inicial
Gui, 2: Hide 
Return 

; ==================================
; === FUNÇÃO DE ALTERNÂNCIA (F4) ===
; ==================================
F4::
; Altera o tipo de mira
If (MiraAtual = "Dot")
{
    MiraAtual := "Cross"
    Gui, 1: Hide ; Esconde o Ponto
    If ToggleVisibilidade ; Só mostra se F9 estiver ativo
        Gui, 2: Show
}
Else
{
    MiraAtual := "Dot"
    Gui, 2: Hide ; Esconde a Cruz
    If ToggleVisibilidade ; Só mostra se F9 estiver ativo
        Gui, 1: Show
}
Return

; ==================================
; === HOTKEYS PARA MUDANÇA DE COR ===
; ==================================

; Função para aplicar a cor em ambas as miras (ativa e inativa)
AplicarCor(Cor)
{
    If (Cor = "Black")
    {
        CorOpt := "+BackgroundBlack"
    }
    Else If (Cor = "Green")
    {
        CorOpt := "+BackgroundGreen"
    }
    Else If (Cor = "Red")
    {
        CorOpt := "+BackgroundRed"
    }

    ; Aplica a cor na mira Ponto (GUI 1)
    Gui, 1: Default
    GuiControl, %CorOpt%, DOT_CONTROL
    
    ; Aplica a cor na mira Cruz (GUI 2)
    Gui, 2: Default
    GuiControl, %CorOpt%, H_LINE 
    GuiControl, %CorOpt%, V_LINE 
}

; Pressione F1 para Preto
F1::
AplicarCor("Black")
Return

; Pressione F2 para Verde
F2::
AplicarCor("Green")
Return

; Pressione F3 para Vermelho
F3::
AplicarCor("Red")
Return


; ==================================
; === HOTKEYS DE CONTROLE GERAL ===
; ==================================

; Hotkey para MOSTRAR ou ESCONDER (Pop-up)
F9::
ToggleVisibilidade := !ToggleVisibilidade
If ToggleVisibilidade
{
    If (MiraAtual = "Dot")
        Gui, 1: Show
    Else
        Gui, 2: Show
}
Else
{
    Gui, 1: Hide
    Gui, 2: Hide
}
Return

; Hotkey para SAIR DO SCRIPT: SHIFT + ESC
+Esc::
GuiClose:
ExitApp

; ==================================
; === FUNÇÃO PARA FORÇAR VISIBILIDADE (TIMER) ===
; ==================================
ForcarVisibilidade:
; Reafirma AlwaysOnTop para as duas miras ativas
If WinExist("ahk_id " . DotGuiHwnd)
    WinSet, AlwaysOnTop, On, ahk_id %DotGuiHwnd%
If WinExist("ahk_id " . CrossGuiHwnd)
    WinSet, AlwaysOnTop, On, ahk_id %CrossGuiHwnd%
Return
