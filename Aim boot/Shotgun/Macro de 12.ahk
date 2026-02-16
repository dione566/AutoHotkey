GameWinTitle := "Point Blank"

; --------------------------------------
; --- Configurações de Cores e Áreas ---
; --------------------------------------
ColorToFind := 0xff0000
Variation := 0

; Define o raio da área de busca
SearchRadius := 350

; --- Variáveis de Deslocamento (Offset) para Mover a Área (Alt + Setas) ---
OffsetX := 0
OffsetY := 0
MoveStep := 5
; -------------------------------------------------------------------------

; Variáveis para o CENTRO da tela (Serão atualizadas no RecalculateSearchArea)
Coordenada_X_Tiro := A_ScreenWidth / 2
Coordenada_Y_Tiro := A_ScreenHeight / 2
SearchAreaX1 := 0
SearchAreaY1 := 0
SearchAreaX2 := 0
SearchAreaY2 := 0
QuadradoTamanho := 2 * SearchRadius
MouseClickType := "LButton"
ClickDelay := 10 ; Usado apenas como variável, não no loop

; --------------------------------------
; --- Variáveis de Estado (Controle) ---
; --------------------------------------

; Estados dos Aimbots
ColorAimbotActive := False ; (Não usado no seu exemplo)
MacroActive := False       ; Controla o AimBot Sniper (Agora por WheelUp)
GlobalPaused := True       ; Controlado por v (começa pausado)

; NOVO ESTADO: Macro de Troca Rápida
QuickSwapMacroActive := False ; Controla o Quick Swap (Agora por WheelDown)

; Estados de Ação
IsShootingA := False ; Estado de clique para o Aimbot (ColorAimbotLoop)
IsShootingB := False ; Estado de execução para o Macro (MacroShotLoop)
IsVisualizerOn := False

; --- Configurações da Janela de Visualização (GUI) ---
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 ; Cor amarela ouro
WinSet, Transparent, 50 

; --- Recálculo Inicial da Área de Busca ---
Gosub, RecalculateSearchArea 

; --- Hotkeys de Controle ---
Return

; -------------------------------------------------------------------------------------
; --- HOTKEY: WheelUp (AimBot Sniper - Sequência de Q - NOVO) ---
; -------------------------------------------------------------------------------------

WheelDown::
    ; Desativa o Macro de Troca Rápida se estiver ativo
    QuickSwapMacroActive := False

    ; Alterna o estado do AimBot Sniper
    MacroActive := True

    if (MacroActive) {
        GlobalPaused := False ; Garante que a pausa global esteja desativada
        SetTimer, MacroShotLoop, 1
        SetTimer, VisualizerUpdate, 10
        ToolTip, ✅ AIMBOT SNIPER LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
    } else {
        SetTimer, MacroShotLoop, Off
        SetTimer, VisualizerUpdate, Off
        ToolTip, 🚫 AimBot Sniper DESLIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        Gui, Hide
    }
    
    SetTimer, RemoveToolTip, -250
    return

; -------------------------------------------------------------------------------------
; --- HOTKEY: z (PAUSA GLOBAL) ---
; (Manter a lógica de reset para ambos os macros)
; -------------------------------------------------------------------------------------

WheelUp::
    ; Desativa todos os loops
    SetTimer, ColorAimbotLoop, Off
    SetTimer, MacroShotLoop, Off
    SetTimer, VisualizerUpdate, Off
    
    ; Desativa o novo macro
    QuickSwapMacroActive := False
    
    Gui, Hide 

    ; Garante que o botão de tiro seja solto se estiver pressionado
    if (IsShootingA or IsShootingB) {
        Send, {%MouseClickType% up}
    }

    ; Reseta estados
    ColorAimbotActive := False
    MacroActive := False
    IsShootingA := False
    IsShootingB := False
    GlobalPaused := True
    
    ToolTip, ✅ TROCA RAPIDA ATIVADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
    SetTimer, RemoveToolTip, -250
    return

; -----------------------------
; --- Hotkeys Adicionais ---
; (Sem Alterações)
; -----------------------------

z::
    Suspend ; Alterna o estado de suspensão

    if (A_IsSuspended) {
        ToolTip, 🛑 SCRIPT PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50

; Desativa os timers/loops aqui
        SetTimer, ColorAimbotLoop, Off
        SetTimer, MacroShotLoop, Off
        SetTimer, VisualizerUpdate, Off

    } else {
        ToolTip, ▶️ SCRIPT ATIVO, A_ScreenWidth/2, A_ScreenHeight/2 -50
    }
    ; Remove o ToolTip após 1.5 segundo
    SetTimer, RemoveToolTip, -250
    return

; Hotkey para Ligar/Desligar o visualizador
~x::
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn) {
        ; Garante que a GUI seja mostrada na posição correta
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
        ToolTip, ⬛ Visualizador LIGADO (X Desliga), A_ScreenWidth/2, A_ScreenHeight/2
    } else {
        Gui, Hide 
        ToolTip, ⬜ Visualizador DESLIGADO (X Liga), A_ScreenWidth/2, A_ScreenHeight/2
    }
    SetTimer, RemoveToolTip, -350
    return

~F7:: ; Hotkey de Saída
    Send, {%MouseClickType% up}
    ExitApp

; --- Hotkeys para Mover a Área de Busca (Alt + Setas) ---

!Up:: 
    OffsetY -= MoveStep
    Gosub, RecalculateSearchArea
    return

!Down:: 
    OffsetY += MoveStep
    Gosub, RecalculateSearchArea
    return

!Left:: 
    OffsetX -= MoveStep
    Gosub, RecalculateSearchArea
    return

!Right:: 
    OffsetX += MoveStep
    Gosub, RecalculateSearchArea
    return

; ----------------------------------------------------
; --- FUNÇÕES DE LÓGICA E UTILIDADE ---
; ----------------------------------------------------

; --- Função Centralizada para Recalcular a Área de Busca ---
RecalculateSearchArea:
    Coordenada_X_Tiro_Recalculada := A_ScreenWidth / 2 + OffsetX
    Coordenada_Y_Tiro_Recalculada := A_ScreenHeight / 2 + OffsetY

    SearchAreaX1 := Coordenada_X_Tiro_Recalculada - SearchRadius
    SearchAreaY1 := Coordenada_Y_Tiro_Recalculada - SearchRadius
    SearchAreaX2 := Coordenada_X_Tiro_Recalculada + SearchRadius
    SearchAreaY2 := Coordenada_Y_Tiro_Recalculada + SearchRadius

    if (IsVisualizerOn) {
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
    }
    return

; --- Função de Atualização da Janela de Visualização ---
VisualizerUpdate:
    Gosub, RecalculateSearchArea
    return

; -------------------------------------------------------------------------------------
; --- LOOP 1: AimBot Padrão (Sem Alterações) ---
; -------------------------------------------------------------------------------------

ColorAimbotLoop:
    IfWinActive, %GameWinTitle%
    {
        ; 1. Busca a cor na área monitorada
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        ColorFound := (ErrorLevel = 0)
        
        ; 2. Lógica de Pressionar e Soltar o Botão
        ; NOTA: Este loop é interrompido se QuickSwapMacroActive estiver ativo
        if (!QuickSwapMacroActive) {
            if (ColorFound) 
            {
                if (!IsShootingA)
                {
                    Send, {%MouseClickType% down} 
                    IsShootingA := True
                }
            }
            else 
            {
                if (IsShootingA)
                {
                    Send, {%MouseClickType% up}
                    IsShootingA := False
                }
            }
        }
    }
    else
    {
        ; Solta o botão se o jogo não estiver ativo
        if (IsShootingA)
        {
            Send, {%MouseClickType% up}
            IsShootingA := False
        }
    }
    return

; -------------------------------------------------------------------------------------
; --- LOOP 2: Macro de Tiro + Q (AimBot Sniper) ---
; -------------------------------------------------------------------------------------

MacroShotLoop:
    IfWinActive, %GameWinTitle%
    {
        ; 1. Busca a cor na área monitorada
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        ColorFound := (ErrorLevel = 0)
        
        ; 2. Lógica da Sequência de Macro
        if (ColorFound) 
        {
            ; O macro é executado APENAS se não estiver no meio de uma sequência
            if (!IsShootingB)
            {
                IsShootingB := True ; Inicia a sequência

                ; --- SEQUÊNCIA DE MACRO ---
                
	    Send {lbutton down}
        Sleep 10
        Send {lbutton up}
		
        Send {3 down}
        Sleep 10
        Send {3 up}
		
		Send {1 down}
        Sleep 10
        Send {1 up}

        Send {1 down}
        Sleep 10
        Send {1 up}
				
        ; --- ESTE É O ATRASO ENTRE AS REPETIÇÕES ---
        Sleep 200  ; 1000ms = 1 segundo. Altere este valor como desejar.

                ; Fim da sequência, pronto para executar novamente se a cor ainda for encontrada
                IsShootingB := False ; CORREÇÃO: Deve ser False para que possa rodar de novo
            }
        }
    }
    return

; --- Função para Limpar o ToolTip ---
RemoveToolTip:
    ToolTip
    return

; -------------------------------------------------------------------------------------
; --- MACRO: Troca Rápida de Armas ---
; -------------------------------------------------------------------------------------

~LButton::
    While GetKeyState("LButton", "P")
    {
       
        Send {LButton down}
        Sleep 10
        Send {LButton up}
        
        Send {3 down}
        Sleep 10
        Send {3 up}

        Send {1 down}
        Sleep 10
        Send {1 up}
		
		Send {1 down}
        Sleep 10
        Send {1 up}
		
        ; --- ESTE É O ATRASO ENTRE AS REPETIÇÕES ---
        Sleep 200  ; 1000ms = 1 segundo. Altere este valor como desejar.
    }
return
	
#if
; MButton simula LButton, mantendo sua função original (~)
~*MButton::LButton