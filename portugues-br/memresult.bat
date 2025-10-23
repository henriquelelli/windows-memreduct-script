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
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: ^| findstr "avail"') do (
    set /a FREE_GB=%%i/1073741824
    set /a FREE_MB=%%i/1048576
    echo Disco C: %FREE_MB% MB (%FREE_GB% GB) livres
)
echo.

:: 2. MEMORIA RAM
echo [2] USO DE MEMORIA RAM:
echo Memoria Fisica:
systeminfo | findstr /C:"Memória física disponível" /C:"Memória física total"
echo.

:: 3. PROCESSOS ATIVOS
echo [3] PROCESSOS EM EXECUCAO:
tasklist /fo table | find /c ".exe" > %temp%\process_count.txt
set /p PROCESS_COUNT=<%temp%\process_count.txt
del %temp%\process_count.txt
echo Total de processos ativos: %PROCESS_COUNT%
echo.

:: 4. USO DO CHROME (se estiver aberto)
echo [4] USO DO CHROME (se aplicavel):
tasklist /fi "IMAGENAME eq chrome.exe" /fo table | findstr "chrome.exe" >nul
if %errorlevel% == 0 (
    echo Chrome esta em execucao
    wmic process where "name='chrome.exe'" get WorkingSetSize /value | find "WorkingSetSize" > %temp%\chrome_mem.txt
    set /p CHROME_MEM=<%temp%\chrome_mem.txt
    del %temp%\chrome_mem.txt
    echo Memoria do Chrome: %CHROME_MEM%
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
for /f "tokens=*" %%i in ('dir "%temp%" /s /-c ^| find "arquivo(s)"') do echo Tamanho temp usuario: %%i
for /f "tokens=*" %%i in ('dir "C:\Windows\Temp" /s /-c ^| find "arquivo(s)"') do echo Tamanho temp sistema: %%i
echo.

:: 7. PERFORMANCE DO SISTEMA
echo [7] INDICADORES DE PERFORMANCE:
echo CPU Usage: 
typeperf "\Processor(_Total)\% Processor Time" -sc 1 | find "0.000000"
echo Disco Usage:
typeperf "\PhysicalDisk(_Total)\% Disk Time" -sc 1 | find "0.000000"
echo.

echo ==================================================
echo      EXECUTE O SCRIPT DE LIMPEZA AGORA
echo   E RODE ESTE MESMO SCRIPT NOVAMENTE APOS
echo ==================================================
echo.

echo Pressione qualquer tecla para salvar este relatorio...
pause >nul

:: Salvar relatorio com timestamp
set TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%
echo Salvando relatorio em: %userprofile%\Desktop\medicao_%TIMESTAMP%.txt

:: Refazer as medicoes para salvar
(
echo ==================================================
echo    RELATORIO DE MEDICAO - %date% %time%
echo ==================================================
echo.
systeminfo | findstr /B /C:"Nome do sistema operacional" /C:"Total de memória física"
echo.
echo [ESPACO EM DISCO]
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: ^| findstr "avail"') do (
    set /a FREE_GB=%%i/1073741824
    set /a FREE_MB=%%i/1048576
    echo Disco C: %FREE_MB% MB (%FREE_GB% GB) livres
)
echo.
echo [MEMORIA RAM]
systeminfo | findstr /C:"Memória física disponível"
echo.
echo [PROCESSOS ATIVOS]
tasklist /fo table | find /c ".exe"
echo.
) > "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

echo Relatorio salvo na area de trabalho!
echo Pressione qualquer tecla para fechar...
pause >nul