; --- Configurações Iniciais ---
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Variável para armazenar a sensibilidade atual (1 a 20)
; O script tentará ler a sensibilidade atual ao iniciar
RegRead, CurrentSens, HKEY_CURRENT_USER, Control Panel\Mouse, MouseSpeed
DllCall("user32.dll\SystemParametersInfo", UInt, 0x70, UInt, 0, UIntP, CurrentSens, UInt, 0)

; --- Hotkeys ---

F5:: ; Aumentar Sensibilidade
    if (CurrentSens < 20) {
        CurrentSens++
        SetMouseSensitivity(CurrentSens)
        ToolTip, Sensibilidade: %CurrentSens%
        SetTimer, RemoveToolTip, -1000
    }
return

F6:: ; Diminuir Sensibilidade
    if (CurrentSens > 1) {
        CurrentSens--
        SetMouseSensitivity(CurrentSens)
        ToolTip, Sensibilidade: %CurrentSens%
        SetTimer, RemoveToolTip, -1000
    }
return

; --- Função para aplicar a mudança ---

SetMouseSensitivity(Value) {
    ; 0x71 é o código para SPI_SETMOUSESPEED
    DllCall("user32.dll\SystemParametersInfo", UInt, 0x71, UInt, 0, UInt, Value, UInt, 0)
}

RemoveToolTip:
    ToolTip
return