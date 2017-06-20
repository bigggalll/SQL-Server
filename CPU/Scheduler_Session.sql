SELECT a.scheduler_id,
       a.status,
       b.session_id,
       pl.*,
(
    SELECT TOP 1 SUBSTRING(s2.text, statement_start_offset/2+1, ((CASE
                                                                      WHEN statement_end_offset = -1
                                                                      THEN(LEN(CONVERT( NVARCHAR(MAX), s2.text))*2)
                                                                      ELSE statement_end_offset
                                                                  END)-statement_start_offset)/2+1)
) AS sql_statement
FROM sys.dm_os_schedulers a
     INNER JOIN sys.dm_os_tasks b ON a.active_worker_address = b.worker_address
     INNER JOIN sys.dm_exec_requests c ON b.task_address = c.task_address
     CROSS APPLY sys.dm_exec_sql_text(c.sql_handle) AS s2 CROSS APPLY sys.dm_exec_query_plan(c.plan_handle) AS pl;
GO

SELECT ost.session_id,
       ost.scheduler_id,
       w.worker_address,
       ost.task_state,
       wt.wait_type,
       wt.wait_duration_ms
FROM sys.dm_os_tasks ost
     LEFT JOIN sys.dm_os_workers w ON ost.worker_address = w.worker_address
     LEFT JOIN sys.dm_os_waiting_tasks wt ON w.task_address = wt.waiting_task_address
--WHERE ost.session_id = 67
ORDER BY scheduler_id;
GO