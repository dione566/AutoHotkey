; --- Configurações Iniciais ---
#NoEnv
SetWorkingDir %A_ScriptDir%
Paused := false

~F7:: ; Fecha o script completamente
    ExitApp

; --- Atalho F6 para Pausar/Despausar ---
F6::
    Suspend, Toggle
    Paused := !Paused
    
    if (Paused)
        ToolTip, SCRIPT PAUSADO
    else
        ToolTip, SCRIPT ATIVO
    
    ; Espera 500ms e remove o ToolTip
    SetTimer, RemoveToolTip, -500
    return

RemoveToolTip:
    ToolTip
    return
; -------------------------------------------

~LButton::
    While GetKeyState("LButton", "P")
    {
        ; Primeiro clique
        Send {LButton down}
        Send {LButton up}

        Sleep, 1 ; Pausa mínima para registro do sistema

        ; Segundo clique
        Send {LButton down}
        Send {LButton up}
        
        Sleep, 10 ; Atraso entre as repetições
    }
    return