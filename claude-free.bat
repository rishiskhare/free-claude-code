@echo off
REM claude-free.bat - Interactive model picker for free-claude-code on Windows

set SCRIPT_DIR=%~dp0
set MODELS_FILE=%SCRIPT_DIR%nvidia_nim_models.json
set PORT=8082
set BASE_URL=http://localhost:%PORT%

if not exist "%MODELS_FILE%" (
    echo Error: %MODELS_FILE% not found
    exit /b 1
)

REM Extract model IDs from JSON using Python
for /f "delims=" %%i in ('python -c "import json; data=json.load(open('%MODELS_FILE%')); [print(m['id']) for m in data.get('data', [])]" 2^>nul') do (
    set models=%%i
)

REM Use fzf if available, otherwise show numbered menu
where fzf >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%i in ('python -c "import json; data=json.load(open('%MODELS_FILE%')); [print(m['id']) for m in data.get('data', [])]" ^| fzf --prompt="Select a model> " --height=40%% --reverse') do set model=%%i
) else (
    echo Select a model:
    python -c "import json; data=json.load(open('%MODELS_FILE%')); [print(f'{i+1}. {m[\"id\"]}') for i, m in enumerate(data.get('data', []))]"
    set /p choice="Enter number: "
    for /f "delims=" %%i in ('python -c "import json; data=json.load(open('%MODELS_FILE%')); print(data['data'][int('%choice%')-1]['id'])"') do set model=%%i
)

if "%model%"=="" (
    echo No model selected.
    exit /b 1
)

echo Launching Claude Code with model: %model%
set ANTHROPIC_AUTH_TOKEN=freecc:%model%
set ANTHROPIC_BASE_URL=%BASE_URL%
claude %*
