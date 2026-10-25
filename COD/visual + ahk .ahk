; ========================================================================
; Co.Aimbot_Profissional - Com Painel (F4), Triggerbot e Controle de Velocidade
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
ColorToFind   := 0xFF0000
Variation     := 5          
Sensibilidade := 0.6        
SensY         := 0.6        
SearchRadius  := 180        
YOffset       := 0          
DeadZone      := 1.0        
MaxMovimento  := 35         

Global Modo := 3            
Global ModoAnterior := 3    
Global Atirando := False
Global GuiVisible := False

; --- Criação do Menu Painel (F4) ---
Gui, Color, 1A1A1A
Gui, Font, s10 cWhite Bold, Segoe UI 
Gui, Add, Text,, Escolha o Modo de Rastreio:

Gui, Font, s10 cWhite Norm, Segoe UI 
Gui, Add, Radio, vModo gSalvarModo, Opção 1: Seguir cor apenas com Lbutton pressionado
Gui, Add, Radio, gSalvarModo, Opção 2: Seguir com Rbutton + Trigger (Segura Lbutton ao mirar)
Gui, Add, Radio, gSalvarModo Checked, Opção 3: Nenhum (Desativado)
Gui, Add, Radio, gSalvarModo, Opção 4: Ocultar painel

; Adição do Controle de Velocidade (Slider)
Gui, Font, s10 cWhite Bold, Segoe UI 
Gui, Add, Text, y+20, Velocidade / Suavidade do Mouse:
Gui, Font, s10 cWhite Norm, Segoe UI 
Gui, Add, Slider, vSensSlider gAtualizarSens Range1-100 TickInterval10 AltSubmit w300, 60
Gui, Add, Text, vSensText w50 x+10 yp, 0.60

SetTimer, MainLoop, 1
return

; ========================================================================
; --- Atualização da Velocidade em Tempo Real ---
; ========================================================================
AtualizarSens:
    Gui, Submit, NoHide
    ; Converte o valor do slider (1 a 100) para casas decimais (0.01 a 1.00)
    Sensibilidade := SensSlider / 100
    SensY := SensSlider / 100
    
    ; Formata o texto para exibir com duas casas decimais
    NovoTexto := Format("{:.2f}", Sensibilidade)
    GuiControl,, SensText, %NovoTexto%
return

; ========================================================================
; --- Atalhos ---
; ========================================================================

F4::
    GuiVisible := !GuiVisible
    if (GuiVisible)
        Gui, Show, w400, Painel de Controle
    else
        Gui, Hide
return

F7::
    Suspend, On
    SoundBeep, 400, 200
return

F8::
    Suspend, Off
    SoundBeep, 800, 200
return

F12::
    Send, #d 
return

~F9::
    ExitApp
return

; Lógica das Caixas de Seleção
SalvarModo:
    Gui, Submit, NoHide
    if (Modo == 4) {
        Gui, Hide
        GuiVisible := False
        Modo := ModoAnterior  
        GuiControl,, Button%Modo%, 1 
    } else {
        ModoAnterior := Modo
    }
return

; ========================================================================
; --- Loop Principal do Aimbot e Triggerbot ---
; ========================================================================

MainLoop:
    if (Modo == 3 || Modo == 4)
        return

    if (Modo == 1) {
        if !GetKeyState("LButton", "P")
            return
    }

    if (Modo == 2) {
        if !GetKeyState("RButton", "P") {
            if (Atirando) {
                Send {LButton Up}
                Atirando := False
            }
            return
        }
    }

    MouseGetPos, MouseX, MouseY
    
    X1 := MouseX - SearchRadius
    Y1 := MouseY - SearchRadius
    X2 := MouseX + SearchRadius
    Y2 := MouseY + SearchRadius

    PixelSearch, FoundX, FoundY, X1, Y1, X2, Y2, ColorToFind, Variation, Fast RGB
    
    if (ErrorLevel = 0)
    {
        TargetY := FoundY + YOffset

        DistX := FoundX - MouseX
        DistY := TargetY - MouseY
        DistTotal := Sqrt(DistX * DistX + DistY * DistY)

        if (DistTotal <= DeadZone) {
            if (Modo == 2 && !Atirando) {
                Send {LButton Down}
                Atirando := True
            }
            return
        }

        MoveX := DistX * Sensibilidade
        MoveY := DistY * SensY
        
        if (MoveX > MaxMovimento) 
            MoveX := MaxMovimento
        if (MoveX < -MaxMovimento) 
            MoveX := -MaxMovimento
        if (MoveY > MaxMovimento) 
            MoveY := MaxMovimento
        if (MoveY < -MaxMovimento) 
            MoveY := -MaxMovimento
        
        if (Abs(MoveX) >= 0.2 or Abs(MoveY) >= 0.2)
        {
            DllCall("mouse_event", "UInt", 0x0001, "Int", Round(MoveX), "Int", Round(MoveY), "UInt", 0, "UPtr", 0)
        }

        if (Modo == 2 && !Atirando) {
            Send {LButton Down}
            Atirando := True
        }
    } 
    else 
    {
        if (Modo == 2 && Atirando) {
            Send {LButton Up}
            Atirando := False
        }
    }
return