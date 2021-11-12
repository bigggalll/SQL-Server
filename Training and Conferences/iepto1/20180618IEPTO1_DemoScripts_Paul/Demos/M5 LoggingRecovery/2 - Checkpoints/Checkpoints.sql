/*============================================================================
 File: Checkpoints.sql 

 Summary: This script shows checkpoint tracing using trace flags
		and the transaction log
	
------------------------------------------------------------------------------
 Copyright (C) 2018 Paul S. Randal, SQLskills.com

 All rights reserved. 

 For more scripts and sample code, check out
	http://www.sqlskills.com/ 

 You may alter this code for your own *non-commercial* purposes. You may
 republish altered code as long as you give due credit. 

 THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF
 ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED
 TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
 PARTICULAR PURPOSE.
============================================================================*/ 

USE [master];
GO

IF DATABASEPROPERTYEX (N'CheckpointTest', N'Version') > 0
BEGIN
	ALTER DATABASE [CheckpointTest] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [CheckpointTest];
END
GO

CREATE DATABASE [CheckpointTest] ON PRIMARY (
    NAME = N'CheckpointTest_data',
    FILENAME = N'D:\SQLskills\CheckpointTest_data.mdf')
LOG ON (
    NAME = N'CheckpointTest_log',
    FILENAME = N'C:\SQLskills\CheckpointTest_log.ldf',
    SIZE = 250MB,
    FILEGROWTH = 20MB);
GO

USE [CheckpointTest];
GO

-- Create a table that will grow very
-- quickly and generate lots of transaction
-- log
CREATE TABLE [BigRows] (
	[c1] INT IDENTITY,
	[c2] CHAR (8000) DEFAULT 'a');
GO

-- Make sure the database is in SIMPLE
-- recovery model
ALTER DATABASE [CheckpointTest] SET RECOVERY SIMPLE;
GO

-- Startup perfmon with checkpoint pages/sec

-- Run the large insert in the second window...

-- Trace CHECKPOINT execution
DBCC TRACEON (3605, -1);
DBCC TRACEON (3502, -1);
DBCC TRACEON (3504, -1);
GO

EXEC xp_readerrorlog;
GO

-- *** Stop the workload ***

-- What about in the log?
BEGIN TRAN [Paul];
GO
INSERT INTO [CheckpointTest].[dbo].[BigRows] DEFAULT VALUES;
GO

CHECKPOINT;
GO

-- Find LSN of the open transaction
-- Look for byte-reversed LSN in the checkpoint
-- payload log record
SELECT * FROM fn_dblog (NULL, NULL)
WHERE [Transaction Name] LIKE 'Paul';

SELECT * FROM fn_dblog (NULL, NULL)
WHERE [Operation] LIKE '%CKPT%';
GO

-- Clean up
COMMIT TRAN;
GO

DBCC TRACEOFF (3605, -1);
DBCC TRACEOFF (3502, -1);
DBCC TRACEOFF (3504, -1);
GO