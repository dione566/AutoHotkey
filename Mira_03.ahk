#NoEnv
#SingleInstance Force
SetWinDelay, -1  ; Torna a movimentação instantânea

; RECOMENDAÇÃO: Rode como Administrador
; CONFIGURADO PARA: 1280 x 720

; === CONFIGURAÇÕES GERAIS ===
CorTransparente := "FF00FF" 
CorInicial := "Green"
LarguraTela := 1280
AlturaTela := 720

; Status inicial
MiraAtual := "Cross" 
ToggleVisibilidade := true 

; === CONFIGURAÇÕES DE TAMANHO ===
TamanhoPonto := 5         
TamanhoCruz := 12         
EspessuraLinha := 2       

; === POSIÇÃO INICIAL (CENTRO) ===
Pos_X := (LarguraTela / 2)
Pos_Y := (AlturaTela / 2)

; ==================================
; === CRIAÇÃO DAS GUIs ===
; ==================================

; GUI 1: Ponto
Gui, 1: -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui, 1: Color, %CorInicial%
Gui, 1: Show, w%TamanhoPonto% h%TamanhoPonto% Hide NoActivate, DotGUI
DotGuiHwnd := WinExist()
WinSet, ExStyle, +0x20, ahk_id %DotGuiHwnd%

; GUI 2: Cruz
Gui, 2: -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui, 2: Color, %CorTransparente%
LX := 0, LY := (TamanhoCruz/2)-(EspessuraLinha/2), VX := (TamanhoCruz/2)-(EspessuraLinha/2), VY := 0
Gui, 2: Add, Progress, x%LX% y%LY% w%TamanhoCruz% h%EspessuraLinha% Background%CorInicial% -Theme vH_LINE
Gui, 2: Add, Progress, x%VX% y%VY% w%EspessuraLinha% h%TamanhoCruz% Background%CorInicial% -Theme vV_LINE
Gui, 2: Show, w%TamanhoCruz% h%TamanhoCruz% Hide NoActivate, CrossGUI
CrossGuiHwnd := WinExist()
WinSet, TransColor, %CorTransparente% 255, ahk_id %CrossGuiHwnd%
WinSet, ExStyle, +0x20, ahk_id %CrossGuiHwnd%

; Ativa a mira inicial
GoSub, ReposicionarMira
GoSub, AtualizarExibicao

SetTimer, ForcarVisibilidade, 500 
Return 

; ==================================
; === MOVIMENTAÇÃO (CTRL + SETAS) ===
; ==================================

^Up::
    Pos_Y -= 1
    GoSub, ReposicionarMira
Return

^Down::
    Pos_Y += 1
    GoSub, ReposicionarMira
Return

^Left::
    Pos_X -= 1
    GoSub, ReposicionarMira
Return

^Right::
    Pos_X += 1
    GoSub, ReposicionarMira
Return

ReposicionarMira:
    ; Calcula o canto superior esquerdo para centralizar o objeto no ponto Pos_X, Pos_Y
    DX := Pos_X - (TamanhoPonto / 2)
    DY := Pos_Y - (TamanhoPonto / 2)
    CX := Pos_X - (TamanhoCruz / 2)
    CY := Pos_Y - (TamanhoCruz / 2)
    
    ; Move as janelas diretamente pelos IDs
    WinMove, ahk_id %DotGuiHwnd%, , %DX%, %DY%
    WinMove, ahk_id %CrossGuiHwnd%, , %CX%, %CY%
Return

; ==================================
; === OUTROS CONTROLES ===
; ==================================

F4:: ; Alternar Tipo
    MiraAtual := (MiraAtual = "Cross") ? "Dot" : "Cross"
    GoSub, AtualizarExibicao
Return

F9:: ; Visibilidade
    ToggleVisibilidade := !ToggleVisibilidade
    GoSub, AtualizarExibicao
Return

AtualizarExibicao:
    Gui, 1: Hide
    Gui, 2: Hide
    if (ToggleVisibilidade) {
        if (MiraAtual = "Dot")
            Gui, 1: Show, NoActivate
        else
            Gui, 2: Show, NoActivate
    }
Return

F1:: AplicarCor("Black")
F2:: AplicarCor("Green")
F3:: AplicarCor("Red")

AplicarCor(Cor) {
    GuiControl, 2: +Background%Cor%, H_LINE 
    GuiControl, 2: +Background%Cor%, V_LINE 
    Gui, 1: Color, %Cor%
}

+Esc:: ExitApp

ForcarVisibilidade:
    if (ToggleVisibilidade) {
        Target := (MiraAtual = "Dot") ? DotGuiHwnd : CrossGuiHwnd
        WinSet, AlwaysOnTop, On, ahk_id %Target%
    }
Return