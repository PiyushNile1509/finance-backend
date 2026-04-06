@echo off
echo ========================================
echo Finance Backend - Setup Verification
echo ========================================
echo.

set ERROR_COUNT=0

echo [1/5] Checking Java installation...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] ERROR: Java is not installed or not in PATH
    echo     Download from: https://adoptium.net/
    set /a ERROR_COUNT+=1
) else (
    java -version 2>&1 | findstr /C:"version" 
    echo [✓] Java found
)
echo.

echo [2/5] Checking Maven installation...
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [X] ERROR: Maven is not installed or not in PATH
    echo     Download from: https://maven.apache.org/download.cgi
    set /a ERROR_COUNT+=1
) else (
    mvn -version 2>&1 | findstr /C:"Apache Maven"
    echo [✓] Maven found
)
echo.

echo [3/5] Checking MySQL installation...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] WARNING: MySQL command not found in PATH
    echo     Make sure MySQL is installed and running
    echo     Download from: https://dev.mysql.com/downloads/mysql/
) else (
    mysql --version
    echo [✓] MySQL found
)
echo.

echo [4/5] Checking project structure...
if not exist "pom.xml" (
    echo [X] ERROR: pom.xml not found
    echo     Make sure you're in the project root directory
    set /a ERROR_COUNT+=1
) else (
    echo [✓] pom.xml found
)

if not exist "src\main\java\com\finance" (
    echo [X] ERROR: Source code directory not found
    set /a ERROR_COUNT+=1
) else (
    echo [✓] Source code directory found
)
echo.

echo [5/5] Checking Maven dependencies...
if not exist "%USERPROFILE%\.m2\repository\org\springframework" (
    echo [!] WARNING: Spring dependencies not found in Maven cache
    echo     Run: mvn clean install
) else (
    echo [✓] Maven dependencies appear to be downloaded
)
echo.

echo ========================================
echo Summary
echo ========================================
if %ERROR_COUNT% equ 0 (
    echo [✓] All checks passed!
    echo.
    echo Next steps:
    echo 1. Run: mvn clean install
    echo 2. Configure database in: src\main\resources\application.properties
    echo 3. Run: mvn spring-boot:run
) else (
    echo [X] %ERROR_COUNT% error(s) found
    echo.
    echo Please fix the errors above before proceeding.
    echo See TROUBLESHOOTING.md for help.
)
echo.
pause
