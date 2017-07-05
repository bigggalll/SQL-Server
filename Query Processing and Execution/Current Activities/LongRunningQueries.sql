SELECT st.text,
       qp.query_plan,
       qs.*
FROM
(
    SELECT TOP 50 *
    FROM sys.dm_exec_query_stats
    ORDER BY total_worker_time DESC
) AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st CROSS APPLY sys.dm_exec_query_plan(qs.plan_handle) AS qp
WHERE qs.max_worker_time > 300
      OR qs.max_elapsed_time > 300;