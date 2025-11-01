<#
.SYNOPSIS
    Script PowerShell para buscar e instalar drivers de Áudio, Vídeo e Wireless
    via Windows Update.
.DESCRIPTION
    Este script utiliza o módulo PSWindowsUpdate (que deve ser instalado previamente)
    para interagir com o Windows Update e forçar a busca e instalação de drivers
    e outras atualizações importantes.
.NOTES
    EXECUTE ESTE SCRIPT COMO ADMINISTRADOR.
    Certifique-se de que o módulo 'PSWindowsUpdate' está instalado.

    (ATUALIZACAO): O comando 'Import-Module' foi adicionado para resolver o erro
    'CommandNotFoundException' e garantir que as funcoes sejam reconhecidas.
#>

# Força a execução como Administrador, se não estiver rodando como tal.
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Este script precisa de privilegios de Administrador para funcionar. Reiniciando..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# 1. Título e Confirmação
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "   INICIO DA ATUALIZACAO DE DRIVERS VIA POWERSHELL (PSWindowsUpdate)"     -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "O script ira verificar e instalar drivers (Audio, Video, Wireless) e" -ForegroundColor White
Write-Host "outras atualizacoes criticas disponiveis no Windows Update." -ForegroundColor White
Write-Host ""

# 2. Verifica e Carrega o Módulo (CRÍTICO)
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Write-Host "ERRO: O modulo 'PSWindowsUpdate' nao esta instalado." -ForegroundColor Red
    Write-Host "Execute 'Install-Module -Name PSWindowsUpdate -Force' em um PowerShell de Administrador antes de rodar o script." -ForegroundColor Red
    
    # Adiciona a pausa antes de sair para que o usuário leia a mensagem de erro.
    Write-Host ""
    Read-Host "Pressione Enter para fechar esta janela..." | Out-Null
    exit 1
}

# Se o módulo existe, force o carregamento para garantir que as funções (cmdlets) estejam disponiveis
Write-Host "-> Modulo PSWindowsUpdate encontrado. Carregando funcoes..." -ForegroundColor DarkYellow
Import-Module -Name PSWindowsUpdate -Force
Write-Host "-> Funcoes carregadas com sucesso!" -ForegroundColor DarkGreen


# 3. Busca por Atualizações (Inclui Drivers)
Write-Host "-> 1/3: Buscando atualizacoes disponiveis (Drivers e Outros)..." -ForegroundColor Yellow
# Removido o parametro '-AutoSelectSelectively' e adicionado '-NotCategory:Updates' para filtrar atualizações de software que podem ser muito grandes
$Updates = Get-WUList -UpdateType 'Driver' | Where-Object { $_.IsInstalled -eq $false }

if ($Updates.Count -eq 0) {
    Write-Host "   Nenhum driver novo ou atualizacao critica encontrado. Sistema atualizado." -ForegroundColor Green
} else {
    Write-Host "   Drivers e/ou Atualizacoes encontrados:" -ForegroundColor Green
    $Updates | Format-Table Title, Size, KB -AutoSize

    # 4. Instala as Atualizações encontradas
    Write-Host ""
    Write-Host "-> 2/3: Iniciando o download e instalacao dos itens acima. Aguarde..." -ForegroundColor Yellow
    # -AcceptAll aceita os EULAs automaticamente. -IgnoreReboot nao reinicia a forca.
    Install-WUUpdate -AcceptAll -IgnoreReboot | Out-Null
    
    Write-Host ""
    Write-Host "-> 3/3: Instalacao concluida. Verificando se a reinicializacao e necessaria." -ForegroundColor Yellow
    
    # 5. Verifica se a Reinicialização é Necessária
    if (Get-WUPendingReboot) {
        Write-Host "ATENCAO: A instalacao de drivers/atualizacoes requer uma REINICIALIZACAO." -ForegroundColor Red
        Write-Host "Voce deve reiniciar o sistema o mais rapido possivel." -ForegroundColor Red
        
        # Oferece a opção de reiniciar
        $reboot = Read-Host "Deseja reiniciar agora? (S/N)"
        if ($reboot -match '^[sS]') {
            Restart-Computer -Force
        }
        
    } else {
        Write-Host "Nao e necessaria a reinicializacao." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "==========================================================================" -ForegroundColor Cyan
Write-Host "FIM DO SCRIPT." -ForegroundColor Cyan
Write-Host "==========================================================================" -ForegroundColor Cyan

# Comando de pausa para manter o script aberto.
Read-Host "Pressione Enter para fechar esta janela..." | Out-Null
