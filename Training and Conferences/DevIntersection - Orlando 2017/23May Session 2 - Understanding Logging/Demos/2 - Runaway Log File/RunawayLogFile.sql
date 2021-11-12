/*============================================================================
  File:     RunawayLogFile.sql

  Summary:  This script shows how a transaction
			log can grow out of control if it
			is mis-managed

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

CREATE DATABASE [DBMaint2008];
GO
USE [DBMaint2008];
GO
SET NOCOUNT ON;
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO

-- Make sure the database is in FULL
-- recovery model
ALTER DATABASE [DBMaint2008] SET RECOVERY FULL;
GO

-- In another window, run LoopInserts.sql

-- Go to perfmon and monitor the log
-- Set scale for size and used size to 0.01

-- Watch the saw-tooth - even though we're in
-- FULL recovery mode, the log is being cleared
-- We're actually in pseudo-simple until a full
-- database backup is taken

BACKUP DATABASE [DBMaint2008] TO
	DISK = N'C:\SQLskills\DBMaint2008.bck'
	WITH INIT, STATS;
GO

-- Now the log is out of control...
-- Change comment out the  waitfor and set the
-- counters to 0.0001

-- Log size is hundreds of MB!

-- What's causing the log to not be cleared?
SELECT [log_reuse_wait_desc]
	FROM [master].[sys].[databases]
	WHERE [name] = N'DBMaint2008';
GO

-- So let's do one
BACKUP LOG [DBMaint2008] TO
	DISK = N'C:\SQLskills\DBMaint2008_log.bck'
	WITH STATS;
GO

-- Note counters.....