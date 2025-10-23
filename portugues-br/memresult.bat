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
for /f "tokens=2,3" %%i in ('dir C:\ ^| find "bytes livres"') do (
    set "FREE_SPACE=%%i %%j"
    echo Disco C: %%i %%j livres
)
echo.

:: 2. INFORMACOES DETALHADAS DO SISTEMA
echo [2] INFORMACOES DO COMPUTADOR:
for /f "tokens=*" %%i in ('systeminfo ^| findstr /B /C:"Nome do sistema operacional" /C:"Total de memória física" /C:"Sistema fabricado" /C:"Processador"') do (
    echo %%i
)
echo.

:: 3. MEMORIA RAM DETALHADA
echo [3] MEMORIA RAM:
for /f "tokens=1,2,3,4" %%a in ('systeminfo ^| findstr /C:"Memória física disponível" /C:"Memória física total"') do (
    if "%%a"=="Memória" (
        if "%%b"=="física" (
            if "%%c"=="disponível:" echo Memoria Disponivel: %%d
            if "%%c"=="total:" echo Memoria Total: %%d
        )
    )
)
echo.

:: 4. PROCESSOS ATIVOS
echo [4] PROCESSOS EM EXECUCAO:
tasklist /fo table | find /c ".exe" > "%temp%\process_count.txt"
set /p PROCESS_COUNT=<"%temp%\process_count.txt"
del "%temp%\process_count.txt" 2>nul
echo Total de processos ativos: %PROCESS_COUNT%
echo.

:: 5. USO DO CHROME (CORRIGIDO)
echo [5] USO DO CHROME:
tasklist /fi "IMAGENAME eq chrome.exe" 2>nul | findstr /i "chrome.exe" >nul
if %errorlevel% == 0 (
    echo Chrome esta em execucao
    for /f "tokens=5" %%i in ('tasklist /fi "IMAGENAME eq chrome.exe" /fo table /nh 2^>nul') do (
        set /a CHROME_MEM_KB=%%i
        set /a CHROME_MEM_MB=!CHROME_MEM_KB!/1024
        echo Memoria do Chrome: !CHROME_MEM_MB! MB
    )
) else (
    echo Chrome nao esta em execucao
)
echo.

:: 6. TEMPO DE ATIVIDADE
echo [6] TEMPO DE ATIVIDADE DO SISTEMA:
for /f "tokens=1,2,3,4" %%a in ('systeminfo ^| findstr /C:"Tempo inicialização do sistema"') do (
    echo Tempo de atividade: %%b %%c %%d
)
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
for /f "tokens=2 delims==" %%i in ('wmic cpu get name /value 2^>nul') do set "PROCESSOR=%%i"

:: Coletar memoria total
set "MEM_TOTAL="
for /f "tokens=4" %%i in ('systeminfo ^| findstr /C:"Memória física total:"') do set "MEM_TOTAL=%%i"

:: Coletar memoria disponivel
set "MEM_AVAIL="
for /f "tokens=4" %%i in ('systeminfo ^| findstr /C:"Memória física disponível:"') do set "MEM_AVAIL=%%i"

:: Coletar sistema operacional
set "OS_NAME="
for /f "tokens=2,3,4,5,6,7,8,9,10" %%i in ('systeminfo ^| findstr /B /C:"Nome do sistema operacional:"') do set "OS_NAME=%%i %%j %%k %%l %%m %%n %%o %%p %%q"

:: Coletar fabricante
set "MANUFACTURER="
for /f "tokens=2,3,4" %%i in ('systeminfo ^| findstr /B /C:"Sistema fabricado por:"') do set "MANUFACTURER=%%i %%j %%k"

:: Coletar tempo de atividade
set "UPTIME="
for /f "tokens=2,3,4" %%i in ('systeminfo ^| findstr /C:"Tempo inicialização do sistema:"') do set "UPTIME=%%i %%j %%k"

:: Coletar uso do Chrome
set "CHROME_STATUS=Chrome nao em execucao"
set "CHROME_MEM=0"
tasklist /fi "IMAGENAME eq chrome.exe" 2>nul | findstr /i "chrome.exe" >nul
if %errorlevel% == 0 (
    set "CHROME_STATUS=Chrome em execucao"
    for /f "tokens=5" %%i in ('tasklist /fi "IMAGENAME eq chrome.exe" /fo table /nh 2^>nul') do (
        set /a CHROME_MEM=%%i/1024
    )
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
echo 🏭 FABRICANTE: !MANUFACTURER!
echo.
echo 🔧 PROCESSADOR: !PROCESSOR!
echo.
echo 🧠 MEMORIA RAM:
echo    Total: !MEM_TOTAL!
echo    Disponivel: !MEM_AVAIL!
echo.
echo 💾 ARMAZENAMENTO:
) > "medicao_%TIMESTAMP%.txt"

:: Adicionar espaço em disco
dir C:\ | find "bytes livres" >> "medicao_%TIMESTAMP%.txt"

:: Continuar com o relatorio
(
echo.
echo ==================================================
echo 📊 METRICAS DE PERFORMANCE
echo ==================================================
echo.
echo 🔄 PROCESSOS ATIVOS: %PROCESS_COUNT%
echo.
echo 🌐 CHROME: !CHROME_STATUS!
) >> "medicao_%TIMESTAMP%.txt"

if "!CHROME_STATUS!"=="Chrome em execucao" (
    echo    Memoria utilizada: !CHROME_MEM! MB >> "medicao_%TIMESTAMP%.txt"
)

(
echo.
echo ⏰ TEMPO DE ATIVIDADE: !UPTIME!
echo.
echo ==================================================
echo 📈 RESUMO DO SISTEMA
echo ==================================================
echo.
echo ✅ Sistema operacional: !OS_NAME!
echo ✅ Processador: !PROCESSOR!
echo ✅ Memoria RAM: !MEM_TOTAL! total, !MEM_AVAIL! disponivel
echo ✅ Processos ativos: %PROCESS_COUNT%
echo ✅ Chrome: !CHROME_STATUS!
if "!CHROME_STATUS!"=="Chrome em execucao" (
    echo ✅ Memoria Chrome: !CHROME_MEM! MB
)
echo ✅ Tempo de atividade: !UPTIME!
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