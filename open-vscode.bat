@echo off
REM Script to open VS Code in the current directory

REM Check if code command is available
where code >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: 'code' command is not found in PATH.
    echo Please install Visual Studio Code and ensure it's added to your PATH.
    echo You can download it from: https://code.visualstudio.com/
    pause
    exit /b 1
)

REM Open VS Code in current directory
echo Opening Visual Studio Code in current directory...
code .

echo VS Code opened successfully.
pause