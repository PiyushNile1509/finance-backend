@echo off
echo ========================================
echo Fixing Maven Dependencies
echo ========================================
echo.

echo Step 1: Checking Maven installation...
where mvn >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Maven is not installed or not in PATH
    echo.
    echo Please install Maven from: https://maven.apache.org/download.cgi
    echo After installation, add Maven's bin directory to your PATH
    echo.
    pause
    exit /b 1
)
echo ✓ Maven found
echo.

echo Step 2: Downloading dependencies...
call mvn dependency:resolve
if %errorlevel% neq 0 (
    echo ERROR: Failed to download dependencies
    pause
    exit /b 1
)
echo.

echo Step 3: Compiling project...
call mvn clean compile -DskipTests
if %errorlevel% neq 0 (
    echo ERROR: Compilation failed
    pause
    exit /b 1
)
echo.

echo ========================================
echo ✓ Dependencies resolved successfully!
echo ========================================
echo.
echo Next steps:
echo 1. Refresh your IDE project (Right-click project ^> Maven ^> Reload Project)
echo 2. If using VS Code, reload the window (Ctrl+Shift+P ^> Reload Window)
echo 3. If using IntelliJ, File ^> Invalidate Caches and Restart
echo.
pause
