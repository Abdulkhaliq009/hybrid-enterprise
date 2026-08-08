# PowerShell DSC baseline for Windows Server 2025
$ErrorActionPreference = "Stop"

Configuration HybridServerBaseline {
  Import-DscResource -ModuleName PSDesiredStateConfiguration

  Node "localhost" {
    Service SQLServerExpress {
      Name        = "MSSQL`$SQLEXPRESS"
      State       = "Running"
      StartupType = "Automatic"
    }

    WindowsFeature RemoteAccess {
      Name   = "RemoteAccess"
      Ensure = "Present"
    }

    Registry DisableSMBv1 {
      Key       = "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters"
      ValueName = "SMB1"
      ValueData = "0"
      ValueType = "Dword"
      Ensure    = "Present"
    }

    Registry EnableAuditLogon {
      Key       = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
      ValueName = "auditbaseobjects"
      ValueData = "1"
      ValueType = "Dword"
      Ensure    = "Present"
    }
  }
}

HybridServerBaseline -OutputPath "C:\DSC\HybridServerBaseline"
Start-DscConfiguration -Path "C:\DSC\HybridServerBaseline" -Wait -Verbose -Force
Write-Host "DSC applied. Verify: Test-DscConfiguration"
