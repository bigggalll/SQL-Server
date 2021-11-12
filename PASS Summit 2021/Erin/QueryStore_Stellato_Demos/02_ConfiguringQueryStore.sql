/*============================================================================
  File:     02_ConfiguringQueryStore.sql

  SQL Server Versions: 2016+, Azure SQLDB
------------------------------------------------------------------------------
  Written by Erin Stellato, SQLskills.com
  
  (c) 2021, SQLskills.com. All rights reserved.

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

/*
	Create a database to use for testing
	*may need to change directory 
*/
DROP DATABASE IF EXISTS [Movies];
GO

CREATE DATABASE [Movies]
	ON  PRIMARY 
	(NAME = N'Movies', FILENAME = N'C:\Databases\Movies\Movies.mdf' , 
	SIZE = 262144KB , FILEGROWTH = 65536KB )
	LOG ON 
	(NAME = N'Movies_log', FILENAME = N'C:\Databases\Movies\Movies_log.ldf' , 
	SIZE = 131072KB , FILEGROWTH = 65536KB );
GO

ALTER DATABASE [Movies] SET RECOVERY SIMPLE;
GO

/*
	Create a table and add some data
*/
USE [Movies];
GO

CREATE TABLE [dbo].[MovieInfo] (
	[MovieID] INT IDENTITY(1,1) PRIMARY KEY, 
	[MovieName] VARCHAR(800), 
	[ReleaseDate] SMALLDATETIME,
	[Rating] VARCHAR(5)
	);
GO

INSERT INTO [dbo].[MovieInfo] ( 
	[MovieName], [ReleaseDate], [Rating]
	)
VALUES
	('IronMan', '2008-05-02 00:00:00', 'PG-13'),
	('Joy', '2016-12-25', 'PG-13'),
	('Caddyshack', '1980-07-25', 'R'),
	('The Martian', '2015-10-02', 'PG-13'),
	('Apollo 13', '1995-05-30 00:00:00', 'PG'),
	('The Hunt for Red October', '1990-03-02 00:00:00', 'PG'),
	('A Few Good Men', '1994-12-11 00:00:00', 'R'),
	('Memento', '2000-10-11', 'R'),
	('The Truman Show', '1998-06-05 00:00:00', 'PG-13'),
	('All The President''s Men', '1976-04-09 00:00:00', 'R'),
	('The Right Stuff', '1983-10-21 00:00:00', 'PG-13'),
	('The Blind Side', '2009-11-20', 'PG-13'),
	('The Natural', '1984-05-11 00:00:00', 'PG'),
	('The Hangover', '2009-06-05 00:00:00', 'R'),
	('The Incredibles', '2004-11-05 00:00:00', 'PG');
GO


CREATE TABLE [dbo].[Actors](
	[ActorID] INT IDENTITY(1,1) PRIMARY KEY, 
	[FirstName] VARCHAR(100), 
	[LastName] VARCHAR(200),
	[DOB] SMALLDATETIME
	);
GO

INSERT INTO [dbo].[Actors](
	[FirstName], [LastName], [DOB]
	)
VALUES
	('Jennifer', 'Lawrence', '1990-08-15'),
	('Robert', 'Redford', '1936-08-18'),
	('Demi', 'Moore', '1962-11-11'),
	('Alec', 'Baldwin', '1958-01-03'),
	('Sandra', 'Bullock', '1964-07-26'),
	('Tom', 'Hanks', '1956-07-09');
GO

CREATE TABLE [dbo].[Cast](
	[MovieID] INT,
	[ActorID] INT
	);
GO

INSERT INTO [dbo].[Cast](
	[MovieID], [ActorID])
VALUES
	(2, 1),
	(10, 2),
	(13, 2),
	(7, 3),
	(6, 4),
	(12, 5),
	(5, 6);
GO


/*
	Enable Query Store through the UI
*/




/*
	this is the default if you script it out
*/
USE [master];
GO
ALTER DATABASE [Movies] 
	SET QUERY_STORE = ON;
GO
ALTER DATABASE [Movies] 
	SET QUERY_STORE (OPERATION_MODE = READ_WRITE);
GO


/*
	This is what it's really setting
*/
USE [master];
GO
ALTER DATABASE [Movies] 
	SET QUERY_STORE = ON;
GO
ALTER DATABASE [Movies] 
	SET QUERY_STORE (
		OPERATION_MODE = READ_WRITE, 
		CLEANUP_POLICY = 
			(STALE_QUERY_THRESHOLD_DAYS = 30), 
		DATA_FLUSH_INTERVAL_SECONDS = 900,  
		INTERVAL_LENGTH_MINUTES = 60, 
		MAX_STORAGE_SIZE_MB = 1000, /* 100 in 2016, 2017 */
		QUERY_CAPTURE_MODE = AUTO, /* ALL in 2016, 2017 */
		SIZE_BASED_CLEANUP_MODE = AUTO, 
		MAX_PLANS_PER_QUERY = 200);
GO


/*
	Demo will use different settings
	**Not for production use!
*/
USE [master];
GO
ALTER DATABASE [Movies] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE,
		/*	
			READ_WRITE = data collection; READ_ONLY = no data collection 
		*/
	CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30),  
		/*	
			How long to retain data in the query store, default is 30 (different for Azure tiers) 
		*/
	DATA_FLUSH_INTERVAL_SECONDS = 60,
		/*	
			How frequently QS data is written to disk, default is 900 (15 minutes) 
			How much QS data could be lost if there's a hard server crash
		*/
	INTERVAL_LENGTH_MINUTES = 10,
		/*	
			Interval across which QS data is aggregated, default is 60 minutes
			Use a smaller value if you need finer granularity or less time to detect and mitigate issues
			This will affect the size of the data (lower value = more data) 
			From BOL: Note that arbitrary values are not allowed - 
				you must use one of the following: 1, 5, 10, 15, 30, 60, and 1440 minutes) 
		*/
	MAX_STORAGE_SIZE_MB = 512,
		/*	
			Size of the QS (when the max is hit, status changes to READ_ONLY) 
			Default was 100MB in 2016 and 2017
			Default is 1000MB in SQL 2019 (varies in Azure depending on tier)
			What this needs to be depends on your workload,
				and how much information you want to keep
		*/
	QUERY_CAPTURE_MODE = ALL,
		/* 
			Are ALL queries captured, or only relevant ones? 
			ALL was default in 2016 and 2017
			AUTO is default in 2019 and Azure
			AUTO is infrequent queries and those with insignificant compile and execution duration are ignored
			The thresholds (execution count, compile and runtime duration) are internally determined
			CUSTOM added in 2019, additional options to configure
		*/
	SIZE_BASED_CLEANUP_MODE = AUTO,
		/* 
			Do you want QS to go into clean up mode as usage gets close to MAX_STORAGE_SIZE_MB? 
			default is ON
			It is recommended to enable this so that QS always run in read-write mode and is collecting data
		*/
	MAX_PLANS_PER_QUERY = 200);
		/*
			Maximum number of plans to store for a query
		*/
GO

/*
	Check current status
*/
USE [Movies];
GO

SELECT 
	[actual_state_desc], 
	[readonly_reason], 
	[desired_state_desc], 
	[current_storage_size_mb], 
    [max_storage_size_mb], 
	[flush_interval_seconds], 
	[interval_length_minutes], 
    [stale_query_threshold_days], 
	[size_based_cleanup_mode_desc], 
    [query_capture_mode_desc], 
	[max_plans_per_query]
FROM [sys].[database_query_store_options];
GO



/*
	Run a query
*/
USE [Movies];
GO

SELECT *
FROM [dbo].[MovieInfo]
WHERE [ReleaseDate] >= '2001-01-01';
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [ActorID] = 2;
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [ActorID] = 54685;
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [LastName] LIKE 'B%';
GO

EXECUTE sp_executesql   
          N'SELECT * FROM [dbo].[Actors]   
          WHERE [LastName] LIKE @name',  
          N'@name nvarchar(20)',
		  @name = 'Ha%'

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [FirstName] LIKE 'Rob%'
OPTION (QUERYTRACEON 4199);
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [FirstName] LIKE 'A%'
OPTION (USE HINT ('ENABLE_PARALLEL_PLAN_PREFERENCE'));
GO

EXEC sp_query_store_flush_db;
GO

/*
	What do we get from the system views?
*/
USE [Movies];
GO

SELECT *
FROM [sys].[query_store_query_text]
ORDER BY [query_text_id] DESC;
GO

SELECT *
FROM [sys].[query_store_query]
ORDER BY [query_text_id] DESC;
GO

SELECT *
FROM [sys].[query_store_plan];
GO

SELECT *
FROM [sys].[query_store_runtime_stats];
GO


/*
	What do we see in Query Store?
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[rs].[count_executions],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]),
	[qsp].[query_plan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
ORDER BY [qst].[query_text_id] DESC;
GO



/*
	Textual matching still in effect
*/
USE [Movies];
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [LastName] LIKE 'Bu%';
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [lastname] LIKE 'Bu%';
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE      [LastName] LIKE 'Bu%';
GO

SELECT [FirstName], [LastName]
FROM [dbo].[Actors]
WHERE [LastName] LIKE 'Bull%'
OPTION (RECOMPILE);
GO


SELECT
	[qst].[query_text_id],
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id],  
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qst].[query_sql_text] LIKE '%[LastName]%';
GO

/*
	Note some of these queries have the same query_hash
*/
SELECT [query_hash] AS [query_hash], COUNT([query_id]) AS [Count]
FROM [sys].[query_store_query] 
GROUP BY [query_hash]
HAVING COUNT(*) > 1;
GO

SELECT
	[qst].[query_text_id],
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id],  
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qsq].[query_hash],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN (
	SELECT [query_hash] AS [query_hash], COUNT([query_id]) AS [Count]
	FROM [sys].[query_store_query] 
	GROUP BY [query_hash]
	HAVING COUNT(*) > 1
	) [m] on [qsq].[query_hash] = [m].[query_hash]
WHERE [qst].[query_sql_text] LIKE '%[LastName]%';
GO

/*
	Individual Queries (statements) are captured
*/
CREATE PROCEDURE [dbo].[usp_GetMovie] (@ID INT)
AS

	SELECT 
		[MovieName],
		[ReleaseDate],
		[Rating]
	FROM [dbo].[MovieInfo]
	WHERE [MovieID] = @ID;

	SELECT
		[a].[FirstName], 
		[a].[LastName], 
		[a].[DOB]
	FROM [dbo].[Actors] [a]
	JOIN [dbo].[Cast] [c] 
		ON [a].[ActorID] = [c].[ActorID]
	WHERE  [c].[MovieID] = @ID;
GO


EXEC [dbo].[usp_GetMovie] 5;
GO
EXEC [dbo].[usp_GetMovie] 12;
GO


SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[rs].[count_executions],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'usp_GetMovie');
GO


/*
	Encrypted Stored procedures...no text, no plan
*/

DROP PROCEDURE IF EXISTS [dbo].[usp_EncryptedGetMovie];
GO

CREATE PROCEDURE [dbo].[usp_EncryptedGetMovie] (@ID INT)
	WITH ENCRYPTION
AS

	SELECT 
		[MovieName],
		[ReleaseDate],
		[Rating]
	FROM [dbo].[MovieInfo]
	WHERE [MovieID] = @ID;

	SELECT
		[a].[FirstName], 
		[a].[LastName], 
		[a].[DOB]
	FROM [dbo].[Actors] [a]
	JOIN [dbo].[Cast] [c] 
		ON [a].[ActorID] = [c].[ActorID]
	WHERE  [c].[MovieID] = @ID;
GO


EXEC [dbo].[usp_EncryptedGetMovie] 5;
GO 10


SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO
SELECT 
	[qs].execution_count, 
	[s].[text], 
	[qs].[query_hash], 
	[qs].[query_plan_hash], 
	[cp].[size_in_bytes]/1024 AS [PlanSizeKB], 
	[qp].[query_plan], 
	[qs].[plan_handle]
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
CROSS APPLY sys.dm_exec_sql_text([qs].[plan_handle]) AS [s]
LEFT OUTER JOIN sys.dm_exec_cached_plans AS [cp] 
	ON [qs].[plan_handle] = [cp].[plan_handle]
WHERE [s].[text] LIKE '%EncryptedGetMovie%';
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


SELECT
	[qsq].[query_id], 
	[qsp].[plan_id], 
	[qsq].[object_id], 
	[rs].[count_executions],
	DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time]) AS [LocalLastExecutionTime],
	[qst].[query_sql_text], 
	ConvertedPlan = TRY_CONVERT(XML, [qsp].[query_plan])
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
WHERE [qsq].[object_id] = OBJECT_ID(N'usp_EncryptedGetMovie');
GO



/*
	If executed from the context of another database,
	still logged in Query Store
	*Note: If both DBs have QS enabled, query is logged
	in DB from which it's initiated

*/



/*
	If you turn it off...
*/
USE [master];
GO
ALTER DATABASE [Movies] 
	SET QUERY_STORE = OFF;
GO

/*
	Everything is still in QS views
*/
USE [Movies];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[initial_compile_start_time],
	[qsq].[last_compile_start_time], 
	[rs].[first_execution_time],
	[rs].[last_execution_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[count_executions],
	[qst].[query_sql_text]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id];
GO


/*
	Clean up
*/
USE [master];
GO
DROP DATABASE [Movies];
GO