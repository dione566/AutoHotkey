@echo off
title Ocultador de Videos (MP4 -> bXA0)
chcp 65001 > nul
echo ======================================================
echo    OCULTADOR E TRAVADOR DE VÍDEOS (.mp4 -> .bXA0)
echo ======================================================
echo.
echo Procurando arquivos de video na pasta...
echo.

setlocal enabledelayedexpansion

rem Varre a pasta procurando arquivos .mp4 de forma insensível a maiúsculas/minúsculas
set "encontrou="
for /f "delims=" %%i in ('dir /b /a-d') do (
    set "ext=%%~xi"
    if /i "!ext!"==".mp4" (
        set "encontrou=1"
    )
)

if not defined encontrou (
    color 0C
    echo [ERRO] Nenhum arquivo .mp4 foi encontrado nesta pasta.
    echo Certifique-se de colocar este arquivo .bat na mesma pasta dos seus videos.
    echo.
    pause
    exit
)

rem Cria o motor de injeção binária em PowerShell
echo param($inFile, $outFile) > temp_inject.ps1
echo $origBytes = [System.IO.File]::ReadAllBytes($inFile) >> temp_inject.ps1
echo $lixo = New-Object Byte[] 32 >> temp_inject.ps1
echo for($i=0; $i -lt 32; $i++) { $lixo[$i] = 0x55 } >> temp_inject.ps1
echo $finalBytes = New-Object Byte[] ($lixo.Length + $origBytes.Length) >> temp_inject.ps1
echo [Array]::Copy($lixo, 0, $finalBytes, 0, $lixo.Length) >> temp_inject.ps1
echo [Array]::Copy($origBytes, 0, $finalBytes, $lixo.Length, $origBytes.Length) >> temp_inject.ps1
echo [System.IO.File]::WriteAllBytes($outFile, $finalBytes) >> temp_inject.ps1

rem Processa cada arquivo individualmente
for /f "delims=" %%f in ('dir /b /a-d') do (
    set "ext=%%~xf"
    if /i "!ext!"==".mp4" (
        set "nome_original=%%~nf"
        echo Ocultando: "%%f" -> "!nome_original!.bXA0"
        
        rem Executa a gravação dos 32 bytes de trava
        powershell -ExecutionPolicy Bypass -File temp_inject.ps1 -inFile "%%f" -outFile "!nome_original!.bXA0"
    )
)

rem Limpeza de arquivos temporários de execução
if exist temp_inject.ps1 del temp_inject.ps1

color 0A
echo.
echo ======================================================
echo  CONCLUÍDO! Os arquivos .bXA0 foram gerados.
echo  A trava foi aplicada e as miniaturas foram ocultadas!
echo ======================================================
echo.
pause