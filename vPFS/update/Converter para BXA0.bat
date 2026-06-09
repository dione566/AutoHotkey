@echo off
title Ocultador Multiformato (Videos e Imagens -> Base64)
chcp 65001 > nul
echo ======================================================
echo    OCULTADOR DE MÍDIAS UNIFICADO (Vídeos e Imagens)
echo ======================================================
echo.
echo Procurando mídias (vídeos e imagens) na pasta...
echo.

setlocal enabledelayedexpansion

rem Lista de formatos suportados (Vídeos e Imagens) separados por espaço
set "FORMATOS=.mp4 .mkv .avi .mov .wmv .flv .webm .jpg .jpeg .png .gif .webp .bmp"

rem Verifica se existe pelo menos um arquivo válido na pasta
set "encontrou="
for /f "delims=" %%i in ('dir /b /a-d') do (
    set "ext=%%~xi"
    for %%e in (%FORMATOS%) do (
        if /i "!ext!"=="%%e" set "encontrou=1"
    )
)

if not defined encontrou (
    color 0C
    echo [ERRO] Nenhum arquivo de vídeo ou imagem suportado foi encontrado.
    echo Certifique-se de colocar este arquivo .bat na pasta correta.
    echo.
    pause
    exit
)

rem Cria o motor de injeção binária em streams usando PowerShell
echo param($inFile, $outDir) > temp_inject.ps1
echo $file = Get-Item $inFile >> temp_inject.ps1
echo $nomeSemExt = $file.BaseName >> temp_inject.ps1
echo $extSemPonto = $file.Extension.TrimStart('.') >> temp_inject.ps1
echo # Converte nome e extensao para Base64 e remove os caracteres '=' >> temp_inject.ps1
echo $nomeB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nomeSemExt)).Replace('=', '') >> temp_inject.ps1
echo $extB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($extSemPonto)).Replace('=', '') >> temp_inject.ps1
echo $novoNome = "$nomeB64.$extB64" >> temp_inject.ps1
echo $outFile = Join-Path $outDir $novoNome >> temp_inject.ps1
echo # Processo de injecao de bytes via Stream (Suporta arquivos grandes) >> temp_inject.ps1
echo $fsOut = [System.IO.File]::Create($outFile) >> temp_inject.ps1
echo $lixo = New-Object Byte[] 32 >> temp_inject.ps1
echo for($i=0; $i -lt 32; $i++) { $lixo[$i] = 0x55 } >> temp_inject.ps1
echo $fsOut.Write($lixo, 0, $lixo.Length) >> temp_inject.ps1
echo $fsIn = [System.IO.File]::OpenRead($inFile) >> temp_inject.ps1
echo $buffer = New-Object Byte[] 65536 >> temp_inject.ps1
echo while (($bytesRead = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) { >> temp_inject.ps1
echo     $fsOut.Write($buffer, 0, $bytesRead) >> temp_inject.ps1
echo } >> temp_inject.ps1
echo $fsIn.Close(); $fsIn.Dispose() >> temp_inject.ps1
echo $fsOut.Close(); $fsOut.Dispose() >> temp_inject.ps1

rem Processa cada arquivo individualmente no local de origem
for /f "delims=" %%f in ('dir /b /a-d') do (
    set "ext=%%~xf"
    set "valido="
    
    rem Verifica se a extensão do arquivo atual está na lista unificada
    for %%e in (%FORMATOS%) do (
        if /i "!ext!"=="%%e" set "valido=1"
    )
    
    if defined valido (
        echo Ocultando e renomeando: "%%f" ...
        
        rem Executa o script do powershell passando a pasta atual como destino
        powershell -ExecutionPolicy Bypass -File temp_inject.ps1 -inFile "%%f" -outDir "."
        
        rem Deleta o arquivo original com segurança
        del /f /q "%%f"
    )
)

rem Limpeza de arquivos temporários de execução
if exist temp_inject.ps1 del temp_inject.ps1

color 0A
echo.
echo ======================================================
echo  CONCLUÍDO! Vídeos e imagens foram processados com sucesso.
echo  O HTML modificado vai ler todos eles normalmente!
echo ======================================================
echo.
pause