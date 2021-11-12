/*============================================================================
  File:     04_WaitStats.sql

  SQL Server Versions: 2017+, Azure SQLDB
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

USE [master]
GO

RESTORE DATABASE [WideWorldImporters] 
	FROM  DISK = N'C:\Backups\WideWorldImporters_Bits.bak' WITH  FILE = 1,  
	MOVE N'WWI_Primary' TO N'C:\Databases\WideWorldImporters\WideWorldImporters.mdf',  
	MOVE N'WWI_UserData' TO N'C:\Databases\WideWorldImporters\WideWorldImporters_UserData.ndf',  
	MOVE N'WWI_Log' TO N'C:\Databases\WideWorldImporters\WideWorldImporters.ldf',  
	NOUNLOAD,  REPLACE,  STATS = 5

GO


/*
	Create procedure for testing
*/
USE [WideWorldImporters];
GO

CREATE PROCEDURE [Application].[usp_GetPersonLoginInfo] (@PersonID INT)
AS

	SELECT 
		[p].[FullName], 
		[p].[IsPermittedToLogon],
		[p].[LogonName],
		[p].[EmailAddress], 
		[c].[FormalName]
	FROM [Application].[People] [p]
	LEFT OUTER JOIN [Application].[Countries] [c] 
		ON [p].[PersonID] = [c].[LastEditedBy]
	WHERE [p].[PersonID] = @PersonID;
GO

/*
	Enable Query Store and clear anything that may be in there
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	INTERVAL_LENGTH_MINUTES = 1
	);
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO


/*
	Check status and settings
*/
USE [WideWorldImporters];
GO
SELECT *
FROM [sys].[database_query_store_options];
GO

/*
	kick off external script
	0_Prep_create_2_clients_usp_GetPersonLoginInfo
*/


/*
	Check the data
*/
SELECT COUNT(*) AS [Count]
FROM [Application].[People] 
WHERE [LogonName] = 'NO LOGON';
GO



/* 
	Run in a separate window 
*/
USE [WideWorldImporters];
GO

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;

UPDATE [Application].[People] 
	SET [LogonName] = ''
	WHERE [LogonName] = 'NO LOGON';

WAITFOR DELAY '00:00:05';

COMMIT;

GO 500 


/* 
	Run in a separate window 
*/
USE [WideWorldImporters];
GO

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;

UPDATE [Application].[People] 
	SET [LogonName] = 'NO LOGON'
	WHERE [LogonName] = '';

WAITFOR DELAY '00:00:05';

COMMIT;

GO 500 



/*
	What do we see in the UI?
*/


/*
	Query plan and execution information
*/
SELECT 
	[rsi].[start_time] AS [IntervalStartTime],
	[rsi].[end_time] AS [IntervalEndTime],
	[qsq].[query_id], 
	[qst].[query_sql_text],
	[qsp].[plan_id],
	[qsq].[object_id],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [Object],
	[rs].[count_executions],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID (N'Application.usp_GetPersonLoginInfo')
ORDER BY [rsi].[start_time]
GO

/*
	Adding in waits
	https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-query-store-wait-stats-transact-sql
*/
SELECT 
	[rsi].[start_time] AS [IntervalStartTime],
	[rsi].[end_time] AS [IntervalEndTime],
	[qsq].[query_id], 
	[qst].[query_sql_text],
	[qsp].[plan_id],
	[qsq].[object_id],
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [Object],
	[rs].[count_executions],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan],
	[ws].[wait_category_desc],
	[ws].[total_query_wait_time_ms]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
JOIN [sys].[query_store_wait_stats] ws
	ON [qsp].[plan_id] = [ws].[plan_id]
	AND [rsi].[runtime_stats_interval_id] = [ws].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID (N'Application.usp_GetPersonLoginInfo')
ORDER BY [rsi].[start_time] ASC, [ws].[total_query_wait_time_ms] DESC;
GO

/*
	Highest waits in last 10 minutes
*/
SELECT
	TOP 25
	[ws].[wait_category_desc],
	[ws].[avg_query_wait_time_ms],
	[ws].[total_query_wait_time_ms],
	[ws].[plan_id],
	CASE
		WHEN [q].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([q].[object_id]) 
	END AS [Object],
	[qt].[query_sql_text],
	[rsi].[start_time] AS [IntervalStartTime],
	[rsi].[end_time] AS [IntervalEndTime]
FROM [sys].[query_store_query_text] [qt]
JOIN [sys].[query_store_query] [q]
	ON [qt].[query_text_id] = [q].[query_text_id]
JOIN [sys].[query_store_plan] [qp] 
	ON [q].[query_id] = [qp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi] 
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
JOIN [sys].[query_store_wait_stats] [ws]
	ON [ws].[runtime_stats_interval_id] = [rs].[runtime_stats_interval_id]
		AND [ws].[plan_id] = [qp].[plan_id]
WHERE [rsi].[end_time] > DATEADD(MINUTE, -10, GETUTCDATE()) 
	AND [ws].[execution_type] = 0
ORDER BY [ws].[avg_query_wait_time_ms] DESC;
GO

/*
	Waits aggregated by plan, for query or SP
*/
SELECT 
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, MAX([qsp].[query_plan])) [QueryPlan],
	SUM([rs].[count_executions] * [rs].avg_duration)/
		SUM([rs].[count_executions]) AS AverageDurationMicroseconds,
	SUM([rs].[count_executions] * [rs].[avg_logical_io_reads])/
		SUM([rs].[count_executions]) AS [AverageLogicalIO],
	[ws].[wait_category_desc],
	AVG([ws].[avg_query_wait_time_ms]) [AvgWaitTimes]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
JOIN [sys].[query_store_runtime_stats_interval] [rsi]
	ON [rs].[runtime_stats_interval_id] = [rsi].[runtime_stats_interval_id]
JOIN [sys].[query_store_wait_stats] ws
	ON [qsp].[plan_id] = [ws].[plan_id]
	AND [rsi].[runtime_stats_interval_id] = [ws].[runtime_stats_interval_id]
WHERE [qsq].[object_id] = OBJECT_ID (N'Application.usp_GetPersonLoginInfo')
AND [ws].[execution_type] = 0
GROUP BY [qsq].[query_id], [qsp].[plan_id],
	[qst].[query_sql_text],
	[ws].[wait_category_desc]
ORDER BY [qsp].[plan_id];
GO


