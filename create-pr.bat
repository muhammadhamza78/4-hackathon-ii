@echo off
REM Script to create a pull request using git

REM Check if git is available
where git >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: 'git' command is not found in PATH.
    echo Please install Git and ensure it's added to your PATH.
    pause
    exit /b 1
)

REM Check if we're in a git repository
git rev-parse --git-dir >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Not in a git repository.
    pause
    exit /b 1
)

REM Check if gh (GitHub CLI) is available
where gh >nul 2>nul
if %errorlevel% equ 0 (
    REM GitHub CLI is available, use it to create PR
    echo Creating pull request using GitHub CLI...
    gh pr create --web
) else (
    REM GitHub CLI is not available, guide user to create PR manually
    echo GitHub CLI not found. Opening GitHub website to create pull request manually.
    git remote -v
    echo.
    echo Please push your changes and create a pull request on GitHub website.
    echo Press any key to open GitHub in browser...
    pause >nul
    REM Try to get the repository URL and open it
    FOR /F "tokens=*" %%g IN ('git config --get remote.origin.url') do (set REPO_URL=%%g)
    if defined REPO_URL (
        REM Convert git URL to HTTPS if needed
        set REPO_URL=!REPO_URL:.git=!
        if "!REPO_URL!" neq "!REPO_URL:git@github.com:=https://github.com/!" (
            set REPO_URL=https://github.com/!REPO_URL:git@github.com:=!
        )
        start "" "!REPO_URL:/=!"
    ) else (
        start "" "https://github.com"
    )
)

pause