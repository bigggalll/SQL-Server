-- Query to identify query using any speicific index
-- Pinal Dave (https://blog.sqlauthority.com)
SELECT
SUBSTRING(sqltext.text, (deqs.statement_start_offset / 2) + 1,
(CASE deqs.statement_end_offset
WHEN -1 THEN DATALENGTH(sqltext.text)
ELSE deqs.statement_end_offset
END - deqs.statement_start_offset) / 2 + 1) AS sqltext,
deqs.execution_count,
deqs.total_logical_reads/execution_count AS avg_logical_reads,
deqs.total_logical_writes/execution_count AS avg_logical_writes,
deqs.total_worker_time/execution_count AS avg_cpu_time,
deqs.last_elapsed_time/execution_count AS avg_elapsed_time,
deqs.total_rows/execution_count AS avg_rows,
deqs.creation_time,
deqs.last_execution_time,
CAST(query_plan AS xml) as plan_xml
FROM sys.dm_exec_query_stats as deqs
CROSS APPLY sys.dm_exec_text_query_plan
(deqs.plan_handle, deqs.statement_start_offset, deqs.statement_end_offset)
as detqp
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS sqltext
WHERE
detqp.query_plan like '%Name of Your Index Here%'
ORDER BY deqs.last_execution_time DESC
OPTION (MAXDOP 1, RECOMPILE);
GO