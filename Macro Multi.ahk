; =========================================================
; SCRIPT AHK UNIFICADO (F5, F6, Z)
; =========================================================

; Váriaveis de controle: 1 = ATIVO, 0 = PAUSADO
Global Autoclick_Ativo := 1
Global TrocaRapida_Ativo := 1

; ==============================
; 0. TECLA Z: CANCELAMENTO GLOBAL
; ==============================
; Z desativa imediatamente ambos os modos.
z::
    ; Define explicitamente ambos como PAUSADO (0)
    Autoclick_Ativo := 0
    TrocaRapida_Ativo := 0
    
    ToolTip, TUDO CANCELADO / PAUSADO (Z), A_ScreenWidth/2 - 50, A_ScreenHeight/2 - 50
    ; Agenda a remoção da ToolTip após 2000 milissegundos (2 segundos)
    SetTimer, RemoveToolTip, -2000 
Return

; ==============================
; 1. TECLA F5: CONTROLE DO AUTOCLICK
; ==============================
F5::
    ; Inverte o estado da variável de controle
    Autoclick_Ativo := !Autoclick_Ativo
    
    If Autoclick_Ativo
    {
        ToolTip, AUTOCLICK ATIVADO (F5), A_ScreenWidth/2 - 50, A_ScreenHeight/2 - 50
        SetTimer, RemoveToolTip, -1500
    }
    Else
    {
        ToolTip, AUTOCLICK PAUSADO (F5), A_ScreenWidth/2 - 50, A_ScreenHeight/2 - 50
    }
Return

; ==============================
; 2. TECLA F6: CONTROLE DA TROCA RÁPIDA
; ==============================
F6::
    ; Inverte o estado da variável de controle
    TrocaRapida_Ativo := !TrocaRapida_Ativo
    
    If TrocaRapida_Ativo
    {
        ToolTip, TROCA RÁPIDA ATIVADA (F6), A_ScreenWidth/2 - 50, A_ScreenHeight/2 - 50
        SetTimer, RemoveToolTip, -1500
    }
    Else
    {
        ToolTip, TROCA RÁPIDA PAUSADA (F6), A_ScreenWidth/2 - 50, A_ScreenHeight/2 - 50
    }
Return

; Rótulo para remover a ToolTip - usado por F5, F6 e Z
RemoveToolTip:
    ToolTip
Return

; ==============================
; 3. FUNCIONALIDADE COMUM: REMAPEAMENTO MButton
; ==============================
; MButton simula LButton, mantendo sua função original (~)
~*MButton::LButton


; =========================================================
; 4. FUNCIONALIDADE DO LBUTTON (Clique Esquerdo)
; =========================================================

; -------------------------------------------
; 4A: AUTOCLICK/CLIQUE RÁPIDO (PRIORIDADE ALTA)
; -------------------------------------------
; Ativa SÓ SE F5 estiver ativo (Autoclick_Ativo = 1)
#If (Autoclick_Ativo)
$*LButton::
{
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
}
Return
#If ; Finaliza a condição #If

; ============================================
; 4B: SEQUÊNCIA DE TECLAS (TROCA RÁPIDA) - CORRIGIDA
; ============================================

; Ativa SÓ SE F5 estiver PAUSADO (!Autoclick_Ativo = 0) 
; E F6 estiver ATIVO (TrocaRapida_Ativo = 1)
#If (!Autoclick_Ativo AND TrocaRapida_Ativo)
$*LButton::
{
        Send {LButton Down}
        Sleep 5
        Send {LButton Up}

        ; Simulação da tecla q (Down + Up)
        Send {q Down}
        Sleep 5
        Send {q Up}

        ; Simulação da tecla q (Down + Up)
        Send {q Down}
        Sleep 5
        Send {q Up}
}
Return
#If
