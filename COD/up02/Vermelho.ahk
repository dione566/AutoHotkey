; --- Configurações Iniciais ---
#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1
Process, Priority,, High

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; --- Configurações de Ajuste (Calibradas para a sua Imagem) ---
ColorToFind   := 0x731201  ; Cor exata do centro do círculo no seu Paint
Variation     := 15         ; Aumentado para ignorar o serrilhado/ruído dos pixels
Sensibilidade := 0.3        ; Movimento firme e suave sem passar direto
SearchRadius  := 80       ; Área de busca maior para encontrar o círculo mais fácil
AimbotActive  := False

; --- AJUSTE DE FOCO (OFFSET) ---
YOffset        := 5

; --- Configuração Inicial do Menu Flutuante ---
MenuX := A_ScreenWidth - 150  
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 
Gui, Color, 1A1A1A                            
Gui, Font, s10 Bold, Segoe UI                 
Return 

; --- Função para Atualizar o Painel ---
AtualizarMenu() {
    global AimbotActive
    global MenuX, MenuY
    
    SetTimer, EsconderMenu, Off
    
    if (A_IsSuspended) {
    } else {
        if (AimbotActive) {
        } else {
        }
    }
}

EsconderMenu:
    Gui, Hide
Return

~f7::
    ExitApp
return

; --- Loop Principal Otimizado ---

MainLoop:
    if (!AimbotActive)
        return

    ; Define o centro da sua tela atual (dinâmico para qualquer resolução)
    MidX := A_ScreenWidth / 2
    MidY := A_ScreenHeight / 2

    ; Cria o quadrado de busca ao redor do centro da tela
    X1 := MidX - SearchRadius
    Y1 := MidY - SearchRadius
    X2 := MidX + SearchRadius
    Y2 := MidY + SearchRadius

    ; Procura a cor na tela usando RGB
    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB

    if (ErrorLevel = 0)
    {
        ; [MELHORIA 1] Compensação do centro do objeto
        ; Se o círculo/alvo tem cerca de 10 pixels, somamos 5 para mirar no meio dele
        ObjetoTamanho := 6 
        FocoX := FoundX + ObjetoTamanho
        FocoY := FoundY + ObjetoTamanho

        ; [MELHORIA 2] Calcula a distância real até o centro ajustado
        ; O YOffset agora é somado diretamente aqui, ajuste se achar necessário
        DistX := FocoX - MidX
        DistY := (FocoY + YOffset) - MidY

        ; [MELHORIA 3] Limitador de Velocidade (Evita que a mira passe direto se o alvo se mover)
        ; Se o movimento for muito brusco, ele suaviza.
        TargetX := DistX * Sensibilidade
        TargetY := DistY * Sensibilidade
        
        ; Trava a velocidade máxima por tick para não dar "puladas" na tela
        MaxMovimento := 20
        if (TargetX > MaxMovimento)
            TargetX := MaxMovimento
        if (TargetX < -MaxMovimento)
            TargetX := -MaxMovimento
        if (TargetY > MaxMovimento)
            TargetY := MaxMovimento
        if (TargetY < -MaxMovimento)
            TargetY := -MaxMovimento

        ; Envia o movimento relativo para o mouse apenas se a distância for relevante (evita tremedeira)
        if (Abs(DistX) > 2 or Abs(DistY) > 2)
        {
            DllCall("mouse_event", "UInt", 0x0001, "Int", TargetX, "Int", TargetY, "UInt", 0, "UPtr", 0)
        }
    }
return

; =======================================================================
; --- Mapeamento do Mouse ---
; =======================================================================

WheelUp::
    AimbotActive := True
    AtualizarMenu()
    SetTimer, MainLoop, 1
return

WheelDown::
    AimbotActive := False
    AtualizarMenu()
    SetTimer, MainLoop, Off
return

F12::
    Send, #d 
return