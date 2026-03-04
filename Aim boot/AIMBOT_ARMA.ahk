; ======================================================================================
; SCRIPT: Point Blank Color Macro
; FUNÇÃO: Auto-trigger baseado em cor (Red)
; ======================================================================================

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input

; --- Configurações de Janela e Cor ---
GameWinTitle := "Point Blank"
ColorToFind  := 0xff0000  ; Vermelho Puro (RGB)
Variation    := 0         ; Tolerância de cor (0 = exata)
SearchRadius := 350       ; Tamanho da área de busca

; --- Variáveis de Ajuste de Mira ---
OffsetX      := 0
OffsetY      := 0

; --- Estados de Controle ---
MacroActive     := False
IsVisualizerOn  := False

; --- Configuração da GUI (Área de Detecção) ---
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 
WinSet, Transparent, 50 

Gosub, RecalculateSearchArea 
Return

; ======================================================================================
; CONTROLES DE ATIVAÇÃO
; ======================================================================================

; LIGA O MACRO (Scroll para cima)
WheelUp:: 
    if (!MacroActive) {
        MacroActive := True
        SetTimer, ColorAimbotLoop, 1
        ToolTip, 🟢 MACRO: ATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -500
    }
return

; DESLIGA O MACRO (Scroll para baixo)
WheelDown:: 
    if (MacroActive) {
        MacroActive := False
        SetTimer, ColorAimbotLoop, Off
        ToolTip, 🔴 MACRO: DESATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -500
    }
return

; PAUSAR SCRIPT (Tecla Z)
z:: 
    Suspend
    MacroActive := False
    SetTimer, ColorAimbotLoop, Off
    ToolTip, % (A_IsSuspended ? "⚠️ SCRIPT PAUSADO" : "✅ SCRIPT ATIVO")
    SetTimer, RemoveToolTip, -1000
return

; ======================================================================================
; LÓGICA DE DISPARO (LOOP)
; ======================================================================================

ColorAimbotLoop:
    IfWinActive, %GameWinTitle%
    {
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        if (ErrorLevel = 0) {
            ; Simulação de clique esquerdo via DllCall (mais rápido que comando 'Click')
            DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Press
            Sleep, 10 
            DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Release
        }
    }
return

; ======================================================================================
; UTILITÁRIOS E GERENCIAMENTO DE ÁREA
; ======================================================================================

; Alternar Visualizador (Tecla X)
~x:: 
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn) {
        Gosub, RecalculateSearchArea
        SetTimer, VisualizerUpdate, 50
    } else {
        Gui, Hide 
        SetTimer, VisualizerUpdate, Off
    }
return

; Cálculo da zona de detecção centralizada
RecalculateSearchArea:
    CX := A_ScreenWidth / 2 + OffsetX
    CY := A_ScreenHeight / 2 + OffsetY
    SearchAreaX1 := CX - SearchRadius
    SearchAreaY1 := CY - SearchRadius
    SearchAreaX2 := CX + SearchRadius
    SearchAreaY2 := CY + SearchRadius
    
    TamVisual := SearchRadius * 2
    if (IsVisualizerOn)
        Gui, Show, w%TamVisual% h%TamVisual% x%SearchAreaX1% y%SearchAreaY1% NoActivate
return

VisualizerUpdate:
    Gosub, RecalculateSearchArea
return

RemoveToolTip:
    ToolTip
return

; Encerrar Script (Tecla F7)
~F7::
    Loop, 5 {
        Contagem := 6 - A_Index
        ToolTip, ⚠️ Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
    ToolTip 
    ExitApp
return