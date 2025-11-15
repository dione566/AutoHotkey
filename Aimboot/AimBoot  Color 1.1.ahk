GameWinTitle := "Point Blank"

; --- Configurações de Cores e Áreas ---
ColorToFind := "FD081D,fb0a2a" ; (FD081D Vermelho, fb0a2a Laranja)
Variation := 0

; Define o raio da área de busca
SearchRadius := 50

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
Paused := False
IsShooting := False
IsVisualizerOn := False 

; --- Configurações da Janela de Visualização (GUI) ---
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFD700 ; Cor amarela ouro
WinSet, Transparent, 100 ; Transparência (100)

; --- Recálculo Inicial da Área de Busca (Define as coordenadas e a posição inicial) ---
Gosub, RecalculateSearchArea 

; --- Mensagem de Início e Início Imediato do Loop ---
ToolTip, ✅ Script ATIVO! (F5 Pausa | X Visualiza | Alt+Setas Move | Z Sair), A_ScreenWidth/2, A_ScreenHeight/2
SetTimer, RemoveToolTip, -5000

; Inicia o loop principal
SetTimer, ColorShotLoop, 10
; Inicia o loop do visualizador (para manter ele centrado, caso a tela mude)
SetTimer, VisualizerUpdate, 50

; -----------------------------
; --- Hotkeys de Controle ---
; -----------------------------

~F5::
    if (Paused) {
        SetTimer, ColorShotLoop, 10
        SetTimer, VisualizerUpdate, 50
        Paused := False
        ToolTip, ✅ Script ATIVO! (F5 Pausa), A_ScreenWidth/2, A_ScreenHeight/2
        SetTimer, RemoveToolTip, -2000
    } else {
        SetTimer, ColorShotLoop, Off
        SetTimer, VisualizerUpdate, Off 
        if (IsShooting) {
            Send, {%MouseClickType% up}
            IsShooting := False
        }
        Paused := True
        ToolTip, 🛑 Script PAUSADO! (F5 Ativa), A_ScreenWidth/2, A_ScreenHeight/2
        SetTimer, RemoveToolTip, -2000
    }
    return

~x:: ; Hotkey para Ligar/Desligar o visualizador
    IsVisualizerOn := !IsVisualizerOn 
    if (IsVisualizerOn) {
        ; Mostra e posiciona imediatamente (com as coordenadas atuais)
        Gui, Show, w%QuadradoTamanho% h%QuadradoTamanho% x%SearchAreaX1% y%SearchAreaY1% NoActivate
        ToolTip, ⬛ Visualizador LIGADO (X Desliga), A_ScreenWidth/2, A_ScreenHeight/2
    } else {
        Gui, Hide 
        ToolTip, ⬜ Visualizador DESLIGADO (X Liga), A_ScreenWidth/2, A_ScreenHeight/2
    }
    SetTimer, RemoveToolTip, -2000
    return

~z::
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
                Send, {%MouseClickType% down} 
                IsShooting := True
            }
        }
        else 
        {
            if (IsShooting)
            {
                Send, {%MouseClickType% up}
                IsShooting := False
            }
        }
    }
    else
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