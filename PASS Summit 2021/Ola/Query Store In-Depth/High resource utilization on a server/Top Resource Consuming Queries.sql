-- Top Resource Consuming Queries

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

SELECT schema_name,
	     object_name,
       query_id,
       query_sql_text,
	     SUM(count_executions) AS count_executions,
	     SUM(total_duration) AS total_duration,
	     SUM(total_cpu_time) AS total_cpu_time,
	     SUM(total_logical_io_reads) AS total_logical_io_reads,
	     SUM(total_physical_io_reads) AS total_physical_io_reads,
	     SUM(total_logical_io_writes) AS total_logical_io_writes
FROM QueryStore
WHERE start_time >= DATEADD(HOUR,-2,SYSUTCDATETIME())
GROUP BY query_id, query_sql_text, schema_name, object_name
ORDER BY SUM(total_duration) DESC