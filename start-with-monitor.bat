@echo off
REM Start Claude Proxy with Live Monitor
title Starting Claude Proxy Server

REM Add npm to PATH
set PATH=%APPDATA%\npm;%PATH%

echo.
echo  Starting Claude Proxy Server...
echo.

REM Start or resurrect the proxy
pm2 resurrect >nul 2>&1
if %errorlevel% neq 0 (
    echo  First time start detected, initializing...
    cd /d "%~dp0"
    pm2 start ecosystem.config.js >nul 2>&1
)

echo  Waiting for server to initialize...
timeout /t 3 /nobreak >nul

REM Open monitor in a new persistent window
echo.
echo  Opening live monitor window...
start "Claude Proxy Monitor - RUNNING" cmd /k "%~dp0monitor-proxy.bat"

echo.
echo  Done! Monitor window is now open.
echo  You can minimize or close it anytime.
echo.
timeout /t 2 /nobreak >nul
exit
