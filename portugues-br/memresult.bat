@echo off
title Teste Medicao
color 0B

echo.
echo TESTE SIMPLES - Se esta vendo esta mensagem, o script funciona!
echo.
echo Coletando informacoes basicas...
echo.

echo Data/Hora: %date% %time%
echo Usuario: %USERNAME%
echo.

echo Espaco em disco C:
fsutil volume diskfree C: | findstr "avail"
echo.

echo Memoria RAM:
systeminfo | findstr /C:"Memória física disponível"
echo.

echo Processos ativos: 
tasklist /fo table | find /c ".exe"
echo.

echo Pressione qualquer tecla para salvar relatorio...
pause >nul

echo Salvando relatorio na area de trabalho...
echo Teste concluido: %date% %time% > "%userprofile%\Desktop\teste_medicao.txt"
echo Relatorio salvo!

echo.
echo Pressione qualquer tecla para fechar...
pause >nul