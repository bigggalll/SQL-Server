/*================================================================
  File:     A Thousand Stings Discovery.sql

  SQL Server Versions tested: SQL Server 2008 R2 10.50.2500
------------------------------------------------------------
  Written by Joseph I. Sack, SQLskills.com

  (c) 2012, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
=================================================================*/

-- **
-- Execute workload scripts and then continue
-- "1 - A Thousand Stings.cmd"
-- **

-- Top five queries by total worker time (DESC)
SELECT  TOP 5
		qs.last_worker_time,
		qs.max_worker_time,
		qs.total_worker_time,
		qs.execution_count,
		stmt_start=qs.statement_start_offset,
		stmt_end=qs.statement_end_offset,
		qt.dbid,
		qt.objectid,
		substring(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as statement
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY qs.total_worker_time DESC;

-- But what are we missing?
SELECT 	qs.last_worker_time,
		qs.max_worker_time,
		qs.total_worker_time,
		qs.execution_count,
		stmt_start=qs.statement_start_offset,
		stmt_end=qs.statement_end_offset,
		qt.dbid,
		qt.objectid,
		substring(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as statement
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
ORDER BY qs.total_worker_time DESC;

-- Now lets try it based on aggregated time and
-- look for several executes
SELECT 	TOP 5 qs.query_hash,
		SUM(qs.total_worker_time) total_worker_time,
		SUM(qs.execution_count) total_execution_count
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
GROUP BY query_hash
HAVING SUM(qs.execution_count) > 100
ORDER BY SUM(qs.total_worker_time) DESC;

-- Plug in query hash for an example
SELECT 	substring(qt.text,qs.statement_start_offset/2, 
		(case when qs.statement_end_offset = -1 
		then len(convert(nvarchar(max), qt.text)) * 2 
		else qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as statement,
		qs.total_worker_time,
		qs.execution_count,
		qs.query_hash,
		qs.query_plan_hash
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
WHERE query_hash = 0x284FF4A81CCF28ED;

