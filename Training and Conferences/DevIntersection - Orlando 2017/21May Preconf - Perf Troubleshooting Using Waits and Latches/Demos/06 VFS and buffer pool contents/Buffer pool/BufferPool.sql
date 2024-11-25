/*============================================================================
  File:     BufferPool.sql

  Summary:  Sys.dm_os_buffer_descriptors

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

IF DATABASEPROPERTYEX (N'SalesDB', N'Version') > 0
BEGIN
	ALTER DATABASE [SalesDB] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [SalesDB];
END
GO

-- Make sure to reset the database
RESTORE DATABASE [SalesDB]
	FROM DISK = N'D:\SQLskills\DemoBackups\SalesDB2014.bak'
WITH STATS = 10, REPLACE;
GO

-- Load some data
SELECT COUNT (*) from [SalesDB].[dbo].[Sales];
GO

-- Basic DMV
SELECT * FROM sys.dm_os_buffer_descriptors;
GO

-- Explain about DBID 32767
-- Explain about read_microsec

-- Now to see aggregated by database
SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO 

-- What about getting a view of what's in
-- memory per *table*?
SELECT * FROM sys.dm_os_buffer_descriptors;
GO

-- All we get is an allocation unit ID

-- For a single database, with names
USE [SalesDB];
GO

SELECT
	[o].[name] AS [ObjectName],
	[p].[index_id],
	[i].[name],
	[i].[type_desc],
	[au].[type_desc],
	[DirtyPageCount],
	[CleanPageCount],
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT
		[allocation_unit_id],
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	WHERE [database_id] = DB_ID (N'SalesDB')
	GROUP BY [allocation_unit_id]) AS [buffers]
INNER JOIN sys.allocation_units AS [au]
	ON [au].[allocation_unit_id] = [buffers].[allocation_unit_id]
INNER JOIN sys.partitions AS [p]
	ON [au].[container_id] = [p].[partition_id]
INNER JOIN sys.indexes AS [i]
	ON [i].[index_id] = [p].[index_id]
		AND [p].[object_id] = [i].[object_id]
INNER JOIN sys.objects AS [o]
	ON [o].[object_id] = [i].[object_id]
WHERE [o].[is_ms_shipped] = 0
ORDER BY [ObjectName], [p].[index_id];
GO

-- How about aggregating the empty space?
SELECT * FROM sys.dm_os_buffer_descriptors;
GO

SELECT
	COUNT (*) * 8 / 1024 AS [MBUsed],
	SUM ([free_space_in_bytes]) / (1024 * 1024) AS [MBEmpty]
FROM sys.dm_os_buffer_descriptors;
GO

-- And by database
SELECT 
	(CASE WHEN ([database_id] = 32767)
		THEN N'Resource Database'
		ELSE DB_NAME ([database_id]) END) AS [DatabaseName],
	COUNT (*) * 8 / 1024 AS [MBUsed],
	SUM ([free_space_in_bytes]) / (1024 * 1024) AS [MBEmpty]

FROM sys.dm_os_buffer_descriptors
GROUP BY [database_id];
GO

-- Dropping all pages for a single database
ALTER DATABASE [SalesDB] SET OFFLINE;
GO
ALTER DATABASE [SalesDB] SET ONLINE;
GO

SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO

-- How much data does CHECKDB read in?
DBCC CHECKDB (N'SalesDB');
GO

-- Looks like at least 24000 pages, right?

SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO

-- Well, you cant't tell from this. How about using WITH TABLOCK?

-- How much data does CHECKDB read in?
DBCC CHECKDB (N'SalesDB') WITH TABLOCK;
GO

SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO

-- What about a backup?
BACKUP DATABASE [SalesDB] TO
	DISK = N'C:\SQLskills\TmpSalesDBBackup.bck'
	WITH INIT;
GO

SELECT *,
	[DirtyPageCount] * 8 / 1024 AS [DirtyPageMB],
	[CleanPageCount] * 8 / 1024 AS [CleanPageMB]
FROM
	(SELECT 
		(CASE WHEN ([database_id] = 32767)
			THEN N'Resource Database'
			ELSE DB_NAME ([database_id]) END) AS [DatabaseName], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 1 ELSE 0 END) AS [DirtyPageCount], 
		SUM (CASE WHEN ([is_modified] = 1)
			THEN 0 ELSE 1 END) AS [CleanPageCount]
	FROM sys.dm_os_buffer_descriptors
	GROUP BY [database_id]) AS [buffers]
ORDER BY [DatabaseName]
GO

-- Doesn't use the buffer pool
-- Notice the dirty page count increased?


