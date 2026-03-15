; --- Script de Limpeza Multi-Player v3 ---
#NoEnv
SetBatchLines, -1

; Garante privilégios de Administrador
if not A_IsAdmin {
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

MsgBox, 4, Limpeza Total de Vídeos, Deseja limpar o histórico do VLC, MPC-HC, PotPlayer e Windows Media Player?
IfMsgBox No
    ExitApp

; 0. FECHAR PROCESSOS (Para liberar os arquivos de configuração)
Process, Close, vlc.exe
Process, Close, mpc-hc.exe
Process, Close, mpc-hc64.exe
Process, Close, PotPlayerMini64.exe
Process, Close, explorer.exe

; --- 1. VLC MEDIA PLAYER ---
VLC_Config := A_AppData . "\vlc\vlc-qt-interface.ini"
if FileExist(VLC_Config) {
    IniDelete, %VLC_Config%, RecentMru
    IniDelete, %VLC_Config%, RecentsMru
}

; --- 2. MPC-HC (Media Player Classic) ---
; O MPC guarda o histórico no registro
RegDelete, HKEY_CURRENT_USER\Software\MPC-HC\MPC-HC\Recent File List
RegDelete, HKEY_CURRENT_USER\Software\MPC-HC\MPC-HC\Recent URL List

; --- 3. POTPLAYER ---
; O PotPlayer guarda em um arquivo .ini na pasta de instalação ou no AppData
Pot_Config := A_AppData . "\PotPlayerMini64\PotPlayerMini64.ini"
if FileExist(Pot_Config) {
    IniDelete, %Pot_Config%, RecentList
}
; Também limpa no Registro caso esteja lá
RegDelete, HKEY_CURRENT_USER\Software\DAUM\PotPlayer\Settings\RecentFileList

; --- 4. WINDOWS MEDIA PLAYER (Antigo e Novo) ---
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentFileList
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\MediaPlayer\Player\RecentURLList
; Histórico de arquivos abertos no "Filmes e TV" / "Media Player" novo
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths

; --- 5. LIMPEZA PROFUNDA DO WINDOWS (Onde ficam os ícones da barra de tarefas) ---
; Limpa os "Recent Items" gerais do Windows
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent

; Limpa as Jump Lists (Ícones que aparecem ao clicar com o botão direito nos players)
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\AutomaticDestinations
FileRemoveDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations, 1
FileCreateDir, %A_AppData%\Microsoft\Windows\Recent\CustomDestinations

; --- 6. REGISTRO GERAL DE DIÁLOGOS (Open/Save) ---
; Limpa o que você abriu recentemente em qualquer janela de "Abrir Arquivo"
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU
RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs

; REINICIAR O EXPLORER (Necessário para limpar os ícones visualmente)
Run, explorer.exe

MsgBox, 64, Concluído, O histórico de todos os reprodutores foi resetado!
ExitApp