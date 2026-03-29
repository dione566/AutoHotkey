#NoEnv
#SingleInstance Force
SetWinDelay, -1

; === CONFIGURAÇÕES GERAIS ===
CorTransparente := "FF00FF" 
LarguraTela := 1024
AlturaTela := 768

; Sistema de Cores (F10)
Cores := ["Green", "Black", "Blue", "Yellow", "White"]
IndiceCor := 1
CorInicial := Cores[IndiceCor]

MiraAtual := "Cross" 
ToggleVisibilidade := true 

TamanhoPonto := 5          
TamanhoCruz := 12          
EspessuraLinha := 2        

Pos_X := (LarguraTela / 2)
Pos_Y := (AlturaTela / 2)

; === CRIAÇÃO DAS GUIs ===
Gui, 1: -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui, 1: Color, %CorInicial%
Gui, 1: Show, w%TamanhoPonto% h%TamanhoPonto% Hide NoActivate, DotGUI
DotGuiHwnd := WinExist()
WinSet, ExStyle, +0x20, ahk_id %DotGuiHwnd%

Gui, 2: -Caption +ToolWindow +AlwaysOnTop +LastFound
Gui, 2: Color, %CorTransparente%
LX := 0, LY := (TamanhoCruz/2)-(EspessuraLinha/2), VX := (TamanhoCruz/2)-(EspessuraLinha/2), VY := 0
Gui, 2: Add, Progress, x%LX% y%LY% w%TamanhoCruz% h%EspessuraLinha% Background%CorInicial% vH_LINE -Theme
Gui, 2: Add, Progress, x%VX% y%VY% w%EspessuraLinha% h%TamanhoCruz% Background%CorInicial% vV_LINE -Theme
Gui, 2: Show, w%TamanhoCruz% h%TamanhoCruz% Hide NoActivate, CrossGUI
CrossGuiHwnd := WinExist()
WinSet, TransColor, %CorTransparente% 255, ahk_id %CrossGuiHwnd%
WinSet, ExStyle, +0x20, ahk_id %CrossGuiHwnd%

GoSub, ReposicionarMira
GoSub, AtualizarExibicao
SetTimer, ForcarVisibilidade, 500 
Return 

; === ATALHOS ===

F10:: ; Alternar Cores
    IndiceCor++
    if (IndiceCor > Cores.MaxIndex())
        IndiceCor := 1
    NovaCor := Cores[IndiceCor]
    
    GuiControl, 2: +Background%NovaCor%, H_LINE 
    GuiControl, 2: +Background%NovaCor%, V_LINE 
    Gui, 1: Color, %NovaCor%
Return

F4:: ; Alternar Tipo
    MiraAtual := (MiraAtual = "Cross") ? "Dot" : "Cross"
    GoSub, AtualizarExibicao
Return

; Movimentação (CTRL + SETAS)
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

~z::
    Suspend, Permit ; <--- ESTA LINHA É A CHAVE: Permite que o Z funcione mesmo suspenso
    
    Suspend, Toggle ; Alterna a suspensão dos outros atalhos
    
    ; Sincroniza a visibilidade da mira com o estado da suspensão
    if (A_IsSuspended) {
        Gui, 1: Hide
        Gui, 2: Hide
        ToolTip, ❌ TUDO DESATIVADO
    } else {
        GoSub, AtualizarExibicao ; Reativa a mira (Dot ou Cross)
        ToolTip, ✅ TUDO ATIVADO
    }
    
    SetTimer, RemoverToolTip, -1000
Return

RemoverToolTip:
    ToolTip
Return

~F7::
    Loop, 2 {
        Contagem := 3 - A_Index
        ToolTip, ⚠️ Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
    ExitApp
return

; === SUBROTINAS ===

ReposicionarMira:
    DX := Pos_X - (TamanhoPonto / 2)
    DY := Pos_Y - (TamanhoPonto / 2)
    CX := Pos_X - (TamanhoCruz / 2)
    CY := Pos_Y - (TamanhoCruz / 2)
    WinMove, ahk_id %DotGuiHwnd%, , %DX%, %DY%
    WinMove, ahk_id %CrossGuiHwnd%, , %CX%, %CY%
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

ForcarVisibilidade:
    if (ToggleVisibilidade) {
        Target := (MiraAtual = "Dot") ? DotGuiHwnd : CrossGuiHwnd
        WinSet, AlwaysOnTop, On, ahk_id %Target%
    }
Return