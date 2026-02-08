#SingleInstance Force

; 📌 Mensagem de inicialização
ToolTip, Script de Fechamento de Programas Ativo - ATIVO, 0, 0
return

; --- Atalho F5 ---
F5::
    ToolTip, Fechando programas...
    
    ; --- Lista dos Programas a Serem Fechados ---
    Process, Close, brave.exe
    Process, Close, BraveUpdate.exe
    Process, Close, chrome.exe
    Process, Close, Discord.exe
    Process, Close, HandBrake.exe
    Process, Close, PhoneMirror.exe
    Process, Close, AnyDesk.exe
    Process, Close, uTorrent.exe
    Process, Close, vlc.exe
    Process, Close, vegas170.exe
    Process, Close, Steam.exe
    Process, Close, PBLauncher.exe
    Process, Close, notepad.exe
    Process, Close, notepad++.exe
    Process, Close, TC Games.exe
    Process, Close, SigmaInstaller.exe
    Process, Close, msedge.exe
    Process, Close, BraveCrashHandler.exe
	Process, Close, scrcpy.exe
    
    ; --- ADICIONE NOVOS PROGRAMAS ABAIXO DESTA LINHA ---
    ; Process, Close, programa_novo.exe
    ; Process, Close, outro_programa.exe

    ; Pequena pausa para o sistema respirar
    Sleep, 500

    ; --- Focar na janela do Point Blank que já está aberta ---
    if WinExist("ahk_exe PointBlank.exe")
    {
        WinActivate, ahk_exe PointBlank.exe
    }

    ; ✅ Mensagem de sucesso
    ToolTip, Programas Fechados! Point Blank Ativo, 0, 0
    
    ; Faz o ToolTip sumir após 3 segundos
    SetTimer, RemoverToolTip, 3000
return

RemoverToolTip:
    ToolTip
    SetTimer, RemoverToolTip, Off
    ToolTip, Script de Fechamento de Programas Ativo - ATIVO, 0, 0
return
