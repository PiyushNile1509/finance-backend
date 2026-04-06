@echo off
echo ========================================
echo Fixing IDE Import Errors
echo ========================================
echo.

echo This script will:
echo 1. Download all Maven dependencies
echo 2. Compile the project
echo 3. Fix IDE import errors
echo.
pause

echo Step 1: Downloading Maven dependencies...
echo.
call mvn dependency:resolve
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Failed to download dependencies
    echo.
    echo Possible causes:
    echo - Maven is not installed
    echo - No internet connection
    echo - Firewall blocking Maven
    echo.
    echo Please install Maven from: https://maven.apache.org/download.cgi
    pause
    exit /b 1
)

echo.
echo Step 2: Compiling project...
echo.
call mvn clean compile
if %errorlevel% neq 0 (
    echo.
    echo ERROR: Compilation failed
    echo Check the error messages above
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Dependencies downloaded
echo ========================================
echo.
echo Now do this in your IDE:
echo.
echo VS Code:
echo   1. Press Ctrl+Shift+P
echo   2. Type: Java: Clean Java Language Server Workspace
echo   3. Select it and restart
echo   4. Press Ctrl+Shift+P again
echo   5. Type: Developer: Reload Window
echo.
echo IntelliJ IDEA:
echo   1. Right-click pom.xml
echo   2. Maven -^> Reload Project
echo.
echo Eclipse:
echo   1. Right-click project
echo   2. Maven -^> Update Project
echo.
pause
