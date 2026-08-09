# Run as Administrator on Windows Server 2025
# Usage: .\01-install-sql.ps1 -SaPassword (Read-Host -AsSecureString "SA Password")
param(
  [Parameter(Mandatory)][SecureString]$SaPassword
)
$ErrorActionPreference = "Stop"
$saPass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SaPassword)
)
Write-Host "Downloading SQL Server Express 2022..."
$url  = "https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x409&culture=en-us&country=us"
$path = "$env:TEMP\SQLServerExpress.exe"
Invoke-WebRequest -Uri $url -OutFile $path -UseBasicParsing
Write-Host "Installing (silent)..."
& $path /Action=Install /IAcceptSqlServerLicenseTerms /Quiet /HideProgressBar
Write-Host "Enabling TCP/IP on port 1433..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer" -Name "LoginMode" -Value 2
$smo = "Microsoft.SqlServer.Management.Smo.Wmi"
[System.Reflection.Assembly]::LoadWithPartialName($smo) | Out-Null
$wmi = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
$tcp = $wmi.ServerInstances["SQLEXPRESS"].ServerProtocols["Tcp"]
$tcp.IsEnabled = $true
$tcp.IPAddresses["IPAll"].IPAddressProperties["TcpPort"].Value = "1433"
$tcp.IPAddresses["IPAll"].IPAddressProperties["TcpDynamicPorts"].Value = ""
$tcp.Alter()
Restart-Service "MSSQL`$SQLEXPRESS" -Force
Write-Host "SQL Server Express running on 1433. Mixed Mode auth enabled."
