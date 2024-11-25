/*============================================================================
  File:     ExtendedEventsWaits.sql

  Summary:  Setup event monitoring for waits

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

/*  Cleanup old files
EXECUTE sp_configure N'show advanced options', 1; RECONFIGURE;
EXECUTE sp_configure N'xp_cmdshell', 1; RECONFIGURE; 
EXEC xp_cmdshell N'DEL C:\SQLskills\EE_WaitStats*';
EXECUTE sp_configure N'xp_cmdshell', 0; RECONFIGURE;
EXECUTE sp_configure N'show advanced options', 0; RECONFIGURE;
*/

-- How can we find out all the waits for
-- a particular query?
USE [master];
GO

IF DATABASEPROPERTYEX (N'production', N'Version') > 0
BEGIN
	ALTER DATABASE [production] SET SINGLE_USER
		WITH ROLLBACK IMMEDIATE;
	DROP DATABASE [production];
END
GO

CREATE DATABASE [production];
GO

USE [production];
GO

CREATE TABLE [t1] (
	[c1] INT IDENTITY,
	[c2] UNIQUEIDENTIFIER ROWGUIDCOL DEFAULT NEWID(),
	[c3] CHAR (5000) DEFAULT 'a');
CREATE CLUSTERED INDEX [t1_CL] ON [t1] ([c1]);
GO

SET NOCOUNT ON;
INSERT INTO [t1] DEFAULT VALUES;
GO 5000

-- First, what events are there that I can use?
SELECT * FROM sys.dm_xe_objects
	WHERE [object_type] = N'event'
	ORDER BY [name];
GO

-- Need to make sure we have the right package
SELECT [xo].[name], [xo].[description], [xp].[name] AS [package]
	FROM sys.dm_xe_objects [xo]
	JOIN sys.dm_xe_packages [xp]
		ON [xo].[package_guid] = [xp].[guid]
	WHERE [xo].[object_type] = N'event'
	ORDER BY [xo].[name];
GO

-- We're going to wait_info. What columns are there?
SELECT * FROM sys.dm_xe_object_columns
	WHERE [object_name] = N'wait_info';
GO

-- wait_completed added in SQL Server 2014.
-- Better as it only fires once per wait and 
-- includes the wait resource too - but only in 2014


-- What are the 'wait_types' and 'event_opcode' maps?
-- Note: some map_key values changed in 2012 and 2014 
SELECT [xmv].[map_key], [xmv].[map_value]
	FROM sys.dm_xe_map_values [xmv]
	JOIN sys.dm_xe_packages [xp]
		ON [xmv].[object_package_guid] = [xp].[guid]
	WHERE [xmv].[name] = N'wait_types'
	AND [xp].[name] = N'sqlos';
GO

SELECT [xmv].[map_key], [xmv].[map_value]
	FROM sys.dm_xe_map_values [xmv]
	JOIN sys.dm_xe_packages [xp]
		ON [xmv].[object_package_guid] = [xp].[guid]
	WHERE [xmv].[name] = N'event_opcode'
	AND [xp].[name] = N'sqlos';
GO

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE name = N'MonitorWaits')
    DROP EVENT SESSION [MonitorWaits] ON SERVER
GO

-- Get session number of window with RunAQuery.sql in it

-- Create the event session
CREATE EVENT SESSION [MonitorWaits] ON SERVER
ADD EVENT [sqlos].[wait_info]
	(WHERE [sqlserver].[session_id] = 54 /*session_id of new connection*/
	AND [opcode] = 1) -- Just the end-of-wait events
ADD TARGET [package0].[asynchronous_file_target]
    (SET FILENAME = N'C:\SQLskills\EE_WaitStats.xel', 
    METADATAFILE = N'C:\SQLskills\EE_WaitStats.xem')
WITH (max_dispatch_latency = 1 seconds);
GO

-- Start the session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = START;
GO

-- Go do the query

-- Stop the event session
ALTER EVENT SESSION [MonitorWaits] ON SERVER
STATE = STOP;
GO

-- Do we have any rows?
SELECT COUNT (*)
	FROM sys.fn_xe_file_target_read_file
	(N'C:\SQLskills\EE_WaitStats*.xel',
	N'C:\SQLskills\EE_WaitStats*.xem', null, null);
GO

-- Create intermediate temp table for raw event data
CREATE TABLE [##RawEventData] (
	[Rowid]			INT IDENTITY PRIMARY KEY,
	[event_data]	XML);
	
GO

-- Read the file data into intermediate temp table
INSERT INTO [##RawEventData] ([event_data])
SELECT
    CAST ([event_data] AS XML) AS [event_data]
FROM sys.fn_xe_file_target_read_file (
	N'C:\SQLskills\EE_WaitStats*.xel',
	N'C:\SQLskills\EE_WaitStats*.xem', null, null);
GO

-- And now extract everything nicely
SELECT
	[event_data].[value] (
		'(/event/@timestamp)[1]',
			'DATETIME') AS [Time],
	[event_data].[value] (
		'(/event/data[@name=''wait_type'']/text)[1]',
			'VARCHAR(100)') AS [Wait Type],
	[event_data].[value] (
		'(/event/data[@name=''opcode'']/text)[1]',
			'VARCHAR(100)') AS [Op],
	[event_data].[value] (
		'(/event/data[@name=''duration'']/value)[1]',
			'BIGINT') AS [Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''max_duration'']/value)[1]',
			'BIGINT') AS [Max Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''total_duration'']/value)[1]',
			'BIGINT') AS [Total Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''signal_duration'']/value)[1]',
			'BIGINT') AS [Signal Duration (ms)],
	[event_data].[value] (
		'(/event/data[@name=''completed_count'']/value)[1]',
			'BIGINT') AS [Count]
FROM [##RawEventData];
GO

-- And finally, aggregation
SELECT
	[waits].[Wait Type],
	COUNT (*) AS [Wait Count],
	SUM ([waits].[Duration]) AS [Wait (ms)],
	SUM ([waits].[Duration]) - SUM (waits.[Signal Duration])
		AS [Resource Wait (ms)],
	SUM ([waits].[Signal Duration]) AS [Signal Wait (ms)],
	SUM ([waits].[Duration]) / COUNT (*) AS [Avg Wait (ms)],
	(SUM ([waits].[Duration]) - SUM (waits.[Signal Duration])) / COUNT (*) 
		AS [Avg ResW (ms)],
	SUM ([waits].[Signal Duration]) / COUNT (*) AS [Avg SigW (ms)]
FROM 
	(SELECT
		[event_data].[value] (
			'(/event/@timestamp)[1]',
				'DATETIME') AS [Time],
		[event_data].[value] (
			'(/event/data[@name=''wait_type'']/text)[1]',
				'VARCHAR(100)') AS [Wait Type],
		[event_data].[value] (
			'(/event/data[@name=''opcode'']/text)[1]',
				'VARCHAR(100)') AS [Op],
		[event_data].[value] (
			'(/event/data[@name=''duration'']/value)[1]',
				'BIGINT') AS [Duration],
		[event_data].[value] (
			'(/event/data[@name=''signal_duration'']/value)[1]',
				'BIGINT') AS [Signal Duration]
	FROM [##RawEventData]
	) AS [waits]
GROUP BY [waits].[Wait Type]
ORDER BY [Wait (ms)] DESC;
GO

-- Cleanup
DROP TABLE [##RawEventData];
GO