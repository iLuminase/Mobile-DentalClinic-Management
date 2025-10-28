@echo off
echo ====================================
echo  Starting Dental Clinic API
echo ====================================
echo.

cd /d "%~dp0"

if not exist "target\dentalclinic-api-0.0.1-SNAPSHOT.jar" (
    echo JAR file not found! Building project...
    call mvn clean package -DskipTests
    echo.
)

echo Starting server at: http://localhost:8080
echo Press Ctrl+C to stop
echo.

java -jar target\dentalclinic-api-0.0.1-SNAPSHOT.jar
