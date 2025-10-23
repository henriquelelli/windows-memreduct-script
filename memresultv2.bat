@echo off
title Medicao de Performance - Antes/Depois
color 0B

:: Habilitar expansao atrasada desde o inicio
setlocal enabledelayedexpansion

echo.
echo ==================================================
echo         MEDICAO DE PERFORMANCE DO SISTEMA
echo ==================================================
echo.

:: Data e hora da medicao
echo [INFORMACOES DO SISTEMA]
echo Data/Hora: %date% %time%
echo Usuario: %USERNAME%
echo Computador: %COMPUTERNAME%
echo.

:: Coletar informações para o relatório
echo Coletando informacoes do sistema...
echo.

:: 1. ESPACO EM DISCO (WMIC - funciona em qualquer idioma)
echo [1] ESPACO EM DISCO LIVRE:
for /f "skip=1 tokens=3" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace 2^>nul ^| findstr [0-9]') do (
    set "FREE_BYTES=%%i"
    set /a FREE_GB=!FREE_BYTES!/1073741824
    echo Disco C: !FREE_GB! GB livres
)
echo.

:: 2. INFORMACOES DO SISTEMA (WMIC - idioma independente)
echo [2] INFORMACOES DO COMPUTADOR:
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10" %%i in ('wmic os get Caption 2^>nul') do (
    if not "%%i"=="" if not "%%i"=="Caption" (
        echo Sistema Operacional: %%i %%j %%k %%l %%m %%n %%o %%p %%q %%r
    )
)
echo.

:: 3. MEMORIA RAM (WMIC - idioma independente)
echo [3] MEMORIA RAM:
for /f "skip=1 tokens=2 delims=," %%i in ('wmic ComputerSystem get TotalPhysicalMemory /value 2^>nul ^| findstr "="') do (
    set "TOTAL_BYTES=%%i"
    set /a TOTAL_GB=!TOTAL_BYTES!/1073741824
    echo Memoria Total: !TOTAL_GB! GB
)

for /f "skip=1 tokens=2 delims=," %%i in ('wmic OS get FreePhysicalMemory /value 2^>nul ^| findstr "="') do (
    set "FREE_KB=%%i"
    set /a FREE_MB=!FREE_KB!/1024
    echo Memoria Disponivel: !FREE_MB! MB
)
echo.

:: 4. PROCESSOS ATIVOS
echo [4] PROCESSOS EM EXECUCAO:
for /f %%i in ('tasklist /fo table ^| find /c ".exe"') do set PROCESS_COUNT=%%i
echo Total de processos ativos: !PROCESS_COUNT!
echo.

:: 5. USO DE NAVEGADORES
echo [5] USO DE NAVEGADORES:

:: Chrome
call :MeasureBrowser "chrome.exe" "Chrome" CHROME_PROCESSES CHROME_MEM_MB

:: Edge
call :MeasureBrowser "msedge.exe" "Edge" EDGE_PROCESSES EDGE_MEM_MB

:: Firefox
call :MeasureBrowser "firefox.exe" "Firefox" FIREFOX_PROCESSES FIREFOX_MEM_MB

echo.

:: 6. TEMPO DE ATIVIDADE (WMIC - idioma independente)
echo [6] TEMPO DE ATIVIDADE DO SISTEMA:
for /f "skip=1 tokens=1,2" %%i in ('wmic os get LastBootUpTime 2^>nul ^| findstr [0-9]') do (
    echo Ultima inicializacao: %%i %%j
)
echo.

:: 7. INFORMACOES DA CPU
echo [7] INFORMACOES DA CPU:
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10" %%i in ('wmic cpu get Name 2^>nul') do (
    if not "%%i"=="" if not "%%i"=="Name" (
        echo Processador: %%i %%j %%k %%l %%m %%n %%o %%p %%q %%r
    )
)
echo.

echo ==================================================
echo      EXECUTE O SCRIPT DE LIMPEZA AGORA
echo   E RODE ESTE MESMO SCRIPT NOVAMENTE APOS
echo ==================================================
echo.

echo Pressione qualquer tecla para salvar este relatorio...
pause >nul
cls

:: Pular a funcao para continuar
goto :continue_script

:: ====================================================================
:: FUNCAO: MeasureBrowser
:: Mede o uso de memoria de um navegador especifico
:: ====================================================================
:MeasureBrowser
set "BROWSER_EXE=%~1"
set "BROWSER_NAME=%~2"
set "VAR_PROCESSES=%~3"
set "VAR_MEMORY=%~4"

set /a BROWSER_MEM=0
set /a BROWSER_COUNT=0

for /f "skip=3 tokens=5,6" %%i in ('tasklist /fi "IMAGENAME eq %BROWSER_EXE%" /fo table 2^>nul') do (
    if not "%%i"=="" (
        if not "%%i"=="K" (
            set "MEM_VALUE=%%i"
            set "MEM_VALUE=!MEM_VALUE:,=!"
            if "!MEM_VALUE!" neq "Memoria" (
                set /a BROWSER_MEM+=!MEM_VALUE!
                set /a BROWSER_COUNT+=1
            )
        )
    )
)

if !BROWSER_COUNT! GTR 0 (
    set /a BROWSER_MEM_MB=!BROWSER_MEM!/1024
    echo %BROWSER_NAME%: !BROWSER_COUNT! processos, !BROWSER_MEM_MB! MB
    set "%VAR_PROCESSES%=!BROWSER_COUNT!"
    set "%VAR_MEMORY%=!BROWSER_MEM_MB!"
) else (
    echo %BROWSER_NAME%: nao em execucao
    set "%VAR_PROCESSES%=0"
    set "%VAR_MEMORY%=0"
)
goto :eof

:: ====================================================================
:: CONTINUACAO DO SCRIPT PRINCIPAL
:: ====================================================================
:continue_script

:: Salvar relatorio na pasta atual
echo Salvando relatorio na pasta atual...

:: Criar timestamp seguro
set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"
set "TIMESTAMP=%TIMESTAMP::=%"
set "TIMESTAMP=%TIMESTAMP:/=%"

:: Coletar informacoes detalhadas para o arquivo (WMIC - idioma independente)
echo Coletando informacoes detalhadas para o relatorio...

:: Coletar processador
set "PROCESSOR="
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10" %%i in ('wmic cpu get Name 2^>nul') do (
    if not "%%i"=="" if not "%%i"=="Name" (
        set "PROCESSOR=%%i %%j %%k %%l %%m %%n %%o %%p %%q %%r"
    )
)

:: Coletar sistema operacional
set "OS_NAME="
for /f "skip=1 tokens=1,2,3,4,5,6,7,8,9,10" %%i in ('wmic os get Caption 2^>nul') do (
    if not "%%i"=="" if not "%%i"=="Caption" (
        set "OS_NAME=%%i %%j %%k %%l %%m %%n %%o %%p %%q %%r"
    )
)

:: Coletar memoria total e disponivel (WMIC)
set "MEM_TOTAL="
set "MEM_AVAIL="

for /f "skip=1 tokens=2 delims=," %%i in ('wmic ComputerSystem get TotalPhysicalMemory /value 2^>nul ^| findstr "="') do (
    set "TOTAL_BYTES=%%i"
    set /a TOTAL_GB=!TOTAL_BYTES!/1073741824
    set "MEM_TOTAL=!TOTAL_GB! GB"
)

for /f "skip=1 tokens=2 delims=," %%i in ('wmic OS get FreePhysicalMemory /value 2^>nul ^| findstr "="') do (
    set "FREE_KB=%%i"
    set /a FREE_MB=!FREE_KB!/1024
    set "MEM_AVAIL=!FREE_MB! MB"
)

:: Coletar espaço em disco
set "FREE_GB="
for /f "skip=1 tokens=3" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace 2^>nul ^| findstr [0-9]') do (
    set "FREE_BYTES=%%i"
    set /a FREE_GB=!FREE_BYTES!/1073741824
)

:: Coletar tempo de atividade
set "UPTIME="
for /f "skip=1 tokens=1,2" %%i in ('wmic os get LastBootUpTime 2^>nul ^| findstr [0-9]') do (
    set "UPTIME=%%i %%j"
)

:: Criar relatorio completo
echo Criando relatorio detalhado...

(
echo ==================================================
echo          RELATORIO DE PERFORMANCE DO SISTEMA
echo ==================================================
echo.
echo 📅 DATA/HORA: %date% %time%
echo 👤 USUARIO: %USERNAME%
echo 💻 COMPUTADOR: %COMPUTERNAME%
echo.
echo ==================================================
echo 🖥️  INFORMACOES DO SISTEMA
echo ==================================================
echo.
echo 📋 SISTEMA OPERACIONAL: !OS_NAME!
echo 🔧 PROCESSADOR: !PROCESSOR!
echo.
echo 🧠 MEMORIA RAM:
echo    Total: !MEM_TOTAL!
echo    Disponivel: !MEM_AVAIL!
echo.
echo 💾 DISCO C: !FREE_GB! GB livres
echo.
echo ==================================================
echo 📊 METRICAS DE PERFORMANCE
echo ==================================================
echo.
echo 🔄 PROCESSOS ATIVOS: !PROCESS_COUNT!
echo.
echo ==================================================
echo 🌐 NAVEGADORES
echo ==================================================
echo.
) > "medicao_%TIMESTAMP%.txt"

:: Adicionar informacoes dos navegadores
if !CHROME_PROCESSES! GTR 0 (
    echo CHROME: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: !CHROME_PROCESSES! >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: !CHROME_MEM_MB! MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo CHROME: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

if !EDGE_PROCESSES! GTR 0 (
    echo EDGE: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: !EDGE_PROCESSES! >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: !EDGE_MEM_MB! MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo EDGE: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

if !FIREFOX_PROCESSES! GTR 0 (
    echo FIREFOX: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: !FIREFOX_PROCESSES! >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: !FIREFOX_MEM_MB! MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo FIREFOX: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

(
echo ⏰ ULTIMA INICIALIZACAO: !UPTIME!
echo.
echo ==================================================
echo 📈 RESUMO DO SISTEMA
echo ==================================================
echo.
echo ✅ Sistema operacional: !OS_NAME!
echo ✅ Processador: !PROCESSOR!
echo ✅ Memoria RAM: !MEM_TOTAL! total, !MEM_AVAIL! disponivel
echo ✅ Disco C: !FREE_GB! GB livres
echo ✅ Processos ativos: !PROCESS_COUNT!
echo ✅ Ultima inicializacao: !UPTIME!
echo.
echo 📊 NAVEGADORES EM EXECUCAO:
) >> "medicao_%TIMESTAMP%.txt"

:: Listar navegadores ativos no resumo
if !CHROME_PROCESSES! GTR 0 (
    echo ✅ Chrome: !CHROME_PROCESSES! processos ^(!CHROME_MEM_MB! MB^) >> "medicao_%TIMESTAMP%.txt"
)
if !EDGE_PROCESSES! GTR 0 (
    echo ✅ Edge: !EDGE_PROCESSES! processos ^(!EDGE_MEM_MB! MB^) >> "medicao_%TIMESTAMP%.txt"
)
if !FIREFOX_PROCESSES! GTR 0 (
    echo ✅ Firefox: !FIREFOX_PROCESSES! processos ^(!FIREFOX_MEM_MB! MB^) >> "medicao_%TIMESTAMP%.txt"
)

:: Se nenhum navegador estiver rodando
set /a TOTAL_BROWSERS=!CHROME_PROCESSES!+!EDGE_PROCESSES!+!FIREFOX_PROCESSES!
if !TOTAL_BROWSERS! EQU 0 (
    echo ⚠ Nenhum navegador em execucao >> "medicao_%TIMESTAMP%.txt"
)

(
echo.
echo ==================================================
echo 💾 ARQUIVO SALVO: medicao_%TIMESTAMP%.txt
echo 📁 LOCAL: %CD%
echo ==================================================
) >> "medicao_%TIMESTAMP%.txt"

echo.
echo ✅ RELATORIO SALVO COM SUCESSO!
echo.
echo 📄 Arquivo: medicao_%TIMESTAMP%.txt
echo 📁 Pasta: %CD%
echo.
echo 📊 USE ESTE RELATORIO PARA COMPARAR:
echo   1. Execute o script de limpeza
echo   2. Rode este script novamente
echo   3. Compare os dois relatorios
echo.
echo Pressione qualquer tecla para fechar...
pause >nul

endlocal