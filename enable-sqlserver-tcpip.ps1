# Enable TCP/IP for SQL Server
# Run this script as Administrator

Write-Host "=== Enabling TCP/IP for SQL Server ===" -ForegroundColor Cyan

# Load SQL Server WMI Provider
try {
    # Try to load the SQL Server WMI module
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
    
    # Get the ManagedComputer object
    $wmi = New-Object('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer')
    
    # Enable TCP/IP for MSSQLSERVER (default instance)
    Write-Host "Looking for SQL Server instances..." -ForegroundColor Yellow
    
    $instances = @("MSSQLSERVER", "SQLEXPRESS")
    
    foreach ($instanceName in $instances) {
        try {
            Write-Host "`nProcessing instance: $instanceName" -ForegroundColor Yellow
            
            $uri = "ManagedComputer[@Name='$env:COMPUTERNAME']/ServerInstance[@Name='$instanceName']/ServerProtocol[@Name='Tcp']"
            $tcp = $wmi.GetSmoObject($uri)
            
            if ($tcp) {
                Write-Host "Current TCP/IP status: $($tcp.IsEnabled)" -ForegroundColor Gray
                
                if (-not $tcp.IsEnabled) {
                    $tcp.IsEnabled = $true
                    $tcp.Alter()
                    Write-Host "✓ TCP/IP enabled for $instanceName" -ForegroundColor Green
                } else {
                    Write-Host "✓ TCP/IP already enabled for $instanceName" -ForegroundColor Green
                }
                
                # Display IP addresses and ports
                Write-Host "  IP Addresses configured:" -ForegroundColor Gray
                foreach ($ip in $tcp.IPAddresses) {
                    if ($ip.IPAddressProperties['Enabled'].Value) {
                        $ipAddr = $ip.IPAddressProperties['IPAddress'].Value
                        $port = $ip.IPAddressProperties['TcpPort'].Value
                        Write-Host "    - $ipAddr : $port" -ForegroundColor Gray
                    }
                }
            }
        } catch {
            Write-Host "  Instance $instanceName not found or not accessible" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "`n=== Restarting SQL Server Services ===" -ForegroundColor Cyan
    
    foreach ($instanceName in $instances) {
        $serviceName = if ($instanceName -eq "MSSQLSERVER") { "MSSQLSERVER" } else { "MSSQL`$$instanceName" }
        
        $service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
        
        if ($service) {
            Write-Host "`nRestarting service: $serviceName" -ForegroundColor Yellow
            
            if ($service.Status -eq 'Running') {
                Stop-Service -Name $serviceName -Force
                Write-Host "  Stopped $serviceName" -ForegroundColor Gray
            }
            
            Start-Service -Name $serviceName
            Write-Host "  Started $serviceName" -ForegroundColor Green
        }
    }
    
    Write-Host "`n=== Testing Connection ===" -ForegroundColor Cyan
    Start-Sleep -Seconds 3
    
    Write-Host "Testing connection to localhost,1433 with sa account..." -ForegroundColor Yellow
    sqlcmd -S localhost,1433 -U sa -P admin123 -Q "SELECT @@VERSION" -C
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✓ TCP/IP connection successful!" -ForegroundColor Green
    } else {
        Write-Host "`n✗ Connection failed. Please check SQL Server Configuration Manager manually." -ForegroundColor Red
    }
    
} catch {
    Write-Host "`n✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nManual steps:" -ForegroundColor Yellow
    Write-Host "1. Open SQL Server Configuration Manager" -ForegroundColor White
    Write-Host "2. Go to: SQL Server Network Configuration > Protocols for MSSQLSERVER" -ForegroundColor White
    Write-Host "3. Right-click TCP/IP > Enable" -ForegroundColor White
    Write-Host "4. Restart SQL Server service" -ForegroundColor White
    Write-Host "`nOr run as Administrator:" -ForegroundColor Yellow
    Write-Host "  Start-Process PowerShell -Verb RunAs -ArgumentList '-File', '$PSCommandPath'" -ForegroundColor White
}
