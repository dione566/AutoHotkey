; =================================================================
; CONFIGURAÇÕES GLOBAIS
; =================================================================

; --- TÍTULO DA JANELA DO JOGO ---
; *ATENÇÃO: Mantenha exatamente o título da janela do seu jogo.
GameWinTitle := "Point Blank" 

; --- Configurações de Cores e Áreas ---
ColorToFind := "fd081d" ; (f1101f,ea171c)
Variation := 0

; Define o raio da área de busca (35 pixels = quadrado de 70x70 no centro)
SearchRadius := 40

; Calcula as coordenadas do CENTRO DA TELA (onde o tiro FIXO será executado)
Coordenada_X_Tiro := A_ScreenWidth / 2
Coordenada_Y_Tiro := A_ScreenHeight / 2

; Define a área de busca (Um quadrado centrado de 70x70)
SearchAreaX1 := Coordenada_X_Tiro - SearchRadius ; X inicial
SearchAreaY1 := Coordenada_Y_Tiro - SearchRadius ; Y inicial
SearchAreaX2 := Coordenada_X_Tiro + SearchRadius ; X final
SearchAreaY2 := Coordenada_Y_Tiro + SearchRadius ; Y final
; --------------------------------------

MouseClickType := "LButton" ; Botão do mouse para atirar
ClickDelay := 1             ; Pequena pausa em ms após o clique
Paused := False             ; Variável reintroduzida: O script inicia ATIVO por padrão

; --- Mensagem de Início e Início Imediato do Loop ---
ToolTip, Script PB - INICIADO. ATIVO. (T Pausa/Despausa | Z para Sair), A_ScreenWidth/2, A_ScreenHeight/2
SetTimer, RemoveToolTip, -5000

; Inicia o loop de busca e tiro imediatamente
SetTimer, ColorShotLoop, 10 ; Inicia o loop para rodar a cada 10ms

; --- Hotkeys de Controle ---

; NOVO: Hotkey para Pausar/Despausar o script
~F5::
    if (Paused) { ; Se estiver PAUSADO, ATIVA
        SetTimer, ColorShotLoop, 10
        Paused := False
        ToolTip, Script ATIVO! (T Pausa), A_ScreenWidth/2, A_ScreenHeight/2
        SetTimer, RemoveToolTip, -2000
    } else { ; Se estiver ATIVO, PAUSA
        SetTimer, ColorShotLoop, Off
        Paused := True
        ToolTip, Script PAUSADO! (T Ativa), A_ScreenWidth/2, A_ScreenHeight/2
        SetTimer, RemoveToolTip, -2000
    }
    return

~z:: ; Tecla para Sair do script COMPLETAMENTE
    ExitApp

; --- Loop Principal de Busca e Tiro ---

ColorShotLoop:
    ; 1. Busca a cor (Com variação) APENAS na área central
    PixelSearch, FoundX, FoundY, SearchAreaX1, SearchAreaY1, SearchAreaX2, SearchAreaY2, ColorToFind, %Variation%, Fast RGB
    
    if (ErrorLevel = 0) ; 2. Se a cor for encontrada
    {
        ; Simulação de clique único (Mais limpa e rápida)
        Click, %MouseClickType%
        Sleep, %ClickDelay%
    }
    
    ; --- ADIÇÃO: Anti-Recoil Básico ---
    ; Move o mouse para baixo se o botão de tiro estiver pressionado.
    if GetKeyState(MouseClickType, "P") {
        ; DllCall para movimento relativo (move 2 pixels para baixo)
        DllCall("mouse_event", uint, 0x01, int, 0, int, 2, uint, 0, int, 0)
    }

    return

; --- Função para Limpar o ToolTip ---
RemoveToolTip:
    ToolTip
    return