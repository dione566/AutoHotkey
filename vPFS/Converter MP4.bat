@echo off
title Restaurador de Miniaturas .bxa0
chcp 65001 > nul
echo ======================================================
echo    RESTAURADOR DE ÍCONES E VÍDEOS (.bxa0 -^> .mp4)
echo ======================================================
echo.
echo Processando arquivos da pasta...
echo.

setlocal enabledelayedexpansion

rem Verifica se existem arquivos .bxa0 na pasta
dir /b *.bxa0 >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [ERRO] Nenhum arquivo .bxa0 foi encontrado nesta pasta.
    echo Certifique-se de salvar este arquivo .bat na mesma pasta dos videos.
    echo.
    pause
    exit
)

rem Cria um script temporário em PowerShell para remover os 32 bytes de forma ultra rápida
echo param($inFile, $outFile) > temp_trim.ps1
echo $bytes = [System.IO.File]::ReadAllBytes($inFile) >> temp_trim.ps1
echo if ($bytes.Length -gt 32) { >> temp_trim.ps1
echo     $clean = New-Object Byte[] ($bytes.Length - 32) >> temp_trim.ps1
echo     [Array]::Copy($bytes, 32, $clean, 0, $clean.Length) >> temp_trim.ps1
echo     [System.IO.File]::WriteAllBytes($outFile, $clean) >> temp_trim.ps1
echo } >> temp_trim.ps1

rem Loop para processar cada arquivo .bxa0 encontrado
for /f "delims=" %%f in ('dir /b *.bxa0') do (
    set "nome_original=%%~nf"
    echo Convertendo: "%%f" -> "!nome_original!.mp4"
    
    rem Executa o corte dos 32 bytes usando o motor do Windows
    powershell -ExecutionPolicy Bypass -File temp_trim.ps1 -inFile "%%f" -outFile "!nome_original!.mp4"
)

rem Apaga o arquivo temporário que usamos
if exist temp_trim.ps1 del temp_trim.ps1

color 0A
echo.
echo ======================================================
echo  CONCLUÍDO! Os arquivos .mp4 foram gerados com sucesso.
echo  As miniaturas e ícones devem aparecer em instantes!
echo ======================================================
echo.
pause