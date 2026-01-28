; --- Configurações Iniciais ---
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; --- Menu Flutuante (Legenda) ---
; Cria uma pequena janela no canto superior esquerdo para servir de guia
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, 222222
Gui, Font, s10 cWhite, Segoe UI
Gui, Add, Text,, [F1] 1445x2960 (620 DPI)
Gui, Add, Text,, [F2] 2890x5920 (620 DPI)
Gui, Add, Text,, [F3] Resetar Padrão
Gui, Add, Text,, [Esc] Fechar Script
Gui, Show, x10 y10 NoActivate, MenuADB ; Posiciona no x10 y10 da tela
return

; --- Atalho F1: Aplicar Resolução 1 ---
F1::
    ToolTip, Aplicando Resolução Personalizada (F1)...
    RunWait, adb shell wm size 1445x2960,, Hide
    RunWait, adb shell wm density 620,, Hide
    ToolTip
    MsgBox, 64, Sucesso, Resolução alterada para 1445x2960 (620 DPI).
return

; --- Atalho F2: Aplicar Resolução 2 ---
F2::
    ToolTip, Aplicando Resolução Personalizada (F2)...
    RunWait, adb shell wm size 2890x5920,, Hide
    RunWait, adb shell wm density 620,, Hide
    ToolTip
    MsgBox, 64, Sucesso, Resolução alterada para 2890x5920 (620 DPI).
return

; --- Atalho F3: Resetar para o Padrão ---
F3::
    ToolTip, Restaurando Padrões...
    RunWait, adb shell wm size reset,, Hide
    RunWait, adb shell wm density reset,, Hide
    ToolTip
    MsgBox, 48, Resetado, Resolução e Densidade restauradas ao padrão original.
return

; --- Atalho Esc: Sair do Script ---
Esc::ExitApp