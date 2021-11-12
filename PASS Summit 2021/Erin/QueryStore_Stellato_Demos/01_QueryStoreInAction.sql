/*============================================================================
  File:     01_QueryStoreInAction.sql

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
	What do we see in the Query Store UI?
*/

/*
	What do we get from the system views?
*/
USE [WideWorldImporters];
GO

SELECT *
FROM [sys].[query_store_query];
GO

SELECT *
FROM [sys].[query_store_query_text];
GO

SELECT *
FROM [sys].[query_store_plan];
GO

SELECT *
FROM [sys].[query_store_runtime_stats];
GO

SELECT *
FROM [sys].[query_store_wait_stats];
GO


/*
	Query compile and optimization information
*/
SELECT 
	[qsq].[query_id], 
	[qsq].[object_id], 
	[qst].[query_sql_text], 
	[qsq].[last_execution_time], 
	[qsq].[last_compile_start_time],
	[qsq].[avg_compile_duration], 
	[qsq].[avg_optimize_cpu_time], 
	[qsq].[avg_optimize_duration]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id];
GO


/*
	Queries executed in the last 2 hours
	with multiple plans
*/
SELECT
	[qsq].[query_id], 
	COUNT([qsp].[plan_id]) AS [PlanCount],
	OBJECT_NAME([qsq].[object_id]) [ObjectName], 
	MAX(DATEADD(MINUTE, -(DATEDIFF(MINUTE, GETDATE(), GETUTCDATE())), 
		[qsp].[last_execution_time])) AS [LocalLastExecutionTime],
	MAX([qst].query_sql_text) AS [Query_Text]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[last_execution_time] > DATEADD(HOUR, -2, GETUTCDATE())
GROUP BY [qsq].[query_id], [qsq].[object_id]
HAVING COUNT([qsp].[plan_id]) > 1;
GO

/*
	What are the plans for a query?
	(can also use Tracked Queries report)
*/
SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
WHERE [qsp].[query_id] = 45;
GO


/*
	Find top resource consumers with TSQL
	Average duration in the last hour
*/
SELECT 
	TOP 10 AVG([rs].[avg_duration]) [AvgDuration], 
	SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY AVG([rs].[avg_duration]) DESC;  
GO


/*
	Highest average logical IO in last hour
*/
SELECT 
	TOP 10 AVG([rs].[avg_logical_io_reads]) [AvgLogicalIO], 
	SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY AVG([rs].[avg_logical_io_reads]) DESC;  
GO


/*
	Highest execution count in last hour
*/
SELECT 
	TOP 10 SUM([rs].[count_executions]) [TotalExecutions],
	[qsq].[query_id],  
	[qst].[query_sql_text], 
	CASE
		WHEN [qsq].[object_id] = 0 THEN N'Ad-hoc'
		ELSE OBJECT_NAME([qsq].[object_id]) 
	END AS [ObjectName],
	[qsp].[plan_id], 
	TRY_CONVERT(XML, [qsp].[query_plan]) [QueryPlan]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id] 
WHERE [rs].[last_execution_time] > DATEADD(HOUR, -1, GETUTCDATE())  
AND [rs].[execution_type] = 0
GROUP BY [qsq].[query_id], [qst].[query_sql_text], 
[qsq].[object_id], [qsp].[plan_id], [qsp].[query_plan]
ORDER BY SUM([rs].[count_executions]) DESC;  
GO






