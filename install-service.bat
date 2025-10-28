@echo off
echo ====================================
echo  Install Dental Clinic API Service
echo ====================================
echo.
echo This will install the API as a Windows Service
echo.

cd /d "%~dp0"

:: Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Please run as Administrator!
    echo Right-click and select "Run as Administrator"
    pause
    exit /b 1
)

:: Build project first
echo [1/3] Building project...
call mvn clean package -DskipTests

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

:: Download NSSM if not exists
if not exist "nssm.exe" (
    echo [2/3] Downloading NSSM (Non-Sucking Service Manager)...
    echo Please download nssm.exe from: https://nssm.cc/download
    echo Place nssm.exe in this folder and run again
    pause
    exit /b 1
)

:: Install service
echo [3/3] Installing Windows Service...
nssm install DentalClinicAPI "%CD%\target\dentalclinic-api-0.0.1-SNAPSHOT.jar"
nssm set DentalClinicAPI AppDirectory "%CD%"
nssm set DentalClinicAPI DisplayName "Dental Clinic API Server"
nssm set DentalClinicAPI Description "REST API for Dental Clinic Management System"
nssm set DentalClinicAPI Start SERVICE_AUTO_START

echo.
echo ====================================
echo Service installed successfully!
echo ====================================
echo.
echo To start: nssm start DentalClinicAPI
echo To stop: nssm stop DentalClinicAPI
echo To uninstall: nssm remove DentalClinicAPI confirm
echo.
echo Starting service now...
nssm start DentalClinicAPI

echo.
echo API is now running at: http://localhost:8080
pause
