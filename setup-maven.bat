@echo off
echo ========================================
echo Maven Setup Assistant
echo ========================================
echo.

echo Checking if Maven is installed...
where mvn >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Maven is installed!
    mvn -version
    echo.
    echo You can now run: mvn clean install
    pause
    exit /b 0
)

echo [X] Maven is NOT installed
echo.
echo ========================================
echo Installation Options
echo ========================================
echo.
echo Option 1: Install Maven (Recommended)
echo   - Download from: https://maven.apache.org/download.cgi
echo   - Extract to: C:\Program Files\Apache\maven
echo   - Add to PATH (see INSTALL_MAVEN.md for details)
echo.
echo Option 2: Use IDE Built-in Maven
echo   - IntelliJ IDEA: Right-click pom.xml ^> Maven ^> Reload
echo   - VS Code: Install "Maven for Java" extension
echo   - Eclipse: Right-click project ^> Run As ^> Maven Install
echo.
echo Option 3: Use Maven Wrapper (No installation needed)
echo   - Download wrapper files
echo   - Use mvnw.cmd instead of mvn
echo.
echo ========================================
echo.

set /p choice="Would you like to open the installation guide? (Y/N): "
if /i "%choice%"=="Y" (
    start INSTALL_MAVEN.md
)

echo.
echo After installing Maven:
echo 1. Restart this terminal
echo 2. Run: mvn -version
echo 3. Run: mvn clean install
echo.
pause
