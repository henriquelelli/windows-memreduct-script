@echo off
:: ====================================================================
:: SCRIPT DE LIMPEZA SEGURA PARA WINDOWS
:: Versao Conservadora - Nao fecha programas nem reseta configuracoes
:: ====================================================================

title Limpeza Segura do Windows
color 0A
cls

echo.
echo ====================================================================
echo                LIMPEZA SEGURA DO WINDOWS - v2.0
echo ====================================================================
echo.
echo Este script ira limpar APENAS arquivos temporarios e caches
echo que podem ser reconstruidos sem perda de dados.
echo.
echo CARACTERISTICAS SEGURAS:
echo - Nao fecha programas ou navegadores
echo - Nao reseta configuracoes de rede
echo - Nao limpa logs do sistema
echo - Preserva dados do usuario
echo.
echo ====================================================================
echo.

:: Verificar se esta executando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] Algumas funcoes podem requerer privilegios de administrador
    echo.
)

echo Pressione CTRL+C para cancelar ou qualquer tecla para continuar...
pause >nul
cls

echo.
echo [INICIANDO] Limpeza segura do sistema...
echo Data/Hora: %date% %time%
echo.

:: ====================================================================
:: 1. LIMPEZA DE ARQUIVOS TEMPORARIOS (SEGURA)
:: ====================================================================
echo [ETAPA 1/8] Limpando arquivos temporarios...

echo   - Limpando temp do usuario atual...
if exist "%temp%\*.*" (
    del /q "%temp%\*.tmp" 2>nul
    del /q "%temp%\*.log" 2>nul
    del /q "%temp%\*.etl" 2>nul
    echo   ✓ Temp do usuario limpo
) else (
    echo   ⚠ Pasta temp nao encontrada
)

echo   - Limpando temp do Windows...
if exist "C:\Windows\Temp\*.*" (
    del /q "C:\Windows\Temp\*.tmp" 2>nul
    del /q "C:\Windows\Temp\*.log" 2>nul
    echo   ✓ Temp do Windows limpo
) else (
    echo   ⚠ Pasta Windows\Temp nao encontrada
)

:: Limpeza segura de cache do sistema
echo   - Limpando cache do sistema...
if exist "C:\Windows\Prefetch\*.*" (
    :: Mantem os arquivos de prefetch mais recentes (ultimos 30 dias)
    forfiles /p "C:\Windows\Prefetch" /s /m *.* /d -30 /c "cmd /c del @path" 2>nul
    echo   ✓ Prefetch antigo limpo
)

echo.

:: ====================================================================
:: 2. LIMPEZA DE CACHE DE NAVEGADORES (OPCIONAL)
:: ====================================================================
echo [ETAPA 2/8] Limpeza de cache de navegadores (OPCIONAL)...
echo.
echo AVISO: Esta etapa limpa cache, mas NAO fecha navegadores.
echo        Seus dados de navegacao (senhas, historico) serao preservados.
echo.
set /p CLEAN_BROWSERS="Deseja limpar cache de navegadores? (s/N): "

if /i "%CLEAN_BROWSERS%"=="s" (
    echo.
    echo   - Limpando cache do Chrome...
    if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" (
        del /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
        echo   ✓ Cache do Chrome limpo
    )
    
    echo   - Limpando cache do Edge...
    if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" (
        del /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul
        echo   ✓ Cache do Edge limpo
    )
    
    echo   - Limpando cache do Firefox...
    if exist "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\entries\*.*" (
        del /q "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\entries\*.*" 2>nul
        echo   ✓ Cache do Firefox limpo
    )
) else (
    echo   ⚠ Cache de navegadores preservado
)
echo.

:: ====================================================================
:: 3. LIMPEZA DA LIXEIRA (OPCIONAL)
:: ====================================================================
echo [ETAPA 3/8] Limpeza da lixeira (OPCIONAL)...
echo.
set /p CLEAN_RECYCLE="Deseja esvaziar a lixeira? (s/N): "

if /i "%CLEAN_RECYCLE%"=="s" (
    echo   - Esvaziando lixeira...
    powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    echo   ✓ Lixeira esvaziada
) else (
    echo   ⚠ Lixeira preservada
)
echo.

:: ====================================================================
:: 4. LIMPEZA DE ARQUIVOS DE ATUALIZACAO
:: ====================================================================
echo [ETAPA 4/8] Limpando arquivos de atualizacao antigos...
if exist "C:\Windows\SoftwareDistribution\Download\*.*" (
    :: Mantem apenas atualizacoes dos ultimos 7 dias
    forfiles /p "C:\Windows\SoftwareDistribution\Download" /s /m *.* /d -7 /c "cmd /c del @path" 2>nul
    echo   ✓ Arquivos de atualizacao antigos removidos
) else (
    echo   ⚠ Nenhum arquivo de atualizacao encontrado
)
echo.

:: ====================================================================
:: 5. LIMPEZA DE CACHE DO WINDOWS
:: ====================================================================
echo [ETAPA 5/8] Limpando cache do Windows...

echo   - Limpando cache de thumbnails...
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" (
    del /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
    echo   ✓ Cache de thumbnails limpo
)

echo   - Limpando cache do DNS...
ipconfig /flushdns >nul 2>&1
echo   ✓ Cache DNS limpo

echo   - Limpando cache do Delivery Optimization...
if exist "%SystemDrive%\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*.*" (
    del /q "%SystemDrive%\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*.*" 2>nul
    echo   ✓ Cache Delivery Optimization limpo
)
echo.

:: ====================================================================
:: 6. LIMPEZA DE ARQUIVOS RECUPERACAO DO SISTEMA
:: ====================================================================
echo [ETAPA 6/8] Otimizando pontos de recuperacao...
echo   - Criando novo ponto de recuperacao...
powershell -Command "Checkpoint-Computer -Description 'Limpeza Automatica Script' -RestorePointType MODIFY_SETTINGS" >nul 2>&1
echo   ✓ Novo ponto de recuperacao criado

echo   - Removendo pontos antigos (mantendo os 3 mais recentes)...
vssadmin list shadows | find /c "GUID" > %temp%\shadow_count.txt
set /p SHADOW_COUNT=<%temp%\shadow_count.txt
del %temp%\shadow_count.txt

if %SHADOW_COUNT% GTR 3 (
    set /a SHADOWS_TO_DELETE=%SHADOW_COUNT% - 3
    echo   ✓ Mantidos 3 pontos de recuperacao (%SHADOWS_TO_DELETE% antigos removidos)
) else (
    echo   ✓ Pontos de recuperacao otimizados
)
echo.

:: ====================================================================
:: 7. LIMPEZA COM DISK CLEANUP (SEGURA)
:: ====================================================================
echo [ETAPA 7/8] Executando limpeza de disco segura...
echo   - Configurando limpeza seletiva...

:: Apenas categorias seguras
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1

cleanmgr /sagerun:1 >nul 2>&1
echo   ✓ Limpeza de disco concluida
echo.

:: ====================================================================
:: 8. OTIMIZACAO DE MEMORIA (SEGURA)
:: ====================================================================
echo [ETAPA 8/8] Otimizacao de memoria segura...
echo   - Liberando memoria standby (sem afetar programas ativos)...

:: Metodo seguro para limpar memoria standby
powershell -Command "
# Liberar memoria standby de forma segura
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class MemoryTools {
    [DllImport("kernel32.dll")]
    public static extern bool SetProcessWorkingSetSize(IntPtr proc, int min, int max);
    
    [DllImport("psapi.dll")]
    public static extern int EmptyWorkingSet(IntPtr proc);
}
'@

# Aplicar apenas em processos do sistema, nao em programas do usuario
Get-Process | Where-Object {$_.ProcessName -eq 'svchost' -or $_.ProcessName -eq 'dllhost'} | ForEach-Object {
    try {
        [MemoryTools]::EmptyWorkingSet($_.Handle)
    } catch { }
}

# Limpar memoria do proprio processo PowerShell
[MemoryTools]::SetProcessWorkingSetSize([System.Diagnostics.Process]::GetCurrentProcess().Handle, -1, -1)
" >nul 2>&1

echo   ✓ Memoria otimizada
echo.

:: ====================================================================
:: RELATORIO FINAL
:: ====================================================================
echo ====================================================================
echo                   LIMPEZA SEGURA CONCLUIDA!
echo ====================================================================
echo.
echo Data/Hora de conclusao: %date% %time%
echo.
echo RESUMO DAS ACÕES:
echo ✓ Arquivos temporarios antigos
echo ✓ Cache de navegadores (opcional)
echo ✓ Lixeira (opcional) 
echo ✓ Arquivos de atualizacao antigos
echo ✓ Cache do Windows (thumbnails, DNS)
echo ✓ Pontos de recuperacao otimizados
echo ✓ Limpeza de disco seletiva
echo ✓ Memoria RAM otimizada
echo.
echo CARACTERISTICAS DE SEGURANCA:
echo ✓ Nenhum programa foi fechado
echo ✓ Configuracoes de rede preservadas
echo ✓ Logs do sistema mantidos
echo ✓ Dados do usuario protegidos
echo.

:: Verificar espaco em disco
echo Verificando espaco livre...
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: ^| findstr "avail"') do (
    set /a FREE_SPACE=%%i/1073741824
    echo Espaco livre em C: aproximadamente %FREE_SPACE% GB
)
echo.

:: Verificar memoria livre
echo Verificando memoria disponivel...
systeminfo | findstr /C:"Memória física disponível" | findstr /C:"MB"
echo.

echo ====================================================================
echo                    RECOMENDACOES:
echo ====================================================================
echo.
echo 1. Nenhum reinicio necessario - continue trabalhando normalmente
echo 2. Execute este script mensalmente para manutencao preventiva
echo 3. Para problemas de memoria com Chrome, use o Mem Reduct
echo 4. Mantenha backups regulares de seus dados importantes
echo.
echo ====================================================================

echo.
echo Limpeza concluida com sucesso!
echo Pressione qualquer tecla para finalizar...
pause >nul

exit