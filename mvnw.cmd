@REM Maven Wrapper startup script
@REM Download and use Maven without installing it

@echo off
set MAVEN_VERSION=3.9.6
set MAVEN_WRAPPER_JAR=.mvn\wrapper\maven-wrapper.jar
set MAVEN_WRAPPER_URL=https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.2.0/maven-wrapper-3.2.0.jar

if not exist "%MAVEN_WRAPPER_JAR%" (
    echo Downloading Maven Wrapper...
    powershell -Command "Invoke-WebRequest -Uri '%MAVEN_WRAPPER_URL%' -OutFile '%MAVEN_WRAPPER_JAR%'"
)

java -jar %MAVEN_WRAPPER_JAR% %*
