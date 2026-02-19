@echo off
title Claude Proxy Monitor - RUNNING
color 0A
mode con: cols=85 lines=25

REM Add npm to PATH
set PATH=%APPDATA%\npm;%PATH%

:MONITOR
cls
echo.
echo  ===============================================================================
echo                       CLAUDE PROXY SERVER - LIVE STATUS
echo  ===============================================================================
echo.
echo  Last Check: %date% %time%
echo.

REM Check if PM2 process is running
echo  [1/3] PM2 Process........
pm2 list 2>nul | findstr /C:"claude-proxy" | findstr /C:"online" >nul 2>&1
if %errorlevel% equ 0 (
    echo        [OK] Running
) else (
    echo        [ERROR] Not found - Attempting to start...
    pm2 resurrect >nul 2>&1
    timeout /t 2 /nobreak >nul
)

REM Check if port 8082 is listening
echo.
echo  [2/3] Port 8082..........
netstat -ano 2>nul | findstr ":8082" | findstr "LISTENING" >nul 2>&1
if %errorlevel% equ 0 (
    echo        [OK] Listening
) else (
    echo        [WARNING] Not listening yet
)

REM Test API endpoint
echo.
echo  [3/3] API Health.........
powershell -Command "$ProgressPreference='SilentlyContinue'; try { $r = Invoke-WebRequest -Uri 'http://localhost:8082/v1/models' -TimeoutSec 3 -UseBasicParsing -ErrorAction Stop; Write-Host '       [OK] Responding (HTTP 200)' } catch { Write-Host '       [ERROR] Not responding' }" 2>nul

echo.
echo  -------------------------------------------------------------------------------

REM Final status with big indicator
powershell -Command "$ProgressPreference='SilentlyContinue'; try { $r = Invoke-WebRequest -Uri 'http://localhost:8082/v1/models' -TimeoutSec 2 -UseBasicParsing -ErrorAction Stop; Write-Host ''; Write-Host '   STATUS: ' -NoNewline; Write-Host 'READY FOR VSCODE!' -ForegroundColor Black -BackgroundColor Green; Write-Host '   Server: http://localhost:8082' -ForegroundColor Cyan; Write-Host '' } catch { Write-Host ''; Write-Host '   STATUS: ' -NoNewline; Write-Host 'STARTING UP...' -ForegroundColor Black -BackgroundColor Yellow; Write-Host '   Please wait a few seconds' -ForegroundColor Yellow; Write-Host '' }" 2>nul

echo  -------------------------------------------------------------------------------
echo.
echo  This window shows live status. You can minimize or close it anytime.
echo  Auto-refresh in 15 seconds... (Press Ctrl+C to exit)
echo.

timeout /t 15 /nobreak >nul
goto MONITOR
