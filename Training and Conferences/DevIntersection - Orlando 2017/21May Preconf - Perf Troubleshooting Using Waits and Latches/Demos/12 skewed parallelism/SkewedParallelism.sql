/*============================================================================
  File:     SkewedParallelism.sql

  Summary:  Show CXPACKET waits on non-control thread and RESOURCE_SEMAPHORE

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

IF DB_ID (N'ExecutionMemory') IS NOT NULL
BEGIN
	ALTER DATABASE [ExecutionMemory] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [ExecutionMemory];
END
GO

CREATE DATABASE [ExecutionMemory];
GO
USE [ExecutionMemory];
GO

-- Create a simple table to use and populate it
CREATE TABLE [Test] (
	[RowID] INT IDENTITY,
	[ParentID] INT,
	[CurrentValue] NVARCHAR (100),
	CONSTRAINT [PK_Test] PRIMARY KEY CLUSTERED ([RowID]));
GO

INSERT INTO [Test] ([ParentID], [CurrentValue])
SELECT 
	CASE WHEN ([t1].[number] % 3 = 0)
		THEN [t1].[number] - [t1].[number] % 6
		ELSE [t1].[number] END, 
	'Test' + CAST ([t1].[number] % 2 AS VARCHAR)
FROM [master].[dbo].[spt_values] AS [t1]
WHERE [t1].[type] = 'P';
GO

-- Skew stats on Test to make it use estimate large memory grant
UPDATE STATISTICS [Test] ([PK_Test]) WITH ROWCOUNT = 10000000, PAGECOUNT = 1000000;
GO

CHECKPOINT;
GO

-- Start the workload

-- Look at waiting tasks

-- Run WorkerQueryForQueryPlan with Actual Plan
-- Look at Properties for arrow from Scan, row distribution

-- ** EXPLAIN MULTIPLE ROWS FOR SAME THREAD IN WAITING TASKS **

-- Rerun without the stats update
