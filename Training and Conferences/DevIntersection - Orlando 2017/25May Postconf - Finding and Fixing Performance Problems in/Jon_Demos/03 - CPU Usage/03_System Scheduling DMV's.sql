/*****************************************************************************
*   Presentation: Module 11 - DMV's
*   FileName:  System Scheduling DMVs.sql
*
*   Summary: Demonstrates how to find information about schedulers, workers
*			 threads, tasks and correlate them to sessions.
*
*   Date: March 14, 2011 
*
*   SQL Server Versions:
*         2008, 2008 R2
*         
******************************************************************************
*   Copyright (C) 2011 Jonathan M. Kehayias, SQLskills.com
*   All rights reserved. 
*
*   For more scripts and sample code, check out 
*      http://sqlskills.com/blogs/jonathan
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


-- Schedulers created by SQL Server
select 
	parent_node_id,
	scheduler_id,
	cpu_id,
	status,
	is_idle,
	preemptive_switches_count,
	context_switches_count, idle_switches_count,
	current_tasks_count,
	runnable_tasks_count,
	current_workers_count,
	active_workers_count,
	load_factor,
	yield_count,
	work_queue_count,
	pending_disk_io_count
from sys.dm_os_schedulers

select * from sys.dm_os_nodes

-- Workers currently created in SQL Server
SELECT *
FROM sys.dm_os_workers

-- Tasks in SQL Server
SELECT *
FROM sys.dm_os_tasks

-- A single session can use multiple workers with parallelism
SELECT
	t.task_address,
	t.session_id,
	t.exec_context_id,
	t.request_id,
	t.scheduler_id,
	t.task_state,
	w.last_wait_type,
	w.state,
	wt.blocking_exec_context_id,
	wt.wait_type,
	wt.wait_duration_ms,
	wt.resource_address,
	wt.resource_description
FROM sys.dm_os_tasks AS t
JOIN sys.dm_os_workers AS w
	ON t.worker_address = w.worker_address
LEFT JOIN sys.dm_os_waiting_tasks as wt
	ON t.task_address = wt.waiting_task_address
	  AND t.exec_context_id = wt.exec_context_id
where t.session_id = 59

--Run CHECKDB

-- Threads created by SQL Server
SELECT 
	os_thread_id,
	started_by_sqlservr,
	creation_time,
	kernel_time,
	usermode_time,
	stack_bytes_committed,
	stack_bytes_used,
	worker_address
FROM sys.dm_os_threads

-- Adding information the schedulers output
SELECT 
	sched.parent_node_id,
	sched.scheduler_id,
	sched.cpu_id,
	sched.context_switches_count,
	sched.preemptive_switches_count,
	sched.idle_switches_count,
	sched.current_tasks_count,
	sched.current_workers_count,
	sched.active_workers_count,
	SUM(CAST(worker.is_preemptive AS int)) AS preemptive_workers,
	SUM(worker.context_switch_count) AS worker_context_switches,
	SUM(worker.pending_io_count) AS worker_pending_io,
	SUM(thread.stack_bytes_committed) AS thread_stack_bytes_committed,
	SUM(thread.stack_bytes_used) AS thread_stack_bytes_used
FROM sys.dm_os_schedulers AS sched
JOIN sys.dm_os_workers AS worker
	ON worker.scheduler_address = sched.scheduler_address
LEFT JOIN sys.dm_os_tasks AS task
	ON task.worker_address = worker.worker_address
LEFT JOIN sys.dm_os_threads AS thread
	ON (sched.scheduler_address = thread.scheduler_address
		AND worker.thread_address = thread.thread_address)
GROUP BY 	sched.parent_node_id,
	sched.scheduler_id,
	sched.cpu_id,
	sched.context_switches_count,
	sched.preemptive_switches_count,
	sched.idle_switches_count,
	sched.current_tasks_count,
	sched.current_workers_count,
	sched.active_workers_count


-- Tying back to Sessions and Requests		
SELECT 
	es.login_name, 
	db_name(r.database_id) name, 
	es.host_name, 
	es.program_name, 
	r.sql_handle, 
	r.statement_start_offset, 
	r.statement_end_offset, 
	es.session_id, 
	wt.wait_type waittype, -- Can't convert this its not Binary anymore.
	w.last_wait_type, 
	t.exec_context_id [ecid], 
	ISNULL(wt.wait_duration_ms, 0) [waittime],
	CONVERT(varchar(64), r.context_info) context_info, 
	r.blocking_session_id, 
	r.plan_handle 
FROM sys.dm_exec_requests r
JOIN sys.dm_exec_sessions es 
	ON r.session_id = es.session_id
JOIN sys.dm_os_tasks t 
	ON r.session_id = t.session_id
JOIN sys.dm_os_workers w 
	ON t.worker_address = w.worker_address
LEFT JOIN sys.dm_os_waiting_tasks wt 
	ON t.task_address = wt.waiting_task_address
WHERE COALESCE(es.is_user_process, 1) = 1
