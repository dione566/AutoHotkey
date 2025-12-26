@echo off
title Limpeza Segura de Espaço Livre (Anti-Recuperacao)

echo ==================================================
echo.
echo    ATENCAO! Este script ira sobrescrever todo o 
echo    espaco nao alocado (LIVRE) do disco selecionado.
echo    Isso e um processo lento e irreversivel que 
echo    impede a recuperacao de arquivos DELETADOS.
echo.
echo ==================================================

:SELECAO_DRIVE
set /p drive_letter="Por favor, digite APENAS a letra do Drive (ex: D, E, F) que voce deseja limpar: "

:: Garante que apenas uma letra foi inserida
if not defined drive_letter goto SELECAO_DRIVE

:: Converte a letra para maiuscula e garante o formato C:\
set drive_path=%drive_letter%:
set drive_path=%drive_path: =%

echo.
echo Voce confirmou o caminho: %drive_path%\
echo.

:CONFIRMACAO
set /p confirmacao="Tem certeza que deseja continuar? (S/N): "

if /i "%confirmacao%"=="s" goto INICIAR_LIMPEZA
if /i "%confirmacao%"=="n" goto SAIR

echo Opcao invalida. Digite S para Sim ou N para Nao.
goto CONFIRMACAO

:INICIAR_LIMPEZA
cls
echo ==================================================
echo.
echo INICIANDO LIMPEZA SEGURA
echo.
echo Drive alvo: %drive_path%\
echo Metodo: CIPHER /W (3 Passagens de Sobrescrita)
echo.
echo ISSO PODE LEVAR MUITAS HORAS DEPENDENDO DO TAMANHO
echo DO ESPACO LIVRE DO SEU DRIVE. NAO INTERROMPA.
echo.
echo ==================================================
echo.

:: Executa o comando de sanitizacao
cipher /w:%drive_path%\

echo.
echo ==================================================
echo.
echo LIMPEZA SEGURA CONCLUIDA!
echo.
echo O espaco livre no drive %drive_path%\ foi sobrescrito
echo e os dados deletados sao agora praticamente irrecuperaveis.
echo.
echo ==================================================
pause

goto SAIR

:SAIR
echo.
echo Saindo...
exit