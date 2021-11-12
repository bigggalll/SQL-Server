-- Setup script for Running Repair demo

USE [master];
GO

IF DATABASEPROPERTYEX (N'Company', N'Version') > 0
BEGIN
	ALTER DATABASE [Company] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company];
END
GO

IF DATABASEPROPERTYEX (N'Company2', N'Version') > 0
BEGIN
	ALTER DATABASE [Company2] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company2];
END
GO

IF DATABASEPROPERTYEX (N'Company3', N'Version') > 0
BEGIN
	ALTER DATABASE [Company3] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [Company3];
END
GO

-- Set up corruption in Company
-- This will be a broken IAM page
CREATE DATABASE [Company] ON PRIMARY (
    NAME = N'Company',
    FILENAME = N'D:\SQLskills\Company.mdf')
LOG ON (
    NAME = N'Company_log',
    FILENAME = N'D:\SQLskills\Company_log.ldf');
GO

USE [Company];
GO

CREATE TABLE [RandomData] (
	[c1]  INT IDENTITY,
	[c2]  CHAR (8000) DEFAULT 'a');
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 10

-- List the pages in the table
DBCC IND (N'Company', N'RandomData', -1);
GO

-- Pick a page to corrupt with type 10
ALTER DATABASE [Company] SET SINGLE_USER;
GO
DBCC WRITEPAGE (N'Company', 1, X, 0, 2, 0x0000, 1);
GO
ALTER DATABASE [Company] SET MULTI_USER;
GO

-- Set up corruption in Company2
-- This will be a broken index page
CREATE DATABASE [Company2] ON PRIMARY (
    NAME = N'Company2',
    FILENAME = N'D:\SQLskills\Company2.mdf')
LOG ON (
    NAME = N'Company2_log',
    FILENAME = N'D:\SQLskills\Company2_log.ldf');
GO

USE [Company2];
GO

CREATE TABLE [RandomData] (
	[c1]  INT IDENTITY,
	[c2]  CHAR (8000) DEFAULT 'a');
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 10

CREATE CLUSTERED INDEX [RandomData_Clustered]
ON [RandomData] ([c1]);
GO

-- List the pages in the table
DBCC IND (N'Company2', N'RandomData', -1);
GO

-- Pick a page to corrupt with type 2
ALTER DATABASE [Company2] SET SINGLE_USER;
GO
DBCC WRITEPAGE (N'Company2', 1, X, 0, 2, 0x0000, 1);
GO
ALTER DATABASE [Company2] SET MULTI_USER;
GO

-- Set up corruption in Company3
-- This will be a broken off-row LOB linkage
CREATE DATABASE [Company3] ON PRIMARY (
    NAME = N'Company3',
    FILENAME = N'D:\SQLskills\Company3.mdf')
LOG ON (
    NAME = N'Company3_log',
    FILENAME = N'D:\SQLskills\Company3_log.ldf');
GO

USE [Company3];
GO

CREATE TABLE [RandomData] (
	[c1]  INT IDENTITY,
	[c2]  VARCHAR (5000) DEFAULT REPLICATE ('a', 5000),
	[c3]  VARCHAR (5000) DEFAULT REPLICATE ('a', 5000));
GO

INSERT INTO [RandomData] DEFAULT VALUES;
GO 10

-- List the pages in the table
DBCC IND (N'Company3', N'RandomData', -1);
GO

-- Pick a page to corrupt with type 3
ALTER DATABASE [Company3] SET SINGLE_USER;
GO
DBCC WRITEPAGE (N'Company3', 1, X, 0, 2, 0x0000, 1);
GO
ALTER DATABASE [Company3] SET MULTI_USER;
GO

-- Clean the error log and suspect_pages
DELETE FROM [msdb].[dbo].[suspect_pages];
EXEC sp_cycle_errorlog;
GO