/*============================================================================
  File:     CircularLog.sql

  Summary:  This script shows how a transaction
			log is circular in nature and how it
			can skip active VLFs

  SQL Server Versions: 2005 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2013, SQLskills.com. All rights reserved.

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

IF DATABASEPROPERTYEX (N'DBMaint2008', N'Version') > 0
BEGIN
	ALTER DATABASE [DBMaint2008] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [DBMaint2008];
END
GO

CREATE DATABASE [DBMaint2008] ON PRIMARY (
    NAME = N'DBMaint2008_data',
    FILENAME = N'D:\SQLskills\DBMaint2008_data.mdf')
LOG ON (
    NAME = N'DBMaint2008_log',
    FILENAME = N'D:\SQLskills\DBMaint2008_log.ldf',
    SIZE = 5MB,
    FILEGROWTH = 1MB);
GO

USE [DBMaint2008];
GO
SET NOCOUNT ON;
GO

-- Make sure the database is in SIMPLE
-- recovery model
ALTER DATABASE [DBMaint2008] SET RECOVERY SIMPLE;
GO

-- What does the log look like?
DBCC LOGINFO;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO

-- Insert some rows to fill the first
-- two VLFs and start on the third
INSERT INTO [BigRows] DEFAULT VALUES;
GO 300

-- What does the log look like now?
DBCC LOGINFO;
GO

-- Now start an explicit transaction which
-- will hold VLF 3 and onwards active
BEGIN TRAN
INSERT INTO [BigRows] DEFAULT VALUES;
GO

-- Now checkpoint to clear the first two
-- VLFs and look at the log again
CHECKPOINT;
GO

DBCC LOGINFO;
GO

-- Now add some more rows that will fill
-- up VLFs 3 and 4 and then wrap around
INSERT INTO [BigRows] DEFAULT VALUES;
GO 300 

DBCC LOGINFO;
GO

-- Now add some more rows - the log is
-- forced to grow. What do the VLF
-- sequence numbers look like?
INSERT INTO [BigRows] DEFAULT VALUES;
GO 300 

DBCC LOGINFO;
GO

-- Will checkpoint clear it now?
CHECKPOINT;
GO

DBCC LOGINFO;
GO

-- Look at the amount of log used
DBCC SQLPERF (LOGSPACE);
GO

-- How about now?
COMMIT TRAN;
GO

DBCC LOGINFO;
GO

-- Look at the amount of log used
-- What happened?
DBCC SQLPERF (LOGSPACE);
GO

-- How about now?
CHECKPOINT;
GO

DBCC LOGINFO;
GO
