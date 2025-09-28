@echo off
setlocal EnableDelayedExpansion

REM FreedomGPT Automatic Installation Script for Windows
REM This script automatically installs and sets up FreedomGPT on Windows systems

echo ============================================================
echo FreedomGPT Automatic Installation Script for Windows
echo ============================================================
echo.

REM Check if we're in the right directory
if not exist "package.json" (
    echo [ERROR] Please run this script from the FreedomGPT repository root directory.
    pause
    exit /b 1
)

findstr "freedomgpt" package.json >nul
if errorlevel 1 (
    echo [ERROR] This doesn't appear to be the FreedomGPT project directory.
    pause
    exit /b 1
)

echo [SUCCESS] Found FreedomGPT project directory.
echo.

REM Check for Node.js
node --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Node.js is not installed. Please install Node.js from https://nodejs.org/
    echo Make sure to add it to your PATH.
    pause
    exit /b 1
)

echo [INFO] Node.js is installed.

REM Check for npm
npm --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] npm is not installed. Please install npm (usually comes with Node.js).
    pause
    exit /b 1
)

echo [INFO] npm is available.

REM Check for git
git --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Git is not installed. Some features may not work properly.
    echo Please install Git from https://git-scm.com/
) else (
    echo [INFO] Git is available.
)

REM Check for cmake
cmake --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] CMake is not installed. Please install CMake from https://cmake.org/download/
    echo CMake is required to build llama.cpp on Windows.
    pause
    exit /b 1
)

echo [INFO] CMake is available.
echo.

REM Install yarn if not present
yarn --version >nul 2>&1
if errorlevel 1 (
    echo [INFO] Installing Yarn package manager...
    npm install -g yarn
    if errorlevel 1 (
        echo [ERROR] Failed to install Yarn. Please install it manually.
        pause
        exit /b 1
    )
)

echo [SUCCESS] Yarn is available.
echo.

REM Initialize git submodules if in a git repository
if exist ".git" (
    echo [INFO] Initializing git submodules...
    git submodule update --init --recursive
    if errorlevel 1 (
        echo [WARNING] Failed to initialize git submodules.
    ) else (
        echo [SUCCESS] Git submodules initialized.
    )
) else (
    echo [WARNING] Not a git repository. Skipping submodule initialization.
)

echo.

REM Install Node.js dependencies
echo [INFO] Installing Node.js dependencies...
yarn install
if errorlevel 1 (
    echo [ERROR] Failed to install Node.js dependencies.
    pause
    exit /b 1
)

echo [SUCCESS] Node.js dependencies installed.
echo.

REM Build llama.cpp
if exist "llama.cpp" (
    echo [INFO] Building llama.cpp server...
    cd llama.cpp
    cmake .
    if errorlevel 1 (
        echo [ERROR] CMake configuration failed for llama.cpp.
        cd ..
        pause
        exit /b 1
    )
    
    cmake --build . --config Release
    if errorlevel 1 (
        echo [ERROR] Failed to build llama.cpp.
        cd ..
        pause
        exit /b 1
    )
    
    cd ..
    echo [SUCCESS] llama.cpp built successfully.
) else (
    echo [WARNING] llama.cpp directory not found. Skipping llama.cpp build.
)

echo.

REM Build application
echo [INFO] Building application...
yarn build
if errorlevel 1 (
    echo [ERROR] Failed to build application.
    pause
    exit /b 1
)

echo [SUCCESS] Application built successfully.
echo.

REM Final verification
echo [INFO] Performing final verification...

set "success=true"

if exist "llama.cpp\bin\Release\server.exe" (
    echo [SUCCESS] llama.cpp server binary found.
) else (
    if exist "llama.cpp\server.exe" (
        echo [SUCCESS] llama.cpp server binary found.
    ) else (
        echo [ERROR] llama.cpp server binary not found.
        set "success=false"
    )
)

if exist "main" (
    if exist "renderer\out" (
        echo [SUCCESS] Application build outputs found.
    ) else (
        if exist "renderer\.next" (
            echo [SUCCESS] Application build outputs found.
        ) else (
            echo [ERROR] Application build outputs not found.
            set "success=false"
        )
    )
) else (
    echo [ERROR] Application build outputs not found.
    set "success=false"
)

echo.
echo ============================================================

if "!success!"=="true" (
    echo [SUCCESS] ^🎉 Installation completed successfully!
    echo.
    echo You can now start FreedomGPT with:
    echo   yarn start
    echo.
    echo Or package the application with:
    echo   yarn make
) else (
    echo [ERROR] ^❌ Installation completed with errors.
    echo.
    echo Please check the error messages above and try again.
    pause
    exit /b 1
)

echo ============================================================
echo.
pause