--Run the following query to get the TOP 50 cached plans that consumed the most cumulative CPU
--All times are in microseconds
SELECT TOP 50 qs.creation_time,
              qs.execution_count,
              qs.total_worker_time AS total_cpu_time,
              qs.max_worker_time AS max_cpu_time,
              qs.total_elapsed_time,
              qs.max_elapsed_time,
              qs.total_logical_reads,
              qs.max_logical_reads,
              qs.total_physical_reads,
              qs.max_physical_reads,
              t.[text],
              qp.query_plan,
              t.dbid,
              t.objectid,
              t.encrypted,
              qs.plan_handle,
              qs.plan_generation_num
FROM sys.dm_exec_query_stats qs
     CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS t 
	CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS qp
ORDER BY qs.total_worker_time DESC;