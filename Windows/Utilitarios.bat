@echo off
set "InterfaceName=Ethernet"
set "GoogleDNS_Primario=8.8.8.8"
set "GoogleDNS_Secundario=8.8.4.4"
set "CloudflareDNS_Primario=1.1.1.1"
set "CloudflareDNS_Secundario=1.0.0.1"

:Menu
cls
echo.
echo =================================================================
echo GERENCIADOR DE REDE: "%InterfaceName%"
echo (Executar como ADMINISTRADOR!)
echo =================================================================
echo.
echo.
echo Escolha uma opcao:
echo.
echo [1] - ATIVAR a interface "%InterfaceName%"
echo [2] - DESATIVAR a interface "%InterfaceName%"
echo -----------------------------------------------------------------
echo [3] - CONFIGURAR DNS: Google (%GoogleDNS_Primario% / %GoogleDNS_Secundario%)
echo [4] - CONFIGURAR DNS: Cloudflare (%CloudflareDNS_Primario% / %CloudflareDNS_Secundario%)
echo [5] - CONFIGURAR DNS: Automatico (DHCP)
echo -----------------------------------------------------------------
echo [6] - INTERFACES DE REDE (netsh interface ipv4 show interfaces)
echo -----------------------------------------------------------------
echo [7] - COMANDOS DE REDE RAPIDOS
echo -----------------------------------------------------------------
echo [8] - SAIR
echo.
set /p Opcao="Digite o numero da opcao e pressione ENTER: "

if "%Opcao%"=="1" goto Ativar
if "%Opcao%"=="2" goto Desativar
if "%Opcao%"=="3" goto ConfigurarDNS_Google
if "%Opcao%"=="4" goto ConfigurarDNS_Cloudflare
if "%Opcao%"=="5" goto DNSAutomatico
if "%Opcao%"=="6" goto MostrarInterfaces
if "%Opcao%"=="7" goto ExecutarComando
if "%Opcao%"=="8" goto Fim
goto Menu

:: =================================================
:: SUBROTINAS DE CONTROLE DE INTERFACE
:: =================================================

:Ativar
cls
echo.
echo ==========================================================
echo Ativando a interface: "%InterfaceName%"
echo ==========================================================
echo.
netsh interface set interface name="%InterfaceName%" admin=enable

if errorlevel 1 (
    echo.
    echo ERRO: Falha ao ativar. Verifique o nome e se o script foi executado como Administrador.
) else (
    echo.
    echo Interface "%InterfaceName%" ATIVADA com sucesso.
)
echo.
pause
goto Menu

:Desativar
cls
echo.
echo ==========================================================
echo Desativando a interface: "%InterfaceName%"
echo ==========================================================
echo.
netsh interface set interface name="%InterfaceName%" admin=disable

if errorlevel 1 (
    echo.
    echo ERRO: Falha ao desativar. Verifique o nome e se o script foi executado como Administrador.
) else (
    echo.
    echo Interface "%InterfaceName%" DESATIVADA com sucesso.
)
echo.
pause
goto Menu

:: =================================================
:: SUBROTINAS DE CONFIGURAÇÃO DE DNS
:: =================================================

:ConfigurarDNS_Google
call :SetDNS %GoogleDNS_Primario% %GoogleDNS_Secundario% "Google"
goto Menu

:ConfigurarDNS_Cloudflare
call :SetDNS %CloudflareDNS_Primario% %CloudflareDNS_Secundario% "Cloudflare"
goto Menu

:SetDNS
:: Recebe 3 argumentos: %1=Primario, %2=Secundario, %3=Nome do Perfil
cls
echo.
echo =================================================================
echo Configurando DNS Fixo (%3) na interface: "%InterfaceName%"
echo Primario: %1
echo Secundario: %2
echo =================================================================
echo.
:: Define o DNS primário (Substitui quaisquer IPs existentes)
netsh interface ipv4 set dnsservers name="%InterfaceName%" static %1 primary

:: Adiciona o DNS secundário
netsh interface ipv4 add dnsservers name="%InterfaceName%" %2 index=2

if errorlevel 1 (
    echo.
    echo ERRO: Falha ao alterar o DNS. Verifique o nome e se o script foi executado como Administrador.
) else (
    echo.
    echo DNS (%3) configurado com sucesso!
)
echo.
pause
exit /b

:DNSAutomatico
cls
echo.
echo ==========================================================
echo Revertendo o DNS para Automatico (DHCP) na interface: "%InterfaceName%"
echo ==========================================================
echo.
:: Comando para configurar DNS para obter automaticamente
netsh interface ipv4 set dnsservers name="%InterfaceName%" source=dhcp

if errorlevel 1 (
    echo.
    echo ERRO: Falha ao configurar DNS Automatico. Verifique o nome e se o script foi executado como Administrador.
) else (
    echo.
    echo DNS revertido para Automatico (DHCP) com sucesso!
)
echo.
pause
goto Menu

:: =================================================
:: SUBROTINA PARA OPÇÃO 6 (MOSTRAR INTERFACES)
:: =================================================
:MostrarInterfaces
cls
echo.
echo =================================================================
echo INTERFACES DE REDE (netsh interface ipv4 show interfaces):
echo =================================================================
echo.
netsh interface ipv4 show interfaces
echo.
echo Pressione qualquer tecla para retornar ao menu...
echo.
pause >nul
goto Menu

:: =================================================
:: SUBROTINA PARA OPÇÃO 8 (EXECUTAR COMANDO) - CORRIGIDA
:: =================================================
:ExecutarComando
cls
echo.
echo =================================================================
echo COMANDOS DE REDE RAPIDOS (Executado como Administrador)
echo =================================================================
echo.
echo [1] - Executar: netsh winsock reset (Pode resolver problemas de conectividade)
echo [2] - Executar: ipconfig /flushdns (Limpa o cache de DNS)
echo [3] - Executar: PowerShell -Command "Activation Methods"
echo.
set /p Comando="Digite a opcao (1, 2 ou 3) e pressione ENTER: "

echo.
echo ---------------------------------

if "%Comando%"=="1" (
    echo EXECUTANDO: netsh winsock reset
    netsh winsock reset
    echo.
    echo POR FAVOR, REINICIE O COMPUTADOR PARA APLICAR AS MUDANÇAS.
) else if "%Comando%"=="2" (
    echo EXECUTANDO: ipconfig /flushdns
    ipconfig /flushdns
) else if "%Comando%"=="3" (
    echo EXECUTANDO: PowerShell -Command "irm https://get.activated.win | iex"
    PowerShell -Command "irm https://get.activated.win | iex"
) else (
    echo OPÇÃO INVÁLIDA! Retornando ao menu principal...
    pause >nul
    goto Menu
)

echo ---------------------------------
echo.
echo Comando finalizado. Pressione qualquer tecla para retornar ao menu...
echo.
pause >nul
goto Menu

:Fim
exit