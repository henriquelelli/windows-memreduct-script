@echo off
title Medicao de Performance - Antes/Depois
color 0B

echo.
echo ==================================================
echo         MEDICAO DE PERFORMANCE DO SISTEMA
echo ==================================================
echo.

:: Data e hora da medicao
echo [INFORMACOES DO SISTEMA]
echo Data/Hora: %date% %time%
systeminfo | findstr /B /C:"Nome do sistema operacional" /C:"Total de memória física"
echo.

:: 1. ESPACO EM DISCO
echo [1] ESPACO EM DISCO LIVRE:
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: 2^>nul ^| findstr "avail"') do (
    set /a FREE_GB=%%i/1073741824
    set /a FREE_MB=%%i/1048576
    echo Disco C: !FREE_MB! MB (!FREE_GB! GB) livres
)
echo.

:: 2. MEMORIA RAM
echo [2] USO DE MEMORIA RAM:
echo Memoria Fisica:
systeminfo | findstr /C:"Memória física disponível" /C:"Memória física total"
echo.

:: 3. PROCESSOS ATIVOS
echo [3] PROCESSOS EM EXECUCAO:
tasklist /fo table | find /c ".exe" > "%temp%\process_count.txt"
set /p PROCESS_COUNT=<"%temp%\process_count.txt"
del "%temp%\process_count.txt" 2>nul
echo Total de processos ativos: %PROCESS_COUNT%
echo.

:: 4. USO DO CHROME (se estiver aberto)
echo [4] USO DO CHROME (se aplicavel):
tasklist /fi "IMAGENAME eq chrome.exe" 2>nul | findstr /i "chrome.exe" >nul
if %errorlevel% == 0 (
    echo Chrome esta em execucao
    for /f "tokens=2 delims==" %%i in ('wmic process where "name='chrome.exe'" get WorkingSetSize /value 2^>nul ^| find "WorkingSetSize"') do (
        set /a CHROME_MEM_KB=%%i/1024
        set /a CHROME_MEM_MB=!CHROME_MEM_KB!/1024
        echo Memoria do Chrome: !CHROME_MEM_MB! MB
    )
) else (
    echo Chrome nao esta em execucao
)
echo.

:: 5. TEMPO DE INICIALIZACAO (aproximado)
echo [5] TEMPO DE ATIVIDADE DO SISTEMA:
systeminfo | findstr /C:"Tempo inicialização do sistema"
echo.

:: 6. ARQUIVOS TEMPORARIOS
echo [6] TAMANHO DA PASTA TEMP:
for /f "tokens=1,2" %%i in ('dir "%temp%" /s /-c 2^>nul ^| find "arquivo(s)"') do echo Temp usuario: %%i arquivos, %%j
for /f "tokens=1,2" %%i in ('dir "C:\Windows\Temp" /s /-c 2^>nul ^| find "arquivo(s)"') do echo Temp sistema: %%i arquivos, %%j
echo.

:: 7. PERFORMANCE DO SISTEMA (SIMPLIFICADO)
echo [7] INDICADORES DE PERFORMANCE:
echo Coletando metricas de CPU e Disco (aguarde 3 segundos)...
typeperf "\Processor(_Total)\% Processor Time" -sc 1 -si 3 2>nul | find "0.000000" >nul && echo CPU: Baixa utilizacao || echo CPU: Media/Alta utilizacao
typeperf "\PhysicalDisk(_Total)\% Disk Time" -sc 1 -si 3 2>nul | find "0.000000" >nul && echo Disco: Baixa utilizacao || echo Disco: Media/Alta utilizacao
echo.

echo ==================================================
echo      EXECUTE O SCRIPT DE LIMPEZA AGORA
echo   E RODE ESTE MESMO SCRIPT NOVAMENTE APOS
echo ==================================================
echo.

echo Pressione qualquer tecla para salvar este relatorio...
pause >nul

:: Salvar relatorio com timestamp seguro para arquivos
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
set TIMESTAMP=%TIMESTAMP: =0%
set TIMESTAMP=%TIMESTAMP::=%

echo Salvando relatorio em: %userprofile%\Desktop\medicao_%TIMESTAMP%.txt

:: Habilitar expansao atrasada para o bloco
setlocal enabledelayedexpansion

:: Refazer as medicoes para salvar
(
echo ==================================================
echo    RELATORIO DE MEDICAO - %date% %time%
echo ==================================================
echo.

systeminfo | findstr /B /C:"Nome do sistema operacional" /C:"Total de memória física"

echo.
echo [ESPACO EM DISCO]
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: 2^>nul ^| findstr "avail"') do (
    set /a FREE_GB=%%i/1073741824
    set /a FREE_MB=%%i/1048576
    echo Disco C: !FREE_MB! MB (!FREE_GB! GB) livres
)

echo.
echo [MEMORIA RAM]
systeminfo | findstr /C:"Memória física disponível" /C:"Memória física total"

echo.
echo [PROCESSOS ATIVOS]
tasklist /fo table | find /c ".exe"

echo.
echo [INFORMACOES ADICIONAIS]
echo Data da coleta: %date% %time%
echo Usuario: %USERNAME%
echo Computador: %COMPUTERNAME%

echo.
echo ==================================================
) > "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

endlocal

echo.
echo Relatorio salvo na area de trabalho: medicao_%TIMESTAMP%.txt
echo.
echo Pressione qualquer tecla para fechar...
pause >nul