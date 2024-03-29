USE [master];
GO
IF DB_ID('LazyWrites') IS NOT NULL
BEGIN
	ALTER DATABASE [LazyWrites] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [LazyWrites];
END
GO
CREATE DATABASE [LazyWrites] ON  PRIMARY 
( NAME = N'LazyWrites', FILENAME = N'C:\SQLData\LazyWrites.mdf' , SIZE = 65536KB , FILEGROWTH = 32768KB )
 LOG ON 
( NAME = N'LazyWrites_log', FILENAME = N'C:\SQLData\LazyWrites_log.ldf' , SIZE = 32768KB , FILEGROWTH = 32768KB )
GO
ALTER DATABASE [LazyWrites] SET RECOVERY SIMPLE; 
GO
USE [LazyWrites]
GO
CREATE TABLE dbo.InsertTable
(ROWID INT IDENTITY PRIMARY KEY,
 DATA NCHAR(4000) DEFAULT '123' NOT NULL)
GO

-- Set Max Server Memory to 2GB
EXEC sys.sp_configure N'show advanced options', N'1'; 
RECONFIGURE;
EXEC sys.sp_configure N'max server memory (MB)', N'2048';
RECONFIGURE;
EXEC sys.sp_configure N'show advanced options', N'0';
RECONFIGURE;
