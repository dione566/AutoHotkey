@echo off
:menu
cls
echo.
echo ===========================================
echo            MENU DE DRIVERS
echo ===========================================
echo.
echo [1] - FAZER BACKUP DOS DRIVERS (C:\BKP_DRIVERS)
echo [2] - RESTAURAR DRIVERS (DE C:\BKP_DRIVERS)
echo [3] - Sair
echo.
echo ===========================================
set /p escolha="Escolha uma opcao: "

if /i "%escolha%"=="1" goto backup
if /i "%escolha%"=="2" goto restaurar
if /i "%escolha%"=="3" goto fim
goto menu

:backup
cls
echo ===========================================
echo            BACKUP DOS DRIVERS
echo ===========================================
echo.
echo Criando a pasta de destino...
if not exist "C:\BKP_DRIVERS" mkdir C:\BKP_DRIVERS
echo.
echo Iniciando o backup para C:\BKP_DRIVERS. Isso pode levar alguns minutos...
echo (Apenas drivers de terceiros serao exportados)
echo.

dism /online /export-driver /destination:C:\BKP_DRIVERS

if %errorlevel% equ 0 (
    echo.
    echo BACKUP CONCLUIDO COM SUCESSO!
) else (
    echo.
    echo Ocorreu um ERRO durante o backup (Codigo de erro: %errorlevel%).
)
pause
goto menu

:restaurar
cls
echo ===========================================
echo           RESTAURAR DRIVERS
echo ===========================================
echo.
echo Utilizando PnPUtil para instalar drivers online...
echo.

if not exist "C:\BKP_DRIVERS" (
    echo ERRO: A pasta de backup C:\BKP_DRIVERS nao foi encontrada.
    echo Por favor, faca o backup primeiro ou verifique o caminho.
    pause
    goto menu
)

echo Iniciando a instalacao dos drivers...

:: COMANDO CORRETO PARA INSTALAR DRIVERS DE UMA PASTA NO MODO ONLINE:
pnputil /add-driver "C:\BKP_DRIVERS\*.inf" /subdirs /install

if %errorlevel% equ 0 (
    echo.
    echo RESTAURACAO CONCLUIDA COM SUCESSO!
    echo Pode ser necessario REINICIAR o sistema para que todos os drivers funcionem.
) else (
    echo.
    echo Ocorreu um ERRO durante a restauracao (Codigo de erro: %errorlevel%).
)
pause
goto menu

:fim
exit