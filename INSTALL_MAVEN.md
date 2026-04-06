# Maven Installation Guide for Windows

## Problem
Maven (mvn) is not recognized, which means it's either not installed or not in your system PATH.

## Solution: Install Maven

### Step 1: Download Maven

1. Go to: https://maven.apache.org/download.cgi
2. Download the **Binary zip archive** (e.g., `apache-maven-3.9.6-bin.zip`)
3. Save it to your Downloads folder

### Step 2: Extract Maven

1. Extract the zip file to: `C:\Program Files\Apache\maven`
   - Or any location you prefer (e.g., `C:\maven`)
2. You should have a folder like: `C:\Program Files\Apache\maven\apache-maven-3.9.6`

### Step 3: Add Maven to PATH

#### Option A: Using System Properties (Recommended)

1. Press `Windows + R`
2. Type `sysdm.cpl` and press Enter
3. Click the "Advanced" tab
4. Click "Environment Variables"
5. Under "System variables", find and select "Path"
6. Click "Edit"
7. Click "New"
8. Add: `C:\Program Files\Apache\maven\apache-maven-3.9.6\bin`
   (adjust the path to match your installation)
9. Click "OK" on all windows
10. **Restart your terminal/IDE**

#### Option B: Using PowerShell (Quick)

Run PowerShell as Administrator and execute:

```powershell
# Set Maven home
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", "C:\Program Files\Apache\maven\apache-maven-3.9.6", "Machine")

# Add to PATH
$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $path + ";C:\Program Files\Apache\maven\apache-maven-3.9.6\bin"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
```

**Important**: Restart your terminal after this!

### Step 4: Verify Installation

Open a **new** terminal and run:

```bash
mvn -version
```

You should see output like:
```
Apache Maven 3.9.6
Maven home: C:\Program Files\Apache\maven\apache-maven-3.9.6
Java version: 17.0.x
```

## Alternative: Use Maven Wrapper (No Installation Required)

If you don't want to install Maven globally, you can use Maven Wrapper:

### For Windows (PowerShell):

```powershell
cd d:\Zoryn_Assestment

# Download Maven Wrapper
Invoke-WebRequest -Uri https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar -OutFile .mvn\wrapper\maven-wrapper.jar

# Use wrapper instead of mvn
.\mvnw.cmd clean install
```

### For Windows (Command Prompt):

```cmd
cd d:\Zoryn_Assestment
mvnw.cmd clean install
```

## Quick Setup Script

I've created a script that will:
1. Check if Maven is installed
2. Guide you through installation if needed
3. Set up the project once Maven is ready

Run: `setup-maven.bat`

## Troubleshooting

### "mvn not recognized" after installation
- **Restart your terminal** (close and reopen)
- **Restart your IDE** completely
- Verify PATH was added correctly: `echo %PATH%` (should include Maven bin folder)

### Java not found
Maven requires Java. Install Java 17 first:
1. Download from: https://adoptium.net/
2. Install Java 17 or higher
3. Verify: `java -version`

### Permission denied
- Run terminal/PowerShell as Administrator
- Check antivirus isn't blocking Maven

## Next Steps After Maven Installation

1. **Restart your terminal/IDE**
2. Verify Maven: `mvn -version`
3. Navigate to project: `cd d:\Zoryn_Assestment`
4. Run: `mvn clean install`
5. Start application: `mvn spring-boot:run`

## Using IDE Built-in Maven

If you're using an IDE, you can use its built-in Maven:

### IntelliJ IDEA:
- Right-click `pom.xml` → Maven → Reload Project
- Or use Maven tool window on the right side

### VS Code:
- Install "Maven for Java" extension
- Use Command Palette (Ctrl+Shift+P) → "Maven: Execute Commands"

### Eclipse:
- Right-click project → Run As → Maven Install
- Or use Maven menu

## Still Having Issues?

If Maven installation fails or you prefer not to install it:

1. Use your IDE's built-in Maven (recommended)
2. Use Maven Wrapper (mvnw.cmd)
3. Download dependencies manually (not recommended)

For more help, see: TROUBLESHOOTING.md
