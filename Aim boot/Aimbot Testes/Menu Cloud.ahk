#NoEnv
#SingleInstance Force
SetWorkingDir %A_ScriptDir%
DetectHiddenWindows, On 

; --- CONFIGURAÇÃO DE LINKS E ARQUIVOS TEMPORÁRIOS ---
; Substitua os links abaixo pelos links RAW reais do seu GitHub se forem diferentes
global URL_1 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Aim%20boot/Sniper/Sniper_2.0.ahk"
global URL_2 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Aim%20boot/Aimbot%20Testes/Sniper%20Puxar%202.1.ahk"
global URL_3 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Aim%20boot/Aimbot%20Testes/Sniper%20%2B%20ZOOM.ahk"
global URL_4 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Aim%20boot/Aimbot%20Testes/HEADSHOT.ahk"
global URL_5 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Mira_03.ahk"
global URL_6 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Aim%20boot/Aimbot%20Testes/DELTAFORCE/Delta%20Force_%20Aimbot%20-%20Recoil%20para%20baixo%20v4.ahk"
global URL_7 := "https://raw.githubusercontent.com/dione566/AutoHotkey/refs/heads/main/Hora%20Certa.ahk"

; Caminhos onde os arquivos serão salvos temporariamente
global File1 := A_Temp "\Sniper_2.0.ahk"
global File2 := A_Temp "\Sniper_puxar_2.1.ahk"
global File3 := A_Temp "\Sniper+Zoom.ahk"
global File4 := A_Temp "\Headshot.ahk"
global File5 := A_Temp "\Mira_03.ahk"
global File6 := A_Temp "\Delta_Force_V4.ahk"
global File7 := A_Temp "\Horacerta.ahk"

; --- INTERFACE ---
Gui, Color, 1A1A1A
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x20 y10 w230 +Center, --- PAINEL CLOUD ---

Gui, Add, Checkbox, x20 y40 vCheck1 gRodar1, Sniper_2.0
Gui, Add, Checkbox, x20 y65 vCheck2 gRodar2, Sniper Puxar 2.1
Gui, Add, Checkbox, x20 y90 vCheck3 gRodar3, Sniper + ZOOM
Gui, Add, Checkbox, x20 y115 vCheck4 gRodar4, HEADSHOT
Gui, Add, Checkbox, x20 y140 vCheck5 gRodar5, Mira_03
Gui, Add, Checkbox, x20 y165 vCheck6 gRodar6, Delta Force v4
Gui, Add, Checkbox, x20 y190 vCheck7 gRodar7, Hora Certa

Gui, Font, s8 cYellow
Gui, Add, Text, x20 y220 w199 +Center, [ F11 ] FECHAR JOGOS
Gui, Font, s8 cLime 
Gui, Add, Text, x20 y235 w199 +Center, [ F12 ] MINIMIZAR JANELA
Gui, Font, s10 cWhite
Gui, Add, Button, x20 y260 w199 h35 gSair, FECHAR TODOS E SAIR

Gui, Show, w260 h310, Menu Cloud
return

; --- FUNÇÃO PARA BAIXAR E RODAR ---
BaixarERodar(url, arquivo, check) {
    if (check) {
        ToolTip, Baixando script da nuvem...
        UrlDownloadToFile, %url%, %arquivo%
        if (ErrorLevel) {
            MsgBox, 16, Erro, Falha ao baixar: %url%
            return
        }
        Run, "%arquivo%"
        ToolTip
    }
}

; --- LOGICA DOS CHECKBOXES ---

Rodar1:
Gui, Submit, NoHide
if (Check1)
    BaixarERodar(URL_1, File1, Check1)
else
    Gosub, Fechar1
return

Rodar2:
Gui, Submit, NoHide
if (Check2)
    BaixarERodar(URL_2, File2, Check2)
else
    Gosub, Fechar2
return

Rodar3:
Gui, Submit, NoHide
if (Check3)
    BaixarERodar(URL_3, File3, Check3)
else
    Gosub, Fechar3
return

Rodar4:
Gui, Submit, NoHide
if (Check4)
    BaixarERodar(URL_4, File4, Check4)
else
    Gosub, Fechar4
return

Rodar5:
Gui, Submit, NoHide
if (Check5)
    BaixarERodar(URL_5, File5, Check5)
else
    Gosub, Fechar5
return

Rodar6:
Gui, Submit, NoHide
if (Check6)
    BaixarERodar(URL_6, File6, Check6)
else
    Gosub, Fechar6
return

Rodar7:
Gui, Submit, NoHide
if (Check7)
    BaixarERodar(URL_7, File7, Check7)
else
    Gosub, Fechar7
return

; --- LABELS DE FECHAMENTO ---

Fechar1:
WinClose, %File1% - AutoHotkey
return

Fechar2:
WinClose, %File2% - AutoHotkey
return

Fechar3:
WinClose, %File3% - AutoHotkey
return

Fechar4:
WinClose, %File4% - AutoHotkey
return

Fechar5:
WinClose, %File5% - AutoHotkey
return

Fechar6:
WinClose, %File6% - AutoHotkey
return

Fechar7:
WinClose, %File7% - AutoHotkey
return

; --- ATALHOS E SAÍDA ---

F9::
    Gui, Submit, NoHide
    Loop, 7 {
        if (!Check%A_Index%)
            Gosub, Fechar%A_Index%
    }
    ToolTip, Scripts desmarcados encerrados
    SetTimer, RemoveToolTipMenu, 2000
return

Sair:
Loop, 7
    Gosub, Fechar%A_Index%
ExitApp

GuiClose:
ExitApp

F12::
    WinGet, active_id, ID, A
    WinMinimize, ahk_id %active_id%
return

F11::
    ToolTip, Fechando processos...
    Process, Close, PBLauncher.exe
    Process, Close, PointBlank.exe
    Process, Close, DeltaForceClient-Win64-Shipping.exe
    Process, Close, DeltaForce.exe
    Sleep, 1000
    ToolTip
return

RemoveToolTipMenu:
ToolTip
return