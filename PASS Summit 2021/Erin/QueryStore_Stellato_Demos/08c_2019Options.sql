/*============================================================================
  File:     08c_2019Options.sql

  SQL Server Versions: 2019, Azure SQL DB
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
	Enable QS and clear data
*/

ALTER DATABASE [WideWorldImporters] SET QUERY_STORE = ON;
GO

ALTER DATABASE [WideWorldImporters] 
SET QUERY_STORE = ON 
    (
      OPERATION_MODE = READ_WRITE, 
      CLEANUP_POLICY = ( STALE_QUERY_THRESHOLD_DAYS = 30 ),
      DATA_FLUSH_INTERVAL_SECONDS = 900,
      MAX_STORAGE_SIZE_MB = 1024, 
      INTERVAL_LENGTH_MINUTES = 1,
      SIZE_BASED_CLEANUP_MODE = AUTO, 
      MAX_PLANS_PER_QUERY = 200,
      WAIT_STATS_CAPTURE_MODE = ON,
      QUERY_CAPTURE_MODE = CUSTOM,
      QUERY_CAPTURE_POLICY = (
        EXECUTION_COUNT = 5,
        TOTAL_COMPILE_CPU_TIME_MS = 4,
        TOTAL_EXECUTION_CPU_TIME_MS = 1000 
      )
    );


ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO


/*
	If you have data in Query Store, you can
	use it to understand what to set for 
	TOTAL_COMPILE_CPU_TIME_MS
*/
USE [WideWorldImporters];
GO

SELECT 
	query_hash, 
	MIN(avg_compile_duration), 
	MAX(avg_compile_duration), 
	AVG(avg_compile_duration), 
	COUNT(query_hash)
FROM sys.query_store_query
GROUP BY query_hash
ORDER BY MIN(avg_compile_duration) DESC;
GO

/*
	If you have data in Query Store, you can
	use it to understand what to set for 
	TOTAL_EXECUTION_CPU_TIME_MS
*/

SELECT 
	q.query_hash, 
	p.query_plan_hash,
	MIN(rs.avg_cpu_time), 
	MAX(rs.avg_cpu_time), 
	AVG(rs.avg_cpu_time), 
	COUNT(q.query_hash),
	COUNT(p.query_plan_hash)
FROM sys.query_store_query q
JOIN sys.query_store_plan p
	ON q.query_id = p.query_id
JOIN sys.query_store_runtime_stats rs
	ON p.plan_id = rs.plan_id
GROUP BY q.query_hash, p.query_plan_hash
ORDER BY MIN(rs.avg_cpu_time) DESC;
GO


/*
	Run 5_SP_multiple_clients to generate workload,
	monitor PerfMon
*/

/*
	What's in QS?
*/
USE [WideWorldImporters];
GO

SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[query_hash],
	[rs].[count_executions],
	[qsq].[avg_compile_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[last_execution_time],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
--WHERE [qsq].[object_id] = 0;
GO


/*
	Check QS counts again
*/
USE [WideWorldImporters];
GO

SELECT COUNT(*) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO

SELECT COUNT(*) AS CountQueries                                     
FROM sys.query_store_query; 
GO

SELECT COUNT(*) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO

/*
	take note of counts
3,3,3
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
or type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO

/*
	take note of memory use
41

*/

/*
	Clear out QS data
*/
ALTER DATABASE [WideWorldImporters] SET QUERY_STORE CLEAR;
GO

/*
	Run 5_AdHoc_multiple_clients to generate adhoc workload
	watch PerfMon
*/


/*
	What's in QS now?
*/
USE [WideWorldImporters];
GO



SELECT
	[qsq].[query_id], 
	[qsp].[plan_id],
	[qsq].[object_id],
	[qsq].[query_hash],
	[rs].[count_executions],
	[qsq].[avg_compile_duration],
	[rs].[avg_cpu_time],
	[rs].[avg_duration],
	[rs].[avg_logical_io_reads],
	[rs].[last_execution_time],
	[qst].[query_sql_text],
	TRY_CONVERT(XML, [qsp].[query_plan]) AS [QueryPlan_XML]
FROM [sys].[query_store_query] [qsq] 
JOIN [sys].[query_store_query_text] [qst]
	ON [qsq].[query_text_id] = [qst].[query_text_id]
JOIN [sys].[query_store_plan] [qsp] 
	ON [qsq].[query_id] = [qsp].[query_id]
JOIN [sys].[query_store_runtime_stats] [rs] 
	ON [qsp].[plan_id] = [rs].[plan_id]
--WHERE [qsq].[object_id] = 0;
GO



/*
	Check QS counts
*/
USE [WideWorldImporters];
GO

SELECT COUNT(*) AS CountQueryText                                 
FROM sys.query_store_query_text;
GO

SELECT COUNT(*) AS CountQueries                                     
FROM sys.query_store_query; 
GO

SELECT COUNT(*) AS CountPlanRows                                      
FROM sys.query_store_plan; 
GO


/*
	Check memory use
*/
SELECT 
	type, 
	sum(pages_kb) AS [MemoryUsed_KB],
	sum(pages_kb)/1024 AS [MemoryUsed_MB]
FROM sys.dm_os_memory_clerks
WHERE type like '%QDS%'
OR type like '%QueryDiskStore%'
GROUP BY type
ORDER BY type;
GO
