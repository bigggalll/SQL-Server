/*============================================================================
  File:     04_UsingQueryStoreReports.sql

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
	Check resource use through the UI
*/

/*
	Find top resource consumers with TSQL
	Longest execution times in the last hour
*/

USE [WideWorldImporters];
GO

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
	Highest logical IO in last 1 hour
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
	Highest execution count in last 1 hour
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



/*
	Check Regressed Queries in the UI
	CPU Avg, 2 days/12 hours
*/

/*
	Queries executed in the last 2 hours
	with multiple plans
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	COUNT([qsp].[plan_id]) AS [PlanCount],
	[qsq].[object_id], 
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
	Query from Regressed Queries view
*/
USE [WideWorldImporters];
GO

DECLARE @history_end_time datetimeoffset(7) = '2018-05-23 18:50:00.0800000 +00:00';
DECLARE @history_start_time datetimeoffset(7) = '2018-05-23 18:30:00.0800000 +00:00';
DECLARE @recent_end_time datetimeoffset(7) = '2018-05-23 19:10:00.0800000 +00:00';
DECLARE @recent_start_time datetimeoffset(7) = '2018-05-23 18:50:00.0800000 +00:00';
DECLARE @min_exec_count bigint = 20;
DECLARE @results_row_count int = 20;

WITH
hist AS
(
    SELECT
        p.query_id query_id,
        ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) total_duration,
        SUM(rs.count_executions) count_executions,
        COUNT(distinct p.plan_id) num_plans
    FROM sys.query_store_runtime_stats rs
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
    WHERE NOT (rs.first_execution_time > @history_end_time OR rs.last_execution_time < @history_start_time)
    GROUP BY p.query_id
),
recent AS
(
    SELECT
        p.query_id query_id,
        ROUND(CONVERT(float, SUM(rs.avg_duration*rs.count_executions))*0.001,2) total_duration,
        SUM(rs.count_executions) count_executions,
        COUNT(distinct p.plan_id) num_plans
    FROM sys.query_store_runtime_stats rs
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id
    WHERE NOT (rs.first_execution_time > @recent_end_time OR rs.last_execution_time < @recent_start_time)
    GROUP BY p.query_id
)
SELECT TOP (@results_row_count)
    results.query_id query_id,
    results.object_id object_id,
    ISNULL(OBJECT_NAME(results.object_id),'') object_name,
    results.query_sql_text query_sql_text,
    results.additional_duration_workload additional_duration_workload,
    results.total_duration_recent total_duration_recent,
    results.total_duration_hist total_duration_hist,
    ISNULL(results.count_executions_recent, 0) count_executions_recent,
    ISNULL(results.count_executions_hist, 0) count_executions_hist,
    queries.num_plans num_plans
FROM
(
    SELECT
        hist.query_id query_id,
        q.object_id object_id,
        qt.query_sql_text query_sql_text,
        ROUND(CONVERT(float, recent.total_duration/recent.count_executions-hist.total_duration/hist.count_executions)*(recent.count_executions), 2) additional_duration_workload,
        ROUND(recent.total_duration, 2) total_duration_recent,
        ROUND(hist.total_duration, 2) total_duration_hist,
        recent.count_executions count_executions_recent,
        hist.count_executions count_executions_hist
    FROM hist
        JOIN recent ON hist.query_id = recent.query_id
        JOIN sys.query_store_query q ON q.query_id = hist.query_id
        JOIN sys.query_store_query_text qt ON q.query_text_id = qt.query_text_id
    WHERE
        recent.count_executions >= @min_exec_count
) AS results
JOIN
(
    SELECT
        p.query_id query_id,
        COUNT(distinct p.plan_id) num_plans
    FROM sys.query_store_plan p
    GROUP BY p.query_id
    HAVING COUNT(distinct p.plan_id) >= 1
) AS queries ON queries.query_id = results.query_id
WHERE additional_duration_workload > 0
ORDER BY additional_duration_workload DESC
OPTION (MERGE JOIN)



/*
	Specifying intervals to find regressed queries

	Compare execution in recent period (1 hour) vs.
	history period (last day) and identifies those that 
	introduced additional_duration_workload. 
	This metric is calculated as a difference 
	between recent average execution and history average execution 
	multiplied by the number of recent executions. 
	It actually represents how much of additional duration 
	recent executions introduced compared to history

*/
--- "Recent" workload - last 1 hour  
DECLARE @recent_start_time datetimeoffset;  
DECLARE @recent_end_time datetimeoffset;  
SET @recent_start_time = DATEADD(hour, -1, SYSUTCDATETIME());  
SET @recent_end_time = SYSUTCDATETIME();  

--- "History" workload  
DECLARE @history_start_time datetimeoffset;  
DECLARE @history_end_time datetimeoffset;  
SET @history_start_time = DATEADD(hour, -24, SYSUTCDATETIME());  
SET @history_end_time = SYSUTCDATETIME();  

WITH  
hist AS  
(  
    SELECT   
        p.query_id query_id,   
        CONVERT(float, SUM(rs.avg_duration*rs.count_executions)) total_duration,   
        SUM(rs.count_executions) count_executions,  
        COUNT(distinct p.plan_id) num_plans   
     FROM sys.query_store_runtime_stats AS rs  
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id  
    WHERE  (rs.first_execution_time >= @history_start_time   
               AND rs.last_execution_time < @history_end_time)  
        OR (rs.first_execution_time <= @history_start_time   
               AND rs.last_execution_time > @history_start_time)  
        OR (rs.first_execution_time <= @history_end_time   
               AND rs.last_execution_time > @history_end_time)  
    GROUP BY p.query_id  
),  
recent AS  
(  
    SELECT   
        p.query_id query_id,   
        CONVERT(float, SUM(rs.avg_duration*rs.count_executions)) total_duration,   
        SUM(rs.count_executions) count_executions,  
        COUNT(distinct p.plan_id) num_plans   
    FROM sys.query_store_runtime_stats AS rs  
        JOIN sys.query_store_plan p ON p.plan_id = rs.plan_id  
    WHERE  (rs.first_execution_time >= @recent_start_time   
               AND rs.last_execution_time < @recent_end_time)  
        OR (rs.first_execution_time <= @recent_start_time   
               AND rs.last_execution_time > @recent_start_time)  
        OR (rs.first_execution_time <= @recent_end_time   
               AND rs.last_execution_time > @recent_end_time)  
    GROUP BY p.query_id  
)  
SELECT   
    results.query_id query_id,  
    results.query_text query_text,  
    results.additional_duration_workload additional_duration_workload,  
    results.total_duration_recent total_duration_recent,  
    results.total_duration_hist total_duration_hist,  
    ISNULL(results.count_executions_recent, 0) count_executions_recent,  
    ISNULL(results.count_executions_hist, 0) count_executions_hist   
FROM  
(  
    SELECT  
        hist.query_id query_id,  
        qt.query_sql_text query_text,  
        ROUND(CONVERT(float, recent.total_duration/  
                   recent.count_executions-hist.total_duration/hist.count_executions)  
               *(recent.count_executions), 2) AS additional_duration_workload,  
        ROUND(recent.total_duration, 2) total_duration_recent,   
        ROUND(hist.total_duration, 2) total_duration_hist,  
        recent.count_executions count_executions_recent,  
        hist.count_executions count_executions_hist     
    FROM hist   
        JOIN recent   
            ON hist.query_id = recent.query_id   
        JOIN sys.query_store_query AS q   
            ON q.query_id = hist.query_id  
        JOIN sys.query_store_query_text AS qt   
            ON q.query_text_id = qt.query_text_id      
) AS results  
WHERE additional_duration_workload > 0  
ORDER BY additional_duration_workload DESC  
OPTION (MERGE JOIN);  
