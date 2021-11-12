/*============================================================================
  File:     ExamineFragmentation.sql

  Summary:  This script examines fragmentation in a database
		and shows the IO difference between the DMV options

  SQL Server Versions: 2008 onwards
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2018, SQLskills.com. All rights reserved.

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

/*  Cleanup old files
EXECUTE sp_configure N'show advanced options', 1; RECONFIGURE;
EXECUTE sp_configure N'xp_cmdshell', 1; RECONFIGURE; 
EXEC xp_cmdshell N'DEL C:\SQLskills\EE_WatchIOs*';
EXECUTE sp_configure N'xp_cmdshell', 0; RECONFIGURE;
EXECUTE sp_configure N'show advanced options', 0; RECONFIGURE;
*/

USE [GUIDTest];
GO

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE [name] = N'EE_WatchIOs')
    DROP EVENT SESSION [EE_WatchIOs] ON SERVER;
GO

-- Create the event session
CREATE EVENT SESSION [EE_WatchIOs] ON SERVER
ADD EVENT [sqlserver].[sql_statement_completed]
	(ACTION ([sqlserver].[sql_text]))
ADD TARGET [package0].[asynchronous_file_target]
    (SET FILENAME = N'C:\SQLskills\EE_WatchIOs.xel', 
    METADATAFILE = N'C:\SQLskills\EE_WatchIOs.xem')
	-- METADATAFILE not needed from 2012 onwards
WITH (max_dispatch_latency = 1 seconds);
GO

-- Start the session
ALTER EVENT SESSION [EE_WatchIOs] ON SERVER
STATE = START;
GO

-- With DETAILED option
SELECT * FROM sys.dm_db_index_physical_stats (
	DB_ID (N'GUIDTest'),
	NULL,
	NULL,
	NULL,
	N'DETAILED');
GO

-- And now with the SAMPLED option
SELECT * FROM sys.dm_db_index_physical_stats (
	DB_ID (N'GUIDTest'),
	NULL,
	NULL,
	NULL,
	N'SAMPLED');
GO

-- And now with the LIMITED option
SELECT * FROM sys.dm_db_index_physical_stats (
	DB_ID (N'GUIDTest'),
	NULL,
	NULL,
	NULL,
	N'LIMITED');
GO

-- Stop the event session and examine the IOs
ALTER EVENT SESSION [EE_WatchIOs] ON SERVER
STATE = STOP;
GO

-- And now extract everything nicely: 2012+
SELECT
	[data].[value] (
		'(/event[@name=''sql_statement_completed'']/@timestamp)[1]',
			'DATETIME') AS [Time],
	[data].[value] (
		'(/event/data[@name=''duration'']/value)[1]', 'INT') / 1000 AS [Duration (ms)],
	[data].[value] (
		'(/event/data[@name=''logical_reads'']/value)[1]', 'BIGINT') AS [Logical Reads],
	[data].[value] (
		'(/event/data[@name=''physical_reads'']/value)[1]', 'BIGINT') AS [Physical Reads],
	[data].[value] (
		'(/event/action[@name=''sql_text'']/value)[1]',
			'VARCHAR(MAX)') AS [SQL Statement]
FROM 
	(SELECT CONVERT (XML, [event_data]) AS [data]
	FROM sys.fn_xe_file_target_read_file
		(N'C:\SQLskills\EE_WatchIOs*.xel',
		N'C:\SQLskills\EE_WatchIOs*.xem', null, null)
	) [entries]
ORDER BY [Time] DESC
GO

-- And now extract everything nicely: pre-2012
SELECT
	[data].[value] (
		'(/event[@name=''sql_statement_completed'']/@timestamp)[1]',
			'DATETIME') AS [Time],
	[data].[value] (
		'(/event/data[@name=''cpu'']/value)[1]', 'INT') AS [CPU (ms)],
	[data].[value] (
		'(/event/data[@name=''reads'']/value)[1]', 'BIGINT') AS [Reads],
	[data].[value] (
		'(/event/action[@name=''sql_text'']/value)[1]',
			'VARCHAR(MAX)') AS [SQL Statement]
FROM 
	(SELECT CONVERT (XML, [event_data]) AS [data]
	FROM sys.fn_xe_file_target_read_file
		(N'C:\SQLskills\EE_WatchIOs*.xel',
		N'C:\SQLskills\EE_WatchIOs*.xem', null, null)
	) [entries]
ORDER BY [Time] DESC;
GO

-- And now with a bit more useful info
SELECT
	OBJECT_NAME ([ips].[object_id]) AS [Object Name],
	[si].[name] AS [Index Name],
	ROUND ([ips].[avg_fragmentation_in_percent], 2) AS [Fragmentation],
	[ips].[page_count] AS [Pages],
	ROUND ([ips].[avg_page_space_used_in_percent], 2) AS [Page Density]
FROM sys.dm_db_index_physical_stats (
	DB_ID (N'GUIDTest'),
	NULL,
	NULL,
	NULL,
	N'DETAILED') [ips]
CROSS APPLY [sys].[indexes] [si]
WHERE
	[si].[object_id] = [ips].[object_id]
	AND [si].[index_id] = [ips].[index_id]
	AND [ips].[index_level] = 0
GO

