#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On ; Necessário para fechar scripts em segundo plano

Gui, Color, 1A1A1A
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y20 w230 +Center, --- PAINEL DE CONTROLE ---

Gui, Add, Checkbox, x20 y50 vCheck1 gRodar1, Ativar Sniper Puxar 2.1
Gui, Add, Checkbox, x20 y80 vCheck2 gRodar2, Ativar No Recoil
Gui, Add, Checkbox, x20 y110 vCheck3 gRodar3, Ativar Macro de 12
Gui, Add, Checkbox, x20 y140 vCheck4 gRodar4, Mira_03
Gui, Add, Checkbox, x20 y170 vCheck5 gRodar5, Delta Force_v4

Gui, Add, Button, x20 y210 w199 h30 gSair, FECHAR TODOS E SAIR

Gui, Show, w260 h280, Menu Painel
return

; --- ATALHO F9 ---
; Quando você apertar F9, ele vai ler quais caixas estão desmarcadas e fechar os scripts respectivos
F9::
    Gui, Submit, NoHide
    if (!Check1) 
        Gosub, Fechar1
    if (!Check2) 
        Gosub, Fechar2
    if (!Check3) 
        Gosub, Fechar3
    if (!Check4) 
        Gosub, Fechar4
    if (!Check5) 
        Gosub, Fechar5
    
    ToolTip, Scripts desmarcados foram encerrados (F9)
    SetTimer, RemoveToolTipMenu, 2000
return

; --- LÓGICA DE EXECUÇÃO ---

Rodar1:
Gui, Submit, NoHide
if (Check1)
    Run, "Sniper Puxar 2.1.ahk"
else
    Gosub, Fechar1
return

Rodar2:
Gui, Submit, NoHide
if (Check2)
    Run, "No Recoil.ahk"
else
    Gosub, Fechar2
return

Rodar3:
Gui, Submit, NoHide
if (Check3)
    Run, "Macro de 12.ahk"
else
    Gosub, Fechar3
return

Rodar4:
Gui, Submit, NoHide
if (Check4)
    Run, "Mira_03.ahk"
else
    Gosub, Fechar4
return

Rodar5:
Gui, Submit, NoHide
if (Check5)
    Run, "Delta Force_ Aimbot - Recoil para baixo v4.ahk"
else
    Gosub, Fechar5
return

; --- LABELS DE FECHAMENTO ESPECÍFICO ---

Fechar1:
WinClose, %A_ScriptDir%\Sniper Puxar 2.1.ahk - AutoHotkey
return

Fechar2:
WinClose, %A_ScriptDir%\No Recoil.ahk - AutoHotkey
return

Fechar3:
WinClose, %A_ScriptDir%\Macro de 12.ahk - AutoHotkey
return

Fechar4:
WinClose, %A_ScriptDir%\Mira_03.ahk - AutoHotkey
return

Fechar5:
WinClose, %A_ScriptDir%\Delta Force_ Aimbot - Recoil para baixo v4.ahk - AutoHotkey
return

; --- CONTROLES GERAIS ---

SuspenderTudo:
Suspend, Toggle
if (A_IsSuspended)
    ToolTip, SISTEMA PAUSADO
else
    ToolTip, SISTEMA ATIVO
SetTimer, RemoveToolTipMenu, 2000
return

RemoveToolTipMenu:
ToolTip
return

Sair:
; Fecha todos antes de sair
Gosub, Fechar1
Gosub, Fechar2
Gosub, Fechar3
Gosub, Fechar4
Gosub, Fechar5
ExitApp

GuiClose:
ExitApp

F12::
    WinGet, active_id, ID, A
    WinMinimize, ahk_id %active_id%
    ; Caso o comando acima falhe, tentamos forçar o estado da janela:
    PostMessage, 0x0112, 0xF020,,, ahk_id %active_id% ; 0x112 é WM_SYSCOMMAND, 0xF020 é SC_MINIMIZE
	
return

; --- Atalho F11 ---
F11::
    ToolTip, Fechando programas...
    
    ; --- Lista dos Programas a Serem Fechados ---
	
    Process, Close, PBLauncher.exe
    Process, Close, PointBlank.exe
    Process, Close, DeltaForceClient-Win64-Shipping.exe
    Process, Close, DeltaForce.exe
    Process, Close, df_garena_launcher.exe
	
    ; Aguarda 2 segundos para o usuário ver a mensagem e depois remove o ToolTip
    Sleep, 2000
    ToolTip
return