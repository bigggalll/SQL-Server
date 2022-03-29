USE [master]
GO

CREATE DATABASE [TestDB]
 ON  PRIMARY 
( NAME = N'TestDB', FILENAME = N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\DATA\TestDB.mdf' ,  MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'TestDB_log1', FILENAME = N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\DATA\TestDB_log1.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%), 
( NAME = N'TestDB_log2', FILENAME = N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\DATA\TestDB_log2.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO

USE TestDB
GO

CREATE TABLE TestTable
(
	ID INT IDENTITY(1,1),
	Value BIGINT
)

--Change recovery model for TestDB to FULL (if your model database is in FULL recovery model, TestDB has been already created in this mode)
ALTER DATABASE TestDB SET RECOVERY FULL 

--Getting log files info
DBCC LOGINFO('TestDB')

USE TestDB
GO

--Checking log information before insertion
SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files


--Inserting data into TestTable
;WITH ValueTable AS
(
	SELECT 1 n
	UNION ALL 
	SELECT n+ 1
	FROM ValueTable
	WHERE n < 10000 --Value 10000 is used to facilitate testing process, please be careful in choosing this value for your server to avoid overloading it
) 
INSERT INTO TestTable (Value)
SELECT n
FROM ValueTable 
OPTION (MAXRECURSION 0)


--Checking log information after insertion
SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files

--Getting log files info
DBCC LOGINFO('TestDB')

USE master
GO

--Remove TestDB_log2 file
ALTER DATABASE TestDB REMOVE FILE TestDB_log2

--Full backup
BACKUP DATABASE TestDB TO DISK =N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\backup\TestDB.bak'

--Transaction log backup
BACKUP LOG TestDB TO DISK =N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\backup\TestDB.trn'

--Getting log files info
DBCC LOGINFO('TestDB')


--Remove TestDB_log2 file
ALTER DATABASE TestDB REMOVE FILE TestDB_log2

--Checking log information
SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files

--Transaction log backup
BACKUP LOG TestDB TO DISK =N'C:\MyInstance2019\MSSQL15.MYINSTANCE2019\MSSQL\backup\TestDB.trn'

--Checking log information
SELECT file_id, name, type_desc, physical_name, size, max_size
FROM sys.database_files