GameWinTitle := "Point Blank"

; --------------------------------------
; --- Configurações de Cores e Áreas ---
; --------------------------------------
ColorToFind := 0xff0000
Variation := 0

; Define o raio da área de busca
SearchRadius := 200

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
ColorAimbotActive := False ; Controlado por WheelUp
MacroActive := False       ; Controlado por WheelDown
GlobalPaused := True       ; Controlado por v (começa pausado)

; NOVO ESTADO: Macro de Troca Rápida
QuickSwapMacroActive := False

; Estados de Ação
IsShootingA := False ; Estado de clique para o Aimbot WheelUp
IsShootingB := False ; Estado de execução para o Macro WheelDown
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
; --- HOTKEY: WheelUp (Aimbot Tiro - Simples) ---
; -------------------------------------------------------------------------------------

WheelUp::
    if (MacroActive) {
        ToolTip, 🚫 Macro (AimBot Sniper) Ativo. Desative-o primeiro., A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -350
        return
    }

    ColorAimbotActive := !ColorAimbotActive
    GlobalPaused := !ColorAimbotActive

    if (ColorAimbotActive) {
        SetTimer, ColorAimbotLoop, 1
        SetTimer, VisualizerUpdate, 10
        ToolTip, ✅ AimBot Tiro LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -350
        SoundBeep, 1000, 150
    } else {
        SetTimer, ColorAimbotLoop, Off
        if (!MacroActive) {
            SetTimer, VisualizerUpdate, Off
            Gui, Hide 
        }
        if (IsShootingA) {
            Send, {%MouseClickType% up}
            IsShootingA := False
        }
        ToolTip, ⏸️ AimBot Padrão PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -350
        SoundBeep, 500, 150
    }
    SetTimer, RemoveToolTip, -350
    return

; -------------------------------------------------------------------------------------
; --- HOTKEY: WheelDown (AimBot Sniper - Sequência de Q) ---
; -------------------------------------------------------------------------------------

WheelDown::
    ; Não permite ativar se o aimbot padrão (WheelUp) estiver ativo
    if (ColorAimbotActive) {
        ToolTip, 🚫 AimBot Tiro Ativo. Desative-o primeiro., A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -350
        return
    }

    MacroActive := !MacroActive
    GlobalPaused := !MacroActive

    if (MacroActive) {
        SetTimer, MacroShotLoop, 1
        SetTimer, VisualizerUpdate, 10
        ToolTip, ✅ AimBot Sniper LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -350
        SoundBeep, 1200, 150
    } else {
        SetTimer, MacroShotLoop, Off
        ; Desliga VisualizerUpdate apenas se o WheelUp não estiver ativo
        if (!ColorAimbotActive) {
            SetTimer, VisualizerUpdate, Off
            Gui, Hide 
        }
        ; Garante que qualquer botão do mouse seja solto se estiver sendo pressionado.
        if (IsShootingB) {
            Send, {%MouseClickType% up}
            IsShootingB := False
        }
        ToolTip, ⏸️ Macro PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 600, 150
    }
    SetTimer, RemoveToolTip, -350
    return

; -------------------------------------------------------------------------------------
; --- HOTKEY: z (PAUSA GLOBAL) ---
; -------------------------------------------------------------------------------------

z::
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
    
    ToolTip, 🛑 MACROS DESATIVADOS, A_ScreenWidth/2, A_ScreenHeight/2 -50
    SoundBeep, 200, 200
    SetTimer, RemoveToolTip, -350
    return

; -----------------------------
; --- Hotkeys Adicionais ---
; -----------------------------

F12::
    Suspend ; Alterna o estado de suspensão

    if (A_IsSuspended) {
        ToolTip, 🛑 SCRIPT PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 300, 100
    } else {
        ToolTip, ▶️ SCRIPT ATIVO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 900, 100
    }
    ; Remove o ToolTip após 1.5 segundo
    SetTimer, RemoveToolTip, -350
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
; --- LOOP 1: AimBot Padrão ---
; -------------------------------------------------------------------------------------

ColorAimbotLoop:
    IfWinActive, %GameWinTitle%
    {
        ; 1. Busca a cor na área monitorada
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        ColorFound := (ErrorLevel = 0)
        
        ; 2. Lógica de Pressionar e Soltar o Botão
        ; NOTA: Este loop é interrompido se estiver ativo, pois o novo macro controlará o LButton
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
; --- LOOP 2: Macro de Tiro + Q ---
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
                
                ; GARANTIA: MIRA 
                Send {lButton Down} 
                Sleep 10
                Send {lButton Up}   
                Sleep 50            
                
                ; AÇÃO (q)
                Send {q Down}
                Sleep 50
                Send {q Up}

                ; AÇÃO (q)
                Send {q Down}
                Sleep 50
                Send {q Up}

                ; TEMPO DE ESPERA ENTRE SEQUÊNCIAS
                Sleep 300

                ; Fim da sequência, pronto para executar novamente se a cor ainda for encontrada
                IsShootingB := False 
            }
        }
    }
    else
    {
        ; Solta o botão se o jogo não estiver ativo (apenas por segurança)
        if (IsShootingB)
        {
            Send, {%MouseClickType% up} 
            IsShootingB := False
        }
    }
    return

; --- Função para Limpar o ToolTip ---
RemoveToolTip:
    ToolTip
    return

; -------------------------------------------------------------------------------------
; --- NOVO MACRO: Troca Rápida de Armas ---
; -------------------------------------------------------------------------------------

MButton::
    ; Alterna o estado de ativação do Quick Swap
    QuickSwapMacroActive := !QuickSwapMacroActive
    
    if (QuickSwapMacroActive) {
        ToolTip, ✅ Troca Rápida LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 800, 150
    } else {
        ToolTip, ⏸️ Troca Rápida PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 400, 150
    }
    SetTimer, RemoveToolTip, -350
    return

; LButton Hotkey Customizada
; Executa o macro APENAS se o QuickSwapMacroActive for True E o jogo estiver ativo.
#if (QuickSwapMacroActive)
LButton::
    IfWinActive, %GameWinTitle%
    {
        Send {1 down}
        Sleep 20
        Send {1 up}

        Send {1 down}
        Sleep 10
        Send {1 up}

        Send {3 down}
        Sleep 10
        Send {3 up}

        Send {1 down}
        Sleep 10
        Send {1 up}
    }
    return
#if

~LButton::
	        While GetKeyState("LButton", "P")
    {
; Primeiro clique
Send {LButton down}
Send {LButton up}

; Pausa mínima para diferenciar os dois cliques
Sleep, 0 

; Segundo clique
Send {LButton down}
Send {LButton up}
        
        ; ATRASO: 5ms. (Ajuste para mudar a velocidade do clique.)
        Sleep, 0
    }
    return
#if