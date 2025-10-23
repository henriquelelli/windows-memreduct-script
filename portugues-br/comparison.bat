@echo off
echo COMPARADOR DE RESULTADOS - ANTES vs DEPOIS
echo.

set /p FILE_BEFORE=Arquivo ANTES (medicao_YYYYMMDD_HHMM.txt): 
set /p FILE_AFTER=Arquivo DEPOIS (medicao_YYYYMMDD_HHMM.txt): 

echo.
echo =============== COMPARACAO ===============
findstr "Disco C:" "%FILE_BEFORE%"
findstr "Disco C:" "%FILE_AFTER%"
echo.
findstr "Memória física disponível" "%FILE_BEFORE%"
findstr "Memória física disponível" "%FILE_AFTER%"
echo.