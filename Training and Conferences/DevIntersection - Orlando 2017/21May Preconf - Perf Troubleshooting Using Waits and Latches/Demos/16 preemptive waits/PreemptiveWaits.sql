/*============================================================================
  File:     PreemptiveSetup.sql

  Summary:  Create some preemptive waits

  SQL Server Versions: 2008 onwards
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

-- sp_configure 'filestream_access_level', 2; reconfigure;

USE [master];
GO

IF DATABASEPROPERTYEX (N'FSWaits', N'Version') > 0
BEGIN
	ALTER DATABASE [FSWaits] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FSWaits];
END
GO

CREATE DATABASE [FSWaits] ON PRIMARY (
    NAME = N'FSWaits_data',
    FILENAME = N'D:\SQLskills\FSWaits_data.mdf'),
FILEGROUP [FileStreamFileGroup] CONTAINS FILESTREAM
  ( NAME = N'FSWaitsDocuments',
    FILENAME = N'C:\SQLskills\Documents')
LOG ON (
    NAME = N'FSWaits_log',
    FILENAME = N'C:\SQLskills\FSWaits_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

-- Create a table with a FILESTREAM column
USE [FSWaits];
GO

CREATE TABLE [FileStreamTest1] (
	[DocId]		UNIQUEIDENTIFIER ROWGUIDCOL NOT NULL UNIQUE,
	[DocName]	VARCHAR (25),
	[Document]	VARBINARY(MAX) FILESTREAM);
GO

-- Clear wait stats in WaitStats1.sql

-- Loop creating files
SET NOCOUNT ON;
GO
WHILE (1=1)
BEGIN
	INSERT INTO [FileStreamTest1] VALUES
		(NEWID (),
		'MyDoc',
		CAST ('SQLskills' AS VARBINARY (MAX)));
END;
GO

-- Examine waits in WaitingTasks.sql
-- Examine waits in WaitStats1.sql

-- Stop the test

-- DON'T FORGET DEMO PART BELOW!!

-- Clear waits in WaitStats1.sql

USE [master];
GO

IF DATABASEPROPERTYEX (N'FSWaits', N'Version') > 0
BEGIN
	ALTER DATABASE [FSWaits] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [FSWaits];
END
GO

-- Examine waits in WaitStats1.sql
