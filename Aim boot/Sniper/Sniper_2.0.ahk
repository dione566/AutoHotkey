GameWinTitle := "Point Blank"

; --- Configurações de Cores ---
ColorToFind := 0xff0000
Variation := 0
SearchRadius := 350

; --- Variáveis de Deslocamento ---
OffsetX := 0
OffsetY := 0
MoveStep := 5

; --- Estados Iniciais ---
AimbotSniperActive := False
QuickSwapActive := False
IsVisualizerOn := False

; --- Configuração da GUI (Visualizador) ---
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 
WinSet, Transparent, 50 

Gosub, RecalculateSearchArea
Return

; -----------------------------------------------------------------------
; --- HOTKEYS DE ATIVAÇÃO ---
; -----------------------------------------------------------------------

; Ativa o AIMBOT SNIPER (Detecta cor e atira/troca sozinho)
WheelDown::
    QuickSwapActive := False
    AimbotSniperActive := True
    SetTimer, MacroShotLoop, 1
    ToolTip, 🎯 AIMBOT SNIPER: LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
    SetTimer, RemoveToolTip, -1000
return

; Ativa o QUICK SWAP (Você clica, ele apenas faz o 3-1 rápido)
WheelUp::
    AimbotSniperActive := False
    SetTimer, MacroShotLoop, Off
    QuickSwapActive := True
    ToolTip, ⚡ TROCA RÁPIDA: LIGADA, A_ScreenWidth/2, A_ScreenHeight/2 -50
    SetTimer, RemoveToolTip, -1000
return

; Desativa TUDO (Modo de segurança)

z::
    Suspend, Toggle ; Alterna o estado dos atalhos
    
    if (A_IsSuspended) 
    {
        ; --- Desativa os timers/loops aqui ---
        AimbotSniperActive := False
        QuickSwapActive := False
        SetTimer, MacroShotLoop, Off
        SetTimer, RemoveToolTip, Off ; Para garantir que não haja conflito
        
        ToolTip, ❌ SCRIPT: DESATIVADO
    } 
    else 
    {
        ToolTip, ✅ SCRIPT: ATIVO
    }
    
    SetTimer, RemoveToolTip, -1000
return

; -----------------------------------------------------------------------
; --- LÓGICA DE TIRO E TROCA ---
; -----------------------------------------------------------------------

; Loop do Aimbot Sniper (Procura a cor)
MacroShotLoop:
    IfWinActive, %GameWinTitle%
    {
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        if (ErrorLevel = 0) {
            Gosub, PerformQuickShot
            Sleep, 350 ; Delay para não bugar a animação da arma
        }
    }
return

; Macro disparado pelo Clique Esquerdo (Apenas se QuickSwap estiver ON)
~LButton::
    if (QuickSwapActive && WinActive(GameWinTitle)) {
        Sleep, 30
        Gosub, PerformWeaponSwap
    }
return

; Sub-rotina de Tiro + Troca
PerformQuickShot:
    Click, Down
    Sleep, 30
    Click, Up
    Gosub, PerformWeaponSwap
return

; Sub-rotina de Troca 3 -> 1
PerformWeaponSwap:
    Send, {3 down}
    Sleep, 30
    Send, {3 up}
    Sleep, 20
    Send, {1 down}
    Sleep, 30
    Send, {1 up}
return

; ----------------------------------------------------
; --- FUNÇÕES VISUAIS E AUXILIARES ---
; ----------------------------------------------------

~x::
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn)
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
    else
        Gui, Hide 
return

RecalculateSearchArea:
    CX := A_ScreenWidth / 2 + OffsetX
    CY := A_ScreenHeight / 2 + OffsetY
    SearchAreaX1 := CX - SearchRadius
    SearchAreaY1 := CY - SearchRadius
    SearchAreaX2 := CX + SearchRadius
    SearchAreaY2 := CY + SearchRadius
    QuadradoTamanho := 2 * SearchRadius
return

RemoveToolTip:
    ToolTip
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

; MButton simula LButton, mantendo sua função original (~)
~*MButton::LButton