/*****************************************************************************
*   Presentation: DBA 246 - Performance Tuning with the Plan Cache 
*   FileName:  1 - Cache Related DMVs.sql
*
*   Summary: Demonstrates the DMV's related to the plan cache in SQL Server.
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


-- Querying actively executing sessions
SELECT 
	r.session_id,
	r.start_time,
	r.sql_handle,
	r.statement_start_offset,
	r.statement_end_offset,
	r.plan_handle,
	r.query_hash,
	r.query_plan_hash	
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions s
	ON r.session_id = s.session_id
WHERE s.is_user_process = 1
  AND s.session_id <> @@SPID


-- Querying cached execution plans
SELECT 
	cp.usecounts,
	cp.size_in_bytes,
	cp.objtype,
	cp.plan_handle
FROM sys.dm_exec_cached_plans cp


-- Query Stats
SELECT *
FROM sys.dm_exec_query_stats


-- Retreive the XML Query Plans from the system
SELECT TOP 10
	qp.query_plan,
	st.text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_query_plan(plan_handle) qp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) st

-- Retreive the Text Query Plans from the system
SELECT TOP 10
	qp.query_plan,
	st.text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY sys.dm_exec_text_query_plan(plan_handle, 0, -1) qp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) st