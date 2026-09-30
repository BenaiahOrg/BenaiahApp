@echo off
REM Benaiah — one-shot development environment setup for Windows.
REM Run from anywhere:  scripts\project_setup.bat

setlocal enabledelayedexpansion

set "ROOT_DIR=%~dp0.."
cd /d "%ROOT_DIR%"

echo [..] Setting up the Benaiah development environment...
echo.

REM --- Check for FVM ---
where fvm >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] FVM found.
    goto :fvm_ready
)

REM Check pub cache path
set "PUB_CACHE_BIN=%LOCALAPPDATA%\Pub\Cache\bin"
if exist "%PUB_CACHE_BIN%\fvm.bat" (
    set "PATH=%PUB_CACHE_BIN%;%PATH%"
    echo [OK] FVM found in Pub cache.
    goto :fvm_ready
)

echo [..] FVM is not installed. Installing via dart pub global...
where dart >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dart SDK not found. Install Flutter/Dart first, then re-run.
    exit /b 1
)
dart pub global activate fvm
if %errorlevel% neq 0 (
    echo [ERROR] Could not install FVM. Install manually: https://fvm.app
    exit /b 1
)
set "PATH=%PUB_CACHE_BIN%;%PATH%"

where fvm >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] FVM still not found. Add %PUB_CACHE_BIN% to your PATH and restart the terminal.
    exit /b 1
)
echo [OK] FVM installed.

:fvm_ready

REM --- Check for FVM config ---
if not exist ".fvm\fvm_config.json" if not exist ".fvmrc" (
    echo [ERROR] Missing .fvm/fvm_config.json or .fvmrc. Pin a Flutter version with: fvm use ^<version^>
    exit /b 1
)

echo [..] Installing Flutter SDK for this project (from FVM config)...
fvm install
if %errorlevel% neq 0 (
    echo [ERROR] FVM install failed.
    exit /b 1
)

echo [..] Flutter / Dart versions:
fvm flutter --version

echo.
echo [..] Running flutter doctor...
fvm flutter doctor

echo.
echo [..] Fetching Dart / Flutter packages...
fvm flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] pub get failed.
    exit /b 1
)
echo [OK] pub get complete.

echo.
echo [..] Generating code (injectable, riverpod, assets)...
fvm dart run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo [ERROR] Code generation failed.
    exit /b 1
)
echo [OK] Code generation complete.

if not exist "secrets.json" (
    copy /Y "secrets.json.example" "secrets.json" >nul
    echo [WARN] Created secrets.json from secrets.json.example; add your YouVersion developer token.
)

echo.
echo [..] Activating Mason CLI (project bricks)...
fvm dart pub global activate mason_cli

where mason >nul 2>&1
if %errorlevel% equ 0 (
    echo [..] Running mason get...
    mason get
    echo [OK] mason get complete.
) else (
    echo [WARN] mason not on PATH. Add %PUB_CACHE_BIN% to your PATH.
)

echo.
echo [OK] Setup complete. Run the dev flavor with:
echo      fvm flutter run --flavor dev -t lib/main.dart --dart-define-from-file=secrets.json

endlocal