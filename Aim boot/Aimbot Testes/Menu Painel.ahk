#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On 

Gui, Color, 1A1A1A
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y10 w230 +Center, --- PAINEL DE CONTROLE ---

Gui, Add, Checkbox, x20 y40 vCheck1 gRodar1, Sniper_2.0
Gui, Add, Checkbox, x20 y65 vCheck2 gRodar2, Sniper Puxar 2.1
Gui, Add, Checkbox, x20 y90 vCheck3 gRodar3, Ativar Sniper + ZOOM
Gui, Add, Checkbox, x20 y115 vCheck4 gRodar4, HEADSHOT
Gui, Add, Checkbox, x20 y140 vCheck5 gRodar5, Mira_03
Gui, Add, Checkbox, x20 y165 vCheck6 gRodar6, Delta Force v4
Gui, Add, Checkbox, x20 y190 vCheck7 gRodar7, Novo Script 02

; --- INFORMAÇÕES ADICIONAIS ---
Gui, Font, s8 cYellow
Gui, Add, Text, x20 y220 w199 +Center, [ F11 ] FECHAR JOGOS
Gui, Font, s8 cLime 
Gui, Add, Text, x20 y235 w199 +Center, [ F12 ] MINIMIZAR JANELA ATIVA
Gui, Font, s10 cWhite

Gui, Add, Button, x20 y260 w199 h35 gSair, FECHAR TODOS E SAIR

; Aumentei a altura (h310) para caber as novas opções
Gui, Show, w260 h310, Menu Painel
return

; --- ATALHO F9 ---
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
    if (!Check6) 
        Gosub, Fechar6
    if (!Check7) 
        Gosub, Fechar7
    
    ToolTip, Scripts desmarcados encerrados (F9)
    SetTimer, RemoveToolTipMenu, 2000
return

; --- LÓGICA DE EXECUÇÃO ---

Rodar1:
Gui, Submit, NoHide
if (Check1)
    Run, "Sniper_2.0.ahk"
else
    Gosub, Fechar1
return

Rodar2:
Gui, Submit, NoHide
if (Check2)
    Run, "Sniper Puxar 2.1.ahk"
else
    Gosub, Fechar2
return

Rodar3:
Gui, Submit, NoHide
if (Check3)
    Run, "Sniper + ZOOM.ahk"
else
    Gosub, Fechar3
return

Rodar4:
Gui, Submit, NoHide
if (Check4)
    Run, "HEADSHOT.ahk"
else
    Gosub, Fechar4
return

Rodar5:
Gui, Submit, NoHide
if (Check5)
    Run, "Mira_03.ahk"
else
    Gosub, Fechar5
return

Rodar6:
Gui, Submit, NoHide
if (Check6)
    Run, "Delta Force_ Aimbot - Recoil para baixo v4.ahk"
else
    Gosub, Fechar6
return

Rodar7:
Gui, Submit, NoHide
if (Check7)
    Run, "NomeDoSeuScriptAqui2.ahk"
else
    Gosub, Fechar7
return

; --- LABELS DE FECHAMENTO ---

Fechar1:
WinClose, %A_ScriptDir%\Sniper_2.0.ahk - AutoHotkey
return

Fechar2:
WinClose, %A_ScriptDir%\Sniper Puxar 2.1.ahk - AutoHotkey
return

Fechar3:
WinClose, %A_ScriptDir%\Sniper + ZOOM.ahk - AutoHotkey
return

Fechar4:
WinClose, %A_ScriptDir%\HEADSHOT.ahk - AutoHotkey
return

Fechar5:
WinClose, %A_ScriptDir%\Mira_03.ahk - AutoHotkey
return

Fechar6:
WinClose, %A_ScriptDir%\Delta Force_ Aimbot - Recoil para baixo v4.ahk - AutoHotkey
return

Fechar7:
WinClose, %A_ScriptDir%\NomeDoSeuScriptAqui2.ahk - AutoHotkey
return

; --- CONTROLES GERAIS ---

RemoveToolTipMenu:
ToolTip
return

Sair:
Gosub, Fechar1
Gosub, Fechar2
Gosub, Fechar3
Gosub, Fechar4
Gosub, Fechar5
Gosub, Fechar6
Gosub, Fechar7
ExitApp

GuiClose:
ExitApp

F12::
    WinGet, active_id, ID, A
    WinMinimize, ahk_id %active_id%
    PostMessage, 0x0112, 0xF020,,, ahk_id %active_id% 
return

F11::
    ToolTip, Fechando programas...
    Process, Close, PBLauncher.exe
    Process, Close, PointBlank.exe
    Process, Close, DeltaForceClient-Win64-Shipping.exe
    Process, Close, DeltaForce.exe
    Process, Close, df_garena_launcher.exe
    Sleep, 2000
    ToolTip
return