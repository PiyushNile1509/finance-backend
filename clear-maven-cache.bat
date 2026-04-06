@echo off
echo ========================================
echo Clearing Maven Cache and Re-downloading
echo ========================================
echo.

echo This will:
echo 1. Clear the cached failed downloads
echo 2. Force Maven to re-download all dependencies
echo.
pause

echo Step 1: Clearing Maven cache for Spring Boot...
echo.
if exist "%USERPROFILE%\.m2\repository\org\springframework" (
    echo Deleting Spring Framework cache...
    rmdir /s /q "%USERPROFILE%\.m2\repository\org\springframework"
    echo Done.
) else (
    echo Spring cache not found, skipping...
)
echo.

echo Step 2: Clearing other cached dependencies...
if exist "%USERPROFILE%\.m2\repository\io\jsonwebtoken" (
    echo Deleting JWT cache...
    rmdir /s /q "%USERPROFILE%\.m2\repository\io\jsonwebtoken"
)
if exist "%USERPROFILE%\.m2\repository\com\mysql" (
    echo Deleting MySQL cache...
    rmdir /s /q "%USERPROFILE%\.m2\repository\com\mysql"
)
echo.

echo Step 3: Force downloading dependencies...
echo This may take a few minutes depending on your internet speed...
echo.
call mvn clean install -U
if %errorlevel% neq 0 (
    echo.
    echo ========================================
    echo ERROR: Download failed
    echo ========================================
    echo.
    echo Possible causes:
    echo 1. No internet connection
    echo 2. Firewall blocking Maven
    echo 3. Maven repository is down
    echo 4. Proxy settings needed
    echo.
    echo Solutions:
    echo - Check your internet connection
    echo - Try again in a few minutes
    echo - If behind a proxy, configure Maven settings.xml
    echo - Try using a VPN if repository is blocked
    echo.
    pause
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS! Dependencies downloaded
echo ========================================
echo.
echo Now refresh your IDE:
echo - VS Code: Ctrl+Shift+P ^> Reload Window
echo - IntelliJ: Right-click pom.xml ^> Maven ^> Reload
echo - Eclipse: Right-click project ^> Maven ^> Update Project
echo.
pause
