@echo off
echo ========================================
echo Finance Backend - Build and Run Script
echo ========================================
echo.

echo [1/3] Checking prerequisites...
echo.

REM Check Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 17 or higher
    pause
    exit /b 1
)
echo ✓ Java found

REM Check Maven
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Maven is not installed or not in PATH
    echo Please install Maven 3.6 or higher
    pause
    exit /b 1
)
echo ✓ Maven found

echo.
echo [2/3] Building the project...
echo.

call mvn clean install -DskipTests
if %errorlevel% neq 0 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

echo.
echo ✓ Build successful!
echo.
echo [3/3] Starting the application...
echo.
echo The application will start on http://localhost:8080
echo.
echo Sample credentials:
echo   Username: admin    Password: admin123    Role: ADMIN
echo   Username: analyst  Password: analyst123  Role: ANALYST
echo   Username: viewer   Password: viewer123   Role: VIEWER
echo.
echo Press Ctrl+C to stop the application
echo.
echo ========================================
echo.

call mvn spring-boot:run
