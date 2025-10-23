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

:: 1. ESPACO EM DISCO
echo [1] ESPACO EM DISCO LIVRE:
for /f "skip=1 tokens=3" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace ^| findstr /r "[0-9]"') do (
    set "FREE_BYTES=%%i"
    set /a FREE_GB=!FREE_BYTES!/1073741824
    echo Disco C: !FREE_GB! GB livres
)
echo.

:: 2. INFORMACOES DETALHADAS DO SISTEMA
echo [2] INFORMACOES DO COMPUTADOR:
for /f "tokens=*" %%i in ('systeminfo ^| findstr /B /C:"Nome do sistema operacional" /C:"Processador"') do (
    echo %%i
)
echo.

:: 3. MEMORIA RAM DETALHADA
echo [3] MEMORIA RAM:
for /f "skip=1 tokens=1" %%i in ('wmic OS get TotalVisibleMemorySize ^| findstr /r "[0-9]"') do (
    set /a MEM_TOTAL_MB=%%i/1024
    echo Memoria Total: !MEM_TOTAL_MB! MB
)
for /f "skip=1 tokens=1" %%i in ('wmic OS get FreePhysicalMemory ^| findstr /r "[0-9]"') do (
    set /a MEM_FREE_MB=%%i/1024
    echo Memoria Disponivel: !MEM_FREE_MB! MB
)
echo.

:: 4. PROCESSOS ATIVOS
echo [4] PROCESSOS EM EXECUCAO:
tasklist /fo table | find /c ".exe" > "%temp%\process_count.txt"
set /p PROCESS_COUNT=<"%temp%\process_count.txt"
del "%temp%\process_count.txt" 2>nul
echo Total de processos ativos: %PROCESS_COUNT%
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

:: 6. TEMPO DE ATIVIDADE
echo [6] TEMPO DE ATIVIDADE DO SISTEMA:
systeminfo | findstr /C:"Tempo inicialização do sistema"
echo.

:: 7. INFORMACOES DA CPU
echo [7] INFORMACOES DA CPU:
wmic cpu get name /value 2>nul | findstr "Name" >nul
if %errorlevel% == 0 (
    for /f "tokens=2 delims==" %%i in ('wmic cpu get name /value') do (
        echo Processador: %%i
    )
) else (
    echo Processador: Informacao nao disponivel
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
:: Parametros: %1=nome_exe, %2=nome_exibicao, %3=var_processos, %4=var_memoria
:: ====================================================================
:MeasureBrowser
set "BROWSER_EXE=%~1"
set "BROWSER_NAME=%~2"
set "VAR_PROCESSES=%~3"
set "VAR_MEMORY=%~4"

tasklist /fi "IMAGENAME eq %BROWSER_EXE%" 2>nul | findstr /i "%BROWSER_EXE%" >nul
if %errorlevel% == 0 (
    set /a BROWSER_MEM=0
    set /a BROWSER_COUNT=0
    
    for /f "skip=3 tokens=5" %%i in ('tasklist /fi "IMAGENAME eq %BROWSER_EXE%" /fo table 2^>nul') do (
        set "MEM_VALUE=%%i"
        set "MEM_VALUE=!MEM_VALUE:,=!"
        set "MEM_VALUE=!MEM_VALUE:.=!"
        
        if not "!MEM_VALUE!"=="" (
            if not "!MEM_VALUE!"=="K" (
                set /a BROWSER_MEM+=!MEM_VALUE!
                set /a BROWSER_COUNT+=1
            )
        )
    )
    
    set /a BROWSER_MEM_MB=!BROWSER_MEM!/1024
    echo %BROWSER_NAME%: !BROWSER_COUNT! processos, !BROWSER_MEM_MB! MB
    
    :: Atribuir valores às variáveis globais
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

:: Coletar informacoes detalhadas para o arquivo
echo Coletando informacoes detalhadas para o relatorio...

:: Coletar processador
set "PROCESSOR="
for /f "tokens=2 delims==" %%i in ('wmic cpu get name /value 2^>nul ^| findstr "Name"') do set "PROCESSOR=%%i"

:: Coletar memoria total e disponivel (CORRIGIDO - USANDO WMIC)
set "MEM_TOTAL="
set "MEM_AVAIL="

for /f "skip=1 tokens=1" %%i in ('wmic OS get TotalVisibleMemorySize ^| findstr /r "[0-9]"') do (
    set /a MEM_TOTAL_KB=%%i
    set /a MEM_TOTAL_MB=!MEM_TOTAL_KB!/1024
    set "MEM_TOTAL=!MEM_TOTAL_MB! MB"
)

for /f "skip=1 tokens=1" %%i in ('wmic OS get FreePhysicalMemory ^| findstr /r "[0-9]"') do (
    set /a MEM_FREE_KB=%%i
    set /a MEM_FREE_MB=!MEM_FREE_KB!/1024
    set "MEM_AVAIL=!MEM_FREE_MB! MB"
)

:: Coletar sistema operacional (CORRIGIDO)
set "OS_NAME="
for /f "tokens=4,5,6,7,8" %%i in ('systeminfo ^| findstr /B /C:"Nome do sistema operacional"') do (
    set "OS_NAME=%%i %%j %%k %%l %%m"
)

:: Coletar tempo de atividade (CORRIGIDO)
set "UPTIME="
for /f "tokens=5,6,7,8" %%i in ('systeminfo ^| findstr /C:"Tempo inicialização do sistema"') do (
    set "UPTIME=%%i %%j %%k %%l"
)

:: Coletar espaço em disco (CORRIGIDO - USANDO WMIC)
set "FREE_GB="
for /f "skip=1 tokens=3" %%i in ('wmic logicaldisk where "DeviceID='C:'" get FreeSpace ^| findstr /r "[0-9]"') do (
    set "FREE_BYTES=%%i"
    set /a FREE_GB=!FREE_BYTES!/1073741824
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
echo 🔄 PROCESSOS ATIVOS: %PROCESS_COUNT%
echo.
echo ==================================================
echo 🌐 NAVEGADORES
echo ==================================================
echo.
) > "medicao_%TIMESTAMP%.txt"

:: Chrome
if %CHROME_PROCESSES% GTR 0 (
    echo CHROME: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: %CHROME_PROCESSES% >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: %CHROME_MEM_MB% MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo CHROME: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

:: Edge
if %EDGE_PROCESSES% GTR 0 (
    echo EDGE: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: %EDGE_PROCESSES% >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: %EDGE_MEM_MB% MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo EDGE: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

:: Firefox
if %FIREFOX_PROCESSES% GTR 0 (
    echo FIREFOX: Em execucao >> "medicao_%TIMESTAMP%.txt"
    echo    Processos: %FIREFOX_PROCESSES% >> "medicao_%TIMESTAMP%.txt"
    echo    Memoria total: %FIREFOX_MEM_MB% MB >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
) else (
    echo FIREFOX: Nao em execucao >> "medicao_%TIMESTAMP%.txt"
    echo. >> "medicao_%TIMESTAMP%.txt"
)

(
echo ⏰ TEMPO DE ATIVIDADE: !UPTIME!
echo.
echo ==================================================
echo 📈 RESUMO DO SISTEMA
echo ==================================================
echo.
echo ✅ Sistema operacional: !OS_NAME!
echo ✅ Processador: !PROCESSOR!
echo ✅ Memoria RAM: !MEM_TOTAL! total, !MEM_AVAIL! disponivel
echo ✅ Disco C: !FREE_GB! GB livres
echo ✅ Processos ativos: %PROCESS_COUNT%
echo ✅ Tempo de atividade: !UPTIME!
echo.
echo 📊 NAVEGADORES EM EXECUCAO:
) >> "medicao_%TIMESTAMP%.txt"

:: Listar navegadores ativos no resumo
if %CHROME_PROCESSES% GTR 0 (
    echo ✅ Chrome: %CHROME_PROCESSES% processos ^(%CHROME_MEM_MB% MB^) >> "medicao_%TIMESTAMP%.txt"
)
if %EDGE_PROCESSES% GTR 0 (
    echo ✅ Edge: %EDGE_PROCESSES% processos ^(%EDGE_MEM_MB% MB^) >> "medicao_%TIMESTAMP%.txt"
)
if %FIREFOX_PROCESSES% GTR 0 (
    echo ✅ Firefox: %FIREFOX_PROCESSES% processos ^(%FIREFOX_MEM_MB% MB^) >> "medicao_%TIMESTAMP%.txt"
)

:: Se nenhum navegador estiver rodando
set /a TOTAL_BROWSERS=%CHROME_PROCESSES%+%EDGE_PROCESSES%+%FIREFOX_PROCESSES%
if %TOTAL_BROWSERS% EQU 0 (
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