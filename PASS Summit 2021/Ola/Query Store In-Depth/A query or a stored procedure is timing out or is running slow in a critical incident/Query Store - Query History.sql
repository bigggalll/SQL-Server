-- Query History

WITH QueryStore AS

(

SELECT query_store_runtime_stats_interval.start_time,
       query_store_runtime_stats_interval.end_time,
       query_store_query.query_id,
       query_store_query.query_hash,
       OBJECT_SCHEMA_NAME(object_id) AS schema_name,
       OBJECT_NAME(object_id) AS object_name,
       query_store_query_text.query_text_id,
       query_store_query_text.query_sql_text,
       query_store_plan.plan_id,
       query_store_plan.query_plan_hash,
       CAST(query_store_plan.query_plan AS xml) AS query_plan,
       query_store_plan.is_forced_plan,
       query_store_runtime_stats.execution_type_desc,
       query_store_runtime_stats.count_executions,
       query_store_runtime_stats.first_execution_time,
       query_store_runtime_stats.last_execution_time,
       query_store_runtime_stats.avg_duration,
       query_store_runtime_stats.avg_duration * count_executions AS total_duration,
       query_store_runtime_stats.avg_cpu_time,
       query_store_runtime_stats.avg_cpu_time * count_executions AS total_cpu_time,
       query_store_runtime_stats.avg_logical_io_reads,
       query_store_runtime_stats.avg_logical_io_reads * count_executions AS total_logical_io_reads,
       query_store_runtime_stats.avg_physical_io_reads,
       query_store_runtime_stats.avg_physical_io_reads * count_executions AS total_physical_io_reads,
       query_store_runtime_stats.avg_logical_io_writes,
       query_store_runtime_stats.avg_logical_io_writes * count_executions AS total_logical_io_writes,
       query_store_runtime_stats.avg_rowcount,
       query_store_runtime_stats.avg_rowcount * count_executions AS total_rowcount
FROM sys.query_store_runtime_stats
INNER JOIN sys.query_store_plan ON sys.query_store_runtime_stats.plan_id = sys.query_store_plan.plan_id
INNER JOIN sys.query_store_query ON sys.query_store_plan.query_id = sys.query_store_query.query_id
INNER JOIN sys.query_store_query_text ON sys.query_store_query.query_text_id = sys.query_store_query_text.query_text_id
INNER JOIN sys.query_store_runtime_stats_interval ON query_store_runtime_stats.runtime_stats_interval_id = query_store_runtime_stats_interval.runtime_stats_interval_id

)

SELECT start_time,
       end_time,
       query_id,
       query_hash,
       schema_name,
       object_name,
       query_text_id,
       plan_id,
       query_plan_hash,
       is_forced_plan,
       execution_type_desc,
       count_executions,
       first_execution_time,
       last_execution_time,
       avg_duration,
       avg_cpu_time,
       avg_logical_io_reads,
       avg_physical_io_reads,
       avg_logical_io_writes,
       avg_rowcount
FROM QueryStore
WHERE query_id = 9
AND start_time >= DATEADD(HOUR,-24,SYSUTCDATETIME())
ORDER BY start_time ASC