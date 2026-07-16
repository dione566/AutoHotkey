<#
.SYNOPSIS
    Menu de Limpeza Extrema e Cache para PC (Unificado)
#>

# --- GARANTE PRIVILÉGIOS DE ADMINISTRADOR ---
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Solicitando privilegios de administrador..." -ForegroundColor Yellow
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

function Limpar-RastrosECache {
    Write-Host ""
    Write-Host "[+] Fechando processos (Explorer, Players, Fotos)..." -ForegroundColor Cyan
    $processes = @("vlc", "mpc-hc", "mpc-hc64", "PotPlayerMini64", "Video.UI", "Microsoft.Photos", "explorer")
    foreach ($proc in $processes) {
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 2

    Write-Host "[+] Limpando Temp do Usuario..." -ForegroundColor Cyan
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    Write-Host "[+] Limpando Temp do Windows..." -ForegroundColor Cyan
    Remove-Item -Path "$env:windir\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Limpando Prefetch..." -ForegroundColor Cyan
    Remove-Item -Path "$env:windir\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Limpando Historicos de Registro (MRU, TypedPaths)..." -ForegroundColor Cyan
    $regPaths = @(
        "HKCU:\Software\MPC-HC\MPC-HC",
        "HKCU:\Software\DAUM\PotPlayer\Settings",
        "HKCU:\Software\Microsoft\MediaPlayer\Player",
        "HKCU:\Software\Microsoft\Windows Photo Viewer\Viewer",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs"
    )
    foreach ($path in $regPaths) {
        if (Test-Path $path) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "[+] Limpando Jump Lists e Itens Recentes..." -ForegroundColor Cyan
    Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Limpando Cache de Icones e Miniaturas..." -ForegroundColor Cyan
    Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache*.db" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache*.db" -Force -ErrorAction SilentlyContinue

    Write-Host "[+] Iniciando Limpeza de Disco integrada (cleanmgr)..." -ForegroundColor Cyan
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait

    Write-Host "[+] Reiniciando o Windows Explorer..." -ForegroundColor Cyan
    Start-Process "explorer.exe"
    
    Write-Host ""
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host " Limpeza de historicos e cache concluida com sucesso! " -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
}

function Executar-Cipher {
    Write-Host ""
    Write-Host "ATENCAO: O processo de limpeza do espaco livre (Cipher) pode demorar" -ForegroundColor Yellow
    Write-Host "bastante dependendo do tamanho do seu HD/SSD." -ForegroundColor Yellow
    $confirm = Read-Host "Deseja iniciar agora? (S/N)"
    
    if ($confirm -match "^[sS]") {
        Write-Host ""
        Write-Host "[+] Iniciando Cipher no drive C: (Uma janela do CMD sera aberta)..." -ForegroundColor Cyan
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c cipher /w:C:" -Wait
        
        Write-Host ""
        Write-Host "====================================================" -ForegroundColor Green
        Write-Host " O espaco livre do drive C: foi sobrescrito!        " -ForegroundColor Green
        Write-Host " Arquivos deletados nao podem ser recuperados.      " -ForegroundColor Green
        Write-Host "====================================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[-] Operacao Cipher cancelada pelo usuario." -ForegroundColor Yellow
    }
}

# --- MENU PRINCIPAL INTERATIVO ---
while ($true) {
    Clear-Host
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host "        MENU DE LIMPEZA PARA VENDA (PS1)        " -ForegroundColor White
    Write-Host "====================================================" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  1. Limpar Rastros, Historicos e Cache" -ForegroundColor Cyan
    Write-Host "  2. Sobrescrever Espaco Livre (Cipher)" -ForegroundColor Cyan
    Write-Host "  3. Fazer Tudo (Recomendado)" -ForegroundColor Cyan
    Write-Host "  4. Sair" -ForegroundColor Red
    Write-Host ""
    
    $choice = Read-Host "Selecione uma opcao"

    switch ($choice) {
        "1" { 
            Limpar-RastrosECache
            Write-Host ""
            Write-Host "Pressione ENTER para voltar ao menu..." ; Read-Host
        }
        "2" { 
            Executar-Cipher
            Write-Host ""
            Write-Host "Pressione ENTER para voltar ao menu..." ; Read-Host
        }
        "3" { 
            Limpar-RastrosECache
            Executar-Cipher
            Write-Host ""
            Write-Host "Pressione ENTER para voltar ao menu..." ; Read-Host
        }
        "4" { 
            exit 
        }
        default { 
            Write-Host ""
            Write-Host "Opcao invalida! Tente novamente." -ForegroundColor Red
            Start-Sleep -Seconds 1 
        }
    }
}