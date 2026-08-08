# Run as Administrator on Windows Server 2025
$ErrorActionPreference = "Stop"
Write-Host "Downloading SQL Server Express 2022..."
$url  = "https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x409&culture=en-us&country=us"
$path = "$env:TEMP\SQLServerExpress.exe"
Invoke-WebRequest -Uri $url -OutFile $path
Write-Host "Installing (silent)..."
& $path /ACTION=Install /FEATURES=SQLEngine /INSTANCENAME=SQLEXPRESS `
  /SECURITYMODE=SQL /SAPWD="LabPassword123!" `
  /SQLSYSADMINACCOUNTS="BUILTIN\Administrators" `
  /IACCEPTSQLSERVERLICENSETERMS /QUIET
Write-Host "Enabling TCP/IP 1433..."
$wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
$tcp = $wmi.ServerInstances["SQLEXPRESS"].ServerProtocols["Tcp"]
$tcp.IsEnabled = $true
$tcp.IPAddresses["IPAll"].IPAddressProperties["TcpPort"].Value = "1433"
$tcp.Alter()
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
Write-Host "SQL Server Express running on 1433."
