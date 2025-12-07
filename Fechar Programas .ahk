#SingleInstance Force

; 📌 Mensagem de inicialização que NÃO DESAPARECE
; Exibe a mensagem "Script de Fechamento de Programas Ativo" no canto superior esquerdo (coordenadas x=0, y=0)
ToolTip, Script de Fechamento de Programas Ativo - ATIVO, 0, 0
return ; O script agora espera pelo atalho F5, mantendo o ToolTip visível.

; --- Atalho F5 ---
F5::
    ; O ToolTip anterior será substituído por esta nova mensagem
    ToolTip, Fechando programas...
    
    ; --- Lista dos Programas a Serem Fechados ---

    Process, Close, PointBlank.exe
    Process, Close, brave.exe
    Process, Close, BraveUpdate.exe
    Process, Close, chrome.exe
    Process, Close, Yoosee.exe
    Process, Close, Discord.exe
    Process, Close, HandBrake.exe
    Process, Close, PhoneMirror.exe
    Process, Close, AnyDesk.exe
    Process, Close, uTorrent.exe
    Process, Close, vlc.exe
    Process, Close, vegas170.exe
    Process, Close, Steam.exe
    
    ; ✅ Mensagem de sucesso (permanecerá na tela até você pressionar F5 novamente)
    ToolTip, Programas Fechados! Script ATIVO, 0, 0
return