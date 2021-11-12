/*============================================================================
  File:     CreateFragmentation.sql

  Summary:  This script shows schemas that can lead to fragmentation

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2016, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

USE [master];
GO

IF DATABASEPROPERTYEX (N'GUIDTest', N'Version') > 0
BEGIN
	ALTER DATABASE [GUIDTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [GUIDTest];
END
GO

CREATE DATABASE [GUIDTest] ON PRIMARY (
    NAME = N'GUIDTest_data',
    FILENAME = N'C:\SQLskills\GUIDTest_data.mdf',
    SIZE = 400MB,
    FILEGROWTH = 25MB)
LOG ON (
    NAME = N'GUIDTest_log',
    FILENAME = N'D:\SQLskills\GUIDTest_log.ldf',
    SIZE = 100MB,
    FILEGROWTH = 5MB);
GO


ALTER DATABASE [GUIDTest] SET RECOVERY SIMPLE;
GO

USE [GUIDTest];
GO

SET NOCOUNT ON;
GO

-- Create a table with a GUID key
CREATE TABLE [BadKeyTable] (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWID (),
    [c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a',
	[c4] VARCHAR(MAX) DEFAULT 'b');
CREATE CLUSTERED INDEX [BadKeyTable_CL] ON
	[BadKeyTable] ([c1]);
CREATE NONCLUSTERED INDEX [BadKeyTable_NCL] ON
	[BadKeyTable] ([c2]);
GO

-- Create another one, but using
-- NEWSEQUENTIALID instead
CREATE TABLE [BetterKeyTable] (
	[c1] UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID (),
    [c2] DATETIME DEFAULT GETDATE (),
	[c3] CHAR (400) DEFAULT 'a',
	[c4] VARCHAR(MAX) DEFAULT 'b');
CREATE CLUSTERED INDEX [BetterKeyTable_CL] ON
	[BetterKeyTable] ([c1]);
CREATE NONCLUSTERED INDEX [BetterKeyTable_NCL] ON
	[BetterKeyTable] ([c2]);
GO

-- Insert 250,000 rows
SET NOCOUNT ON;
GO
DECLARE @a INT;
SELECT @a = 0;
WHILE (@a < 250000)
BEGIN
	INSERT INTO [BetterKeyTable] DEFAULT VALUES;
	SELECT @a = @a + 1;
END;
GO
DECLARE @a INT;
SELECT @a = 0;
WHILE (@a < 250000)
BEGIN
	INSERT INTO [BadKeyTable] DEFAULT VALUES;
	SELECT @a = @a + 1;
END;
GO
