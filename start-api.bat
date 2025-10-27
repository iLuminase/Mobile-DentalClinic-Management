@echo off
echo ====================================
echo  Dental Clinic API Server
echo ====================================
echo.

cd /d "%~dp0"

echo [1/2] Building project...
call mvn clean package -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo [2/2] Starting server...
echo Server will run at: http://localhost:8080
echo Press Ctrl+C to stop
echo.

java -jar target\dentalclinic-api-0.0.1-SNAPSHOT.jar

pause
