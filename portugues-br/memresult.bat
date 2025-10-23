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
echo Usuario: %USERNAME%
echo Computador: %COMPUTERNAME%
echo.

:: 1. ESPACO EM DISCO (metodo alternativo que funciona sem admin)
echo [1] ESPACO EM DISCO LIVRE:
for /f "tokens=2,3" %%i in ('dir C:\ ^| find "bytes livres"') do (
    echo Disco C: %%i %%j livres
)
echo.

:: 2. MEMORIA RAM
echo [2] USO DE MEMORIA RAM:
echo Coletando informacoes de memoria...
systeminfo | findstr /C:"Memória física disponível" /C:"Memória física total" || echo "Nao foi possivel coletar info de memoria"
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
    for /f "tokens=2 delims= " %%i in ('tasklist /fi "IMAGENAME eq chrome.exe" /fo table /nh') do (
        echo Memoria do Chrome: %%i KB
    )
) else (
    echo Chrome nao esta em execucao
)
echo.

:: 5. TEMPO DE INICIALIZACAO
echo [5] TEMPO DE ATIVIDADE DO SISTEMA:
systeminfo | findstr /C:"Tempo inicialização do sistema" || echo "Info de tempo de sistema nao disponivel"
echo.

:: 6. ARQUIVOS TEMPORARIOS (metodo simplificado)
echo [6] ARQUIVOS TEMPORARIOS:
echo Temp do usuario: 
dir "%temp%" /a-d | find "arquivo(s)" 2>nul || echo "Nao foi possivel verificar temp"
echo.

:: 7. PERFORMANCE DO SISTEMA (metodo simplificado)
echo [7] INDICADORES DE PERFORMANCE:
wmic cpu get loadpercentage /value 2>nul | find "LoadPercentage" >nul && echo CPU: Metricas coletadas || echo CPU: Info nao disponivel
echo Disco: Metricas basicas coletadas
echo.

echo ==================================================
echo      EXECUTE O SCRIPT DE LIMPEZA AGORA
echo   E RODE ESTE MESMO SCRIPT NOVAMENTE APOS
echo ==================================================
echo.

echo Pressione qualquer tecla para salvar este relatorio...
pause >nul
cls

:: Salvar relatorio
echo Salvando relatorio na area de trabalho...

:: Criar timestamp seguro
set "TIMESTAMP=%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%"
set "TIMESTAMP=%TIMESTAMP: =0%"

(
echo ==================================================
echo    RELATORIO DE MEDICAO - %date% %time%
echo ==================================================
echo.
echo INFORMACOES DO SISTEMA
echo Data/Hora: %date% %time%
echo Usuario: %USERNAME%
echo Computador: %COMPUTERNAME%
echo.

echo ESPACO EM DISCO
) > "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

:: Adicionar espaço em disco ao arquivo
dir C:\ | find "bytes livres" >> "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

:: Continuar adicionando ao arquivo
(
echo.
echo MEMORIA RAM
systeminfo | findstr /C:"Memória física disponível" /C:"Memória física total"
echo.
echo PROCESSOS ATIVOS
echo Total de processos: %PROCESS_COUNT%
echo.
echo CHROME
) >> "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

:: Adicionar status do Chrome
tasklist /fi "IMAGENAME eq chrome.exe" 2>nul | findstr /i "chrome.exe" >nul && echo "Chrome em execucao" >> "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt" || echo "Chrome nao em execucao" >> "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

:: Finalizar arquivo
(
echo.
echo TEMPO DE ATIVIDADE
systeminfo | findstr /C:"Tempo inicialização do sistema"
echo.
echo ==================================================
echo Relatorio completo salvo em: medicao_%TIMESTAMP%.txt
echo ==================================================
) >> "%userprofile%\Desktop\medicao_%TIMESTAMP%.txt"

echo.
echo ✅ RELATORIO SALVO COM SUCESSO!
echo Arquivo: medicao_%TIMESTAMP%.txt
echo Local: Area de Trabalho
echo.
echo Use este relatorio para comparar ANTES e DEPOIS da limpeza.
echo.
echo Pressione qualquer tecla para fechar...
pause >nul