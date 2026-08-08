$SqlInstance = "localhost\SQLEXPRESS"
$query = @"
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'labdb')
  CREATE DATABASE [labdb];
GO
USE [labdb];
GO
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'labuser')
  CREATE LOGIN [labuser] WITH PASSWORD = 'ChangeMe123!';
GO
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'labuser')
BEGIN
  CREATE USER [labuser] FOR LOGIN [labuser];
  ALTER ROLE db_datareader ADD MEMBER [labuser];
  ALTER ROLE db_datawriter ADD MEMBER [labuser];
END
GO
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='products' AND xtype='U')
BEGIN
  CREATE TABLE products (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
  );
  INSERT INTO products (name, price) VALUES ('Croissant',2.50),('Sourdough',6.00),('Cinnamon Roll',3.25);
END
GO
"@
sqlcmd -S $SqlInstance -E -Q $query
Write-Host "labdb, labuser, products table ready."
