#Requires AutoHotkey v2.0
#SingleInstance Force

; Define que as coordenadas do ToolTip são baseadas na tela inteira (Screen)
CoordMode "ToolTip", "Screen"

; Inicia o temporizador para atualizar a cada segundo
SetTimer(RelogioTopo, 1000)

RelogioTopo() {
    ; Calcula o horário de Cuiabá (UTC-4)
    HoraCuiaba := DateAdd(A_NowUTC, -4, "Hours")
    Texto := FormatTime(HoraCuiaba, "'Cuiabá:' HH:mm:ss")
    
    ; Calcula a posição centralizada no topo
    ; A_ScreenWidth é a largura total do seu monitor
    PosicaoX := (A_ScreenWidth / 2) - 50 
    PosicaoY := 0 ; 0 encosta no topo da tela
    
    ToolTip(Texto, PosicaoX, PosicaoY)
}

; Tecla de emergência: Aperte F8 para fechar o relógio
F8::ExitApp