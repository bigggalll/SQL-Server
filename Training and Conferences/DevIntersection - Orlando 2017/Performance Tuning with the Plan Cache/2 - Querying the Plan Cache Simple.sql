/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  2 - Querying the Plan Cache Simple.sql
*
*   Summary: Demonstrates how to query basic information from the Plan Cache.
*
*   Date: October 16, 2010 
*
*   SQL Server Versions:
*         2005, 2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2010 Jonathan M. Kehayias
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlblog.com/blogs/jonathan_kehayias
*
*   You may alter this code for your own *non-commercial* purposes. You may
*   republish altered code as long as you include this copyright and give 
*	due credit. 
*
*
*   THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
*   ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
*   TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
*   PARTICULAR PURPOSE. 
*
******************************************************************************/

 --TOP N most frequently executed queries
SELECT TOP 10
	qs.execution_count,
	qs.total_worker_time/qs.execution_count AS avg_worker_time, 
	qs.total_worker_time,  
	qs.total_elapsed_time, 
	qs.total_elapsed_time/qs.execution_count AS avg_elapsed_time,
	qs.creation_time,
	SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
		((CASE qs.statement_end_offset 
			WHEN -1 THEN DATALENGTH(st.text)
		  ELSE qs.statement_end_offset END 
			- qs.statement_start_offset)/2) + 1) AS statement_text,
	qp.query_plan
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.execution_count DESC

 --TOP N most costly queries by physical IO
 SELECT TOP 10
	qs.execution_count,
	qs.total_worker_time/qs.execution_count AS avg_worker_time, 
	qs.total_worker_time,  
	qs.total_elapsed_time, 
	qs.total_physical_reads,
	qs.total_elapsed_time/qs.execution_count AS avg_elapsed_time,
	qs.total_physical_reads/qs.execution_count AS avg_physical_reads,
	qs.total_logical_reads/qs.execution_count AS avg_logical_reads,
	qs.creation_time,
	SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
		((CASE qs.statement_end_offset 
			WHEN -1 THEN DATALENGTH(st.text)
		  ELSE qs.statement_end_offset END 
			- qs.statement_start_offset)/2) + 1) AS statement_text,
	qp.query_plan
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_physical_reads DESC

--TOP N Total IO (reads+writes) consuming queries
SELECT TOP 10
	qs.execution_count,
	qs.total_worker_time/qs.execution_count AS avg_worker_time, 
	qs.total_logical_reads + qs.total_logical_writes AS total_logical_io,
	qs.total_worker_time,  
	qs.total_elapsed_time, 
	qs.total_physical_reads,
	qs.total_elapsed_time/qs.execution_count AS avg_elapsed_time,
	qs.total_physical_reads/qs.execution_count AS avg_physical_reads,
	qs.total_logical_reads/qs.execution_count AS avg_logical_reads,
	qs.creation_time,
	SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
		((CASE qs.statement_end_offset 
			WHEN -1 THEN DATALENGTH(st.text)
		  ELSE qs.statement_end_offset END 
			- qs.statement_start_offset)/2) + 1) AS statement_text,
	qp.query_plan
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_logical_reads + qs.total_logical_writes DESC
 
 
 --Query plans with long average execution times
 SELECT TOP 10
	qs.execution_count,
	qs.total_worker_time/qs.execution_count AS avg_worker_time, 
	qs.total_worker_time,  
	qs.total_elapsed_time, 
	qs.total_elapsed_time/qs.execution_count AS avg_elapsed_time,
	qs.creation_time,
	SUBSTRING(st.text, (qs.statement_start_offset/2) + 1,
		((CASE qs.statement_end_offset 
			WHEN -1 THEN DATALENGTH(st.text)
		  ELSE qs.statement_end_offset END 
			- qs.statement_start_offset)/2) + 1) AS statement_text,
	qp.query_plan
FROM sys.dm_exec_query_stats qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) qp
ORDER BY qs.total_elapsed_time/qs.execution_count DESC


 --Cache bloat from Adhoc / Non-Parameterized workloads.
SELECT 
	COUNT(*) AS single_use_plans, 
	SUM(cp.size_in_bytes)/1024 AS size_in_kb
FROM sys.dm_exec_cached_plans cp
WHERE cp.usecounts = 1
  AND cp.objtype = N'Adhoc' 

--Plans that consume the most memory in the plan cache.
SELECT TOP 5
	query_plan
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
ORDER BY size_in_bytes DESC