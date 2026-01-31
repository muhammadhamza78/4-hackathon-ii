@echo off
REM Combined script to open VS Code and create a pull request

echo Select an option:
echo 1. Open VS Code
echo 2. Create Pull Request
echo 3. Both (Open VS Code and Create Pull Request)
echo.

choice /C 123 /M "Enter your choice"

if errorlevel 3 goto both
if errorlevel 2 goto createpr
if errorlevel 1 goto opencode

:opencode
call open-vscode.bat
goto end

:createpr
call create-pr.bat
goto end

:both
start "VS Code" /B call open-vscode.bat
timeout /t 2 /nobreak >nul
call create-pr.bat
goto end

:end
echo.
echo Operation completed.
pause