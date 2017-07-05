-- ======================================================================= --
-- Requête fournie par François                                            --
-- Deux variantes.  avec et sans spid de 50 et moins.                      --
-- ======================================================================= --


-- ======================================================================= --
--                                                                         --
-- Extraction des jobs actives sur le serveur sans spid 50 et moins        --
-- ======================================================================= --

Declare @exec_requests table (session_id int, total_elapsed_time bigint, cpu_time bigint, start_time datetime)
insert into @exec_requests (session_id, total_elapsed_time, cpu_time, start_time)
select session_id, total_elapsed_time, cpu_time, start_time from sys.dm_exec_requests AS r with(nolock) WHERE r.session_id != @@SPID and r.group_id > 1
 
waitfor delay '00:00:01'
 
SELECT s.session_id
    ,g.name group_name
    ,r.status
    ,s.program_name
    ,s.login_name
    ,s.host_name
    ,r.blocking_session_id 'blocked by'
       ,r.cpu_time
    ,r.wait_type
    ,r.wait_resource
    ,r.wait_time / 1000. 'Wait Time (in Sec)'
    ,r.total_elapsed_time / 1000. 'Elapsed Time (in Sec)'
       ,cast(case r.total_elapsed_time when 0 then 0 else 100. * r.cpu_time / r.total_elapsed_time end as dec(5,2)) as '%Total_Run'
       ,cast(case r.total_elapsed_time when 0 then 0 else 100. * r.wait_time / r.total_elapsed_time end as dec(5,2)) as '%Total_Wait'
       ,cast(((r.cpu_time - e.cpu_time)*1. / (r.total_elapsed_time-e.total_elapsed_time) * 100 / (select cpu_count from sys.dm_os_sys_info)) as dec(5,2)) as '%CPU Now'
    ,r.scheduler_id
    ,r.logical_reads
    ,r.reads
    ,r.writes
    ,r.open_transaction_count 'tran'
    ,r.command
    ,Substring(st.TEXT, (r.statement_start_offset / 2) + 1, ((CASE r.statement_end_offset WHEN - 1 THEN Datalength(st.TEXT) ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1) AS statement_text
    ,qp.query_plan
    ,Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text
    ,s.host_process_id
    ,s.last_request_end_time
    ,s.login_time
	,CASE s.transaction_isolation_level
		WHEN 0 THEN 'Unspecified'
		WHEN 1 THEN 'ReadUncommitted'
		WHEN 2 THEN 'ReadCommitted'
		WHEN 3 THEN 'Repeatable'
		WHEN 4 THEN 'Serializable'
		WHEN 5 THEN 'Snapshot' END AS TRANSACTION_ISOLATION_LEVEL 
    --,stat.*
FROM sys.dm_exec_sessions AS s with(nolock)
INNER JOIN sys.dm_exec_requests AS r  with(nolock) ON r.session_id = s.session_id
LEFT OUTER JOIN sys.resource_governor_workload_groups as g on g.group_id=s.group_id
LEFT OUTER JOIN @exec_requests e on e.session_id = r.session_id and e.start_time = r.start_time and e.total_elapsed_time < r.total_elapsed_time
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) as qp
OUTER APPLY (select top 1 * from sys.dm_exec_query_stats qs with(nolock) where r.plan_handle = qs.plan_handle) as stat  
WHERE r.session_id != @@SPID and r.group_id > 1
ORDER BY r.cpu_time DESC, s.session_id





-- ======================================================================= --
--                                                                         --
-- Extraction des jobs actives sur le serveur incluant spid 50 et moins    --
-- ======================================================================= --

insert into @exec_requests (session_id, total_elapsed_time, cpu_time, start_time)
select session_id, total_elapsed_time, cpu_time, start_time from sys.dm_exec_requests AS r with(nolock) WHERE r.session_id != @@SPID and r.group_id > 1
 
waitfor delay '00:00:01'
 
SELECT s.session_id
    ,g.name group_name
    ,r.status
    ,s.program_name
    ,s.login_name
    ,s.host_name
    ,r.blocking_session_id 'blocked by'
     ,r.cpu_time
    ,r.wait_type
    ,r.wait_resource
    ,r.wait_time / 1000. 'Wait Time (in Sec)'
    ,r.total_elapsed_time / 1000. 'Elapsed Time (in Sec)'
       ,cast(case r.total_elapsed_time when 0 then 0 else 100. * r.cpu_time / r.total_elapsed_time end as dec(5,2)) as '%Total_Run'
       ,cast(case r.total_elapsed_time when 0 then 0 else 100. * r.wait_time / r.total_elapsed_time end as dec(5,2)) as '%Total_Wait'
       ,cast(((r.cpu_time - e.cpu_time)*1. / (r.total_elapsed_time-e.total_elapsed_time) * 100 / (select cpu_count from sys.dm_os_sys_info)) as dec(5,2)) as '%CPU Now'
    ,r.scheduler_id 
	,sch.parent_node_id
	,sch.cpu_id
    ,r.logical_reads
    ,r.reads
    ,r.writes
    ,r.open_transaction_count 'tran'
    ,r.command
    ,Substring(st.TEXT, (r.statement_start_offset / 2) + 1, ((CASE r.statement_end_offset WHEN - 1 THEN Datalength(st.TEXT) ELSE r.statement_end_offset END - r.statement_start_offset) / 2) + 1) AS statement_text
    ,qp.query_plan
    ,Coalesce(Quotename(Db_name(st.dbid)) + N'.' + Quotename(Object_schema_name(st.objectid, st.dbid)) + N'.' + Quotename(Object_name(st.objectid, st.dbid)), '') AS command_text
    ,s.host_process_id
    ,s.last_request_end_time
    ,s.login_time
    --,stat.*
FROM sys.dm_exec_sessions AS s with(nolock)
INNER JOIN sys.dm_exec_requests AS r  with(nolock) ON r.session_id = s.session_id
INNER JOIN sys.dm_os_schedulers AS sch with(nolock) ON r.scheduler_id = sch.scheduler_id
LEFT OUTER JOIN sys.resource_governor_workload_groups as g on g.group_id=s.group_id
LEFT OUTER JOIN @exec_requests e on e.session_id = r.session_id and e.start_time = r.start_time and e.total_elapsed_time < r.total_elapsed_time
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
OUTER APPLY sys.dm_exec_query_plan(r.plan_handle) as qp
OUTER APPLY (select top 1 * from sys.dm_exec_query_stats qs with(nolock) where r.plan_handle = qs.plan_handle) as stat  
WHERE r.session_id != @@SPID --and r.group_id > 1
ORDER BY [%CPU Now] desc, s.session_id

--select cpu_id, SUM(runnable_tasks_count)
--FROM sys.dm_os_schedulers
--group by cpu_id

--select * FROM sys.dm_os_schedulers
