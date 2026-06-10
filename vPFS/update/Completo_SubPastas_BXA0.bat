@echo off
title Ocultador Multiformato em Lote (Subpastas -> Base64)
chcp 65001 > nul

echo ======================================================
echo     OCULTADOR DE MÍDIAS UNIFICADO (Modo Raiz / Lote)
echo ======================================================
echo.
echo Escaneando subpastas a partir da raiz atual...
echo.

setlocal enabledelayedexpansion

rem Lista de formatos suportados
set "FORMATOS=.mp4 .mkv .avi .mov .wmv .flv .webm .jpg .jpeg .png .gif .webp .bmp"

rem Cria o motor do PowerShell na pasta TEMP do Windows para não poluir a raiz
set "TEMP_PS1=%temp%\temp_inject_%random%.ps1"

echo param($inFile, $outDir) > "%TEMP_PS1%"
echo $file = Get-Item $inFile >> "%TEMP_PS1%"
echo $nomeSemExt = $file.BaseName >> "%TEMP_PS1%"
echo $extSemPonto = $file.Extension.TrimStart('.') >> "%TEMP_PS1%"
echo $nomeB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($nomeSemExt)).Replace('=', '') >> "%TEMP_PS1%"
echo $extB64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($extSemPonto)).Replace('=', '') >> "%TEMP_PS1%"
echo $novoNome = "$nomeB64.$extB64" >> "%TEMP_PS1%"
echo $outFile = Join-Path $outDir $novoNome >> "%TEMP_PS1%"
echo $fsOut = [System.IO.File]::Create($outFile) >> "%TEMP_PS1%"
echo $lixo = New-Object Byte[] 32 >> "%TEMP_PS1%"
echo for($i=0; $i -lt 32; $i++) { $lixo[$i] = 0x55 } >> "%TEMP_PS1%"
echo $fsOut.Write($lixo, 0, $lixo.Length) >> "%TEMP_PS1%"
echo $fsIn = [System.IO.File]::OpenRead($inFile) >> "%TEMP_PS1%"
echo $buffer = New-Object Byte[] 65536 >> "%TEMP_PS1%"
echo while (($bytesRead = $fsIn.Read($buffer, 0, $buffer.Length)) -gt 0) { >> "%TEMP_PS1%"
echo      $fsOut.Write($buffer, 0, $bytesRead) >> "%TEMP_PS1%"
echo } >> "%TEMP_PS1%"
echo $fsIn.Close(); $fsIn.Dispose() >> "%TEMP_PS1%"
echo $fsOut.Close(); $fsOut.Dispose() >> "%TEMP_PS1%"

set "processou_algo="

rem Loop que entra em cada subpasta do diretório atual do script
for /d %%D in (*) do (
    set "PASTA_ATUAL=%%~fD"
    
    rem Verifica se existem arquivos válidos nesta subpasta específica
    set "encontrou_na_pasta="
    for /f "delims=" %%i in ('dir /b /a-d "!PASTA_ATUAL!" 2^>nul') do (
        set "ext=%%~xi"
        for %%e in (%FORMATOS%) do (
            if /i "!ext!"=="%%e" set "encontrou_na_pasta=1"
        )
    )
    
    rem Se achou mídias na pasta, começa o processamento dela
    if defined encontrou_na_pasta (
        set "processou_algo=1"
        echo --------------------------------------------------
        echo Processando pasta: "%%~nD"
        echo --------------------------------------------------
        
        for /f "delims=" %%f in ('dir /b /a-d "!PASTA_ATUAL!"') do (
            set "ext=%%~xf"
            set "valido="
            
            for %%e in (%FORMATOS%) do (
                if /i "!ext!"=="%%e" set "valido=1"
            )
            
            if defined valido (
                echo   -^> Ocultando: "%%f"
                powershell -ExecutionPolicy Bypass -File "%TEMP_PS1%" -inFile "!PASTA_ATUAL!\%%f" -outDir "!PASTA_ATUAL!"
                del /f /q "!PASTA_ATUAL!\%%f"
            )
        )
        echo.
    )
)

rem Limpeza final do script temporário
if exist "%TEMP_PS1%" del "%TEMP_PS1%"

echo ======================================================
if defined processou_algo (
    color 0A
    echo  CONCLUÍDO! Todas as subpastas foram atualizadas.
) else (
    color 0C
    echo  [AVISO] Nenhuma mídia compatível foi encontrada nas subpastas.
)
echo ======================================================
echo.
pause