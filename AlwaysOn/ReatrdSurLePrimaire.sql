
SELECT wait_type,
       waiting_tasks_count,
       wait_time_ms,
       wait_time_ms / waiting_tasks_count AS 'time_per_wait'
FROM sys.dm_os_wait_stats
WHERE waiting_tasks_count > 0
      AND wait_type like '%HADR_SYNC%';   