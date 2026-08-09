# Run as Administrator on Windows Server 2025
# Usage: .\04-create-db-user.ps1 -DbPassword (Read-Host -AsSecureString "DB Password")
param(
  [string]$SqlInstance   = "localhost\SQLEXPRESS",
  [string]$DbName        = "labdb",
  [string]$SqlUser       = "labuser",
  [Parameter(Mandatory)][SecureString]$DbPassword
)
$ErrorActionPreference = "Stop"
$sqlcmd = Get-ChildItem "C:\Program Files\Microsoft SQL Server" -Recurse -Filter "SQLCMD.EXE" |
  Select-Object -First 1 -ExpandProperty FullName
$pass = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($DbPassword)
)
& $sqlcmd -S $SqlInstance -E -No -C -Q "IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = '$DbName') CREATE DATABASE [$DbName];"
& $sqlcmd -S $SqlInstance -E -No -C -Q "USE [$DbName]; IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = '$SqlUser') CREATE LOGIN [$SqlUser] WITH PASSWORD = '$pass';"
& $sqlcmd -S $SqlInstance -E -No -C -Q "USE [$DbName]; IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = '$SqlUser') BEGIN CREATE USER [$SqlUser] FOR LOGIN [$SqlUser]; ALTER ROLE db_datareader ADD MEMBER [$SqlUser]; ALTER ROLE db_datawriter ADD MEMBER [$SqlUser]; END"
& $sqlcmd -S $SqlInstance -E -No -C -Q "USE [$DbName]; IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='products' AND xtype='U') BEGIN CREATE TABLE products (id INT IDENTITY(1,1) PRIMARY KEY, name NVARCHAR(100) NOT NULL, price DECIMAL(10,2) NOT NULL, created_at DATETIME DEFAULT GETDATE()); INSERT INTO products (name, price) VALUES ('Croissant',2.50),('Sourdough',6.00),('Cinnamon Roll',3.25); END"
Write-Host "Database, user, and products table ready."
