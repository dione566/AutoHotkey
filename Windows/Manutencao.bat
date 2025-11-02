@echo off
echo ==========================================================
echo               Script de Manutencao do Sistema
echo ==========================================================
echo.

:: 1. Altera para o diretório raiz (opcional, dependendo de onde o script sera executado)
echo Comando: cd /
cd /
echo Diretorio atual: %CD%
echo.

:: 2. Exibe a estrutura de diretorios a partir da raiz (pode demorar em C:)
echo Comando: tree
echo **A exibicao da arvore (tree) pode ser longa. Pressione Ctrl+C para pular.**
tree
echo.

:: 3. Verifica e repara arquivos de sistema
echo Comando: sfc /scannow
echo **Executando SFC (System File Checker) para verificar arquivos do sistema.**
sfc /scannow
echo.

:: 4. Verifica e repara o disco (agendara para o proximo reboot)
echo Comando: chkdsk c: /f
echo **Executando CHKDSK para verificar e reparar o disco C:.**
echo **Voce sera solicitado a AGENDAR a verificacao no proximo REINICIO.**
chkdsk c: /f
echo.

echo ==========================================================
echo         Comandos Concluidos. Pressione qualquer tecla para sair.
echo =PO==========================================================
pause