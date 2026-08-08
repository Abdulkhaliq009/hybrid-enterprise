# Backup and Restore Procedures

## What is backed up

| Asset | Method | Schedule | Retention |
|---|---|---|---|
| SQL databases | SQL native backup to disk + copy to Azure via AzCopy | Daily 02:00 | 7d (dev) / 30d (prod) |
| Azure VMs (if any) | Recovery Services vault policy | Daily 02:00 | 7d / 30d + 4 weekly |
| Terraform state | Azure Storage versioning on the state container | Continuous | 30 versions |
| Cluster config | Helm values + manifests in Git | Every commit | Full history |

## SQL backup script (runs on Windows Server via Task Scheduler)

```powershell
$stamp = Get-Date -Format "yyyyMMdd-HHmm"
sqlcmd -S localhost\SQLEXPRESS -E -Q "BACKUP DATABASE [labdb] TO DISK='C:\Backups\labdb-$stamp.bak' WITH COMPRESSION"
azcopy copy "C:\Backups\labdb-$stamp.bak" "https://<storage>.blob.core.windows.net/sqlbackups/?<sas>"
```

## Restore procedure (the RTO-critical path)

```powershell
# 1. Get the newest backup
azcopy copy "https://<storage>.blob.core.windows.net/sqlbackups/<newest>.bak" "C:\Restore\"

# 2. Restore
sqlcmd -S localhost\SQLEXPRESS -E -Q "RESTORE DATABASE [labdb] FROM DISK='C:\Restore\<newest>.bak' WITH REPLACE"

# 3. Verify row counts
sqlcmd -S localhost\SQLEXPRESS -E -Q "SELECT COUNT(*) FROM labdb.dbo.products"
```

Practice this quarterly. An untested backup is a rumor.
