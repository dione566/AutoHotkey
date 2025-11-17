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
ColorAimbotActive := False ; Controlado por F5
MacroActive := False       ; Controlado por F6
GlobalPaused := True       ; Controlado por 8 (começa pausado)

; Estados de Ação
IsShootingA := False ; Estado de clique para o Aimbot F5
IsShootingB := False ; Estado de execução para o Macro F6
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
; --- HOTKEY: F5 (Aimbot Tiro - Simples Hold) ---
; -------------------------------------------------------------------------------------

WheelUp::
    ; Não permite ativar se o macro (F6) estiver ativo para evitar conflito de timers
    if (MacroActive) {
        ToolTip, 🚫 Macro (F6) Ativo. Desative-o primeiro., A_ScreenWidth/2, A_ScreenHeight/2
        SetTimer, RemoveToolTip, -2000
        return
    }

    ColorAimbotActive := !ColorAimbotActive
    GlobalPaused := !ColorAimbotActive

    if (ColorAimbotActive) {
        SetTimer, ColorAimbotLoop, 1
        SetTimer, VisualizerUpdate, 10
        ToolTip, ✅ Aimbot Tiro LIGADO (F5), A_ScreenWidth/2, A_ScreenHeight/2
	    SetTimer, RemoveToolTip, -500
        SoundBeep, 1000, 150
    } else {
        SetTimer, ColorAimbotLoop, Off
        ; Desliga VisualizerUpdate apenas se o F6 não estiver ativo
        if (!MacroActive) {
            SetTimer, VisualizerUpdate, Off
            Gui, Hide 
        }
        if (IsShootingA) {
            Send, {%MouseClickType% up}
            IsShootingA := False
        }
        ToolTip, ⏸️ Aimbot Padrão PAUSADO (F5), A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -500
        SoundBeep, 500, 150
    }
    SetTimer, RemoveToolTip, -500
    return

; -------------------------------------------------------------------------------------
; --- HOTKEY: F6 (Aimbot Sniper - Sequência de Q) ---
; -------------------------------------------------------------------------------------

WheelDown::
    ; Não permite ativar se o aimbot padrão (F5) estiver ativo
    if (ColorAimbotActive) {
        ToolTip, 🚫 Aimbot Tiro (F5) Ativo. Desative-o primeiro., A_ScreenWidth/2, A_ScreenHeight/2 -50
        SetTimer, RemoveToolTip, -2000
        return
    }

    MacroActive := !MacroActive
    GlobalPaused := !MacroActive

    if (MacroActive) {
        SetTimer, MacroShotLoop, 1
        SetTimer, VisualizerUpdate, 10
        ToolTip, ✅ Aim Sniper LIGADO (F6), A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -500
        SoundBeep, 1200, 150
    } else {
        SetTimer, MacroShotLoop, Off
        ; Desliga VisualizerUpdate apenas se o F5 não estiver ativo
        if (!ColorAimbotActive) {
            SetTimer, VisualizerUpdate, Off
            Gui, Hide 
        }
        ; Garante que qualquer botão do mouse seja solto se estiver sendo pressionado.
        if (IsShootingB) {
            Send, {%MouseClickType% up}
            IsShootingB := False
        }
        ToolTip, ⏸️ Macro PAUSADO (F6), A_ScreenWidth/2, A_ScreenHeight/2 -50
        SoundBeep, 600, 150
    }
    SetTimer, RemoveToolTip, -500
    return

; -------------------------------------------------------------------------------------
; --- HOTKEY: 8 (PAUSA GLOBAL) ---
; -------------------------------------------------------------------------------------

z::
    ; Desativa ambos os loops
    SetTimer, ColorAimbotLoop, Off
    SetTimer, MacroShotLoop, Off
    SetTimer, VisualizerUpdate, Off
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
    
    ToolTip, 🛑 PAUSA GLOBAL ATIVADA (8), A_ScreenWidth/2, A_ScreenHeight/2
    SoundBeep, 200, 200
    SetTimer, RemoveToolTip, -500
    return

; -----------------------------
; --- Hotkeys Adicionais ---
; -----------------------------

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
    SetTimer, RemoveToolTip, -2000
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
; --- LOOP 1: Aimbot Padrão (F5) ---
; -------------------------------------------------------------------------------------

ColorAimbotLoop:
    IfWinActive, %GameWinTitle%
    {
        ; 1. Busca a cor na área monitorada
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        ColorFound := (ErrorLevel = 0)
        
        ; 2. Lógica de Pressionar e Soltar o Botão
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
; --- LOOP 2: Macro de Tiro + Q (F6) ---
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
                
                ; GARANTIA: MIRA (Send {lButton Down/Up} no seu script é geralmente RButton para ADS, mas mantive o LButton do seu original)
                Send {lButton Down} 
                Sleep 10
                Send {lButton Up}    
                Sleep 30                    

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
        ; Nota: Não há um "else" neste loop, pois a ação Macro é um disparo por sequência.
        ; Ele não precisa segurar o botão, apenas verificar a cor, executar o macro, e 
        ; esperar para executar novamente.
    }
    else
    {
        ; Solta o botão se o jogo não estiver ativo (apenas por segurança)
        if (IsShootingB)
        {
            ; Aqui você poderia querer garantir que o LButton seja solto se o jogo sair da tela
            Send, {%MouseClickType% up} 
            IsShootingB := False
        }
		~LButton::
{
    ; O script só executa se a tecla LButton for *solta* (Implícito pelo HotKey ser a tecla principal)
    ; E se não estiver no meio de uma sequência
    if (!IsShootingQQ)
    {
        IsShootingQQ := True ; Inicia a sequência

        ; --- DEFINIÇÃO DE ATRASOS VARIÁVEIS (Simulação Humana) ---
        Random, delay1, 10, 30    ; Duração do primeiro tiro (LButton)
        Random, delay2, 80, 120   ; Atraso entre o tiro e o primeiro Q
        Random, delay3, 90, 130   ; Duração/Atraso do primeiro Q
        Random, delay4, 280, 320  ; Tempo de espera antes de permitir novo clique

        ; --- SEQUÊNCIA DISPARO (LButton) -> Q -> Q ---

        ; 1. DISPARO/AÇÃO (LButton - Já foi pressionado pelo usuário, agora enviamos o Down/Up simulado)
        ; Se o LButton não for usado para atirar no seu jogo, você deve pular este passo.
        ; Se o LButton for o disparo, ele já ocorreu e podemos prosseguir para o Q.
        
                ; GARANTIA: MIRA (Send {lButton Down/Up} no seu script é geralmente RButton para ADS, mas mantive o LButton do seu original)
                Send {lButton Down} 
                Sleep 15
                Send {lButton Up}    
                Sleep 30                    

                ; AÇÃO (q)
                Send {q Down}
                Sleep 50
                Send {q Up}

                ; AÇÃO (q)
                Send {q Down}
                Sleep 50
                Send {q Up}
                Sleep 300
        ; Fim da sequência, pronto para executar novamente
        IsShootingQQ := False    
    }
    return ; Encerra a execução do HotKey
}
    }
    return

; --- Função para Limpar o ToolTip ---
RemoveToolTip:
    ToolTip
    return