@echo off
setlocal enabledelayedexpansion

:: Spicetify Auto-Install Batch Script
:: Run this whenever Spicetify uninstalls itself

title Spicetify Auto-Installer

echo ========================================
echo   Spicetify Auto-Install Script
echo ========================================
echo.

:: Check if running as admin and warn
net session >nul 2>&1
if %errorLevel% == 0 (
    echo WARNING: Running as administrator!
    echo This can cause issues. Close this and run normally.
    echo.
    timeout /t 5 >nul
)

:: Close Spotify if running
echo Checking for running Spotify processes...
tasklist /FI "IMAGENAME eq Spotify.exe" 2>NUL | find /I /N "Spotify.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Closing Spotify...
    taskkill /F /IM Spotify.exe >nul 2>&1
    timeout /t 2 >nul
)

echo.
echo ========================================
echo Installing Spicetify...
echo ========================================
echo.

:: Create temporary PowerShell script for Spicetify installation
echo Write-Host "Downloading and installing Spicetify..." > "%temp%\install_spicetify.ps1"
echo $installScript = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1" -UseBasicParsing >> "%temp%\install_spicetify.ps1"
echo $scriptBlock = [scriptblock]::Create($installScript.Content) >> "%temp%\install_spicetify.ps1"
echo ^& $scriptBlock >> "%temp%\install_spicetify.ps1"

:: Run the installation script with auto-yes
echo y| powershell -ExecutionPolicy Bypass -File "%temp%\install_spicetify.ps1"

del "%temp%\install_spicetify.ps1" >nul 2>&1

:: Wait for installation to complete
timeout /t 3 >nul

echo.
echo ========================================
echo Applying Spicetify...
echo ========================================
echo.

:: Try different possible paths for spicetify
set "SPICETIFY_PATH="

if exist "%USERPROFILE%\spicetify-cli\spicetify.exe" (
    set "SPICETIFY_PATH=%USERPROFILE%\spicetify-cli\spicetify.exe"
) else if exist "%APPDATA%\spicetify\spicetify.exe" (
    set "SPICETIFY_PATH=%APPDATA%\spicetify\spicetify.exe"
) else if exist "%LOCALAPPDATA%\spicetify\spicetify.exe" (
    set "SPICETIFY_PATH=%LOCALAPPDATA%\spicetify\spicetify.exe"
) else (
    :: Try to find it in PATH
    where spicetify >nul 2>&1
    if !errorLevel! == 0 (
        set "SPICETIFY_PATH=spicetify"
    )
)

if defined SPICETIFY_PATH (
    echo Found Spicetify at: !SPICETIFY_PATH!
    echo.
    "!SPICETIFY_PATH!" backup apply
) else (
    echo Could not find Spicetify executable. Installation may have failed.
    echo.
)

echo.
echo ========================================
echo Installing Marketplace...
echo ========================================
echo.

:: Create temporary PowerShell script for Marketplace installation
echo Write-Host "Downloading and installing Marketplace..." > "%temp%\install_marketplace.ps1"
echo $installScript = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.ps1" -UseBasicParsing >> "%temp%\install_marketplace.ps1"
echo $scriptBlock = [scriptblock]::Create($installScript.Content) >> "%temp%\install_marketplace.ps1"
echo ^& $scriptBlock >> "%temp%\install_marketplace.ps1"

powershell -ExecutionPolicy Bypass -File "%temp%\install_marketplace.ps1"

del "%temp%\install_marketplace.ps1" >nul 2>&1

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo Opening Spotify in 3 seconds...
echo.

timeout /t 3 >nul

:: Start Spotify
if exist "%APPDATA%\Spotify\Spotify.exe" (
    start "" "%APPDATA%\Spotify\Spotify.exe"
) else if exist "%LOCALAPPDATA%\Spotify\Spotify.exe" (
    start "" "%LOCALAPPDATA%\Spotify\Spotify.exe"
)

echo Press any key to exit...
pause >nul