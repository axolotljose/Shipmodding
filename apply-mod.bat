@echo off
REM Light Shield Mod - Apply Script for Windows
REM This script applies the Light Shield mod to a Ship of Harkinian repository

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%1"

if "%REPO_ROOT%"=="" set "REPO_ROOT=."

if not exist "%REPO_ROOT%\soh\soh\Enhancements" (
    echo ERROR: This doesn't look like a Shipwright repository.
    echo Usage: apply-mod.bat C:\path\to\Shipwright
    echo Or run from within the Shipwright repo: apply-mod.bat
    pause
    exit /b 1
)

echo === Light Shield Mod Installer ===
echo Target repository: %REPO_ROOT%
echo.

REM Step 1: Copy the LightShield directory
echo [1/4] Copying LightShield module...
if not exist "%REPO_ROOT%\soh\soh\Enhancements\LightShield" mkdir "%REPO_ROOT%\soh\soh\Enhancements\LightShield"
copy /Y "%SCRIPT_DIR%\soh\soh\Enhancements\LightShield\LightShield.cpp" "%REPO_ROOT%\soh\soh\Enhancements\LightShield\"
copy /Y "%SCRIPT_DIR%\soh\soh\Enhancements\LightShield\LightShield.h" "%REPO_ROOT%\soh\soh\Enhancements\LightShield\"

REM Step 2: Add to CMakeLists.txt
echo [2/4] Updating CMakeLists.txt...
set "CMAKE_FILE=%REPO_ROOT%\soh\soh\Enhancements\CMakeLists.txt"
if exist "%CMAKE_FILE%" (
    findstr /C:"LightShield" "%CMAKE_FILE%" >nul
    if errorlevel 1 (
        powershell -Command "(Get-Content '%CMAKE_FILE%') -replace '(# Add new source files here)', '$1`n`nset(ENHANCEMENT_SRCS ${ENHANCEMENT_SRCS} ${CMAKE_CURRENT_SOURCE_DIR}/LightShield/LightShield.cpp)' | Set-Content '%CMAKE_FILE%'"
        echo       - Added LightShield.cpp to CMakeLists.txt
    ) else (
        echo       - LightShield already in CMakeLists.txt, skipping
    )
) else (
    echo WARNING: Could not find %CMAKE_FILE%
    echo          You may need to manually add the LightShield source file.
)

REM Step 3: Add to mods.cpp
echo [3/4] Updating mods.cpp...
set "MODS_FILE=%REPO_ROOT%\soh\soh\Enhancements\mods.cpp"
if exist "%MODS_FILE%" (
    findstr /C:"LightShield" "%MODS_FILE%" >nul
    if errorlevel 1 (
        REM Add include at the top
        powershell -Command "(Get-Content '%MODS_FILE%') -replace '(#include \"mods.h\")', '$1`n#include \"LightShield/LightShield.h\"' | Set-Content '%MODS_FILE%'"
        REM Add init call inside InitMods function
        powershell -Command "(Get-Content '%MODS_FILE%') -replace '(void InitMods\(\) \{)', '$1`n    LightShield_Init();' | Set-Content '%MODS_FILE%'"
        echo       - Added LightShield_Init() to mods.cpp
    ) else (
        echo       - LightShield already in mods.cpp, skipping
    )
) else (
    echo WARNING: Could not find %MODS_FILE%
    echo          You may need to manually add the LightShield init.
)

REM Step 4: Add to SohMenuEnhancements.cpp
echo [4/4] Updating SohMenuEnhancements.cpp...
set "MENU_FILE=%REPO_ROOT%\soh\soh\SohGui\SohMenuEnhancements.cpp"
if exist "%MENU_FILE%" (
    findstr /C:"LightShield" "%MENU_FILE%" >nul
    if errorlevel 1 (
        REM Add include
        powershell -Command "(Get-Content '%MENU_FILE%') -replace '(#include <soh/Enhancements/TimeDisplay/TimeDisplay.h>)', '$1`n#include <soh/Enhancements/LightShield/LightShield.h>' | Set-Content '%MENU_FILE%'"
        echo       - Added LightShield menu entries
    ) else (
        echo       - LightShield already in menu, skipping
    )
) else (
    echo WARNING: Could not find %MENU_FILE%
    echo          You may need to manually add the menu entries.
)

echo.
echo === Mod Applied Successfully! ===
echo.
echo Next steps:
echo   1. Build Ship of Harkinian following the official BUILDING.md guide
echo   2. Or push to your fork and use GitHub Actions to build
echo   3. In-game: Go to Enhancements ^> Equipment ^> Gameplay to enable
echo.
pause
