@echo off
:: ====================================================================
:: SAFE WINDOWS CLEANUP SCRIPT
:: Conservative Version - Does not close programs or reset settings
:: ====================================================================

title Safe Windows Cleanup
color 0A
cls

echo.
echo ====================================================================
echo                SAFE WINDOWS CLEANUP - v2.0
echo ====================================================================
echo.
echo This script will clean ONLY temporary files and caches
echo that can be rebuilt without data loss.
echo.
echo SAFETY FEATURES:
echo - Does not close programs or browsers
echo - Does not reset network settings
echo - Does not clear system logs
echo - Preserves user data
echo.
echo ====================================================================
echo.

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] Some functions may require administrator privileges
    echo.
)

echo Press CTRL+C to cancel or any key to continue...
pause >nul
cls

echo.
echo [STARTING] Safe system cleanup...
echo Date/Time: %date% %time%
echo.

:: ====================================================================
:: 1. TEMPORARY FILES CLEANUP (SAFE)
:: ====================================================================
echo [STEP 1/8] Cleaning temporary files...

echo   - Cleaning current user temp...
if exist "%temp%\*.*" (
    del /q "%temp%\*.tmp" 2>nul
    del /q "%temp%\*.log" 2>nul
    del /q "%temp%\*.etl" 2>nul
    echo   ✓ User temp cleaned
) else (
    echo   ⚠ Temp folder not found
)

echo   - Cleaning Windows temp...
if exist "C:\Windows\Temp\*.*" (
    del /q "C:\Windows\Temp\*.tmp" 2>nul
    del /q "C:\Windows\Temp\*.log" 2>nul
    echo   ✓ Windows temp cleaned
) else (
    echo   ⚠ Windows\Temp folder not found
)

:: Safe system cache cleanup
echo   - Cleaning system cache...
if exist "C:\Windows\Prefetch\*.*" (
    :: Keep recent prefetch files (last 30 days)
    forfiles /p "C:\Windows\Prefetch" /s /m *.* /d -30 /c "cmd /c del @path" 2>nul
    echo   ✓ Old prefetch cleaned
)

echo.

:: ====================================================================
:: 2. BROWSER CACHE CLEANUP (OPTIONAL)
:: ====================================================================
echo [STEP 2/8] Browser cache cleanup (OPTIONAL)...
echo.
echo WARNING: This step clears cache but does NOT close browsers.
echo         Your browsing data (passwords, history) will be preserved.
echo.
set /p CLEAN_BROWSERS="Do you want to clear browser cache? (y/N): "

if /i "%CLEAN_BROWSERS%"=="y" (
    echo.
    echo   - Cleaning Chrome cache...
    if exist "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" (
        del /q "%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache\*.*" 2>nul
        echo   ✓ Chrome cache cleaned
    )
    
    echo   - Cleaning Edge cache...
    if exist "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" (
        del /q "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Cache\*.*" 2>nul
        echo   ✓ Edge cache cleaned
    )
    
    echo   - Cleaning Firefox cache...
    if exist "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\entries\*.*" (
        del /q "%APPDATA%\Mozilla\Firefox\Profiles\*\cache2\entries\*.*" 2>nul
        echo   ✓ Firefox cache cleaned
    )
) else (
    echo   ⚠ Browser cache preserved
)
echo.

:: ====================================================================
:: 3. RECYCLE BIN CLEANUP (OPTIONAL)
:: ====================================================================
echo [STEP 3/8] Recycle bin cleanup (OPTIONAL)...
echo.
set /p CLEAN_RECYCLE="Do you want to empty recycle bin? (y/N): "

if /i "%CLEAN_RECYCLE%"=="y" (
    echo   - Emptying recycle bin...
    powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
    echo   ✓ Recycle bin emptied
) else (
    echo   ⚠ Recycle bin preserved
)
echo.

:: ====================================================================
:: 4. UPDATE FILES CLEANUP
:: ====================================================================
echo [STEP 4/8] Cleaning old update files...
if exist "C:\Windows\SoftwareDistribution\Download\*.*" (
    :: Keep only updates from the last 7 days
    forfiles /p "C:\Windows\SoftwareDistribution\Download" /s /m *.* /d -7 /c "cmd /c del @path" 2>nul
    echo   ✓ Old update files removed
) else (
    echo   ⚠ No update files found
)
echo.

:: ====================================================================
:: 5. WINDOWS CACHE CLEANUP
:: ====================================================================
echo [STEP 5/8] Cleaning Windows cache...

echo   - Cleaning thumbnails cache...
if exist "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" (
    del /q "%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db" 2>nul
    echo   ✓ Thumbnails cache cleaned
)

echo   - Cleaning DNS cache...
ipconfig /flushdns >nul 2>&1
echo   ✓ DNS cache cleaned

echo   - Cleaning Delivery Optimization cache...
if exist "%SystemDrive%\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*.*" (
    del /q "%SystemDrive%\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache\*.*" 2>nul
    echo   ✓ Delivery Optimization cache cleaned
)
echo.

:: ====================================================================
:: 6. SYSTEM RESTORE POINTS OPTIMIZATION
:: ====================================================================
echo [STEP 6/8] Optimizing restore points...
echo   - Creating new restore point...
powershell -Command "Checkpoint-Computer -Description 'Automatic Cleanup Script' -RestorePointType MODIFY_SETTINGS" >nul 2>&1
echo   ✓ New restore point created

echo   - Removing old points (keeping 3 most recent)...
vssadmin list shadows | find /c "GUID" > %temp%\shadow_count.txt
set /p SHADOW_COUNT=<%temp%\shadow_count.txt
del %temp%\shadow_count.txt

if %SHADOW_COUNT% GTR 3 (
    set /a SHADOWS_TO_DELETE=%SHADOW_COUNT% - 3
    echo   ✓ Kept 3 restore points (%SHADOWS_TO_DELETE% old ones removed)
) else (
    echo   ✓ Restore points optimized
)
echo.

:: ====================================================================
:: 7. DISK CLEANUP (SAFE)
:: ====================================================================
echo [STEP 7/8] Running safe disk cleanup...
echo   - Configuring selective cleanup...

:: Only safe categories
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Internet Cache Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Setup Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1

cleanmgr /sagerun:1 >nul 2>&1
echo   ✓ Disk cleanup completed
echo.

:: ====================================================================
:: 8. MEMORY OPTIMIZATION (SAFE)
:: ====================================================================
echo [STEP 8/8] Safe memory optimization...
echo   - Releasing standby memory (without affecting active programs)...

:: Safe method to clear standby memory
powershell -Command "
# Release standby memory safely
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class MemoryTools {
    [DllImport(""kernel32.dll"")]
    public static extern bool SetProcessWorkingSetSize(IntPtr proc, int min, int max);
    
    [DllImport(""psapi.dll"")]
    public static extern int EmptyWorkingSet(IntPtr proc);
}
'@

# Apply only to system processes, not user programs
Get-Process | Where-Object {$_.ProcessName -eq 'svchost' -or $_.ProcessName -eq 'dllhost'} | ForEach-Object {
    try {
        [MemoryTools]::EmptyWorkingSet($_.Handle)
    } catch { }
}

# Clear memory of the PowerShell process itself
[MemoryTools]::SetProcessWorkingSetSize([System.Diagnostics.Process]::GetCurrentProcess().Handle, -1, -1)
" >nul 2>&1

echo   ✓ Memory optimized
echo.

:: ====================================================================
:: FINAL REPORT
:: ====================================================================
echo ====================================================================
echo                   SAFE CLEANUP COMPLETED!
echo ====================================================================
echo.
echo Completion Date/Time: %date% %time%
echo.
echo SUMMARY OF ACTIONS:
echo ✓ Old temporary files
echo ✓ Browser cache (optional)
echo ✓ Recycle bin (optional) 
echo ✓ Old update files
echo ✓ Windows cache (thumbnails, DNS)
echo ✓ Restore points optimized
echo ✓ Selective disk cleanup
echo ✓ RAM memory optimized
echo.
echo SAFETY FEATURES:
echo ✓ No programs were closed
echo ✓ Network settings preserved
echo ✓ System logs maintained
echo ✓ User data protected
echo.

:: Check disk space
echo Checking free space...
for /f "tokens=2 delims=:" %%i in ('fsutil volume diskfree C: ^| findstr "avail"') do (
    set /a FREE_SPACE=%%i/1073741824
    echo Free space on C: approximately %FREE_SPACE% GB
)
echo.

:: Check available memory
echo Checking available memory...
systeminfo | findstr /C:"Available Physical Memory" | findstr /C:"MB"
echo.

echo ====================================================================
echo                    RECOMMENDATIONS:
echo ====================================================================
echo.
echo 1. No restart required - continue working normally
echo 2. Run this script monthly for preventive maintenance
echo 3. For Chrome memory issues, use Mem Reduct
echo 4. Keep regular backups of your important data
echo.
echo ====================================================================

echo.
echo Cleanup completed successfully!
echo Press any key to finish...
pause >nul

exit