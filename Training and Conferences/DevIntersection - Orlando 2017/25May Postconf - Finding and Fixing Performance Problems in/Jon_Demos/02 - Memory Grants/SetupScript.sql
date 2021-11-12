USE master;
GO
IF DB_ID('ExecutionMemory') IS NOT NULL
BEGIN
	ALTER DATABASE ExecutionMemory SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE ExecutionMemory;
END
GO
CREATE DATABASE ExecutionMemory;
GO
USE ExecutionMemory;
GO
CREATE TABLE Test
(RowID INT IDENTITY, ParentID INT, CurrentValue NVARCHAR(100),
CONSTRAINT PK_Test PRIMARY KEY CLUSTERED 
( RowID ));
GO
INSERT INTO Test(ParentID, CurrentValue)
SELECT 
	CASE WHEN (t1.number%3 = 0) THEN t1.number-t1.number%6 ELSE t1.number END, 
	'Test'+CAST(t1.number%2 AS VARCHAR)
FROM master.dbo.spt_values AS t1
WHERE t1.type = 'P'
GO
CREATE TABLE Test2
(RowID INT IDENTITY, ParentID INT, CurrentValue NVARCHAR(100),
CONSTRAINT PK_Test2 PRIMARY KEY CLUSTERED 
( RowID ));
GO
INSERT INTO Test2(ParentID, CurrentValue)
SELECT 
	CASE WHEN (t1.number%3 = 0) THEN t1.number-t1.number%6 ELSE t1.number END, 
	'Test'+CAST(t1.number%2 AS VARCHAR)
FROM master.dbo.spt_values AS t1
WHERE t1.type = 'P'
GO
-- Skew stats on Test to make it use estimate large memory grant
UPDATE STATISTICS Test ([PK_Test]) WITH ROWCOUNT = 10000000, PAGECOUNT = 1000000
GO

CHECKPOINT;



-- Set Max Server Memory to 1GB
EXEC sys.sp_configure N'show advanced options', N'1'; 
RECONFIGURE;
EXEC sys.sp_configure N'max server memory (MB)', N'1024';
RECONFIGURE;
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE;
