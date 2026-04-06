# Maven Auto-Installer and Project Builder
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Maven Auto-Setup for Finance Backend" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Maven is already installed
$mavenInstalled = Get-Command mvn -ErrorAction SilentlyContinue
if ($mavenInstalled) {
    Write-Host "[OK] Maven is already installed!" -ForegroundColor Green
    mvn -version
    Write-Host ""
    Write-Host "Building project..." -ForegroundColor Yellow
    mvn clean install
    exit
}

Write-Host "[!] Maven not found. Installing Maven temporarily..." -ForegroundColor Yellow
Write-Host ""

# Create temp directory
$tempDir = "$env:TEMP\maven-temp"
$mavenVersion = "3.9.6"
$mavenUrl = "https://dlcdn.apache.org/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"
$mavenZip = "$tempDir\maven.zip"
$mavenHome = "$tempDir\apache-maven-$mavenVersion"

# Create temp directory
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "Downloading Maven $mavenVersion..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZip -UseBasicParsing
    Write-Host "[OK] Downloaded successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to download Maven" -ForegroundColor Red
    Write-Host "Please install Maven manually from: https://maven.apache.org/download.cgi" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or use your IDE to build the project:" -ForegroundColor Yellow
    Write-Host "  - IntelliJ: Right-click pom.xml > Maven > Reload Project" -ForegroundColor Cyan
    Write-Host "  - VS Code: Ctrl+Shift+P > Java: Clean Workspace" -ForegroundColor Cyan
    Write-Host "  - Eclipse: Right-click project > Maven > Update Project" -ForegroundColor Cyan
    pause
    exit 1
}

Write-Host "Extracting Maven..." -ForegroundColor Yellow
Expand-Archive -Path $mavenZip -DestinationPath $tempDir -Force
Write-Host "[OK] Extracted successfully" -ForegroundColor Green
Write-Host ""

# Set Maven environment for this session
$env:MAVEN_HOME = $mavenHome
$env:PATH = "$mavenHome\bin;$env:PATH"

Write-Host "Verifying Maven installation..." -ForegroundColor Yellow
& "$mavenHome\bin\mvn.cmd" -version
Write-Host ""

Write-Host "Building project (this may take a few minutes)..." -ForegroundColor Yellow
Write-Host ""

# Build the project
& "$mavenHome\bin\mvn.cmd" clean install

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "SUCCESS! Project built successfully" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "To run the application:" -ForegroundColor Cyan
    Write-Host "  & '$mavenHome\bin\mvn.cmd' spring-boot:run" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Or use your IDE to run FinanceBackendApplication.java" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "BUILD FAILED" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please check the error messages above." -ForegroundColor Yellow
    Write-Host "Common issues:" -ForegroundColor Yellow
    Write-Host "  1. No internet connection" -ForegroundColor Cyan
    Write-Host "  2. Firewall blocking Maven" -ForegroundColor Cyan
    Write-Host "  3. Java not installed (need Java 17+)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Note: This Maven installation is temporary." -ForegroundColor Yellow
Write-Host "For permanent installation, see: INSTALL_MAVEN.md" -ForegroundColor Yellow
Write-Host ""
pause
