# Manual Steps to Enable TCP/IP for SQL Server

## Problem
Spring Boot application cannot connect to SQL Server because TCP/IP is disabled.

Error message:
```
The TCP/IP connection to the host ., port 1433 has failed.
```

## Solution: Enable TCP/IP

### Method 1: Using SQL Server Configuration Manager (Recommended)

1. **Open SQL Server Configuration Manager**
   - Press `Win + R`
   - Type: `SQLServerManager16.msc` (for SQL Server 2022)
   - Or search for "SQL Server Configuration Manager" in Start Menu

2. **Navigate to Protocols**
   - Expand **SQL Server Network Configuration**
   - Click on **Protocols for MSSQLSERVER** (default instance)

3. **Enable TCP/IP**
   - Right-click on **TCP/IP**
   - Select **Enable**
   - Click **OK** on the warning dialog

4. **Configure TCP/IP Port (Optional)**
   - Right-click on **TCP/IP** again
   - Select **Properties**
   - Go to **IP Addresses** tab
   - Scroll to **IPAll** section at the bottom
   - Set **TCP Port** to `1433` (if not already set)
   - Click **OK**

5. **Restart SQL Server Service**
   - In Configuration Manager, go to **SQL Server Services**
   - Right-click on **SQL Server (MSSQLSERVER)**
   - Select **Restart**
   - Wait for service to fully restart (status = Running)

### Method 2: Using PowerShell (Run as Administrator)

```powershell
# Enable TCP/IP
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement") | Out-Null
$wmi = New-Object('Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer')
$uri = "ManagedComputer[@Name='$env:COMPUTERNAME']/ServerInstance[@Name='MSSQLSERVER']/ServerProtocol[@Name='Tcp']"
$tcp = $wmi.GetSmoObject($uri)
$tcp.IsEnabled = $true
$tcp.Alter()

# Restart SQL Server
Restart-Service -Name MSSQLSERVER -Force
```

### Method 3: Using Command Line (Run as Administrator)

```cmd
:: Restart SQL Server after enabling TCP/IP in Configuration Manager
net stop MSSQLSERVER
net start MSSQLSERVER
```

## Verify Connection

After enabling TCP/IP and restarting the service, test the connection:

```powershell
# Test with sqlcmd
sqlcmd -S localhost,1433 -U sa -P admin123 -Q "SELECT @@VERSION" -C

# Or test with telnet
telnet localhost 1433
```

If the connection works, you should see SQL Server version information.

## Alternative: Use Named Pipes (If TCP/IP Cannot Be Enabled)

If you cannot enable TCP/IP, update `application.yml` to use Named Pipes:

```yaml
spring:
  datasource:
    url: jdbc:sqlserver://(local);databaseName=dentalclinic_db;integratedSecurity=false;encrypt=false;trustServerCertificate=true
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

**Note**: Named Pipes may be slower than TCP/IP for network connections.

## Firewall Configuration (If Still Not Working)

If connection still fails after enabling TCP/IP:

1. Open **Windows Defender Firewall**
2. Click **Advanced settings**
3. Click **Inbound Rules** > **New Rule**
4. Select **Port** > **Next**
5. Select **TCP** and enter **1433** > **Next**
6. Select **Allow the connection** > **Next**
7. Check all profiles > **Next**
8. Name: "SQL Server TCP Port 1433" > **Finish**

## Expected Result

After completing these steps, your Spring Boot application should connect successfully:

```
HikariPool-1 - Starting...
HikariPool-1 - Start completed.
Hibernate: 
    create table users (...)
```

## Troubleshooting

### Check if SQL Server is listening on port 1433:
```powershell
netstat -an | findstr "1433"
```

Expected output:
```
TCP    0.0.0.0:1433           0.0.0.0:0              LISTENING
TCP    [::]:1433              [::]:0                 LISTENING
```

### Check SQL Server service status:
```powershell
Get-Service -Name MSSQLSERVER
```

Expected status: **Running**

### Check SQL Server logs:
- Location: `C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Log\ERRORLOG`
- Look for: "Server is listening on [ 'any' <ipv4> 1433]"
