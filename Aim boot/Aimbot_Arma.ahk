GameWinTitle := "Point Blank"

; --- Configurações de Cores e Áreas ---
ColorToFind := 0xff0000
Variation := 0
SearchRadius := 350

; --- Variáveis de Deslocamento ---
OffsetX := 0
OffsetY := 0

; --- Estados de Controle ---
MacroActive := False
IsVisualizerOn := False

; Configuração da GUI do Visualizador
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 
WinSet, Transparent, 50 

Gosub, RecalculateSearchArea 
Return

; -------------------------------------------------------------------------------------
; --- CONTROLES PRINCIPAIS ---
; -------------------------------------------------------------------------------------

WheelUp:: ; LIGA O MACRO
    if (!MacroActive) {
        MacroActive := True
        SetTimer, ColorAimbotLoop, 1
        ToolTip, MACRO: ATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -500
    }
return

WheelDown:: ; DESLIGA O MACRO
    if (MacroActive) {
        MacroActive := False
        SetTimer, ColorAimbotLoop, Off
        ToolTip, MACRO: DESATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -500
    }
return

; -------------------------------------------------------------------------------------
; --- LÓGICA DE DISPARO ---
; -------------------------------------------------------------------------------------
ColorAimbotLoop:
    IfWinActive, %GameWinTitle%
    {
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        if (ErrorLevel = 0) {
            DllCall("mouse_event", "UInt", 0x0002, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Clique Esquerdo (Pressionar)
            Sleep, 10 
            DllCall("mouse_event", "UInt", 0x0004, "Int", 0, "Int", 0, "UInt", 0, "UPtr", 0) ; Clique Esquerdo (Soltar)
        }
    }
return

; -------------------------------------------------------------------------------------
; --- UTILITÁRIOS ---
; -------------------------------------------------------------------------------------

z:: ; Pausar Script Totalmente
    Suspend
    MacroActive := False
    SetTimer, ColorAimbotLoop, Off
    ToolTip, % (A_IsSuspended ? "SCRIPT PAUSADO" : "SCRIPT ATIVO")
    SetTimer, RemoveToolTip, -1000
return

~x:: ; Alternar Visualizador de Área (Quadrado Amarelo)
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn) {
        Gosub, RecalculateSearchArea
        SetTimer, VisualizerUpdate, 50
    } else {
        Gui, Hide 
        SetTimer, VisualizerUpdate, Off
    }
return

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

~F7::
    Loop, 4 {
        Contagem := 5 - A_Index
        ToolTip, Encerrando em %Contagem% segundos...
        Sleep, 1000
    }
    ToolTip ; Limpa o tooltip antes de fechar
    ExitApp
return


