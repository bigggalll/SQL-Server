/*================================================================
  File:     Narcissistic Parallelism Discovery.sql

  SQL Server Versions tested: SQL Server 2012, 11.0.3321
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
-- Execute "3 - Narcissistic Parallelism.cmd"
-- **

-- Identifying potential parallel plans
SELECT 	qs.total_worker_time,
		qs.total_elapsed_time,
            substring(qt.text,qs.statement_start_offset/2, 
			(case when qs.statement_end_offset = -1 
			then len(convert(nvarchar(max), qt.text)) * 2 
			else 
			qs.statement_end_offset end -qs.statement_start_offset)/2) 
		as query_text,
		qs.execution_count,
		qs.sql_handle,
		qs.plan_handle
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
WHERE qs.total_worker_time > qs.total_elapsed_time
ORDER BY qs.total_worker_time DESC;

-- Another option for identification
SELECT  r.session_id, 
		r.plan_handle, 
		MAX(ISNULL(exec_context_id, 0)) as workers 
FROM	sys.dm_exec_requests r 
INNER JOIN sys.dm_os_tasks t ON 
	r.session_id = t.session_id 
INNER JOIN sys.dm_exec_sessions s ON 
	r.session_id = s.session_id 
WHERE s.is_user_process = 0x1 
GROUP BY r.session_id,
		 r.plan_handle
HAVING MAX(ISNULL(exec_context_id, 0)) > 0;

-- We can check the plan now
SELECT query_plan
FROM sys.dm_exec_query_plan	
	/** PLUG IN NEW plan handle **/
	(0x0600060036AEA22B306E22A40300000001000000000000000000000000000000000000000000000000000000);

-- Looking at parallelism meta-data 
SELECT *
FROM sys.dm_os_waiting_tasks
WHERE session_id IN
	(SELECT session_id
	 FROM sys.dm_os_tasks
	 WHERE exec_context_id > 0);

-- A quick look at the tasks
-- Run a few times until you see the NULL parent 
SELECT	task_address,
		task_state,
		scheduler_id,
		exec_context_id,
		worker_address,
		parent_task_address
FROM sys.dm_os_tasks
-- !!!! change this based on the blocker
WHERE session_id = 53;  -- !!!! change this based on the blocker

