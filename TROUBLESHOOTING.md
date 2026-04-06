# Troubleshooting Guide

## Error: "lombok cannot be resolved" and Spring imports not found

These errors occur when your IDE hasn't loaded the Maven dependencies yet. Here's how to fix them:

### Solution 1: Download Maven Dependencies

Run this command in the project directory:
```bash
mvn clean install
```

Or use the provided script:
```bash
fix-dependencies.bat
```

### Solution 2: Refresh IDE

#### For VS Code:
1. Open Command Palette (Ctrl+Shift+P)
2. Type "Java: Clean Java Language Server Workspace"
3. Click it and select "Restart and delete"
4. Reload window (Ctrl+Shift+P > "Developer: Reload Window")

#### For IntelliJ IDEA:
1. Right-click on `pom.xml`
2. Select "Maven" > "Reload Project"
3. Or: File > Invalidate Caches > Invalidate and Restart

#### For Eclipse:
1. Right-click on project
2. Select "Maven" > "Update Project"
3. Check "Force Update of Snapshots/Releases"
4. Click OK

### Solution 3: Verify Maven Installation

Check if Maven is installed:
```bash
mvn -version
```

If not installed:
1. Download from: https://maven.apache.org/download.cgi
2. Extract to a folder (e.g., C:\Program Files\Apache\maven)
3. Add to PATH:
   - Windows: System Properties > Environment Variables > Path > Add Maven's bin folder
4. Restart your terminal/IDE

### Solution 4: Check Java Version

Ensure Java 17 or higher is installed:
```bash
java -version
```

If not installed:
1. Download from: https://adoptium.net/
2. Install Java 17 or higher
3. Set JAVA_HOME environment variable

### Solution 5: Manual Dependency Download

If Maven is installed but dependencies aren't downloading:

```bash
# Clear Maven cache
rmdir /s /q %USERPROFILE%\.m2\repository

# Download dependencies
mvn dependency:resolve

# Compile project
mvn clean compile
```

### Solution 6: IDE-Specific Lombok Setup

Lombok requires IDE plugin installation:

#### VS Code:
1. Install "Lombok Annotations Support" extension
2. Reload window

#### IntelliJ IDEA:
1. File > Settings > Plugins
2. Search for "Lombok"
3. Install and restart

#### Eclipse:
1. Download lombok.jar from https://projectlombok.org/download
2. Run: `java -jar lombok.jar`
3. Select Eclipse installation
4. Click Install/Update

### Solution 7: Verify pom.xml

Ensure these dependencies are in pom.xml:

```xml
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```

### Quick Fix Checklist

- [ ] Maven is installed and in PATH
- [ ] Java 17+ is installed
- [ ] Run `mvn clean install`
- [ ] Refresh/reload IDE project
- [ ] Lombok plugin installed in IDE
- [ ] Internet connection active (for downloading dependencies)

### Still Having Issues?

1. Delete the `target` folder
2. Delete `.m2/repository` folder (Maven cache)
3. Run `mvn clean install -U` (force update)
4. Restart IDE completely
5. Check IDE error logs for specific issues

### Common Error Messages

**"Package org.springframework does not exist"**
- Solution: Run `mvn clean install`

**"Cannot resolve symbol 'RequiredArgsConstructor'"**
- Solution: Install Lombok plugin in IDE

**"The import lombok cannot be resolved"**
- Solution: Run `mvn dependency:resolve` and refresh IDE

**"BUILD FAILURE" during Maven build**
- Check internet connection
- Check Maven settings.xml
- Try with `-U` flag: `mvn clean install -U`

### Contact Support

If none of these solutions work:
1. Check the error logs in your IDE
2. Verify all prerequisites are installed
3. Try creating a new simple Spring Boot project to test Maven setup
