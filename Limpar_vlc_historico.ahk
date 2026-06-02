; ==============================================================================
; Script: Menu de Limpeza Extrema para Venda de PC (Com Cipher /w:)
; ==============================================================================
#NoEnv
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SendMode Input

; --- GARANTE PRIVILÉGIOS DE ADMINISTRADOR ---
if not A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; --- CRIAÇÃO DA INTERFACE FLUTUANTE (GUI) ---
Gui, +AlwaysOnTop -Caption +ToolWindow +Border
Gui, Color, 1F1F1F
Gui, Font, s10 cWhite, Segoe UI

Gui, Add, Text, x15 y10 w220 Center +BackgroundTrans, 🛠️ MENU DE LIMPEZA PARA VENDA
Gui, Add, Text, x15 y28 w220 h1+000000 vLine +BackgroundTrans, ----------------------------------------

Gui, Add, Button, x15 y45 w220 h30 gRotinaRastros, 1. Limpar Rastros e Históricos
Gui, Add, Button, x15 y85 w220 h30 gRotinaCipher, 2. Sobrescrever Espaço Livre (Cipher)
Gui, Add, Button, x15 y125 w220 h30 gRotinaAmbos, 3. Fazer Tudo (Recomendado)
Gui, Add, Button, x15 y170 w220 h25 gSair, Sair

; Exibe o menu exatamente onde o ponteiro do mouse está
MouseGetPos, MouseX, MouseY
Gui, Show, x%MouseX% y%MouseY% w250 h210, Menu Limpeza
return

; ==============================================================================
; SUB-ROTINAS DE FUNÇÃO
; ==============================================================================

RotinaRastros:
Gui, Destroy
Func_LimparRastros()
MsgBox, 64, Sucesso, Limpeza de históricos e cache concluída!
ExitApp

RotinaCipher:
Gui, Destroy
Func_ExecutarCipher()
ExitApp

RotinaAmbos:
Gui, Destroy
Func_LimparRastros()
Func_ExecutarCipher()
ExitApp

Sair:
Gui, Destroy
ExitApp

; ==============================================================================
; FUNÇÃO 1: LIMPEZA PROFUNDA DE RASTROS, FOTOS E VÍDEOS
; ==============================================================================
Func_LimparRastros() {
    ; Fechar Processos
    Process, Close, vlc.exe
    Process, Close, mpc-hc.exe
    Process, Close, mpc-hc64.exe
    Process, Close, PotPlayerMini64.exe
    Process, Close, Video.UI.exe          
    Process, Close, Microsoft.Photos.exe  
    Process, Close, explorer.exe
    Sleep, 1500

    ; Históricos de Players
    VLC_Config := A_AppData . "\vlc\vlc-qt-interface.ini"
    if FileExist(VLC_Config) {
        IniDelete, %VLC_Config%, RecentMru
        IniDelete, %VLC_Config%, RecentsMru
    }
    RegDelete, HKEY_CURRENT_USER\Software\MPC-HC\MPC-HC\Recent File List
    RegDelete, HKEY_CURRENT_USER\Software\MPC-HC\MPC-HC\Recent URL List
    Pot_Config := A_AppData . "\PotPlayerMini64\PotPlayerMini64.ini"
    if FileExist(Pot_Config) {
        IniDelete, %Pot_Config%, RecentList
    }
    RegDelete, HKEY_CURRENT_USER\Software\DAUM\PotPlayer\Settings\RecentFileList
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentFileList
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentURLList

    ; Fotos e Apps Modernos
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows Photo Viewer\Viewer\FileHistory
    FileRemoveDir, %A_LocalAppData%\Packages\Microsoft.Windows.Photos_8wekyb3d8bbwe\LocalState, 1
    FileCreateDir, %A_LocalAppData%\Packages\Microsoft.Windows.Photos_8wekyb3d8bbwe\LocalState
    FileRemoveDir, %A_LocalAppData%\Packages\Microsoft.ZuneVideo_8wekyb3d8bbwe\LocalState, 1
    FileCreateDir, %A_LocalAppData%\Packages\Microsoft.ZuneVideo_8wekyb3d8bbwe\LocalState

    ; Históricos do Windows Explorer e Diálogos
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU         
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

    ; Jump Lists e Itens Recentes
    FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent, 1
    FileCreateDir, %A_AppData%\Microsoft\Windows\Recent
    FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations, 1
    FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations
    FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations, 1
    FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations

    ; Cache de Ícones e Miniaturas
    IconCache := A_LocalAppData . "\IconCache.db"
    IconCacheDir := A_LocalAppData . "\Microsoft\Windows\Explorer"
    if FileExist(IconCache) {
        FileSetAttrib, -H, %IconCache%
        FileDelete, %IconCache%
    }
    FileDelete, %IconCacheDir%\iconcache*.db
    FileDelete, %IconCacheDir%\thumbcache*.db

    Run, explorer.exe
    Sleep, 1000
}

; ==============================================================================
; FUNÇÃO 2: SOBRESCREVER ESPAÇO LIVRE (IMPE_DE RECUPERAÇÃO DE DADOS)
; ==============================================================================
Func_ExecutarCipher() {
    MsgBox, 36, Confirmar Cipher, Atenção: O processo de limpeza do espaço livre (Cipher) pode demorar bastante dependendo do tamanho do seu HD/SSD.`n`nDeseja iniciar agora?
    IfMsgBox No
        return

    ; Abre o CMD visível executando o Cipher para que você acompanhe o progresso por lá
    RunWait, %comspec% /c cipher /w:C:
    
    MsgBox, 64, Concluído, O espaço livre do drive C: foi sobrescrito com sucesso. Arquivos antigos deletados não podem mais ser recuperados!
}