; ========================================================================
; Co.Aimbot_Profissional - Rastreio Centralizado em Tempo Real
; ========================================================================

if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
SendMode Input
SetBatchLines -1
Process, Priority,, High

CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; --- Configurações Iniciais ---
ColorToFind   := 0xEE00E9
Variation     := 5          ; Tolerância de cor
Sensibilidade := 0.6        ; Sensibilidade horizontal (X)
SensY         := 0.6        ; Sensibilidade vertical (Y)
SearchRadius  := 180        ; Raio de busca ao redor do rato
SearchActive  := False

; --- AJUSTE DE ALTURA (OFFSET) ---
YOffset       := 0          ; Se quiser descentralizar verticalmente

; --- PARÂMETROS DE RESPOSTA ---
DeadZone      := 1.0        ; Trava o movimento quando estiver em cima do alvo
MaxMovimento  := 35         ; Limite máximo de deslocamento por ciclo

; --- Configuração do Menu Flutuante ---
MenuX := A_ScreenWidth - 150  
MenuY := 10

Gui, +AlwaysOnTop -Caption +ToolWindow +E0x20 
Gui, Color, 1A1A1A                             
Gui, Font, s10 Bold, Segoe UI                  
Gui, Add, Text, x10 y5 w130 vStatusSearch, SEARCH: OFF
Return 

AtualizarMenu() {
    global SearchActive, MenuX, MenuY
    SetTimer, EsconderMenu, Off
    if (A_IsSuspended) {
        GuiControl, +cFF4444, StatusSearch
        GuiControl,, StatusSearch, SUSPENDIDO
    } else {
        if (SearchActive) {
            GuiControl, +c44FF44, StatusSearch
            GuiControl,, StatusSearch, SEARCH: ON
        } else {
            GuiControl, +cFF4444, StatusSearch
            GuiControl,, StatusSearch, SEARCH: OFF
        }
    }
    Gui, Show, x%MenuX% y%MenuY% w140 h30 NoActivate
    SetTimer, EsconderMenu, -1500
}

EsconderMenu:
    Gui, Hide
Return

; ========================================================================
; --- Mapeamento do Rato ---
; ========================================================================

WheelUp::
    SearchActive := True
    AtualizarMenu()
    SetTimer, MainLoop, 1       
return

WheelDown::
    SearchActive := False
    AtualizarMenu()
    SetTimer, MainLoop, Off
return

F12::
    Send, #d 
return

; ========================================================================
; --- Loop Principal do Aimbot (Tempo Real) ---
; ========================================================================

MainLoop:
    if (!SearchActive)
        return

    ; Posição atual do ponteiro do rato
    MouseGetPos, MouseX, MouseY
    
    ; Define a área de busca ao redor do ponteiro do rato
    X1 := MouseX - SearchRadius
    Y1 := MouseY - SearchRadius
    X2 := MouseX + SearchRadius
    Y2 := MouseY + SearchRadius

    ; 1. Encontra o primeiro ponto da cor
    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB
    
    if (ErrorLevel = 0)
    {
        ; 2. Varredura inteligente para achar o centro do objeto (Bordas Oposta)
        ; Procura o limite direito a partir do ponto encontrado na mesma altura
        PixelSearch, RightX, _, FoundX, FoundY, FoundX + 50, FoundY, ColorToFind, Variation, Fast RGB
        EndX := (ErrorLevel = 0) ? RightX : FoundX

        ; Procura o limite inferior a partir do ponto encontrado na mesma largura
        PixelSearch, _, BottomY, FoundX, FoundY, FoundX, FoundY + 50, ColorToFind, Variation, Fast RGB
        EndY := (ErrorLevel = 0) ? BottomY : FoundY

        ; Calcula o centro exato do objeto encontrado
        TargetX := FoundX + ((EndX - FoundX) / 2)
        TargetY := FoundY + ((EndY - FoundY) / 2) + YOffset

        ; Calcula a distância entre o rato e o centro real do alvo
        DistX := TargetX - MouseX
        DistY := TargetY - MouseY
        DistTotal := Sqrt(DistX * DistX + DistY * DistY)

        ; Se o rato já estiver no centro do alvo, ignora o movimento
        if (DistTotal <= DeadZone) 
            return

        ; Cálculo do movimento em tempo real
        MoveX := DistX * Sensibilidade
        MoveY := DistY * SensY
        
        ; Limita a velocidade para evitar saltos bruscos
        if (MoveX > MaxMovimento) 
            MoveX := MaxMovimento
        if (MoveX < -MaxMovimento) 
            MoveX := -MaxMovimento
        if (MoveY > MaxMovimento) 
            MoveY := MaxMovimento
        if (MoveY < -MaxMovimento) 
            MoveY := -MaxMovimento
        
        ; Move o rato imediatamente para as novas coordenadas do centro
        if (Abs(MoveX) >= 0.2 or Abs(MoveY) >= 0.2)
        {
            DllCall("mouse_event", "UInt", 0x0001, "Int", Round(MoveX), "Int", Round(MoveY), "UInt", 0, "UPtr", 0)
        }
    }
return

~F9::
    ExitApp
return