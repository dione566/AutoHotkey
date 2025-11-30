GameWinTitle := "Point Blank"

; --- Localiza as cores ---
;ff0000 Vermelho Puro
;fd081D Vermelho
;fb0a2a Laranja

; --- Configurações de Cores e Áreas ---
ColorToFind := 0xff0000
Variation := 0

; Define o raio da área de busca
SearchRadius := 200

; --- Variáveis de Deslocamento (Offset) para Mover a Área ---
OffsetX := 0 ; Deslocamento horizontal inicial
OffsetY := 0 ; Deslocamento vertical inicial
MoveStep := 5 ; Quantidade de pixels para mover a cada tecla (Ajuste se quiser mover mais rápido/lento)
; -----------------------------------------------------------

; Variáveis para o CENTRO da tela (Serão atualizadas no RecalculateSearchArea)
Coordenada_X_Tiro := A_ScreenWidth / 2
Coordenada_Y_Tiro := A_ScreenHeight / 2

; Variáveis de Área de Busca (Valores iniciais de 0, preenchidos por RecalculateSearchArea)
SearchAreaX1 := 0
SearchAreaY1 := 0
SearchAreaX2 := 0
SearchAreaY2 := 0

; Largura e Altura do Quadrado (2 * Raio)
QuadradoTamanho := 2 * SearchRadius
; --------------------------------------

MouseClickType := "LButton"
ClickDelay := 10
Paused := True ; ⬅️ ALTERADO: Começa no estado de PAUSADO
IsShooting := False
IsVisualizerOn := False 

; --- Configurações da Janela de Visualização (GUI) ---
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 ; Cor amarela ouro
WinSet, Transparent, 50 ; Transparência (100)

; --- Recálculo Inicial da Área de Busca (Define as coordenadas e a posição inicial) ---
Gosub, RecalculateSearchArea 

; REMOVIDO/COMENTADO: SetTimer para iniciar os loops
; Inicia o loop principal
; SetTimer, ColorShotLoop, 30
; Inicia o loop do visualizador (para manter ele centrado, caso a tela mude)
; SetTimer, VisualizerUpdate, 50

; -----------------------------
; --- Hotkeys de Controle ---
; -----------------------------

z::
    Suspend ; Alterna o estado de suspensão

    if (A_IsSuspended) {
        ToolTip, 🛑 SCRIPT PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 + 80
        SoundBeep, 300, 100
    } else {
        ToolTip, ▶️ SCRIPT ATIVO, A_ScreenWidth/2, A_ScreenHeight/2 + 80
        SoundBeep, 900, 100
    }
    ; Remove o ToolTip após 1.5 segundo
    SetTimer, RemoveToolTip, -350
    return
	
; --- Variável de Estado ---
Toggle = 0              ; Define o estado inicial: 0 (Desativado)
Return

; Rolar Para Cima (WheelUp) para ATIVAR / DESPAUSAR
WheelUp::
    if (Paused) {
        SetTimer, ColorShotLoop, 1
        SetTimer, VisualizerUpdate, 10
	    ToolTip, ✅ LIGADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -350
        Paused := False
        SetTimer, RemoveToolTip, -350
	    SoundBeep, 1000, 150 ; Toca um som agudo
    }
    return

; Rolar Para Baixo (WheelDown) para PAUSAR
WheelDown::
    if (!Paused) {
        SetTimer, ColorShotLoop, Off
        SetTimer, VisualizerUpdate, Off 
		ToolTip, ⏸️ PAUSADO, A_ScreenWidth/2, A_ScreenHeight/2 -50
	    SetTimer, RemoveToolTip, -350
        if (IsShooting) {
            Send, {%MouseClickType% up}
            IsShooting := False
        }
        Paused := True
        SetTimer, RemoveToolTip, -350
        SoundBeep, 500, 150 ; Toca um som agudo
    }
    return

~x:: ; Hotkey para Ligar/Desligar o visualizador
; ... (Resto do código 'x', 'z', e Alt+Setas)
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn) {
        ; Mostra e posiciona imediatamente (com as coordenadas atuais)
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
        ToolTip, ⬛ Visualizador LIGADO (X Desliga), A_ScreenWidth/2, A_ScreenHeight/2
    } else {
        Gui, Hide 
        ToolTip, ⬜ Visualizador DESLIGADO (X Liga), A_ScreenWidth/2, A_ScreenHeight/2
    }
    SetTimer, RemoveToolTip, -1000
    return

~F7::
    Send, {%MouseClickType% up}
    ExitApp

; --- NOVO: Hotkeys para Mover a Área de Busca (Alt + Setas) ---

!Up:: ; Alt + Seta para Cima
    OffsetY -= MoveStep
    Gosub, RecalculateSearchArea
    return

!Down:: ; Alt + Seta para Baixo
    OffsetY += MoveStep
    Gosub, RecalculateSearchArea
    return

!Left:: ; Alt + Seta para Esquerda
    OffsetX -= MoveStep
    Gosub, RecalculateSearchArea
    return

!Right:: ; Alt + Seta para Direita
    OffsetX += MoveStep
    Gosub, RecalculateSearchArea
    return

; ----------------------------------------------------
; --- Função Centralizada para Recalcular a Área de Busca ---
RecalculateSearchArea:
    ; 1. Recalcula o CENTRO DA TELA e aplica o DESLOCAMENTO (Offset)
    Coordenada_X_Tiro_Recalculada := A_ScreenWidth / 2 + OffsetX
    Coordenada_Y_Tiro_Recalculada := A_ScreenHeight / 2 + OffsetY

    ; 2. Define as novas coordenadas da ÁREA DE BUSCA (Quadrado)
    SearchAreaX1 := Coordenada_X_Tiro_Recalculada - SearchRadius
    SearchAreaY1 := Coordenada_Y_Tiro_Recalculada - SearchRadius
    SearchAreaX2 := Coordenada_X_Tiro_Recalculada + SearchRadius
    SearchAreaY2 := Coordenada_Y_Tiro_Recalculada + SearchRadius

    ; 3. Move o visualizador (GUI) se ele estiver ligado
    if (IsVisualizerOn) {
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
    }
    return

; --- Função de Atualização da Janela de Visualização ---
VisualizerUpdate:
    ; Garante que o centro da tela seja recalculado periodicamente, mantendo o offset.
    Gosub, RecalculateSearchArea
    return

; --- Loop Principal ---
ColorShotLoop:
    IfWinActive, %GameWinTitle%
    {
        ; 1. Busca a cor (Com variação) APENAS na área que está sendo monitorada (já deslocada)
        PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
        
        ColorFound := (ErrorLevel = 0)
        
        ; --- Lógica para Pressionar e Soltar o Botão ---
        
        if (ColorFound) 
        {
            if (!IsShooting)
            {
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
                IsShooting := True
            }
        }
        ;else 
        {
            if (IsShooting)
            {
                Send, {%MouseClickType% up}
                IsShooting := False
            }
        }
    }
    ;else
    {
        ; 4. Se o jogo não estiver ativo, garante que o botão seja solto
        if (IsShooting)
        {
            Send, {%MouseClickType% up}
            IsShooting := False
        }
    }
    return

; --- Função para Limpar o ToolTip ---
RemoveToolTip:
    ToolTip
    return
	
	~LButton::
	        While GetKeyState("LButton", "P")
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
; MButton simula LButton, mantendo sua função original (~)
~*MButton::LButton

; =========================================================
; 4. FUNCIONALIDADE DO LBUTTON (Clique Esquerdo)