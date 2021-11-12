/*============================================================================
  File:     09_WorkloadAnalysis.sql

  SQL Server Versions: 2016, 2017, 2019
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
	Enable Query Store and clear anything that may be in there
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE (
	OPERATION_MODE = READ_WRITE, 
	INTERVAL_LENGTH_MINUTES = 10
	);
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Make sure instance setting for optimize for adhoc is DISABLED
*/	
sp_configure 'advanced options', 1
GO
RECONFIGURE
GO
sp_configure 'optimize for ad hoc workloads', 0
GO
RECONFIGURE
GO



/*
	Run 5_SP_multiple_clients (clear cache first)
	Run 01 workload
	Run some random queries too
*/
DBCC FREEPROCCACHE;
GO

USE [WideWorldImporters];
GO

SELECT *
FROM application.people;
GO 10

SELECT *
FROM [Application].[People];
GO 10

SELECT *
FROM Sales.Customers
SELECT *
FROM Sales.CustomerCategories;
GO 10

EXEC [Sales].[usp_FindOrderByDescription] '%Blue%';
GO 10

EXEC [Sales].[usp_GetFullProductInfo] 200;
GO 10

/*
	What do we see in the plan cache/query stats DMVs?
*/
SELECT 
	[t].[dbid],
	[qs].[execution_count], 
	[t].[text],
	[qs].[query_hash], 
	[qs].[query_plan_hash],
	[qs].[plan_handle],
	[qs].[sql_handle],
	[qs].[statement_start_offset],
	[qs].[statement_end_offset],
	[qs].[statement_sql_handle],  
	[qp].[query_plan]
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
CROSS APPLY sys.dm_exec_sql_text([qs].[sql_handle]) AS [t];
GO

/*
	How many different queries?  
*/
SELECT COUNT(*) AS CountQueries
FROM sys.dm_exec_query_stats;
GO


SELECT 
	[t].[dbid],
	COUNT(*)
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_sql_text([qs].[sql_handle]) AS [t]
GROUP BY [t].[dbid];
GO

/*
	How many different queries if we look at query_hash?  
*/
SELECT COUNT(query_hash) AS CountQueries
FROM sys.dm_exec_query_stats;
GO

/*
	How many unique queries?
*/
SELECT COUNT (DISTINCT query_hash) AS CountUniqueQueries
FROM sys.dm_exec_query_stats;
GO

SELECT query_hash, COUNT (query_hash) AS CountUniqueQueries
FROM sys.dm_exec_query_stats
GROUP BY query_hash;
GO

/*
	How many different plans if we look at query_plan_hash?
*/
SELECT COUNT (query_plan_hash) AS CountPlans
FROM sys.dm_exec_query_stats;
GO

/*
	How many unique query plans?
*/
SELECT COUNT (DISTINCT query_plan_hash) AS CountUniquePlans
FROM sys.dm_exec_query_stats;
GO

/*
	Now run 5_AdHoc_multiple_clients
*/

/*
	What do we see now in the plan cache/query stats DMVs?
*/
SELECT 
	[t].[dbid],
	[qs].[execution_count], 
	[t].[text],
	[qs].[query_hash], 
	[qs].[query_plan_hash],
	[qs].[plan_handle],
	[qs].[sql_handle],
	[qs].[statement_start_offset],
	[qs].[statement_end_offset],
	[qs].[statement_sql_handle],  
	[qp].[query_plan]
FROM sys.dm_exec_query_stats AS [qs]
CROSS APPLY sys.dm_exec_query_plan ([qs].[plan_handle]) AS [qp]
CROSS APPLY sys.dm_exec_sql_text([qs].[sql_handle]) AS [t];
GO


/*
	How many different queries?  
*/
SELECT COUNT(sql_handle) AS CountQueries
FROM sys.dm_exec_query_stats;
GO

/*
	How many different queries if we look at query_hash?  
*/
SELECT COUNT(query_hash) AS CountQueries
FROM sys.dm_exec_query_stats;
GO

/*
	How many unique queries?
*/
SELECT COUNT (DISTINCT query_hash) AS CountUniqueQueries
FROM sys.dm_exec_query_stats;
GO

/*
	How many different plans if we look at query_plan_hash?
*/
SELECT COUNT (query_plan_hash) AS CountPlans
FROM sys.dm_exec_query_stats;
GO

/*
	How many unique query plans?
*/
SELECT COUNT (DISTINCT query_plan_hash) AS CountUniquePlans
FROM sys.dm_exec_query_stats;
GO

/*
	What does Kimberly's query show us?
*/
SELECT objtype AS [CacheType],
    COUNT_BIG(*) AS [Total Plans],
    SUM(CAST(size_in_bytes AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs],
    AVG(usecounts) AS [Avg Use Count],
    SUM(CAST((CASE WHEN usecounts = 1 THEN size_in_bytes
        ELSE 0
        END) AS DECIMAL(18, 2))) / 1024 / 1024 AS [Total MBs – USE Count 1],
    SUM(CASE WHEN usecounts = 1 THEN 1
        ELSE 0
        END) AS [Total Plans – USE Count 1]
FROM sys.dm_exec_cached_plans
GROUP BY objtype
ORDER BY [Total MBs – USE Count 1] DESC
GO

/*
	We get better data from Query Store
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[rs].[count_executions],
	[rs].[last_execution_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id];
GO

SELECT COUNT(query_text_id) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO
--

SELECT COUNT(query_id) AS CountQueries                                     
FROM sys.query_store_query; 
GO
--

SELECT COUNT(DISTINCT query_hash) AS CountUniqueQueries           
FROM sys.query_store_query; 
GO
--

SELECT COUNT(plan_id) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO
--

SELECT COUNT(DISTINCT query_plan_hash) AS CountUniquePlans 	     
FROM sys.query_store_plan; 
GO
--


/*
	Info from plan cache
*/
SELECT qs.query_hash
    , COUNT(DISTINCT qs.query_plan_hash) AS [Distinct Plan Count]
    , SUM(qs.EXECUTION_COUNT) AS [Execution Total]
FROM sys.dm_exec_query_stats AS qs 
	CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS st
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
GROUP BY qs.query_hash
ORDER BY [Execution Total] DESC;
GO

/*
	Info from QS
*/
SELECT 
	q.query_hash,
	COUNT(q.query_hash) [NumQueries],
	COUNT(DISTINCT p.query_plan_hash) AS [DistinctPlans]           
FROM sys.query_store_query q
JOIN sys.query_store_plan p
	ON q.query_id = p.plan_id
GROUP BY q.query_hash; 
GO

/*
	Include execution counts
*/
SELECT 
	q.query_hash,
	COUNT(q.query_hash) [NumQueries],
	COUNT(DISTINCT p.query_plan_hash) AS [DistinctPlans],
	SUM(rs.count_executions) [ExecutionCount]
FROM sys.query_store_query q
JOIN sys.query_store_plan p
	ON q.query_id = p.plan_id
JOIN sys.query_store_runtime_stats rs
	ON p.plan_id = rs.plan_id
GROUP BY q.query_hash; 
GO

/*
	Get the query information 
	(not a pretty way)
*/
SELECT 
	q.query_hash,
	COUNT(q.query_hash) [NumQueries],
	COUNT(DISTINCT p.query_plan_hash) AS [DistinctPlans],
	SUM(rs.count_executions) [ExecutionCount],
	t.query_sql_text
FROM sys.query_store_query_text t
JOIN sys.query_store_query q
	ON t.query_text_id = q.query_text_id
JOIN sys.query_store_plan p
	ON q.query_id = p.plan_id
JOIN sys.query_store_runtime_stats rs
	ON p.plan_id = rs.plan_id
GROUP BY q.query_hash, t.query_sql_text; 
GO


/*
	What happens if we enable forced parameterization?
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

ALTER DATABASE [WideWorldImporters] SET PARAMETERIZATION FORCED WITH NO_WAIT;
GO




/*
	Run SP workload first SP_multiple_clients_10
*/

/*
	check distribution
*/
USE WideWorldImporters;
GO

SELECT COUNT(query_text_id) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO
--

SELECT COUNT(query_id) AS CountQueries                                     
FROM sys.query_store_query; 
GO
--

SELECT COUNT(DISTINCT query_hash) AS CountUniqueQueries           
FROM sys.query_store_query; 
GO
--

SELECT COUNT(plan_id) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO
--

SELECT COUNT(DISTINCT query_plan_hash) AS CountUniquePlans 	     
FROM sys.query_store_plan; 
GO
--


/*
	Run ad-hoc workload AdHoc_multiple_clients_2 
*/

/*
	check distribution again
*/
SELECT COUNT(query_text_id) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO
--

SELECT COUNT(query_id) AS CountQueries                                     
FROM sys.query_store_query; 
GO
--

SELECT COUNT(DISTINCT query_hash) AS CountUniqueQueries           
FROM sys.query_store_query; 
GO
--

SELECT COUNT(plan_id) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO
--

SELECT COUNT(DISTINCT query_plan_hash) AS CountUniquePlans 	     
FROM sys.query_store_plan; 
GO
--

/*
	Informal perf analysis
*/

/*
	Clear out QS again
	Open up PerfMon
	*Forced parameterization is enabled
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Run SP_multiple_clients_10 to generate workload
	watch in PerfMon
*/

/*
	Run AdHoc_multiple_clients_2 to generate adhoc workload
	watch in Perfon
*/

/*
	Check memory use
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
GROUP BY type
ORDER BY type;
GO


/*
	Now, go back to SIMPLE parameterization monitor PerfMon
*/
USE [master];
GO

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

ALTER DATABASE [WideWorldImporters] SET PARAMETERIZATION SIMPLE WITH NO_WAIT;
GO

/*
	Run SP_multiple_clients_10 to generate workload
*/

/*
	Run AdHoc_multiple_clients_2 to generate adhoc workload
*/

/*
	Check memory use
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
GROUP BY type
ORDER BY type;
GO


