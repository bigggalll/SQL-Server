-- Script to look at the waiting tasks
SELECT
	owt.session_id,
	owt.wait_duration_ms,
	owt.wait_type,
	owt.blocking_session_id,
	owt.resource_description,
	es.program_name,
	est.text,
	est.dbid,
	eqp.query_plan,
	es.cpu_time,
	es.memory_usage
FROM sys.dm_os_waiting_tasks owt
INNER JOIN sys.dm_exec_sessions es ON
	owt.session_id = es.session_id
INNER JOIN sys.dm_exec_requests er ON
	es.session_id = er.session_id
OUTER APPLY sys.dm_exec_sql_text (er.sql_handle) est
OUTER APPLY sys.dm_exec_query_plan (er.plan_handle) eqp
WHERE es.is_user_process = 1;
GO

-- Look at resource semaphore information
SELECT * 
FROM sys.dm_exec_query_resource_semaphores;
GO


-- Look at the default pool resource semaphore information
SELECT * 
FROM sys.dm_exec_query_resource_semaphores
WHERE pool_id = 2;
GO


-- Look at default pool small resource semaphore information
SELECT * 
FROM sys.dm_exec_query_resource_semaphores
WHERE pool_id = 2 
  AND resource_semaphore_id = 1;
GO

-- Look at default pool normal resource semaphore information
SELECT * 
FROM sys.dm_exec_query_resource_semaphores
WHERE pool_id = 2 
  AND resource_semaphore_id = 0
GO


-- Look at memory grant information
SELECT * 
FROM sys.dm_exec_query_memory_grants
ORDER BY grant_time, wait_order

select * from sys.dm_exec_requests

select * from sys.dm_os_wait_stats
where wait_type = 'Resource_semaphore'
or wait_type = 'cxpacket'


/*

dbcc memorystatus

ALTER INDEX PK_Test ON Test REBUILD

dbcc freeproccache


select * from test

update Test set ParentID = 1 where RowID = 1

update statistics test(PK_Test) with fullscan

dbcc show_statistics('test', 'pk_test') WITH HISTOGRAM

*/